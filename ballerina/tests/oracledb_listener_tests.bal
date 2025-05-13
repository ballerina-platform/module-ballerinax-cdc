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

import ballerina/test;

Service testServiceOracleDb = service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
    }
};

function getDummyOracleListener() returns OracleListener {
    return new ({
        database: {
            username: "testUser",
            password: "testPassword",
            databaseName: ""
        }
    });
}

@test:Config {}
function testOracleDbStartingWithoutAService() returns error? {
    OracleListener oracleDbListener = getDummyOracleListener();
    Error? result = oracleDbListener.'start();
    test:assertEquals(result is () ? "" : result.message(), "Cannot start the listener without at least one attached service.");
}

@test:Config {}
function testOracleDbStopWithoutStart() returns error? {
    OracleListener oracleDbListener = getDummyOracleListener();
    error? result = oracleDbListener.gracefulStop();
    test:assertTrue(result is ());
}

@test:Config {}
function testOracleDbStartWithConflictingServices() returns error? {
    OracleListener oracleDbListener = getDummyOracleListener();

    Service service1 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    Service service2 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    check oracleDbListener.attach(service1);
    Error? result = oracleDbListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "The 'cdc:ServiceConfig' annotation is mandatory when attaching multiple services to the 'cdc:Listener'.");
    check oracleDbListener.detach(service1);
}

@test:Config {}
function testOracleDbStartWithServicesWithSameAnnotation() returns error? {
    OracleListener oracleDbListener = getDummyOracleListener();

    Service service1 = @ServiceConfig {
        tables: "table1"
    } service object {
        remote function onCreate(record {} after, string tableName = "table1") returns error? {
        }
    };

    Service service2 = @ServiceConfig {
        tables: "table1"
    } service object {
        remote function onCreate(record {} after, string tableName = "table1") returns error? {
        }
    };

    check oracleDbListener.attach(service1);
    error? result = oracleDbListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "Multiple services cannot be used to receive events from the same table 'table1'.");
    check oracleDbListener.detach(service1);
}
