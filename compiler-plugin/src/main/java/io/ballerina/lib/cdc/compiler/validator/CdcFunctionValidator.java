/*
 * Copyright (c) 2025, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.lib.cdc.compiler.validator;

import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.MethodSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeReferenceTypeSymbol;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.ParameterNode;
import io.ballerina.compiler.syntax.tree.RequiredParameterNode;
import io.ballerina.compiler.syntax.tree.ReturnTypeDescriptorNode;
import io.ballerina.compiler.syntax.tree.SeparatedNodeList;
import io.ballerina.compiler.syntax.tree.SyntaxKind;
import io.ballerina.lib.cdc.compiler.DiagnosticCodes;
import io.ballerina.lib.cdc.compiler.Utils;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Location;

import java.util.List;
import java.util.Optional;

import static io.ballerina.compiler.api.symbols.TypeDescKind.RECORD;
import static io.ballerina.compiler.api.symbols.TypeDescKind.STRING;
import static io.ballerina.compiler.api.symbols.TypeDescKind.TYPE_REFERENCE;
import static io.ballerina.compiler.syntax.tree.SyntaxKind.ERROR_TYPE_DESC;
import static io.ballerina.compiler.syntax.tree.SyntaxKind.OPTIONAL_TYPE_DESC;
import static io.ballerina.compiler.syntax.tree.SyntaxKind.QUALIFIED_NAME_REFERENCE;
import static io.ballerina.compiler.syntax.tree.SyntaxKind.UNION_TYPE_DESC;
import static io.ballerina.lib.cdc.compiler.Constants.ERROR_PARAM;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_CREATE;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_DELETE;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_ERROR;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_READ;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_TRUNCATE;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_UPDATE;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.FUNCTION_SHOULD_BE_REMOTE;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_PARAM_COUNT;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_PARAM_TYPE;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_RETURN_TYPE_ERROR_OR_NIL;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.MUST_BE_REQUIRED_PARAM;
import static io.ballerina.lib.cdc.compiler.Utils.getMethodSymbol;
import static io.ballerina.lib.cdc.compiler.Utils.isCdcModule;

public class CdcFunctionValidator {
    private final SyntaxNodeAnalysisContext context;
    private final SemanticModel semanticModel;
    private final FunctionDefinitionNode functionDefNode;
    private final String functionName;

    public CdcFunctionValidator(SyntaxNodeAnalysisContext context, FunctionDefinitionNode functionDefNode) {
        this.context = context;
        this.semanticModel = context.semanticModel();
        this.functionDefNode = functionDefNode;
        this.functionName = getMethodSymbol(semanticModel, functionDefNode)
                .flatMap(MethodSymbol::getName)
                .orElse("");
    }

    public void validate() {
        switch (this.functionName) {
            case ON_READ, ON_CREATE, ON_DELETE -> validateSingleRecordParamFunction();
            case ON_UPDATE -> validateTwoRecordParamFunction();
            case ON_TRUNCATE -> validateEmptyParamFunction();
            case ON_ERROR -> validateOnErrorFunction();
            default -> {
                // No validation required for other functions.
            }
        }
    }

    private void validateEmptyParamFunction() {
        if (!isRemoteFunction()) {
            return;
        }

        SeparatedNodeList<ParameterNode> parameters = functionDefNode.functionSignature().parameters();
        if (parameters.size() > 1) {
            reportErrorDiagnostics(INVALID_PARAM_COUNT, functionDefNode.functionSignature().location(),
                    "'" + functionName + "' must have no parameters or at most one optional " +
                            "parameter of type 'string'");
            return;
        }

        if (parameters.size() == 1) {
            validateParameter(parameters.get(0), STRING);
        }

        validateReturnTypeErrorOrNil();
    }

    private void validateSingleRecordParamFunction() {
        if (!isRemoteFunction()) {
            return;
        }

        SeparatedNodeList<ParameterNode> parameters = functionDefNode.functionSignature().parameters();
        if (parameters.isEmpty() || parameters.size() > 2) {
            reportErrorDiagnostics(INVALID_PARAM_COUNT, functionDefNode.functionSignature().location(),
                    "'" + functionName + "' must have exactly one parameter of type 'record' and " +
                            "may include an additional parameter of type 'string'");
            return;
        }

        validateParameter(parameters.get(0), RECORD);
        if (parameters.size() == 2) {
            validateParameter(parameters.get(1), STRING);
        }

        validateReturnTypeErrorOrNil();
    }

    private void validateTwoRecordParamFunction() {
        if (!isRemoteFunction()) {
            return;
        }

        SeparatedNodeList<ParameterNode> parameters = functionDefNode.functionSignature().parameters();
        if (parameters.size() < 2 || parameters.size() > 3) {
            reportErrorDiagnostics(INVALID_PARAM_COUNT, functionDefNode.functionSignature().location(),
                    "'" + functionName + "' must have exactly two parameters of type 'record' and " +
                            "may include an additional parameter of type 'string'");
            return;
        }

        validateParameter(parameters.get(0), RECORD);
        validateParameter(parameters.get(1), RECORD);
        if (parameters.size() == 3) {
            validateParameter(parameters.get(2), STRING);
        }

        validateReturnTypeErrorOrNil();
    }

    private void validateOnErrorFunction() {
        if (!isRemoteFunction()) {
            return;
        }

        SeparatedNodeList<ParameterNode> parameters = functionDefNode.functionSignature().parameters();
        if (parameters.size() != 1) {
            reportErrorDiagnostics(INVALID_PARAM_COUNT, functionDefNode.functionSignature().location(),
                    "'" + functionName + "' must have exactly one parameter of type 'error?' or 'cdc:Error?'");
            return;
        }

        validateErrorParameter(parameters.get(0));
        validateReturnTypeErrorOrNil();
    }

    private boolean isRemoteFunction() {
        Optional<MethodSymbol> methodSymbolOpt = getMethodSymbol(semanticModel, functionDefNode);
        if (methodSymbolOpt.isEmpty() || !Utils.isRemoteFunction(methodSymbolOpt.get())) {
            reportErrorDiagnostics(FUNCTION_SHOULD_BE_REMOTE, functionDefNode.location(), functionName);
            return false;
        }
        return true;
    }

    private void validateParameter(ParameterNode parameterNode, TypeDescKind expectedType) {
        if (!(parameterNode instanceof RequiredParameterNode requiredParam)) {
            reportDiagnosticsForNonRequiredParam(parameterNode);
            return;
        }

        Optional<Symbol> typeSymbolOpt = this.semanticModel.symbol(requiredParam.typeName());
        if (typeSymbolOpt.isEmpty()) {
            return;
        }

        TypeSymbol typeSymbol = (TypeSymbol) typeSymbolOpt.get();
        TypeDescKind actualTypeDesc = typeSymbol.typeKind();
        if (actualTypeDesc == TYPE_REFERENCE && typeSymbol instanceof TypeReferenceTypeSymbol typeRefSymbol) {
            actualTypeDesc = typeRefSymbol.typeDescriptor().typeKind();
        }
        if (actualTypeDesc != expectedType) {
            reportErrorDiagnostics(INVALID_PARAM_TYPE, requiredParam.typeName().location(),
                    requiredParam.paramName().map(Node::toString).orElse(""), expectedType.getName());
        }
    }

    private void validateErrorParameter(ParameterNode parameterNode) {
        if (!(parameterNode instanceof RequiredParameterNode requiredParam)) {
            reportDiagnosticsForNonRequiredParam(parameterNode);
            return;
        }

        SyntaxKind paramKind = requiredParam.typeName().kind();
        if (paramKind == QUALIFIED_NAME_REFERENCE) {
            Optional<Symbol> paramSymbolOpt = semanticModel.symbol(requiredParam.typeName());
            if (paramSymbolOpt.isEmpty() ||
                    !paramSymbolOpt.get().getName().orElse("").equals(ERROR_PARAM) ||
                    !isCdcModule(paramSymbolOpt.get().getModule().orElse(null))) {
                reportErrorDiagnostics(INVALID_PARAM_TYPE, parameterNode.location(),
                        requiredParam.paramName().map(Node::toString).orElse(""),
                        "error?' or 'cdc:Error?");
            }
        } else if (paramKind != ERROR_TYPE_DESC) {
            reportErrorDiagnostics(INVALID_PARAM_TYPE, parameterNode.location(),
                    requiredParam.paramName().map(Node::toString).orElse(""),
                    "error?' or 'cdc:Error?");
        }
    }

    private void reportDiagnosticsForNonRequiredParam(ParameterNode parameterNode) {
        Optional<Symbol> symbolOpt = semanticModel.symbol(parameterNode);
        symbolOpt.ifPresent(symbol -> reportErrorDiagnostics(MUST_BE_REQUIRED_PARAM, parameterNode.location(),
                symbol.getName().orElse("")));
    }

    private void reportErrorDiagnostics(DiagnosticCodes diagnosticCode, Location location, String... formattedStrings) {
        context.reportDiagnostic(Utils.createDiagnostic(diagnosticCode, location, formattedStrings));
    }

    private void validateReturnTypeErrorOrNil() {
        Optional<ReturnTypeDescriptorNode> returnTypeDescriptorNode =
                functionDefNode.functionSignature().returnTypeDesc();
        if (returnTypeDescriptorNode.isEmpty()) {
            return;
        }

        Optional<TypeSymbol> returnTypeOpt = getMethodSymbol(semanticModel, functionDefNode)
                .flatMap(methodSymbol -> methodSymbol.typeDescriptor().returnTypeDescriptor());
        if (returnTypeOpt.isEmpty()) {
            return;
        }

        if (returnTypeDescriptorNode.get().type().kind() == UNION_TYPE_DESC ||
                returnTypeDescriptorNode.get().type().kind() == OPTIONAL_TYPE_DESC) {
            List<TypeSymbol> returnTypeMembers = ((UnionTypeSymbol) returnTypeOpt.get()).memberTypeDescriptors();
            returnTypeMembers.forEach(
                    member -> validateErrorReturnSymbol(member, returnTypeDescriptorNode.get().location()));
        } else {
            validateErrorReturnSymbol(returnTypeOpt.get(), returnTypeDescriptorNode.get().location());
        }
    }

    private void validateErrorReturnSymbol(TypeSymbol returnType, Location location) {
        if (returnType.typeKind() == TYPE_REFERENCE) {
            if (!isCdcModule(returnType.getModule().orElse(null)) ||
                    !returnType.getName().orElse("").equals(ERROR_PARAM)) {
                reportErrorDiagnostics(INVALID_RETURN_TYPE_ERROR_OR_NIL, location, functionName);
            }
        } else if (returnType.typeKind() != TypeDescKind.NIL && returnType.typeKind() != TypeDescKind.ERROR) {
            reportErrorDiagnostics(INVALID_RETURN_TYPE_ERROR_OR_NIL, location, functionName);
        }
    }
}
