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

Service testServicePostgreSql = service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
    }
};

function getDummyPostgreSqlListener() returns PostgreSqlListener {
    return new ({
        database: {
            username: "testUser",
            password: "testPassword",
            databaseName: ""
        }
    });
}

@test:Config {}
function testPostgreSQLStartingWithoutAService() returns error? {
    PostgreSqlListener postgreSqlListener = getDummyPostgreSqlListener();
    Error? result = postgreSqlListener.'start();
    test:assertEquals(result is () ? "" : result.message(), "Cannot start the listener without at least one attached service.");
}

@test:Config {}
function testPostgreSQLStopWithoutStart() returns error? {
    PostgreSqlListener postgreSqlListener = getDummyPostgreSqlListener();
    error? result = postgreSqlListener.gracefulStop();
    test:assertTrue(result is ());
}

@test:Config {}
function testPostgreSQLStartWithConflictingServices() returns error? {
    PostgreSqlListener postgreSqlListener = getDummyPostgreSqlListener();

    Service service1 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    Service service2 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    check postgreSqlListener.attach(service1);
    Error? result = postgreSqlListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "The 'cdc:ServiceConfig' annotation is mandatory when attaching multiple services to the 'cdc:Listener'.");
    check postgreSqlListener.detach(service1);
}

@test:Config {}
function testPostgreSQLStartWithServicesWithSameAnnotation() returns error? {
    PostgreSqlListener postgreSqlListener = getDummyPostgreSqlListener();

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

    check postgreSqlListener.attach(service1);
    error? result = postgreSqlListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "Multiple services cannot be used to receive events from the same table 'table1'.");
    check postgreSqlListener.detach(service1);
}
