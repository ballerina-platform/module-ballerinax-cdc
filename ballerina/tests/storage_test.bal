// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

@test:Config {groups: ["schema-history"]}
function testKafkaSchemaHistoryWithExtendedOptions() {
    map<string> expectedProperties = {
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "schema.history.internal.kafka.bootstrap.servers": "localhost:9092",
        "schema.history.internal.kafka.topic": "schema-changes"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <KafkaInternalSchemaStorage>{
            bootstrapServers: "localhost:9092",
            topicName: "schema-changes"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "Schema history internal does not match.");
    test:assertEquals(actualProperties["schema.history.internal.kafka.bootstrap.servers"],
        expectedProperties["schema.history.internal.kafka.bootstrap.servers"],
        msg = "Kafka bootstrap servers does not match.");
}

@test:Config {groups: ["schema-history"]}
function testMemorySchemaHistory() {
    map<string> expectedProperties = {
        "schema.history.internal": "io.debezium.relational.history.MemorySchemaHistory"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <MemoryInternalSchemaStorage>{}
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "Memory schema history does not match.");
}

@test:Config {groups: ["schema-history"]}
function testJdbcSchemaHistory() {
    map<string> expectedProperties = {
        "schema.history.internal": "io.debezium.storage.jdbc.history.JdbcSchemaHistory",
        "schema.history.internal.jdbc.url": "jdbc:mysql://localhost:3306/history",
        "schema.history.internal.jdbc.user": "dbuser"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <JdbcInternalSchemaStorage>{
            url: "jdbc:mysql://localhost:3306/history",
            username: "dbuser",
            password: "dbpass"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "JDBC schema history does not match.");
}

@test:Config {groups: ["schema-history"]}
function testRedisSchemaHistory() {
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal": "io.debezium.storage.redis.history.RedisSchemaHistory",
        "schema.history.internal.redis.address": "localhost:6379",
        "schema.history.internal.redis.key": "metadata:debezium:schema_history",
        "schema.history.internal.redis.db.index": "0",
        "schema.history.internal.redis.ssl.enabled": "true",
        "schema.history.internal.redis.ssl.hostname.verification.enabled": "true",
        "schema.history.internal.redis.ssl.truststore": "/path/to/truststore.jks",
        "schema.history.internal.redis.ssl.truststore.password": "trustpass",
        "schema.history.internal.redis.ssl.truststore.type": "JKS",
        "schema.history.internal.redis.ssl.keystore": "/path/to/keystore.jks",
        "schema.history.internal.redis.ssl.keystore.password": "keypass",
        "schema.history.internal.redis.ssl.keystore.type": "JKS",
        "schema.history.internal.redis.connection.timeout.ms": "2000",
        "schema.history.internal.redis.socket.timeout.ms": "2000",
        "schema.history.internal.redis.retry.initial.delay.ms": "300",
        "schema.history.internal.redis.retry.max.delay.ms": "10000",
        "schema.history.internal.redis.retry.max.attempts": "10",
        "schema.history.internal.redis.wait.enabled": "false",
        "schema.history.internal.redis.cluster.enabled": "false",
        "offset.storage": "org.apache.kafka.connect.storage.FileOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "offset.storage.file.filename": "tmp/debezium-offsets.dat",
        "tombstones.on.delete": "false",
        "include.schema.changes": "false"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <RedisInternalSchemaStorage>{
            address: "localhost:6379",
            secureSocket: {
                cert: {path: "/path/to/truststore.jks", password: "trustpass"},
                key: {path: "/path/to/keystore.jks", password: "keypass"},
                verifyHostName: true
            }
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties, expectedProperties, msg = "Redis schema history properties do not match.");
}

@test:Config {groups: ["schema-history"]}
function testS3SchemaHistory() {
    map<string> expectedProperties = {
        "schema.history.internal": "io.debezium.storage.s3.history.S3SchemaHistory",
        "schema.history.internal.s3.bucket.name": "my-bucket",
        "schema.history.internal.s3.region.name": "us-east-1"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <AmazonS3InternalSchemaStorage>{
            bucketName: "my-bucket",
            objectName: "schema-history",
            region: "us-east-1"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "S3 schema history does not match.");
}

@test:Config {groups: ["schema-history"]}
function testAzureBlobSchemaHistory() {
    map<string> expectedProperties = {
        "schema.history.internal": "io.debezium.storage.azure.blob.history.AzureBlobSchemaHistory",
        "schema.history.internal.azure.storage.account.name": "myaccount",
        "schema.history.internal.azure.storage.container.name": "mycontainer"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <AzureBlobInternalSchemaStorage>{
            connectionString: "DefaultEndpointsProtocol=https;AccountName=myaccount;AccountKey=mykey",
            accountName: "myaccount",
            containerName: "mycontainer",
            blobName: "schema-history"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "Azure Blob schema history does not match.");
}

@test:Config {groups: ["schema-history"]}
function testRocketMQSchemaHistory() {
    map<string> expectedProperties = {
        "schema.history.internal": "io.debezium.storage.rocketmq.history.RocketMqSchemaHistory",
        "schema.history.internal.rocketmq.name.srv.addr": "localhost:9876"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <RocketMQInternalSchemaStorage>{
            topicName: "schema-history",
            nameServerAddress: "localhost:9876",
            accessKey: "accessKey",
            secretKey: "secretKey",
            recoveryAttempts: 10,
            storeRecordTimeout: 3.0
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "RocketMQ schema history does not match.");
}

@test:Config {groups: ["offset-storage"]}
function testMemoryOffsetStorage() {
    map<string> expectedProperties = {
        "offset.storage": "org.apache.kafka.connect.storage.MemoryOffsetBackingStore"
    };

    ListenerConfiguration config = {
        offsetStorage: <MemoryOffsetStorage>{}
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["offset.storage"],
        expectedProperties["offset.storage"],
        msg = "Memory offset storage does not match.");
}

@test:Config {groups: ["offset-storage"]}
function testRedisOffsetStorage() {
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "schema.history.internal": "io.debezium.storage.file.history.FileSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.file.filename": "tmp/dbhistory.dat",
        "offset.storage": "io.debezium.storage.redis.offset.RedisOffsetBackingStore",
        "offset.storage.redis.address": "localhost:6379",
        "offset.storage.redis.key": "metadata:debezium:offsets",
        "offset.storage.redis.db.index": "0",
        "offset.storage.redis.ssl.enabled": "true",
        "offset.storage.redis.ssl.hostname.verification.enabled": "false",
        "offset.storage.redis.ssl.truststore": "/path/to/truststore.jks",
        "offset.storage.redis.ssl.truststore.password": "password",
        "offset.storage.redis.ssl.truststore.type": "JKS",
        "offset.storage.redis.connection.timeout.ms": "2000",
        "offset.storage.redis.socket.timeout.ms": "2000",
        "offset.storage.redis.retry.initial.delay.ms": "300",
        "offset.storage.redis.retry.max.delay.ms": "10000",
        "offset.storage.redis.retry.max.attempts": "10",
        "offset.storage.redis.wait.enabled": "false",
        "offset.storage.redis.cluster.enabled": "false",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "tombstones.on.delete": "false",
        "include.schema.changes": "false"
    };

    ListenerConfiguration config = {
        offsetStorage: <RedisOffsetStorage>{
            address: "localhost:6379",
            secureSocket: {
                cert: {path: "/path/to/truststore.jks", password: "password"}
            }
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties, expectedProperties, msg = "Redis offset storage properties do not match.");
}

@test:Config {groups: ["offset-storage"]}
function testJdbcOffsetStorage() {
    map<string> expectedProperties = {
        "offset.storage": "io.debezium.storage.jdbc.offset.JdbcOffsetBackingStore",
        "offset.storage.jdbc.url": "jdbc:mysql://localhost:3306/offsets",
        "offset.storage.jdbc.user": "dbuser"
    };

    ListenerConfiguration config = {
        offsetStorage: <JdbcOffsetStorage>{
            url: "jdbc:mysql://localhost:3306/offsets",
            username: "dbuser",
            password: "dbpass"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["offset.storage"],
        expectedProperties["offset.storage"],
        msg = "JDBC offset storage does not match.");
}

@test:Config {groups: ["snapshot"]}
function testExtendedSnapshotConfiguration() {
    map<string> expectedProperties = {
        "snapshot.mode": "no_data",
        "snapshot.delay.ms": "10000",
        "snapshot.fetch.size": "1000"
    };

    SampleDBOptions options = {
        snapshotMode: NO_DATA,
        extendedSnapshot: {
            delay: 10,
            fetchSize: 1000
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["snapshot.mode"],
        expectedProperties["snapshot.mode"],
        msg = "Snapshot mode does not match.");
    test:assertEquals(actualProperties["snapshot.delay.ms"],
        expectedProperties["snapshot.delay.ms"],
        msg = "Snapshot delay does not match.");
    test:assertEquals(actualProperties["snapshot.fetch.size"],
        expectedProperties["snapshot.fetch.size"],
        msg = "Snapshot fetch size does not match.");
}
