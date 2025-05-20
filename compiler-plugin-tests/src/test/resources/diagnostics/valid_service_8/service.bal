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

import ballerinax/cdc;

listener MockListener cdcListener = new (database = {
    username: "root",
    password: "root"
});

service cdc:Service on cdcListener {

    private final string var1 = "cdc Service";
    private final int var2 = 54;

    remote function onUpdate(record {|anydata...;|} after, record {|anydata...;|} before) returns cdc:Error? {
    }

    remote function onError(cdc:Error after) returns error|() {
    }
}

service cdc:Service on cdcListener {

    private final string var1 = "cdc Service";
    private final int var2 = 54;

    remote function onCreate(record {|anydata...;|} after) returns cdc:Error? {
    }

    remote function onError(cdc:Error after) returns cdc:Error|() {
    }
}

service cdc:Service on cdcListener {

    private final string var1 = "cdc Service";
    private final int var2 = 54;

    remote function onUpdate(record {||} after, record {||} before) returns cdc:Error? {
    }

    remote function onError(cdc:Error after) returns cdc:Error|error? {
    }
}

service cdc:Service on cdcListener {

    private final string var1 = "cdc Service";
    private final int var2 = 54;

    remote function onUpdate(record {||} after, record {||} before) returns cdc:Error? {
    }

    remote function onError(cdc:Error after) returns cdc:Error? {
    }
}

service cdc:Service on cdcListener {

    private final string var1 = "cdc Service";
    private final int var2 = 54;

    remote function onUpdate(record {||} after, record {||} before) returns cdc:Error? {
    }

    remote function onError(cdc:Error after) returns error|() {
    }
}
