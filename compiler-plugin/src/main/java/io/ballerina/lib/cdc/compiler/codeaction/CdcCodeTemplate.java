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

import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.tools.text.TextEdit;
import io.ballerina.tools.text.TextRange;

import java.util.ArrayList;
import java.util.List;

import static io.ballerina.lib.cdc.compiler.Constants.CODE_TEMPLATE_NAME;
import static io.ballerina.lib.cdc.compiler.Constants.LS;

/**
 * Code action template for adding CDC-related functions to a service.
 */
public class CdcCodeTemplate extends AbstractCdcCodeTemplate {

    private static final String ON_READ_FUNCTION_TEXT = LS +
            "\tremote function onRead(record {|anydata...;|} after) returns cdc:Error? {" + LS + LS + "\t}" + LS;

    private static final String ON_CREATE_FUNCTION_TEXT = LS +
            "\tremote function onCreate(record {|anydata...;|} after) returns cdc:Error? {" + LS + LS + "\t}" + LS;

    private static final String ON_UPDATE_FUNCTION_TEXT = LS +
            "\tremote function onUpdate(record {|anydata...;|} before, record {|anydata...;|} after) " +
            "returns cdc:Error? {" + LS + LS + "\t}" + LS;

    private static final String ON_DELETE_FUNCTION_TEXT = LS +
            "\tremote function onDelete(record {|anydata...;|} before) returns cdc:Error? {" + LS + LS + "\t}" + LS;

    private static final String ON_TRUNCATE_FUNCTION_TEXT = LS +
            "\tremote function onTruncate() returns cdc:Error? {" + LS + LS + "\t}" + LS;

    @Override
    protected List<TextEdit> generateTextEdits(ServiceDeclarationNode serviceDeclarationNode,
                                               boolean isPostgresListener) {
        List<TextEdit> textEdits = new ArrayList<>();
        TextRange resourceTextRange = calculateTextRange(serviceDeclarationNode);

        StringBuilder addText = new StringBuilder()
                .append(ON_READ_FUNCTION_TEXT)
                .append(ON_CREATE_FUNCTION_TEXT)
                .append(ON_UPDATE_FUNCTION_TEXT)
                .append(ON_DELETE_FUNCTION_TEXT);

        if (isPostgresListener) {
            addText.append(ON_TRUNCATE_FUNCTION_TEXT);
        }

        textEdits.add(TextEdit.from(resourceTextRange, addText.toString()));
        return textEdits;
    }

    @Override
    public String getCodeActionDescription() {
        return "Add all functions";
    }

    @Override
    public String name() {
        return CODE_TEMPLATE_NAME;
    }
}
