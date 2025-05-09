// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/cdc;

listener cdc:MySqlListener cdcListener = new (database = {
    username: "root",
    password: "root"
});

service cdc:Service on cdcListener {

    private final string var1 = "cdc Service";
    private final int var2 = 54;

    remote function onRead(record {|anydata...;|} after) returns cdc:Error? {
    }

    remote function onCreate(Table1|Table2 after) returns cdc:Error? {
    }
}

type Table1 record {
 string id;
};

type Table2 record {
 string id2;
};
