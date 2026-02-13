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
import ballerinax/kafka;

# Represents the SSL modes for secure database connections.
public enum SslMode {
    DISABLED = "disabled",
    PREFERRED = "preferred",
    REQUIRED = "required",
    VERIFY_CA = "verify_ca",
    VERIFY_IDENTITY = "verify_identity"
}

# Defines the modes for handling event processing failures.
public enum EventProcessingFailureHandlingMode {
    FAIL = "fail",
    WARN = "warn",
    SKIP = "skip"
}

# Represents the snapshot modes for capturing database states.
#
# + ALWAYS - Always take a snapshot of the structure and data of captured tables at every start.
# + INITIAL - Take a snapshot only at the initial startup, then stream subsequent changes.
# + INITIAL_ONLY - Take a snapshot only at the initial startup, then stop without streaming changes.
# + NO_DATA - Take a snapshot without creating READ events for the initial data set.
# + RECOVERY - Take a snapshot during recovery to restore schema history.
# + WHEN_NEEDED - Take a snapshot only when required, e.g., missing or invalid offsets.
# + CONFIGURATION_BASED - Take a snapshot based on configuration properties.
# + CUSTOM - Take a custom snapshot using a custom implementation.
public enum SnapshotMode {
    ALWAYS = "always",
    INITIAL = "initial",
    INITIAL_ONLY = "initial_only",
    SCHEMA_ONLY = "schema_only",
    NO_DATA = "no_data",
    RECOVERY = "recovery",
    WHEN_NEEDED = "when_needed",
    CONFIGURATION_BASED = "configuration_based",
    CUSTOM = "custom"
}

# Represents the types of database operations.
public enum Operation {
    CREATE = "c",
    UPDATE = "u",
    DELETE = "d",
    TRUNCATE = "t",
    NONE = "none"
}

# Represents the modes for handling decimal values from the database.
public enum DecimalHandlingMode {
    PRECISE = "precise",
    DOUBLE = "double",
    STRING = "string"
}

# Represents a secure database connection configuration.
#
# + sslMode - The SSL mode to use for the connection
# + keyStore - The keystore for SSL connections
# + trustStore - The truststore for SSL connections
public type SecureDatabaseConnection record {|
    SslMode sslMode = PREFERRED;
    crypto:KeyStore keyStore?;
    crypto:TrustStore trustStore?;
|};

# Represents the internal schema history configuration.
#
# + className - The class name of the schema history implementation to use
# + topicPrefix - The prefix for the topic names used in Kafka-based schema history
type SchemaHistoryInternal record {|
    string className;
    string topicPrefix = "bal_cdc_schema_history";
|};

# Represents the file-based schema history configuration.
#
# + className - The class name of the file schema history implementation to use
# + fileName - The name of the file to store schema history
public type FileInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.file.history.FileSchemaHistory";
    string fileName = "tmp/dbhistory.dat";
|};

# Represents the Kafka-based schema history configuration.
#
# + className - The class name of the Kafka schema history implementation to use
# + topicName - The name of the Kafka topic to store schema history
# + bootstrapServers - The list of Kafka bootstrap servers
# + securityProtocol - Kafka security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, or SASL_SSL). Defaults to PLAINTEXT
# + auth - SASL authentication credentials (mechanism, username, password). Required for SASL_PLAINTEXT and SASL_SSL
# + secureSocket - SSL/TLS configuration with truststore and optional keystore for mutual TLS. Supports both JKS/PKCS12 truststores and PEM certificates
public type KafkaInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.kafka.history.KafkaSchemaHistory";
    string topicName = "bal_cdc_internal_schema_history";
    string|string[] bootstrapServers;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# Represents the base configuration for offset storage.
#
# + flushInterval - The interval in seconds to flush offsets
# + flushTimeout - The timeout in seconds for flushing offsets
type OffsetStorage record {|
    decimal flushInterval = 60;
    decimal flushTimeout = 5;
|};

# Represents the file-based offset storage configuration.
#
# + className - The class name of the file offset storage implementation to use
# + fileName - The name of the file to store offsets
public type FileOffsetStorage record {|
    *OffsetStorage;
    string className = "org.apache.kafka.connect.storage.FileOffsetBackingStore";
    string fileName = "tmp/debezium-offsets.dat";
|};

# Represents the Kafka-based offset storage configuration.
#
# + className - The class name of the Kafka offset storage implementation to use
# + bootstrapServers - The list of Kafka bootstrap servers
# + topicName - The name of the Kafka topic to store offsets
# + partitions - The number of partitions for the Kafka topic
# + replicationFactor - The replication factor for the Kafka topic
# + securityProtocol - Kafka security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, or SASL_SSL). Defaults to PLAINTEXT
# + auth - SASL authentication credentials (mechanism, username, password). Required for SASL_PLAINTEXT and SASL_SSL
# + secureSocket - SSL/TLS configuration with truststore and optional keystore for mutual TLS
public type KafkaOffsetStorage record {|
    *OffsetStorage;
    string className = "org.apache.kafka.connect.storage.KafkaOffsetBackingStore";
    string|string[] bootstrapServers;
    string topicName = "bal_cdc_offsets";
    int partitions = 1;
    int replicationFactor = 2;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# Represents the base configuration for a database connection.
#
# + connectorClass - The class name of the database connector implementation to use
# + hostname - The hostname of the database server
# + port - The port number of the database server
# + username - The username for the database connection
# + password - The password for the database connection
# + connectTimeout - The connection timeout in seconds
# + tasksMax - The maximum number of tasks that should be created for this connector
# + secure - The secure connection configuration
# + includedTables - A list of regular expressions matching fully-qualified table identifiers to capture changes from (should not be used alongside tableExclude)
# + excludedTables - A list of regular expressions matching fully-qualified table identifiers to exclude from change capture (should not be used alongside tableInclude)
# + includedColumns - A list of regular expressions matching fully-qualified column identifiers to capture changes from (should not be used alongside columnExclude)
# + excludedColumns - A list of regular expressions matching fully-qualified column identifiers to exclude from change capture (should not be used alongside columnInclude)
public type DatabaseConnection record {|
    string connectorClass;
    string hostname;
    int port;
    string username;
    string password;
    decimal connectTimeout?;
    int tasksMax = 1;
    SecureDatabaseConnection secure?;
    string|string[] includedTables?;
    string|string[] excludedTables?;
    string|string[] includedColumns?;
    string|string[] excludedColumns?;
|};

# Provides a set of additional configurations related to the cdc connection.
#
# + snapshotMode - The mode for capturing snapshots
# + eventProcessingFailureHandlingMode - The mode for handling event processing failures
# + skippedOperations - The list of operations to skip
# + skipMessagesWithoutChange - Whether to skip messages without changes
# + decimalHandlingMode - The mode for handling decimal values from the database
# + maxQueueSize - The maximum size of the queue for events
# + maxBatchSize - The maximum size of the batch for events
# + queryTimeout - Specifies the time, in seconds, that the connector waits for a query to complete. Set the value to 0 (zero) to remove the timeout
public type Options record {|
    SnapshotMode snapshotMode = INITIAL;
    EventProcessingFailureHandlingMode eventProcessingFailureHandlingMode = WARN;
    Operation[] skippedOperations = [TRUNCATE];
    boolean skipMessagesWithoutChange = false;
    DecimalHandlingMode decimalHandlingMode = DOUBLE;
    int maxQueueSize = 8192;
    int maxBatchSize = 2048;
    decimal queryTimeout = 60;
|};

# Represents the base configuration for the CDC engine.
#
# + engineName - The name of the CDC engine
# + internalSchemaStorage - The internal schema history configuration
# + offsetStorage - The offset storage configuration
# + options - The additional options for the CDC engine
# + livenessInterval - Time interval (in seconds) used to evaluate the liveness of the CDC listener
public type ListenerConfiguration record {|
    string engineName = "ballerina-cdc-connector";
    FileInternalSchemaStorage|KafkaInternalSchemaStorage internalSchemaStorage = {};
    FileOffsetStorage|KafkaOffsetStorage offsetStorage = {};
    Options options = {};
    decimal livenessInterval = 60.0;
|};
