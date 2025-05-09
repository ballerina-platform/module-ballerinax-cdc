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

import java.util.List;

import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_CREATE;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_DELETE;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_READ;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_TRUNCATE;
import static io.ballerina.lib.cdc.compiler.Constants.ServiceMethodNames.ON_UPDATE;

public class Constants {
    public static final String PACKAGE_ORG = "ballerinax";
    public static final String PACKAGE_PREFIX = "cdc";

    // Parameters
    public static final String ERROR_PARAM = "Error";

    // Code template related constants
    public static final String NODE_LOCATION = "node.location";
    public static final String IS_POSTGRES_LISTENER = "is.postgres.listener";

    public static final String LS = System.lineSeparator();
    public static final String CODE_TEMPLATE_NAME = "ADD_FUNCTIONS_CODE_SNIPPET";
    public static final String CODE_TEMPLATE_NAME_WITH_TABLE_NAME = "ADD_FUNCTIONS_W_TABLE_NAME_CODE_SNIPPET";

    public static final String POSTGRES_LISTENER_NAME = "PostgreSqlListener";
    public static final List<String> VALID_FUNCTIONS = List.of(
            ON_READ, ON_CREATE, ON_DELETE, ON_UPDATE, ON_TRUNCATE
    );
    public static final List<String> VALID_FUNCTIONS_NON_POSTGRES = List.of(
            ON_READ, ON_CREATE, ON_DELETE, ON_UPDATE
    );

    private Constants() {
    }

    public static class ServiceMethodNames {
        public static final String ON_READ = "onRead";
        public static final String ON_CREATE = "onCreate";
        public static final String ON_UPDATE = "onUpdate";
        public static final String ON_DELETE = "onDelete";
        public static final String ON_ERROR = "onError";
        public static final String ON_TRUNCATE = "onTruncate";

        private ServiceMethodNames() {
        }
    }
}
