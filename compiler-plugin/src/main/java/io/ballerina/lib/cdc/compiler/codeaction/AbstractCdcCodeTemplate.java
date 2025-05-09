/**
 * Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.lib.cdc.compiler.codeaction;

import io.ballerina.compiler.syntax.tree.Node;
import io.ballerina.compiler.syntax.tree.NonTerminalNode;
import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.compiler.syntax.tree.SyntaxTree;
import io.ballerina.lib.cdc.compiler.DiagnosticCodes;
import io.ballerina.projects.plugins.codeaction.CodeAction;
import io.ballerina.projects.plugins.codeaction.CodeActionArgument;
import io.ballerina.projects.plugins.codeaction.CodeActionContext;
import io.ballerina.projects.plugins.codeaction.CodeActionExecutionContext;
import io.ballerina.projects.plugins.codeaction.CodeActionInfo;
import io.ballerina.projects.plugins.codeaction.DocumentEdit;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.text.LineRange;
import io.ballerina.tools.text.TextDocumentChange;
import io.ballerina.tools.text.TextEdit;
import io.ballerina.tools.text.TextRange;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static io.ballerina.lib.cdc.compiler.Constants.IS_POSTGRES_LISTENER;
import static io.ballerina.lib.cdc.compiler.Constants.NODE_LOCATION;
import static io.ballerina.lib.cdc.compiler.Utils.findNode;

/**
 * Abstract class for CDC code templates to share common functionality.
 */
public abstract class AbstractCdcCodeTemplate implements CodeAction {

    @Override
    public List<String> supportedDiagnosticCodes() {
        return List.of(
                DiagnosticCodes.EMPTY_SERVICE.getCode(),
                DiagnosticCodes.EMPTY_SERVICE_POSTGRESQL.getCode()
        );
    }

    @Override
    public Optional<CodeActionInfo> codeActionInfo(CodeActionContext codeActionContext) {
        Diagnostic diagnostic = codeActionContext.diagnostic();
        if (diagnostic.location() == null) {
            return Optional.empty();
        }
        CodeActionArgument locationArg = CodeActionArgument.from(NODE_LOCATION, diagnostic.location().lineRange());
        CodeActionArgument isPostgres = CodeActionArgument.from(IS_POSTGRES_LISTENER,
                diagnostic.diagnosticInfo().code().equals(DiagnosticCodes.EMPTY_SERVICE_POSTGRESQL.getCode()));
        return Optional.of(CodeActionInfo.from(getCodeActionDescription(), List.of(locationArg, isPostgres)));
    }

    protected abstract String getCodeActionDescription();

    @Override
    public List<DocumentEdit> execute(CodeActionExecutionContext context) {
        LineRange lineRange = extractArgument(context, NODE_LOCATION, LineRange.class, null);
        boolean isPostgresListener = extractArgument(context, IS_POSTGRES_LISTENER, Boolean.class, false);

        if (lineRange == null) {
            return Collections.emptyList();
        }

        SyntaxTree syntaxTree = context.currentDocument().syntaxTree();
        NonTerminalNode node = findNode(syntaxTree, lineRange);
        if (!(node instanceof ServiceDeclarationNode serviceDeclarationNode)) {
            return Collections.emptyList();
        }

        List<TextEdit> textEdits = generateTextEdits(serviceDeclarationNode, isPostgresListener);
        TextDocumentChange change = TextDocumentChange.from(textEdits.toArray(new TextEdit[0]));
        return List.of(new DocumentEdit(context.fileUri(),
                SyntaxTree.from(syntaxTree, change)));
    }

    protected <T> T extractArgument(CodeActionExecutionContext context, String key, Class<T> type, T defaultValue) {
        return context.arguments().stream()
                .filter(arg -> key.equals(arg.key()))
                .map(arg -> arg.valueAs(type))
                .findFirst()
                .orElse(defaultValue);
    }

    protected TextRange calculateTextRange(ServiceDeclarationNode serviceDeclarationNode) {
        if (serviceDeclarationNode.members().isEmpty()) {
            return TextRange.from(serviceDeclarationNode.openBraceToken().textRange().endOffset(), 1);
        } else {
            Node lastMember = serviceDeclarationNode.members().get(serviceDeclarationNode.members().size() - 1);
            return TextRange.from(lastMember.textRange().endOffset(),
                    serviceDeclarationNode.closeBraceToken().textRange().startOffset() -
                            lastMember.textRange().endOffset());
        }
    }

    protected abstract List<TextEdit> generateTextEdits(ServiceDeclarationNode serviceDeclarationNode,
                                                        boolean isPostgresListener);
}
