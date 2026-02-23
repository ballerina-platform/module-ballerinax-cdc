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

import ballerina/crypto;
import ballerina/test;

import ballerinax/kafka;

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
    populateSampleDBDebeziumProperties(config, actualProperties);

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
        "tombstones.on.delete": "false",
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
        "include.schema.changes": "false"
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
        "tombstones.on.delete": "false",
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
        "include.schema.changes": "false"
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
        "tombstones.on.delete": "false",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "localhost:9093",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.kafka.recovery.poll.interval.ms": "100",
        "schema.history.internal.kafka.recovery.attempts": "100",
        "schema.history.internal.kafka.query.timeout.ms": "3",
        "schema.history.internal.kafka.create.timeout.ms": "30",
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
        "include.schema.changes": "false"
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
        "tombstones.on.delete": "false",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "kafka1:9093",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.kafka.recovery.poll.interval.ms": "100",
        "schema.history.internal.kafka.recovery.attempts": "100",
        "schema.history.internal.kafka.query.timeout.ms": "3",
        "schema.history.internal.kafka.create.timeout.ms": "30",
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
        "include.schema.changes": "false"
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
        "tombstones.on.delete": "false",
        "schema.history.internal": "io.debezium.storage.kafka.history.KafkaSchemaHistory",
        "topic.prefix": "bal_cdc_schema_history",
        "schema.history.internal.kafka.bootstrap.servers": "kafka1:9093",
        "schema.history.internal.kafka.topic": "bal_cdc_internal_schema_history",
        "schema.history.internal.kafka.recovery.poll.interval.ms": "100",
        "schema.history.internal.kafka.recovery.attempts": "100",
        "schema.history.internal.kafka.query.timeout.ms": "3",
        "schema.history.internal.kafka.create.timeout.ms": "30",
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
        "include.schema.changes": "false"
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
