/**
 * Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
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
package io.ballerina.lib.cdc.compiler;

import io.ballerina.compiler.api.SemanticModel;
import io.ballerina.compiler.api.symbols.MethodSymbol;
import io.ballerina.compiler.api.symbols.ModuleSymbol;
import io.ballerina.compiler.api.symbols.Qualifier;
import io.ballerina.compiler.syntax.tree.FunctionDefinitionNode;
import io.ballerina.compiler.syntax.tree.ModulePartNode;
import io.ballerina.compiler.syntax.tree.NonTerminalNode;
import io.ballerina.compiler.syntax.tree.SyntaxTree;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.diagnostics.DiagnosticFactory;
import io.ballerina.tools.diagnostics.DiagnosticInfo;
import io.ballerina.tools.diagnostics.Location;
import io.ballerina.tools.text.LineRange;
import io.ballerina.tools.text.TextDocument;
import io.ballerina.tools.text.TextRange;

import java.util.Optional;

import static io.ballerina.lib.cdc.compiler.Constants.PACKAGE_ORG;
import static io.ballerina.lib.cdc.compiler.Constants.PACKAGE_PREFIX;

/**
 * Utility class for common operations used in the CDC compiler plugin.
 */
public final class Utils {

    private Utils() {
    }

    public static Diagnostic createDiagnostic(DiagnosticCodes code, Location location, String... formattedSections) {
        String message = String.format(code.getMessage(), (Object[]) formattedSections);
        DiagnosticInfo diagnosticInfo = new DiagnosticInfo(code.getCode(), message, code.getSeverity());
        return DiagnosticFactory.createDiagnostic(diagnosticInfo, location);
    }

    public static boolean isCdcModule(ModuleSymbol moduleSymbol) {
        if (moduleSymbol == null || moduleSymbol.id() == null) {
            return false;
        }
        String moduleName = moduleSymbol.id().moduleName();
        String orgName = moduleSymbol.id().orgName();
        return PACKAGE_PREFIX.equals(moduleName) && PACKAGE_ORG.equals(orgName);
    }

    public static boolean isRemoteFunction(MethodSymbol methodSymbol) {
        return methodSymbol.qualifiers().contains(Qualifier.REMOTE);
    }

    public static Optional<MethodSymbol> getMethodSymbol(SemanticModel semanticModel,
                                                         FunctionDefinitionNode functionDefinitionNode) {
        return semanticModel.symbol(functionDefinitionNode)
                .filter(MethodSymbol.class::isInstance)
                .map(MethodSymbol.class::cast);
    }

    public static NonTerminalNode findNode(SyntaxTree syntaxTree, LineRange lineRange) {
        if (syntaxTree == null || lineRange == null) {
            return null;
        }

        TextDocument textDocument = syntaxTree.textDocument();
        int start = textDocument.textPositionFrom(lineRange.startLine());
        int end = textDocument.textPositionFrom(lineRange.endLine());
        return ((ModulePartNode) syntaxTree.rootNode()).findNode(TextRange.from(start, end - start), true);
    }

}
