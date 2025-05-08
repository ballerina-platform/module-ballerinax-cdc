// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;

isolated function externDetach(MySqlListener|MsSqlListener|PostgreSqlListener|OracleListener self, Service o) returns boolean|Error = @java:Method {
    name: "detach",
    'class: "io.ballerina.lib.cdc.Listener"
} external;

isolated function externAttach(MySqlListener|MsSqlListener|PostgreSqlListener|OracleListener self, Service o) returns Error? = @java:Method {
    name: "attach",
    'class: "io.ballerina.lib.cdc.Listener"
} external;

isolated function externStart(MySqlListener|MsSqlListener|PostgreSqlListener|OracleListener self, map<string> config) returns Error? = @java:Method {
    name: "start",
    'class: "io.ballerina.lib.cdc.Listener"
} external;
