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

Service testService = service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
    }
};

function getDummyMySqlListener() returns MySqlListener {
    return new ({
        database: {
            username: "testUser",
            password: "testPassword"
        }
    });
}

@test:Config {}
function testStartingWithoutAService() returns error? {
    MySqlListener mysqlListener = getDummyMySqlListener();
    Error? result = mysqlListener.'start();
    test:assertEquals(result is () ? "" : result.message(), "Cannot start the listener without at least one attached service.");
}

@test:Config {}
function testStopWithoutStart() returns error? {
    MySqlListener mysqlListener = getDummyMySqlListener();
    error? result = mysqlListener.gracefulStop();
    test:assertTrue(result is ());
}

@test:Config {}
function testStartWithConflictingServices() returns error? {
    MySqlListener mysqlListener = getDummyMySqlListener();

    Service service1 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    Service service2 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    check mysqlListener.attach(service1);
    Error? result = mysqlListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "The 'cdc:ServiceConfig' annotation is mandatory when attaching multiple services to the 'cdc:Listener'.");
    check mysqlListener.detach(service1);
}

@test:Config {}
function testStartWithServicesWithSameAnnotation() returns error? {
    MySqlListener mysqlListener = getDummyMySqlListener();

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

    check mysqlListener.attach(service1);
    error? result = mysqlListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "Multiple services cannot be used to receive events from the same table 'table1'.");
    check mysqlListener.detach(service1);
}

@test:Config {
}
function testAttachAfterStart() returns error? {
    MySqlListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        snapshotMode: NO_DATA
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    error? result = mysqlListener.attach(testService);
    test:assertEquals(result is () ? "" : result.message(),
            "Cannot attach CDC service to the listener once it is running.");
    check mysqlListener.immediateStop();
}

@test:Config {
}
function testDetachAfterStart() returns error? {
    MySqlListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        snapshotMode: NO_DATA
    });

    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    error? result = mysqlListener.detach(testService);
    test:assertEquals(result is () ? "" : result.message(),
            "Cannot detach a service from the listener once it is running.");
    check mysqlListener.gracefulStop();
}
