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
package io.ballerina.lib.cdc.compiler;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import io.ballerina.projects.CodeActionManager;
import io.ballerina.projects.Document;
import io.ballerina.projects.DocumentId;
import io.ballerina.projects.Package;
import io.ballerina.projects.PackageCompilation;
import io.ballerina.projects.Project;
import io.ballerina.projects.directory.ProjectLoader;
import io.ballerina.projects.plugins.codeaction.CodeActionArgument;
import io.ballerina.projects.plugins.codeaction.CodeActionContextImpl;
import io.ballerina.projects.plugins.codeaction.CodeActionExecutionContext;
import io.ballerina.projects.plugins.codeaction.CodeActionExecutionContextImpl;
import io.ballerina.projects.plugins.codeaction.CodeActionInfo;
import io.ballerina.projects.plugins.codeaction.DocumentEdit;
import io.ballerina.tools.text.LinePosition;
import org.testng.Assert;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static io.ballerina.lib.cdc.compiler.TestUtils.getEnvironmentBuilder;

/**
 * Abstract implementation of code action tests.
 */
public abstract class AbstractCodeActionTest {

    private static final Gson GSON = new Gson();

    protected void performTest(Path filePath, LinePosition cursorPos, int expectedCodeAction,
                               CodeActionInfo expected, Path expectedSrc)
            throws IOException {
        Project project = ProjectLoader.loadProject(filePath, getEnvironmentBuilder());
        List<CodeActionInfo> codeActions = getCodeActions(filePath, cursorPos, project);

        Assert.assertTrue(codeActions.size() >= expectedCodeAction, "Expect at least 2 code actions");

        Optional<CodeActionInfo> found = findCodeAction(codeActions, expected);
        Assert.assertTrue(found.isPresent(), "Code action not found: " + GSON.toJson(expected));

        List<DocumentEdit> actualEdits = executeCodeAction(project, filePath, found.get());
        Assert.assertEquals(actualEdits.size(), 1, "Expected changes to 1 file");

        String expectedFileUri = filePath.toUri().toString();
        Optional<DocumentEdit> actualEdit = actualEdits.stream()
                .filter(docEdit -> docEdit.getFileUri().equals(expectedFileUri))
                .findFirst();

        Assert.assertTrue(actualEdit.isPresent(), "Edits not found for fileUri: " + expectedFileUri);

        String modifiedSourceCode = actualEdit.get().getModifiedSyntaxTree().toSourceCode();
        // Normalized actual to match Linux based expected source codes
        String normalizedModifiedSourceCode = modifiedSourceCode.replace(System.lineSeparator(), "\n");

        String expectedSourceCode = readExpectedSourceCode(expectedSrc);
        Assert.assertEquals(normalizedModifiedSourceCode, expectedSourceCode,
                "Actual source code didn't match expected source code");
    }

    private List<CodeActionInfo> getCodeActions(Path filePath, LinePosition cursorPos, Project project) {
        Package currentPackage = project.currentPackage();
        PackageCompilation compilation = currentPackage.getCompilation();
        CodeActionManager codeActionManager = compilation.getCodeActionManager();

        DocumentId documentId = project.documentId(filePath);
        Document document = currentPackage.getDefaultModule().document(documentId);

        return compilation.diagnosticResult().diagnostics().stream()
                .filter(diagnostic -> TestUtils.isWithinRange(diagnostic.location().lineRange(), cursorPos))
                .flatMap(diagnostic -> {
                    CodeActionContextImpl context = CodeActionContextImpl.from(
                            filePath.toUri().toString(),
                            filePath,
                            cursorPos,
                            document,
                            compilation.getSemanticModel(documentId.moduleId()),
                            diagnostic);
                    return codeActionManager.codeActions(context).getCodeActions().stream();
                })
                .collect(Collectors.toList());
    }

    private List<DocumentEdit> executeCodeAction(Project project, Path filePath, CodeActionInfo codeAction) {
        Package currentPackage = project.currentPackage();
        PackageCompilation compilation = currentPackage.getCompilation();

        DocumentId documentId = project.documentId(filePath);
        Document document = currentPackage.getDefaultModule().document(documentId);

        List<CodeActionArgument> codeActionArguments = codeAction.getArguments().stream()
                .map(arg -> CodeActionArgument.from(GSON.toJsonTree(arg)))
                .collect(Collectors.toList());

        CodeActionExecutionContext executionContext = CodeActionExecutionContextImpl.from(
                filePath.toUri().toString(),
                filePath,
                null,
                document,
                compilation.getSemanticModel(document.documentId().moduleId()),
                codeActionArguments);

        return compilation.getCodeActionManager()
                .executeCodeAction(codeAction.getProviderName(), executionContext);
    }

    private Optional<CodeActionInfo> findCodeAction(List<CodeActionInfo> codeActions, CodeActionInfo expected) {
        JsonObject expectedCodeAction = GSON.toJsonTree(expected).getAsJsonObject();
        return codeActions.stream()
                .filter(codeActionInfo -> {
                    JsonObject actualCodeAction = GSON.toJsonTree(codeActionInfo).getAsJsonObject();
                    return actualCodeAction.equals(expectedCodeAction);
                })
                .findFirst();
    }

    private String readExpectedSourceCode(Path expectedSrc) throws IOException {
        return Files.readString(expectedSrc).replace(System.lineSeparator(), "\n");
    }
}
