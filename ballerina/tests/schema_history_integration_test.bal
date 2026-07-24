// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/file;
import ballerina/lang.runtime;
import ballerina/test;
import ballerinax/cdc.schema.azure.blob.driver as _;
import ballerinax/cdc.schema.aws.s3.driver as _;
import ballerinax/cdc.schema.rocketmq.driver as _;

Service schemaHistoryTestService =
@ServiceConfig {tables: "store_db.products"}
service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
        schemaHistoryCreateEventCount += 1;
    }

    remote function onRead(record {} before, string tableName = "") returns error? {
        schemaHistoryReadEventCount += 1;
    }
};

int schemaHistoryCreateEventCount = 0;
int schemaHistoryReadEventCount = 0;
string? activeSchemaHistoryStorageName = ();
int? activeSchemaHistoryProductId = ();

const int SCHEMA_HISTORY_EVENT_WAIT_ATTEMPTS = 120;
const decimal SCHEMA_HISTORY_EVENT_POLL_INTERVAL_SECONDS = 0.25;

@test:Config {groups: ["schema-history-integration"], after: cleanupSchemaHistoryTest}
function testAzureBlobSchemaHistoryRestart() returns error? {
    check runSchemaHistoryRestartTest({
        connectionString: "UseDevelopmentStorage=true",
        containerName: "schema-history",
        blobName: "azure-schema-history.dat"
    }, "azure", 3101);
}

@test:Config {groups: ["schema-history-integration"], after: cleanupSchemaHistoryTest}
function testS3SchemaHistoryRestart() returns error? {
    check runSchemaHistoryRestartTest({
        accessKeyId: "minioadmin",
        secretAccessKey: "minioadmin",
        region: "us-east-1",
        bucketName: "cdc-schema-history",
        objectName: "s3-schema-history.dat",
        endpoint: "http://localhost:9000",
        forcePathStyle: true
    }, "s3", 3201);
}

@test:Config {groups: ["schema-history-integration"], after: cleanupSchemaHistoryTest}
function testRocketMqSchemaHistoryRestart() returns error? {
    check runSchemaHistoryRestartTest({
        topicName: "cdc-schema-history",
        nameServerAddress: "localhost:9876",
        recoveryAttempts: 10,
        storeRecordTimeout: 5.0
    }, "rocketmq", 3301);
}

function runSchemaHistoryRestartTest(InternalSchemaStorage schemaStorage, string storageName, int productId) returns error? {
    schemaHistoryCreateEventCount = 0;
    schemaHistoryReadEventCount = 0;
    activeSchemaHistoryStorageName = storageName;
    activeSchemaHistoryProductId = productId;
    ignoreSchemaHistoryCleanupResult(file:remove(schemaHistoryOffsetFile(storageName)));
    _ = check mysqlClient->execute(`DELETE FROM products WHERE id = ${productId}`);

    MockListener initialListener = trackMockListener(new (schemaHistoryListenerConfiguration(schemaStorage, storageName)));
    check initialListener.attach(schemaHistoryTestService);
    check initialListener.start();
    check waitForSchemaHistoryEvent(false, storageName);
    check initialListener.gracefulStop();

    _ = check mysqlClient->execute(
        `INSERT INTO products (id, name, price, description, vendor_id)
         VALUES (${productId}, ${storageName}, 1.0, 'Restart verification', 1)`);

    schemaHistoryCreateEventCount = 0;
    MockListener restartedListener = trackMockListener(new (schemaHistoryListenerConfiguration(schemaStorage, storageName)));
    check restartedListener.attach(schemaHistoryTestService);
    check restartedListener.start();
    check waitForSchemaHistoryEvent(true, storageName);
    check restartedListener.gracefulStop();
}

function waitForSchemaHistoryEvent(boolean expectCreateEvent, string storageName) returns error? {
    int attempts = 0;
    while attempts < SCHEMA_HISTORY_EVENT_WAIT_ATTEMPTS {
        if expectCreateEvent ? schemaHistoryCreateEventCount > 0 : schemaHistoryReadEventCount > 0 {
            return;
        }
        runtime:sleep(SCHEMA_HISTORY_EVENT_POLL_INTERVAL_SECONDS);
        attempts += 1;
    }
    return error(expectCreateEvent ? "The listener did not resume from " + storageName + " schema history."
        : "The initial snapshot was not received for " + storageName + ".");
}

function cleanupSchemaHistoryTest() {
    cleanupTrackedMockListeners();
    if activeSchemaHistoryStorageName is string {
        string storageName = <string>activeSchemaHistoryStorageName;
        ignoreSchemaHistoryCleanupResult(file:remove(schemaHistoryOffsetFile(storageName)));
    }
    if activeSchemaHistoryProductId is int {
        int productId = <int>activeSchemaHistoryProductId;
        var cleanupResult = mysqlClient->execute(`DELETE FROM products WHERE id = ${productId}`);
        ignoreSchemaHistoryCleanupResult(cleanupResult);
    }
    activeSchemaHistoryStorageName = ();
    activeSchemaHistoryProductId = ();
}

function ignoreSchemaHistoryCleanupResult(any|error ignoredResult) {
}

function schemaHistoryListenerConfiguration(InternalSchemaStorage schemaStorage, string storageName)
        returns MySqlListenerConfiguration {
    return {
        engineName: "schema-history-" + storageName,
        internalSchemaStorage: schemaStorage,
        offsetStorage: {fileName: schemaHistoryOffsetFile(storageName)},
        database: {
            username,
            password,
            port,
            includedDatabases: database,
            includedTables: ["store_db.products"],
            databaseServerId: storageName == "azure" ? "9301" : storageName == "s3" ? "9302" : "9303"
        }
    };
}

function schemaHistoryOffsetFile(string storageName) returns string {
    return "/tmp/" + storageName + "-schema-history-offsets.dat";
}
