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

@test:Config {}
function testGetDebeziumProperties() {
    // Input parameters for the function
    string databaseName = "test_db";
    string tableName = "test_table";
    string username = "test_user";
    string password = "test_password";

    // Expected properties map
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "connector.class": "io.debezium.connector.sqlserver.SqlServerConnector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "database.query.timeout.ms": "60000",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "offset.storage": "org.apache.kafka.connect.storage.KafkaOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "bootstrap.servers": "",
        "offset.storage.topic": "bal_cdc_offsets",
        "offset.storage.partitions": "1",
        "offset.storage.replication.factor": "2",
        "database.hostname": "localhost",
        "database.port": "1433",
        "database.user": "test_user",
        "database.password": "test_password",
        "tasks.max": "1",
        "table.include.list": "test_table",
        "database.names": "test_db",
        "database.encrypt": "false",
        "include.schema.changes": "false"
    };

    MsSqlListenerConfiguration config = {
        database: {
            username: username,
            password: password,
            databaseNames: databaseName,
            includedTables: tableName
        },
        offsetStorage: {
            bootstrapServers: ""
        },
        internalSchemaStorage: {
            bootstrapServers: ""
        }
    };

    // Call the function to test
    map<string> actualProperties = getDebeziumProperties(config);

    // Validate the returned properties
    test:assertEquals(actualProperties, expectedProperties, msg = "Debezium properties do not match the expected values.");
}
