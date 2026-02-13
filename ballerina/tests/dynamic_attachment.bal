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
import ballerina/lang.runtime;

Service testService = service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
    }
};

function getDummyMySqlListener() returns MockListener {
    return new ({
        database: {
            username: "testUser",
            password: "testPassword"
        }
    });
}

@test:Config {}
function testStartingWithoutAService() returns error? {
    MockListener mysqlListener = getDummyMySqlListener();
    Error? result = mysqlListener.'start();
    test:assertEquals(result is () ? "" : result.message(), "Cannot start the listener without at least one attached service.");
}

@test:Config {}
function testStopWithoutStart() returns error? {
    MockListener mysqlListener = getDummyMySqlListener();
    error? result = mysqlListener.gracefulStop();
    test:assertTrue(result is ());
}

@test:Config {}
function testStartWithConflictingServices() returns error? {
    MockListener mysqlListener = getDummyMySqlListener();

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
    MockListener mysqlListener = getDummyMySqlListener();

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

@test:Config {}
function testAttachAfterStart() returns error? {
    MockListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        options: {
            snapshotMode: NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    error? result = mysqlListener.attach(testService);
    test:assertEquals(result is () ? "" : result.message(),
            "Cannot attach a CDC service to the listener once it is running.");
    check mysqlListener.immediateStop();
}

@test:Config {
}
function testDetachAfterStart() returns error? {
    MockListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        options: {
            snapshotMode: NO_DATA
        }
    });

    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    error? result = mysqlListener.detach(testService);
    test:assertEquals(result is () ? "" : result.message(),
            "Cannot detach a CDC service from the listener once it is running.");
    check mysqlListener.gracefulStop();
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessBeforeListenerStart() returns error? {
    MockListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        options: {
            snapshotMode: NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    boolean liveness = check isLive(mysqlListener);
    test:assertFalse(liveness, "Liveness check passes even before listener starts");
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessWithStartedListener() returns error? {
    MockListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        options: {
            snapshotMode: NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    boolean liveness = check isLive(mysqlListener);
    test:assertTrue(liveness, "Liveness fails for a started listener");
    check mysqlListener.gracefulStop();
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessAfterListenerStop() returns error? {
    MockListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        options: {
            snapshotMode: NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    check mysqlListener.gracefulStop();
    boolean liveness = check isLive(mysqlListener);
    test:assertFalse(liveness, "Liveness check passes after the listener has stopped");
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessWithoutReceivingEvents() returns error? {
    MockListener mysqlListener = new ({
        database: {
            username,
            password,
            port
        },
        options: {
            snapshotMode: NO_DATA
        },
        livenessInterval: 5.0
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    runtime:sleep(10);
    boolean liveness = check isLive(mysqlListener);
    test:assertFalse(liveness, "Liveness check passes even after not receiving events within the liveness interval");
    check mysqlListener.gracefulStop();
}
