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
import ballerinax/postgresql;

listener postgresql:Listener postgresListener = new (database = {
    username: "root",
    password: "root",
    databaseName: "testdb"
});

service cdc:Service on postgresListener {
    remote function onTruncate() {

    }
}

service cdc:Service on postgresListener {
    remote function onTruncate(string abc) {

    }
}

service cdc:Service on postgresListener {
    remote function onTruncate(string abc, string abc1) {

    }
}

service cdc:Service on postgresListener {
    remote function onTruncate(json abc) {

    }
}


service cdc:Service on postgresListener {
    remote function onTruncate(string abc) returns cdc:Error? {

    }
}

service cdc:Service on postgresListener {
    remote function onTruncate(string abc) returns cdc:Error {
        return error cdc:Error("error");
    }
}


service cdc:Service on postgresListener {
    remote function onTruncate(string abc) returns cdc:Error|string {
        return error cdc:Error("error");
    }
}

service cdc:Service on postgresListener {
    remote function onTruncate(string abc) returns string {
        return "";
    }
}
