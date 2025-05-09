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

public isolated class MySqlListener {

    public isolated function init() {
    }

    public isolated function attach(cdc:Service s, string[]|string? name = ()) returns cdc:Error? {
    }

    public isolated function 'start() returns cdc:Error? {
    }

    public isolated function detach(cdc:Service s) returns cdc:Error? {
    }

    public isolated function gracefulStop() returns cdc:Error? {
    }

    public isolated function immediateStop() returns cdc:Error? {
    }
}

listener MySqlListener cdcListener = new ();

service cdc:Service on cdcListener {

}
