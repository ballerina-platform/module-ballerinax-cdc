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

import ballerina/crypto;
import ballerina/test;

import ballerinax/kafka;

// Sample database options for testing (mimics database-specific modules)
public type SampleDBOptions record {|
    *Options;
    // Sample-specific options for testing
    ExtendedSnapshotConfiguration extendedSnapshot?;
    // Can add more sample-specific options here if needed
|};

// Sample database listener configuration for testing
public type SampleDBListenerConfiguration record {|
    *ListenerConfiguration;
    SampleDBOptions options = {};
|};

// Populates SampleDB-specific options (mimics database-specific modules)
isolated function populateSampleDBOptions(SampleDBOptions options, map<string> configMap) {
    // Populate common options from cdc module
    populateOptions(options, configMap, typeof options);

    // Populate extended snapshot configuration if present
    ExtendedSnapshotConfiguration? extendedSnapshot = options.extendedSnapshot;
    if extendedSnapshot is ExtendedSnapshotConfiguration {
        populateExtendedSnapshotConfiguration(extendedSnapshot, configMap);
    }
}

@test:Config {}
function testGetDebeziumProperties() {
    // Expected properties map
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.producer.security.protocol": "PLAINTEXT",
        "schema.history.internal.consumer.security.protocol": "PLAINTEXT",
        "schema.history.internal.kafka.recovery.poll.interval.ms": "100",
        "schema.history.internal.kafka.recovery.attempts": "100",
        "schema.history.internal.kafka.query.timeout.ms": "3",
        "schema.history.internal.kafka.create.timeout.ms": "30",
        "offset.storage": "org.apache.kafka.connect.storage.KafkaOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "bootstrap.servers": "",
        "offset.storage.topic": "bal_cdc_offsets",
        "offset.storage.partitions": "1",
        "offset.storage.replication.factor": "2",
        "security.protocol": "PLAINTEXT",
        "include.schema.changes": "false",
        "database.query.timeout.ms": "60000"
    };

    SampleDBListenerConfiguration config = {
        offsetStorage: {
            bootstrapServers: ""
        },
        internalSchemaStorage: {
            bootstrapServers: ""
        }
    };

    map<string> actualProperties = {};
    // Call the function to test
    populateDebeziumProperties(config, actualProperties);
    populateSampleDBOptions(config.options, actualProperties);

    // Validate the returned properties
    test:assertEquals(actualProperties, expectedProperties, msg = "Debezium properties do not match the expected values.");
}

@test:Config {}
function testGetDatabaseDebeziumProperties() {
    // Expected properties map
    map<string> expectedProperties = {
        "connector.class": "",
        "database.hostname": "localhost",
        "database.port": "3307",
        "database.user": "root",
        "database.password": "root",
        "tasks.max": "1",
        "connect.timeout.ms": "600000",
        "database.ssl.mode": "disabled",
        "database.ssl.keystore": "",
        "database.ssl.keystore.password": "",
        "database.ssl.truststore": "",
        "database.ssl.truststore.password": "",
        "table.include.list": "",
        "column.include.list": "ya,tan"
    };

    DatabaseConnection config = {
        username: "root",
        password: "root",
        port: 3307,
        hostname: "localhost",
        connectorClass: "",
        connectTimeout: 600,
        tasksMax: 1,
        secure: {
            sslMode: DISABLED,
            keyStore: {path: "", password: ""},
            trustStore: {path: "", password: ""}
        },
        includedTables: "",
        includedColumns: ["ya", "tan"]
    };

    map<string> actualProperties = {};
    // Call the function to test
    populateDatabaseConfigurations(config, actualProperties);

    // Validate the returned properties
    test:assertEquals(actualProperties, expectedProperties, msg = "Debezium properties do not match the expected values.");
}

@test:Config {}
function testKafkaOffsetStorageWithSslAuth() {
    // Expected properties map with SSL authentication for offset storage
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "schema.history.internal": "io.debezium.storage.file.history.FileSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.file.filename": "tmp/dbhistory.dat",
        "offset.storage": "org.apache.kafka.connect.storage.KafkaOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "bootstrap.servers": "localhost:9093",
        "offset.storage.topic": "bal_cdc_offsets",
        "offset.storage.partitions": "1",
        "offset.storage.replication.factor": "2",
        "security.protocol": "SSL",
        "ssl.keystore.location": "/path/to/keystore.jks",
        "ssl.keystore.password": "keystore-password",
        "ssl.truststore.location": "/path/to/truststore.jks",
        "ssl.truststore.password": "truststore-password",
        "include.schema.changes": "false",
        "database.query.timeout.ms": "60000"
    };

    ListenerConfiguration config = {
        offsetStorage: {
            bootstrapServers: "localhost:9093",
            securityProtocol: kafka:PROTOCOL_SSL,
            secureSocket: {
                cert: {path: "/path/to/truststore.jks", password: "truststore-password"},
                key: {
                    keyStore: {path: "/path/to/keystore.jks", password: "keystore-password"}
                }
            }
        },
        internalSchemaStorage: <FileInternalSchemaStorage>{}
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);
    test:assertEquals(actualProperties, expectedProperties, msg = "Kafka offset storage SSL auth properties do not match.");
}

@test:Config {}
function testKafkaOffsetStorageWithSaslAuth() {
    // Expected properties map with SASL authentication for offset storage
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "schema.history.internal": "io.debezium.storage.file.history.FileSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.file.filename": "tmp/dbhistory.dat",
        "offset.storage": "org.apache.kafka.connect.storage.KafkaOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "bootstrap.servers": "localhost:9093",
        "offset.storage.topic": "bal_cdc_offsets",
        "offset.storage.partitions": "1",
        "offset.storage.replication.factor": "2",
        "security.protocol": "SASL_SSL",
        "sasl.mechanism": "SCRAM-SHA-256",
        "sasl.jaas.config": "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"user\" password=\"pass\";",
        "ssl.truststore.location": "/path/to/truststore.jks",
        "ssl.truststore.password": "truststore-password",
        "include.schema.changes": "false",
        "database.query.timeout.ms": "60000"
    };

    ListenerConfiguration config = {
        offsetStorage: {
            bootstrapServers: "localhost:9093",
            securityProtocol: kafka:PROTOCOL_SASL_SSL,
            auth: {
                mechanism: kafka:AUTH_SASL_SCRAM_SHA_256,
                username: "user",
                password: "pass"
            },
            secureSocket: {
                cert: <crypto:TrustStore>{path: "/path/to/truststore.jks", password: "truststore-password"}
            }
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);
    test:assertEquals(actualProperties, expectedProperties, msg = "Kafka offset storage SASL auth properties do not match.");
}

@test:Config {}
function testKafkaSchemaHistoryWithAuth() {
    // Expected properties map with SASL authentication for schema history
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "localhost:9093",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.producer.security.protocol": "SASL_SSL",
        "schema.history.internal.producer.sasl.mechanism": "PLAIN",
        "schema.history.internal.producer.sasl.jaas.config": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"user\" password=\"pass\";",
        "schema.history.internal.producer.ssl.truststore.location": "/path/to/truststore.jks",
        "schema.history.internal.producer.ssl.truststore.password": "truststore-password",
        "schema.history.internal.consumer.security.protocol": "SASL_SSL",
        "schema.history.internal.consumer.sasl.mechanism": "PLAIN",
        "schema.history.internal.consumer.sasl.jaas.config": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"user\" password=\"pass\";",
        "schema.history.internal.consumer.ssl.truststore.location": "/path/to/truststore.jks",
        "schema.history.internal.consumer.ssl.truststore.password": "truststore-password",
        "offset.storage": "org.apache.kafka.connect.storage.FileOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "offset.storage.file.filename": "tmp/debezium-offsets.dat",
        "include.schema.changes": "false",
        "database.query.timeout.ms": "60000"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: {
            bootstrapServers: "localhost:9093",
            securityProtocol: kafka:PROTOCOL_SASL_SSL,
            auth: {
                mechanism: kafka:AUTH_SASL_PLAIN,
                username: "user",
                password: "pass"
            },
            secureSocket: {
                cert: <crypto:TrustStore>{path: "/path/to/truststore.jks", password: "truststore-password"}
            }
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);
    test:assertEquals(actualProperties, expectedProperties, msg = "Kafka schema history auth properties do not match.");
}

@test:Config {}
function testBothKafkaStoragesWithAuth() {
    // Test that both offset storage and schema history can have independent auth configurations
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "kafka1:9093",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.producer.security.protocol": "SSL",
        "schema.history.internal.producer.ssl.keystore.location": "/path/to/keystore1.jks",
        "schema.history.internal.producer.ssl.keystore.password": "pass1",
        "schema.history.internal.producer.ssl.truststore.location": "/path/to/truststore1.jks",
        "schema.history.internal.producer.ssl.truststore.password": "pass1",
        "schema.history.internal.consumer.security.protocol": "SSL",
        "schema.history.internal.consumer.ssl.keystore.location": "/path/to/keystore1.jks",
        "schema.history.internal.consumer.ssl.keystore.password": "pass1",
        "schema.history.internal.consumer.ssl.truststore.location": "/path/to/truststore1.jks",
        "schema.history.internal.consumer.ssl.truststore.password": "pass1",
        "offset.storage": "org.apache.kafka.connect.storage.KafkaOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "bootstrap.servers": "kafka2:9093",
        "offset.storage.topic": "bal_cdc_offsets",
        "offset.storage.partitions": "1",
        "offset.storage.replication.factor": "2",
        "security.protocol": "SASL_PLAINTEXT",
        "sasl.mechanism": "SCRAM-SHA-512",
        "sasl.jaas.config": "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"offsetuser\" password=\"offsetpass\";",
        "include.schema.changes": "false",
        "database.query.timeout.ms": "60000"
    };

    ListenerConfiguration config = {
        offsetStorage: {
            bootstrapServers: "kafka2:9093",
                securityProtocol: kafka:PROTOCOL_SASL_PLAINTEXT,
                auth: {
                    mechanism: kafka:AUTH_SASL_SCRAM_SHA_512,
                    username: "offsetuser",
                    password: "offsetpass"
                }
        },
        internalSchemaStorage: {
            bootstrapServers: "kafka1:9093",
            securityProtocol: kafka:PROTOCOL_SSL,
            secureSocket: {
                cert: <crypto:TrustStore>{path: "/path/to/truststore1.jks", password: "pass1"},
                key: {
                    keyStore: {path: "/path/to/keystore1.jks", password: "pass1"}
                }
            }
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);
    test:assertEquals(actualProperties, expectedProperties, msg = "Both Kafka storages with independent auth do not match.");
}

@test:Config {}
function testBothKafkaStoragesWithCertKey() {
    // Test that both offset storage and schema history can use CertKey independently
    map<string> expectedProperties = {
        "name": "ballerina-cdc-connector",
        "max.queue.size": "8192",
        "max.batch.size": "2048",
        "event.processing.failure.handling.mode": "warn",
        "snapshot.mode": "initial",
        "skipped.operations": "t",
        "skip.messages.without.change": "false",
        "tombstones.on.delete": "false",
        "decimal.handling.mode": "double",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "kafka1:9093",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.producer.security.protocol": "SSL",
        "schema.history.internal.producer.ssl.keystore.type": "PEM",
        "schema.history.internal.producer.ssl.keystore.certificate.chain": "-----BEGIN CERTIFICATE-----\ntest-cert-content\n-----END CERTIFICATE-----",
        "schema.history.internal.producer.ssl.keystore.key": "-----BEGIN PRIVATE KEY-----\ntest-key-content\n-----END PRIVATE KEY-----",
        "schema.history.internal.producer.ssl.truststore.location": "truststore1.pem",
        "schema.history.internal.producer.ssl.truststore.type": "PEM",
        "schema.history.internal.consumer.security.protocol": "SSL",
        "schema.history.internal.consumer.ssl.keystore.type": "PEM",
        "schema.history.internal.consumer.ssl.keystore.certificate.chain": "-----BEGIN CERTIFICATE-----\ntest-cert-content\n-----END CERTIFICATE-----",
        "schema.history.internal.consumer.ssl.keystore.key": "-----BEGIN PRIVATE KEY-----\ntest-key-content\n-----END PRIVATE KEY-----",
        "schema.history.internal.consumer.ssl.truststore.location": "truststore1.pem",
        "schema.history.internal.consumer.ssl.truststore.type": "PEM",
        "offset.storage": "org.apache.kafka.connect.storage.KafkaOffsetBackingStore",
        "offset.flush.interval.ms": "60000",
        "offset.flush.timeout.ms": "5000",
        "bootstrap.servers": "kafka2:9093",
        "offset.storage.topic": "bal_cdc_offsets",
        "offset.storage.partitions": "1",
        "offset.storage.replication.factor": "2",
        "security.protocol": "SSL",
        "ssl.keystore.type": "PEM",
        "ssl.keystore.certificate.chain": "-----BEGIN CERTIFICATE-----\ntest-cert-content\n-----END CERTIFICATE-----",
        "ssl.keystore.key": "-----BEGIN PRIVATE KEY-----\ntest-key-content\n-----END PRIVATE KEY-----",
        "ssl.key.password": "offset-key-password",
        "ssl.truststore.location": "truststore2.pem",
        "ssl.truststore.type": "PEM",
        "include.schema.changes": "false",
        "database.query.timeout.ms": "60000"
    };

    ListenerConfiguration config = {
        offsetStorage: {
            bootstrapServers: "kafka2:9093",
            securityProtocol: kafka:PROTOCOL_SSL,
            secureSocket: {
                cert: "truststore2.pem",
                key: {
                    certFile: "tests/resources/test-cert.pem",
                    keyFile: "tests/resources/test-key.pem",
                    keyPassword: "offset-key-password"
                }
            }
        },
        internalSchemaStorage: {
            bootstrapServers: "kafka1:9093",
            securityProtocol: kafka:PROTOCOL_SSL,
            secureSocket: {
                cert: "truststore1.pem",
                key: {
                    certFile: "tests/resources/test-cert.pem",
                    keyFile: "tests/resources/test-key.pem"
                }
            }
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);
    test:assertEquals(actualProperties, expectedProperties, msg = "Both Kafka storages with CertKey do not match.");
}

// ========== OPTIONS TESTS ==========

@test:Config {groups: ["options-basic"]}
function testPopulateOptionsWithDefaults() {
    SampleDBOptions options = {};
    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    // Should have default values populated
    test:assertEquals(actualProperties["snapshot.mode"], "initial");
    test:assertEquals(actualProperties["decimal.handling.mode"], "double");
}

@test:Config {groups: ["options-heartbeat"]}
function testPopulateOptionsWithHeartbeat() {
    map<string> expectedProperties = {
        "heartbeat.interval.ms": "5000",
        "heartbeat.action.query": "SELECT 1"
    };

    SampleDBOptions options = {
        heartbeat: {
            interval: 5,
            actionQuery: "SELECT 1"
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["heartbeat.interval.ms"],
        expectedProperties["heartbeat.interval.ms"],
        msg = "Heartbeat interval does not match.");
    test:assertEquals(actualProperties["heartbeat.action.query"],
        expectedProperties["heartbeat.action.query"],
        msg = "Heartbeat action query does not match.");
}

@test:Config {groups: ["options-signal"]}
function testPopulateOptionsWithFileSignal() {
    map<string> expectedProperties = {
        "signal.enabled.channels": "file",
        "signal.file": "/tmp/signals.txt"
    };

    SampleDBOptions options = {
        signal: {
            enabledChannels: [FILE],
            filePath: "/tmp/signals.txt"
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["signal.enabled.channels"],
        expectedProperties["signal.enabled.channels"],
        msg = "Signal enabled channels does not match.");
    test:assertEquals(actualProperties["signal.file"],
        expectedProperties["signal.file"],
        msg = "Signal file does not match.");
}

@test:Config {groups: ["options-signal"]}
function testPopulateOptionsWithKafkaSignal() {
    map<string> expectedProperties = {
        "signal.enabled.channels": "kafka",
        "signal.kafka.topic": "cdc-signals",
        "signal.kafka.bootstrap.servers": "localhost:9092"
    };

    SampleDBOptions options = {
        signal: {
            enabledChannels: [KAFKA],
            topic: "cdc-signals",
            bootstrapServers: "localhost:9092"
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["signal.enabled.channels"],
        expectedProperties["signal.enabled.channels"],
        msg = "Signal enabled channels does not match.");
    test:assertEquals(actualProperties["signal.kafka.topic"],
        expectedProperties["signal.kafka.topic"],
        msg = "Signal kafka topic does not match.");
    test:assertEquals(actualProperties["signal.kafka.bootstrap.servers"],
        expectedProperties["signal.kafka.bootstrap.servers"],
        msg = "Signal kafka bootstrap servers does not match.");
}

@test:Config {groups: ["options-transaction"]}
function testPopulateOptionsWithTransactionMetadata() {
    map<string> expectedProperties = {
        "provide.transaction.metadata": "true"
    };

    SampleDBOptions options = {
        transactionMetadata: {
            enabled: true
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["provide.transaction.metadata"],
        expectedProperties["provide.transaction.metadata"],
        msg = "Transaction metadata does not match.");
}

@test:Config {groups: ["options-column"]}
function testPopulateOptionsWithColumnHashMask() {
    map<string> expectedProperties = {
        "column.mask.hash.v2.SHA-256.with.salt.CzQMA0cB5K": "inventory.orders.customerName, inventory.shipment.customerName"
    };

    SampleDBOptions options = {
        columnTransform: {
            maskWithHash: [
                {
                    regexPatterns: ["inventory.orders.customerName", "inventory.shipment.customerName"],
                    algorithm: "SHA-256",
                    salt: "CzQMA0cB5K"
                }
            ]
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["column.mask.hash.v2.SHA-256.with.salt.CzQMA0cB5K"],
        expectedProperties["column.mask.hash.v2.SHA-256.with.salt.CzQMA0cB5K"],
        msg = "Hash algorithm does not match.");
}

@test:Config {groups: ["options-column"]}
function testPopulateOptionsWithColumnCharMask() {
    map<string> expectedProperties = {
        "column.mask.with.10.chars": "MySql.customers.name",
        "column.mask.with.5.chars": "MySql.orders.id"
    };

    SampleDBOptions options = {
        columnTransform: {
            maskWithChars: [
                {
                    length: 10,
                    regexPatterns: "MySql.customers.name"
                },
                {
                    length: 5,
                    regexPatterns: "MySql.orders.id"
                }
            ]
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["column.mask.with.10.chars"],
        expectedProperties["column.mask.with.10.chars"],
        msg = "Char mask with 10 chars does not match.");
    test:assertEquals(actualProperties["column.mask.with.5.chars"],
        expectedProperties["column.mask.with.5.chars"],
        msg = "Char mask with 5 chars does not match.");
}

@test:Config {groups: ["options-column"]}
function testPopulateOptionsWithColumnTruncate() {
    map<string> expectedProperties = {
        "column.truncate.to.20.chars": "MySql.logs.message"
    };

    SampleDBOptions options = {
        columnTransform: {
            truncateToChars: [
                {
                    length: 20,
                    regexPatterns: "MySql.logs.message"
                }
            ]
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["column.truncate.to.20.chars"],
        expectedProperties["column.truncate.to.20.chars"],
        msg = "Column truncate does not match.");
}

@test:Config {groups: ["options-topic"]}
function testPopulateOptionsWithTopicConfig() {
    map<string> expectedProperties = {
        "topic.delimiter": "-"
    };

    SampleDBOptions options = {
        topicConfig: {
            delimiter: "-"
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["topic.delimiter"],
        expectedProperties["topic.delimiter"],
        msg = "Topic delimiter does not match.");
}

@test:Config {groups: ["options-error"]}
function testPopulateOptionsWithErrorHandling() {
    map<string> expectedProperties = {
        "errors.max.retries": "5"
    };

    SampleDBOptions options = {
        errorHandling: {
            maxRetries: 5
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["errors.max.retries"],
        expectedProperties["errors.max.retries"],
        msg = "Max retries does not match.");
}

@test:Config {groups: ["options-perf"]}
function testPopulateOptionsWithPerformance() {
    map<string> expectedProperties = {
        "max.queue.size": "16384",
        "max.batch.size": "4096"
    };

    SampleDBOptions options = {
        maxQueueSize: 16384,
        maxBatchSize: 4096
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["max.queue.size"],
        expectedProperties["max.queue.size"],
        msg = "Max queue size does not match.");
    test:assertEquals(actualProperties["max.batch.size"],
        expectedProperties["max.batch.size"],
        msg = "Max batch size does not match.");
}

@test:Config {groups: ["options-monitoring"]}
function testPopulateOptionsWithMonitoring() {
    map<string> expectedProperties = {
        "max.queue.size.in.bytes": "1048576"
    };

    SampleDBOptions options = {
        performance: {
            maxQueueSizeInBytes: 1048576
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["max.queue.size.in.bytes"],
        expectedProperties["max.queue.size.in.bytes"],
        msg = "Max queue size in bytes does not match.");
}

@test:Config {groups: ["options-guardrail"]}
function testPopulateOptionsWithGuardrail() {
    map<string> expectedProperties = {
        "query.fetch.size": "1000"
    };

    SampleDBOptions options = {
        performance: {
            queryFetchSize: 1000
        }
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["query.fetch.size"],
        expectedProperties["query.fetch.size"],
        msg = "Query fetch size does not match.");
}

@test:Config {groups: ["options-additional"]}
function testPopulateOptionsWithAdditionalProperties() {
    map<string> expectedProperties = {
        "custom.property.1": "value1",
        "custom.property.2": "value2"
    };

    SampleDBOptions options = {
        "custom.property.1": "value1",
        "custom.property.2": "value2"
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    test:assertEquals(actualProperties["custom.property.1"],
        expectedProperties["custom.property.1"],
        msg = "Additional property 1 does not match.");
    test:assertEquals(actualProperties["custom.property.2"],
        expectedProperties["custom.property.2"],
        msg = "Additional property 2 does not match.");
}

// TODO: add another test to validate that non-string additional properties are ignored and logged as errors

// ========== SCHEMA HISTORY STORAGE TESTS ==========

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
            user: "dbuser",
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
        "schema.history.internal": "io.debezium.storage.redis.history.RedisSchemaHistory",
        "schema.history.internal.redis.address": "localhost:6379"
    };

    ListenerConfiguration config = {
        internalSchemaStorage: <RedisInternalSchemaStorage>{
            address: "localhost:6379"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["schema.history.internal"],
        expectedProperties["schema.history.internal"],
        msg = "Redis schema history does not match.");
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

// ========== OFFSET STORAGE TESTS ==========

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
        "offset.storage": "io.debezium.storage.redis.offset.RedisOffsetBackingStore",
        "offset.storage.redis.address": "localhost:6379"
    };

    ListenerConfiguration config = {
        offsetStorage: <RedisOffsetStorage>{
            address: "localhost:6379"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["offset.storage"],
        expectedProperties["offset.storage"],
        msg = "Redis offset storage does not match.");
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
            user: "dbuser",
            password: "dbpass"
        }
    };

    map<string> actualProperties = {};
    populateDebeziumProperties(config, actualProperties);

    test:assertEquals(actualProperties["offset.storage"],
        expectedProperties["offset.storage"],
        msg = "JDBC offset storage does not match.");
}

// ========== SNAPSHOT CONFIGURATION TESTS ==========

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
