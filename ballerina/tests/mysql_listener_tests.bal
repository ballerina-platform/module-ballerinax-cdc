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

import ballerina/lang.runtime;
import ballerina/test;
import ballerinax/mysql;

Service mysqlTestService =
@ServiceConfig {tables: "store_db.products"}
service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
        createEventCount = createEventCount + 1;
    }

    remote function onUpdate(record {} before, record {} after, string tableName = "") returns error? {
        updateEventCount = updateEventCount + 1;
    }

    remote function onDelete(record {} before, string tableName = "") returns error? {
        deleteEventCount = deleteEventCount + 1;
    }

    remote function onRead(record {} before, string tableName = "") returns error? {
        readEventCount = readEventCount + 1;
    }
};

Service mysqlDatabindingFailService =
@ServiceConfig {tables: "store_db.vendors"}
service object {

    remote function onCreate(WrongVendor after, string tableName = "") returns error? {
        createEventCount = createEventCount + 1;
    }

    remote function onError(Error e) returns error? {
        onErrorCount = onErrorCount + 1;
    }
};

type WrongVendor record {|
    int test;
|};

final mysql:Client mysqlClient = check new (host = "localhost",
    port = port,
    user = username,
    password = password,
    database = database
);

int createEventCount = 0;
int updateEventCount = 0;
int deleteEventCount = 0;
int readEventCount = 0;
int onErrorCount = 0;

@test:Config {
}
function testMySqlListenerEvents() returns error? {
    MySqlListener testListener = new ({
        database: {
            username,
            password,
            port,
            includedDatabases: database,
            includedTables: ["store_db.products", "store_db.vendors"]
        }
    });

    check testListener.attach(mysqlTestService);
    check testListener.attach(mysqlDatabindingFailService);
    check testListener.start();
    runtime:sleep(5);

    test:assertEquals(readEventCount, 2, msg = "READ event count mismatch.");

    // Test CREATE event
    _ = check mysqlClient->execute(
        `INSERT INTO products (id, name, price, description, vendor_id) 
        VALUES (1103, 'Product A', 10.0, 'testProduct', 1)`);
    runtime:sleep(3);
    test:assertEquals(createEventCount, 1, msg = "CREATE event count mismatch.");

    // Test UPDATE event
    _ = check mysqlClient->execute(
        `UPDATE products SET price = 15.0 WHERE id = 1103`);
    runtime:sleep(3);
    test:assertEquals(updateEventCount, 1, msg = "UPDATE event count mismatch.");

    // Test DELETE event
    _ = check mysqlClient->execute(
        `DELETE FROM products WHERE id = 1103`);

    runtime:sleep(3);
    test:assertEquals(deleteEventCount, 1, msg = "DELETE event count mismatch.");

    // Test CREATE event for vendors table
    _ = check mysqlClient->execute(
        `INSERT INTO vendors (id, name, contact_info) 
        VALUES (201, 'Vendor A', 'contact@vendora.com')`);
    runtime:sleep(3);
    test:assertEquals(onErrorCount, 3, msg = "Error count mismatch.");
    // 1,2 for onRead method not present, 3 for payload binding failure

    check testListener.gracefulStop();
}
