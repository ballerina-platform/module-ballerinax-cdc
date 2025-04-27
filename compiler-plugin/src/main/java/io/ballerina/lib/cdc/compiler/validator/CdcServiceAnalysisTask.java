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
import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.ServiceDeclarationSymbol;
import io.ballerina.compiler.api.symbols.Symbol;
import io.ballerina.compiler.api.symbols.TypeDescKind;
import io.ballerina.compiler.api.symbols.TypeSymbol;
import io.ballerina.compiler.api.symbols.UnionTypeSymbol;
import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.lib.cdc.compiler.Utils;
import io.ballerina.projects.plugins.AnalysisTask;
import io.ballerina.projects.plugins.SyntaxNodeAnalysisContext;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import java.util.List;
import java.util.Optional;

import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_MULTIPLE_LISTENERS;

public class CdcServiceAnalysisTask implements AnalysisTask<SyntaxNodeAnalysisContext> {

    private static boolean hasCdcListener(List<TypeSymbol> listeners) {
        return listeners.stream()
                .map(TypeSymbol::getModule)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .anyMatch(Utils::isCdcModule);
    }

    @Override
    public void perform(SyntaxNodeAnalysisContext context) {
        List<Diagnostic> diagnostics = context.semanticModel().diagnostics();
        for (Diagnostic diagnostic : diagnostics) {
            if (diagnostic.diagnosticInfo().severity() == DiagnosticSeverity.ERROR) {
                return;
            }
        }
        if (!isCdcService(context)) {
            return;
        }
        // Created inner class to keep context as class param
        new CdcServiceValidator(context).validate();
    }

    private boolean isCdcService(SyntaxNodeAnalysisContext context) {
        SemanticModel semanticModel = context.semanticModel();
        ServiceDeclarationNode serviceDeclarationNode = (ServiceDeclarationNode) context.node();
        Optional<Symbol> symbol = semanticModel.symbol(serviceDeclarationNode);
        if (symbol.isEmpty()) {
            return false;
        }

        ServiceDeclarationSymbol serviceDeclarationSymbol = (ServiceDeclarationSymbol) symbol.get();
        List<TypeSymbol> listeners = serviceDeclarationSymbol.listenerTypes();

        if (listeners.size() > 1 && hasCdcListener(listeners)) {
            context.reportDiagnostic(Utils.createDiagnostic(INVALID_MULTIPLE_LISTENERS,
                    serviceDeclarationNode.location()));
            return false;
        }

        return listeners.stream()
                .map(this::getModuleFromListener)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .anyMatch(Utils::isCdcModule);
    }

    private Optional<ModuleSymbol> getModuleFromListener(TypeSymbol listener) {
        if (listener.typeKind() == TypeDescKind.UNION) {
            UnionTypeSymbol unionTypeSymbol = (UnionTypeSymbol) listener;
            return unionTypeSymbol.memberTypeDescriptors().stream()
                    .map(TypeSymbol::getModule)
                    .filter(Optional::isPresent)
                    .map(Optional::get)
                    .findFirst();
        }
        return listener.getModule();
    }
}
