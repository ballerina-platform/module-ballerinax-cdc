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

import io.ballerina.projects.DiagnosticResult;
import io.ballerina.projects.PackageCompilation;
import io.ballerina.projects.directory.BuildProject;
import io.ballerina.tools.diagnostics.Diagnostic;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.nio.file.Path;
import java.nio.file.Paths;

import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.FUNCTION_SHOULD_BE_REMOTE;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_MULTIPLE_LISTENERS;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_PARAM_COUNT;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_PARAM_TYPE;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_RESOURCE_FUNCTION;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.INVALID_RETURN_TYPE_ERROR_OR_NIL;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.MUST_BE_REQUIRED_PARAM;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.NOT_OF_SAME_TYPE;
import static io.ballerina.lib.cdc.compiler.DiagnosticCodes.NO_VALID_FUNCTION;
import static io.ballerina.lib.cdc.compiler.TestUtils.getEnvironmentBuilder;

/**
 * Tests the custom CDC compiler plugin.
 */
public class CompilerPluginTest {

    private static final Path RESOURCE_DIRECTORY = Paths.get("src", "test", "resources", "diagnostics")
            .toAbsolutePath();

    private PackageCompilation loadAndCompilePackage(String path) {
        Path projectDirPath = RESOURCE_DIRECTORY.resolve(path);
        BuildProject project = BuildProject.load(getEnvironmentBuilder(), projectDirPath);
        return project.currentPackage().getCompilation();
    }

    private void assertDiagnostics(DiagnosticResult diagnosticResult, Object[][] expectedErrors) {
        Assert.assertEquals(diagnosticResult.errors().size(), expectedErrors.length);
        Diagnostic[] diagnostics = diagnosticResult.errors().toArray(new Diagnostic[0]);
        for (int i = 0; i < expectedErrors.length; i++) {
            if (expectedErrors[i].length != 2) {
                continue;
            }
            String expectedCode = ((DiagnosticCodes) expectedErrors[i][0]).getCode();
            String expectedMessage = (String) expectedErrors[i][1];
            Assert.assertEquals(diagnostics[i].diagnosticInfo().code(), expectedCode);
            Assert.assertEquals(diagnostics[i].diagnosticInfo().messageFormat(), expectedMessage);
        }
    }

    @Test(description = "Service validating return types")
    public void testValidService1() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_1");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validating import as")
    public void testValidService2() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_2");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate basic service")
    public void testValidService3() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_3");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validating using only record type")
    public void testValidService4() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_4");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate onUpdate method")
    public void testValidService5() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_5");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validating readonly record param type")
    public void testValidService6() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_6");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate onError function")
    public void testValidService7() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_7");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate onError function return types")
    public void testValidService8() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_8");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate data binding parameter")
    public void testValidService9() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_9");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate readonly data binding parameter")
    public void testValidService10() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_10");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate applying to only cdc listenerr")
    public void testValidService11() {
        PackageCompilation currentPackage = loadAndCompilePackage("valid_service_11");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        Assert.assertEquals(diagnosticResult.errors().size(), 0);
    }

    @Test(description = "Validate no remote method")
    public void testInvalidService1() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_1");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {NO_VALID_FUNCTION,
                        "Service must have at least one remote 'onRead', " +
                                "'onCreate', 'onUpdate' or 'onDelete' functions."},
                {NO_VALID_FUNCTION,
                        "Service must have at least one remote 'onRead', " +
                                "'onCreate', 'onUpdate', 'onDelete' or 'onTruncate' functions."}
        });
    }

    @Test(description = "No validation if base compilation unsuccessful")
    public void testInvalidService2() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_2");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {},
                {}
        });
    }

    @Test(description = "Validate onRead without remote keyword")
    public void testInvalidService3() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_3");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {FUNCTION_SHOULD_BE_REMOTE,
                        "Invalid function: The function 'onRead' must be declared as a remote function."}
        });
    }

    @Test(description = "Validate invalid parameter as the data binding param")
    public void testInvalidService4() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_4");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'before' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'before' must be of type 'record'."}
        });
    }

    @Test(description = "Validate invalid parameter in 2 parameter scenario")
    public void testInvalidService5() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_5");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'before' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'after' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'before' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'after' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'before' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'after' must be of type 'record'."},
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'after' must be of type 'record'."},
                {NOT_OF_SAME_TYPE,
                        "Invalid parameter type: The function 'onUpdate' must have parameters of the same type."}
        });
    }

    @Test(description = "Validate invalid return type")
    public void testInvalidService6() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_6");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_RETURN_TYPE_ERROR_OR_NIL,
                        "Invalid return type: The function 'onUpdate' must return either 'error?' or 'cdc:Error?'."}
        });
    }

    @Test(description = "Validate tableName param in 1 parameter scenario")
    public void testInvalidService7() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_7");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_TYPE, "Invalid parameter type: The parameter 'tableName' must be of type 'string'."}
        });
    }

    @Test(description = "Validate multiple listeners")
    public void testInvalidService9() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_9");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_MULTIPLE_LISTENERS,
                        "Invalid service attachment: The service can only be attached to one 'cdc:Listener'."}
        });
    }

    @Test(description = "Validate resource function")
    public void testInvalidService10() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_10");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_RESOURCE_FUNCTION, "Invalid resource function: Resource functions are not allowed."}
        });
    }

    @Test(description = "Validate 0 parameter scenario")
    public void testInvalidService11() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_11");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onCreate' must have exactly one parameter of type " +
                                "'record' and may include an additional parameter of type 'string'."},
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onUpdate' must have exactly two parameters of type " +
                                "'record' and may include an additional parameter of type 'string'."},
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onUpdate' must have exactly two parameters of type " +
                                "'record' and may include an additional parameter of type 'string'."}
        });
    }

    @Test(description = "Validate non-required parameter")
    public void testInvalidService12() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_12");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {MUST_BE_REQUIRED_PARAM, "Invalid parameter: The parameter 'tableName' must be a required parameter."}
        });
    }

    @Test(description = "Validate invalid parameter for onError")
    public void testInvalidService14() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_14");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_TYPE,
                        "Invalid parameter type: The parameter 'before' must be of type 'error?' or 'cdc:Error?'."}
        });
    }

    @Test(description = "Validate 0 parameter for onError")
    public void testInvalidService15() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_15");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onError' must have exactly one parameter of " +
                                "type 'error?' or 'cdc:Error?'."}
        });
    }

    @Test(description = "Validate no remote keyword for onError")
    public void testInvalidService17() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_17");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {FUNCTION_SHOULD_BE_REMOTE,
                        "Invalid function: The function 'onError' must be declared as a remote function."}
        });
    }

    @Test(description = "Validate resource functions with onError")
    public void testInvalidService18() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_18");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_RESOURCE_FUNCTION, "Invalid resource function: Resource functions are not allowed."}
        });
    }

    @Test(description = "Validate parameters more than 3 for onConsumerRecord")
    public void testInvalidService19() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_19");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onCreate' must have exactly one parameter of type " +
                                "'record' and may include an additional parameter of type 'string'."},
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onUpdate' must have exactly two parameters of type " +
                                "'record' and may include an additional parameter of type 'string'."},
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onError' must have exactly one parameter of type " +
                                "'error?' or 'cdc:Error?'."}
        });
    }

    @Test(description = "Validate parameters for onTruncate")
    public void testInvalidService20() {
        PackageCompilation currentPackage = loadAndCompilePackage("invalid_service_20");
        DiagnosticResult diagnosticResult = currentPackage.diagnosticResult();
        assertDiagnostics(diagnosticResult, new Object[][]{
                {INVALID_PARAM_COUNT,
                        "Invalid parameter count: The function 'onTruncate' must have no parameters or " +
                                "at most one optional parameter of type 'string'."},
                {INVALID_PARAM_TYPE,
                        "Invalid parameter type: The parameter 'abc' must be of type 'string'."},
                {INVALID_RETURN_TYPE_ERROR_OR_NIL,
                        "Invalid return type: The function 'onTruncate' must return either 'error?' or 'cdc:Error?'."},
                {INVALID_RETURN_TYPE_ERROR_OR_NIL,
                        "Invalid return type: The function 'onTruncate' must return either 'error?' or 'cdc:Error?'."}
        });
    }

}
