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

import io.ballerina.tools.diagnostics.DiagnosticSeverity;

import static io.ballerina.tools.diagnostics.DiagnosticSeverity.ERROR;
import static io.ballerina.tools.diagnostics.DiagnosticSeverity.INTERNAL;

public enum DiagnosticCodes {
    NO_VALID_FUNCTION("CDC_101", ERROR, "Service must have at least one remote %s functions."),
    INVALID_RESOURCE_FUNCTION("CDC_102", ERROR, "Invalid resource function: Resource functions are not allowed."),
    FUNCTION_SHOULD_BE_REMOTE("CDC_103", ERROR,
            "Invalid function: The function '%s' must be declared as a remote function."),
    INVALID_PARAM_COUNT("CDC_104", ERROR, "Invalid parameter count: The function %s."),
    MUST_BE_REQUIRED_PARAM("CDC_105", ERROR, "Invalid parameter: The parameter '%s' must be a required parameter."),
    INVALID_PARAM_TYPE("CDC_106", ERROR, "Invalid parameter type: The parameter '%s' must be of type '%s'."),
    NOT_OF_SAME_TYPE("CDC_107", ERROR,
            "Invalid parameter type: The function '%s' must have parameters of the same type."),
    INVALID_RETURN_TYPE_ERROR_OR_NIL("CDC_108", ERROR,
            "Invalid return type: The function '%s' must return either 'error?' or 'cdc:Error?'."),
    INVALID_MULTIPLE_LISTENERS("CDC_109", ERROR,
            "Invalid service attachment: The service can only be attached to one 'cdc:Listener'."),
    // Internal diagnostics used to indicate empty service
    EMPTY_SERVICE("CDC_601", INTERNAL, ""),
    EMPTY_SERVICE_POSTGRESQL("CDC_602", INTERNAL, "");

    private final String message;
    private final DiagnosticSeverity severity;
    private final String code;

    DiagnosticCodes(String code, DiagnosticSeverity severity, String message) {
        this.code = code;
        this.message = message;
        this.severity = severity;
    }

    public String getCode() {
        return code;
    }

    public DiagnosticSeverity getSeverity() {
        return severity;
    }

    public String getMessage() {
        return message;
    }

}
