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
        heartbeatConfig: {
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
        signalConfig: {
            fileConfig: {
                fileName: "/tmp/signals.txt"
            }
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
        signalConfig: {
            kafkaConfig: {
                topicName: "cdc-signals",
                bootstrapServers: "localhost:9092"
            }
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
        transactionMetadataConfig: {
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
        columnTransformConfig: {
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
        columnTransformConfig: {
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
        columnTransformConfig: {
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
        connectionRetryConfig: {
            maxAttempts: 5
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
        performanceConfig: {
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
        performanceConfig: {
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
    // Test that additional properties of various primitive types are converted to strings
    SampleDBOptions options = {
        "custom.string.property": "stringValue",
        "custom.int.property": 123,
        "custom.boolean.true": true,
        "custom.boolean.false": false,
        "custom.decimal.property": 45.67,
        "custom.float.property": 3.14
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    // Verify all primitive properties are present and converted to strings
    test:assertEquals(actualProperties["custom.string.property"], "stringValue",
        msg = "String property should be preserved.");
    test:assertEquals(actualProperties["custom.int.property"], "123",
        msg = "Int property should be converted to string.");
    test:assertEquals(actualProperties["custom.boolean.true"], "true",
        msg = "Boolean true should be converted to string 'true'.");
    test:assertEquals(actualProperties["custom.boolean.false"], "false",
        msg = "Boolean false should be converted to string 'false'.");
    test:assertEquals(actualProperties["custom.decimal.property"], "45.67",
        msg = "Decimal property should be converted to string.");
    // Float may have precision variations, so check if value exists and is a string representation
    test:assertTrue(actualProperties.hasKey("custom.float.property"),
        msg = "Float property should be present.");
    string? floatValue = actualProperties["custom.float.property"];
    test:assertTrue(floatValue is string && floatValue.startsWith("3.14"),
        msg = "Float property should be converted to string starting with '3.14'.");
}

@test:Config {groups: ["options-additional"]}
function testUnsupportedAdditionalPropertiesIgnored() {
    // Complex types (arrays, records) should be ignored and logged as errors
    SampleDBOptions options = {
        "valid.string.property": "validValue",
        "valid.int.property": 42,
        "invalid.array.property": [1, 2, 3]
    };

    map<string> actualProperties = {};
    populateSampleDBOptions(options, actualProperties);

    // Valid primitive properties should be present
    test:assertTrue(actualProperties.hasKey("valid.string.property"),
        msg = "Valid string property should be present.");
    test:assertEquals(actualProperties["valid.string.property"], "validValue",
        msg = "Valid string property value mismatch.");
    test:assertTrue(actualProperties.hasKey("valid.int.property"),
        msg = "Valid int property should be present.");
    test:assertEquals(actualProperties["valid.int.property"], "42",
        msg = "Valid int property should be converted to string.");

    // Complex types should be ignored
    test:assertFalse(actualProperties.hasKey("invalid.array.property"),
        msg = "Invalid array property should be ignored.");
}

