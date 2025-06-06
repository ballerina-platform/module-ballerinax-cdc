/**
 * Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.lib.cdc.compiler.codeaction;

import io.ballerina.compiler.syntax.tree.SyntaxTree;
import io.ballerina.lib.cdc.compiler.DiagnosticCodes;
import io.ballerina.projects.plugins.codeaction.CodeAction;
import io.ballerina.projects.plugins.codeaction.CodeActionArgument;
import io.ballerina.projects.plugins.codeaction.CodeActionContext;
import io.ballerina.projects.plugins.codeaction.CodeActionExecutionContext;
import io.ballerina.projects.plugins.codeaction.CodeActionInfo;
import io.ballerina.projects.plugins.codeaction.DocumentEdit;
import io.ballerina.tools.diagnostics.Diagnostic;
import io.ballerina.tools.text.TextDocumentChange;
import io.ballerina.tools.text.TextEdit;
import io.ballerina.tools.text.TextRange;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static io.ballerina.lib.cdc.compiler.Utils.extractArgument;
import static io.ballerina.lib.cdc.compiler.codeaction.Constants.NODE_LOCATION;

public abstract class AbstractChangeReturnType implements CodeAction {
    @Override
    public List<String> supportedDiagnosticCodes() {
        return List.of(DiagnosticCodes.INVALID_RETURN_TYPE_ERROR_OR_NIL.getCode());
    }

    @Override
    public Optional<CodeActionInfo> codeActionInfo(CodeActionContext codeActionContext) {
        Diagnostic diagnostic = codeActionContext.diagnostic();
        if (diagnostic.location() == null) {
            return Optional.empty();
        }
        CodeActionArgument locationArg = CodeActionArgument.from(NODE_LOCATION,
                diagnostic.location().textRange());
        return Optional.of(CodeActionInfo.from(getCodeActionDescription(), List.of(locationArg)));
    }

    protected abstract String getCodeActionDescription();

    @Override
    public List<DocumentEdit> execute(CodeActionExecutionContext context) {
        TextRange textRange = extractArgument(context, NODE_LOCATION, TextRange.class, null);

        if (textRange == null) {
            return Collections.emptyList();
        }

        List<TextEdit> textEdits = new ArrayList<>();
        textEdits.add(TextEdit.from(textRange, getChangedReturnSignature()));

        TextDocumentChange change = TextDocumentChange.from(textEdits.toArray(new TextEdit[0]));
        return List.of(new DocumentEdit(context.fileUri(),
                SyntaxTree.from(context.currentDocument().syntaxTree(), change)));
    }

    protected abstract String getChangedReturnSignature();
}
