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

# Represents snapshot isolation modes for transactions.
public enum SnapshotIsolationMode {
    SERIALIZABLE = "serializable",
    REPEATABLE_READ = "repeatable_read",
    READ_COMMITTED = "read_committed",
    READ_UNCOMMITTED = "read_uncommitted"
}

# Represents snapshot locking modes (used by MySQL, PostgreSQL, SQL Server).
public enum SnapshotLockingMode {
    EXCLUSIVE = "exclusive",
    SHARED = "shared",
    MINIMAL = "minimal",
    EXTENDED = "extended",
    NONE = "none",
    CUSTOM = "custom"
}

# Represents snapshot query modes.
public enum SnapshotQueryMode {
    SELECT_ALL = "select_all",
    CUSTOM = "custom"
}

# Represents incremental snapshot watermarking strategies.
public enum IncrementalSnapshotWatermarkingStrategy {
    INSERT_INSERT = "insert_insert",
    INSERT_DELETE = "insert_delete"
}

# Represents binary data handling modes.
public enum BinaryHandlingMode {
    BYTES = "bytes",
    BASE64 = "base64",
    BASE64_URL_SAFE = "base64-url-safe",
    HEX = "hex"
}

# Represents time precision modes.
public enum TimePrecisionMode {
    ADAPTIVE = "adaptive",
    ADAPTIVE_TIME_MICROSECONDS = "adaptive_time_microseconds",
    CONNECT = "connect",
    ISOSTRING = "isostring",
    MICROSECONDS = "microseconds",
    NANOSECONDS = "nanoseconds"
}

# Represents signal channel types.
public enum SignalChannel {
    SOURCE = "source",
    KAFKA = "kafka",
    FILE = "file",
    JMX = "jmx"
}

# Represents guardrail limit actions.
public enum GuardrailLimitAction {
    FAIL = "fail",
    WARN = "warn"
}

# Represents publication autocreate modes (PostgreSQL).
public enum PublicationAutocreateMode {
    ALL_TABLES = "all_tables",
    DISABLED = "disabled",
    FILTERED = "filtered"
}

# Represents LSN flush modes (PostgreSQL).
public enum LsnFlushMode {
    MANUAL = "manual",
    CONNECTOR = "connector",
    CONNECTOR_AND_DRIVER = "connector_and_driver"
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
    decimal recoveryPollInterval = 0.1;
    int recoveryAttempts = 10;
    decimal queryTimeout = 0.0003;
    decimal createTimeout = 0.003;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# Represents the memory-based schema history configuration.
#
# + className - The class name of the memory schema history implementation to use
public type MemoryInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.memory.history.MemorySchemaHistory";
|};

# Represents the JDBC-based schema history configuration.
#
# + className - The class name of the JDBC schema history implementation to use
# + jdbcUrl - The JDBC connection URL
# + jdbcUser - The database username
# + jdbcPassword - The database password
# + tableName - The name of the schema history table
# + tableDdl - DDL statement for creating the schema history table (optional, uses default if not provided)
# + tableSelect - SELECT query for reading schema history (optional, uses default if not provided)
# + tableInsert - INSERT query for creating new schema history entries (optional, uses default if not provided)
public type JdbcInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.jdbc.history.JdbcSchemaHistory";
    string url;
    string user?;
    string password?;
    decimal retryDelay = 3.0;
    int retryMaxAttempts = 5;
    string tableName = "debezium_database_history";
    string tableDdl?;
    string tableSelect?;
    string tableInsert?;
    string tableDelete?;
|};

# Represents the Redis-based schema history configuration.
#
# + className - The class name of the Redis schema history implementation to use
# + address - The Redis server address (host:port)
# + user - The Redis username for authentication
# + password - The Redis password for authentication
# + sslEnabled - Whether SSL/TLS is enabled
# + clusterEnabled - Whether Redis cluster mode is enabled
# + waitEnabled - Whether to wait for replication
# + waitTimeoutMs - Timeout in milliseconds for waiting for replication (only when waitEnabled is true)
# + waitRetryEnabled - Whether to retry wait operations on failure
# + waitRetryDelayMs - Delay in milliseconds between wait retries
# + retryInitialDelayMs - Initial delay in milliseconds for retry attempts
# + retryMaxDelayMs - Maximum delay in milliseconds for retry attempts
# + connectionTimeoutMs - Connection timeout in milliseconds
# + socketTimeoutMs - Socket timeout in milliseconds
public type RedisInternalSchemaStorage record {|
    // *SchemaHistoryInternal; // TODO: can we remove this?
    string className = "io.debezium.storage.redis.history.RedisSchemaHistory";
    string key = "metadata:debezium:schema_history";
    string address;
    string user?;
    string password?;
    int dbIndex = 0;
    boolean sslEnabled = false;
    boolean sslHostNameVerificationEnabled = false;
    string sslTruststorePath?; // TODO: bundle these parameters like in KafkaOffsetStorage
    string sslTruststorePassword?;
    string sslTruststoreType?;
    string sslKeystorePath?;
    string sslKeystorePassword?;
    string sslKeystoreType?;
    decimal connectionTimeout = 2.0; // TODO: check if we use the same name everywhere
    decimal socketTimeout = 2.0;
    decimal retryInitialDelay = 0.3; // TODO: do we need to nest the retry configs together?
    decimal retryMaxDelay = 10.0;
    int retryMaxAttempts = 10;
    boolean waitEnabled = false; // TODO: do we need to nest the wait configs together?
    decimal waitTimeout = 1.0;
    boolean waitRetryEnabled = false;
    decimal waitRetryDelay = 1.0;
    boolean clusterEnabled = false;
|};

# Amazon S3-based schema history storage configuration.
#
# + className - Fully-qualified class name of the S3 schema history implementation
# + accessKeyId - AWS access key ID for authentication
# + secretAccessKey - AWS secret access key for authentication
# + region - AWS region name where the S3 bucket is located
# + bucketName - Name of the S3 bucket to store schema history
# + objectName - Name of the object (file) within the S3 bucket
# + endpoint - Custom S3 endpoint URL (optional, for S3-compatible storage)
public type AmazonS3InternalSchemaStorage record {|
    string className = "io.debezium.storage.s3.history.S3SchemaHistory";
    string accessKeyId?;
    string secretAccessKey?;
    string region?;
    string bucketName;
    string objectName;
    string endpoint?;
|};

# Azure Blob Storage-based schema history storage configuration.
#
# + className - Fully-qualified class name of the Azure Blob schema history implementation
# + connectionString - Azure Storage connection string for authentication
# + accountName - Azure Storage account name
# + containerName - Name of the Azure Blob container to store schema history
# + blobName - Name of the blob (file) within the container
public type AzureBlobInternalSchemaStorage record {|
    string className = "io.debezium.storage.azure.blob.history.AzureBlobSchemaHistory";
    string connectionString;
    string accountName;
    string containerName;
    string blobName;
|};

# RocketMQ-based schema history storage configuration.
#
# + className - Fully-qualified class name of the RocketMQ schema history implementation
# + topicName - Name of the RocketMQ topic to store schema history
# + nameServerAddress - Address of the RocketMQ name server
# + aclEnabled - Whether Access Control List (ACL) authentication is enabled
# + accessKey - Access key for ACL authentication
# + secretKey - Secret key for ACL authentication
# + recoveryAttempts - Maximum number of recovery attempts when reading schema history
# + recoveryPollInterval - Interval in seconds between recovery poll attempts
# + storeRecordTimeout - Timeout in seconds for storing schema history records
public type RocketMQInternalSchemaStorage record {|
    string className = "io.debezium.storage.rocketmq.history.RocketMQSchemaHistory";
    string topicName;
    string nameServerAddress;
    boolean aclEnabled = false;
    string accessKey;
    string secretKey;
    int recoveryAttempts;
    decimal recoveryPollInterval = 0.1;
    decimal storeRecordTimeout;
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

# Represents the memory-based offset storage configuration.
#
# + className - The class name of the memory offset storage implementation to use
public type MemoryOffsetStorage record {|
    *OffsetStorage;
    string className = "org.apache.kafka.connect.storage.MemoryOffsetBackingStore";
|};

# Represents the Redis-based offset storage configuration.
#
# + className - The class name of the Redis offset storage implementation to use
# + address - The Redis server address (host:port)
# + user - The Redis username for authentication
# + password - The Redis password for authentication
# + sslEnabled - Whether SSL/TLS is enabled
# + clusterEnabled - Whether Redis cluster mode is enabled
# + waitEnabled - Whether to wait for replication
# + waitTimeoutMs - Timeout in milliseconds for waiting for replication (only when waitEnabled is true)
# + waitRetryEnabled - Whether to retry wait operations on failure
# + waitRetryDelayMs - Delay in milliseconds between wait retries
# + retryInitialDelayMs - Initial delay in milliseconds for retry attempts
# + retryMaxDelayMs - Maximum delay in milliseconds for retry attempts
# + connectionTimeoutMs - Connection timeout in milliseconds
# + socketTimeoutMs - Socket timeout in milliseconds
public type RedisOffsetStorage record {|
    *OffsetStorage;
    string className = "io.debezium.storage.redis.offset.RedisOffsetBackingStore";
    string key = "metadata:debezium:offsets";
    string address;
    string user?;
    string password?;
    int dbIndex = 0;
    boolean sslEnabled = false;
    boolean sslHostNameVerificationEnabled = false;
    string sslTruststorePath?; // TODO: bundle these parameters like in KafkaOffsetStorage
    string sslTruststorePassword?;
    string sslTruststoreType = "JKS";
    string sslKeystorePath?;
    string sslKeystorePassword?;
    string sslKeystoreType = "JKS";
    decimal connectionTimeout = 2.0; // TODO: check if we use the same name everywhere
    decimal socketTimeout = 2.0;
    decimal retryInitialDelay = 0.3; // TODO: do we need to nest the retry configs together?
    decimal retryMaxDelay = 10.0;
    int retryMaxAttempts = 10;
    boolean waitEnabled = false; // TODO: do we need to nest the wait configs together?
    decimal waitTimeout = 1.0;
    boolean waitRetryEnabled = false;
    decimal waitRetryDelay = 1.0;
    boolean clusterEnabled = false;
|};

# Represents the JDBC-based offset storage configuration.
#
# + className - The class name of the JDBC offset storage implementation to use
# + jdbcUrl - The JDBC connection URL
# + jdbcUser - The database username
# + jdbcPassword - The database password
# + tableName - The name of the offset storage table
# + tableDdl - DDL statement for creating the offset storage table (optional, uses default if not provided)
# + tableSelect - SELECT query for reading offsets (optional, uses default if not provided)
# + tableInsert - INSERT query for creating new offsets (optional, uses default if not provided)
# + tableUpdate - UPDATE query for updating existing offsets (optional, uses default if not provided)
# + tableDelete - DELETE query for removing offsets (optional, uses default if not provided)
public type JdbcOffsetStorage record {|
    *OffsetStorage;
    string className = "io.debezium.storage.jdbc.offset.JdbcOffsetBackingStore";
    string url;
    string user?;
    string password?;
    decimal retryDelay = 3.0;
    int retryMaxAttempts = 5;
    string tableName = "debezium_offset_storage";
    string tableDdl?;
    string tableSelect?;
    string tableInsert?;
    string tableDelete?;
|};

# Heartbeat configuration for maintaining connection liveness and preventing idle connection termination.
#
# + interval - Interval in seconds between heartbeat messages (0 = disabled)
# + actionQuery - Optional SQL query to execute with each heartbeat for keeping connections active
public type HeartbeatConfiguration record {|
    decimal interval = 0.0;
    string actionQuery?;
|};

# Base signal configuration for ad-hoc snapshots and runtime control operations.
#
# + enabledChannels - List of enabled signal channels (source, kafka, file, jmx)
# + dataCollection - Fully-qualified name of the database table for source-based signals
public type CommonSignalConfiguration record {|
    SignalChannel[] enabledChannels = [SOURCE];
    string dataCollection?;
|};

# Kafka-based signal configuration for ad-hoc snapshot and runtime commands.
#
# + topic - Kafka topic name for signal messages
# + bootstrapServers - Kafka bootstrap servers for signal consumer
# + groupId - Consumer group ID for reading signal messages
# + securityProtocol - Kafka security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL)
# + auth - SASL authentication configuration for Kafka signal consumer
# + secureSocket - SSL/TLS configuration for Kafka signal consumer
public type KafkaSignalConfiguration record {|
    *CommonSignalConfiguration;
    string topic?;
    string|string[] bootstrapServers?;
    string groupId?;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# File-based signal configuration for ad-hoc snapshot and runtime commands.
#
# + filePath - Path to the signal file that is monitored for changes
public type FileSignalConfiguration record {|
    *CommonSignalConfiguration;
    string filePath = "file-signals.txt";
|};

# Signal configuration supporting either file-based or Kafka-based signaling.
public type SignalConfiguration FileSignalConfiguration|KafkaSignalConfiguration;

# Incremental snapshot configuration for non-blocking snapshots with chunked processing.
#
# + chunkSize - Number of rows per incremental snapshot chunk (smaller = less memory, more overhead)
# + watermarkingStrategy - Watermarking strategy for chunk boundaries (insert_insert or insert_delete)
# + allowSchemaChanges - Whether to allow DDL schema changes during incremental snapshot
public type IncrementalSnapshotConfiguration record {|
    int chunkSize = 1024;
    IncrementalSnapshotWatermarkingStrategy watermarkingStrategy = INSERT_INSERT;
    boolean allowSchemaChanges = false;
|};

# Extended snapshot configuration for fine-tuning snapshot behavior.
#
# + delay - Delay in seconds before starting snapshot (useful for coordinating with other systems)
# + fetchSize - Number of rows to fetch per database round trip during snapshot
# + maxThreads - Maximum number of threads for parallel snapshot operations
# + includeCollectionList - Regex patterns for tables/collections to include in snapshot
# + incrementalConfig - Incremental snapshot configuration for chunked snapshots
public type ExtendedSnapshotConfiguration record {|
    decimal delay?;
    int fetchSize?;
    int maxThreads = 1;
    string|string[] includeCollectionList?;
    IncrementalSnapshotConfiguration incrementalConfig?;
|};

# Extended snapshot configuration for relational databases with transaction control.
#
# + isolationMode - Transaction isolation level during snapshots (serializable, repeatable_read, etc.)
# + lockingMode - Table locking strategy during snapshots (exclusive, shared, minimal, none)
# + selectStatementOverrides - Custom SELECT statements per table for filtering snapshot data
# + queryMode - Query strategy for snapshots (select_all or custom)
public type RelationalExtendedSnapshotConfiguration record {|
    *ExtendedSnapshotConfiguration;
    SnapshotIsolationMode isolationMode?;
    SnapshotLockingMode lockingMode?;
    string|string[] selectStatementOverrides?;
    SnapshotQueryMode queryMode?;
|};

# Transaction metadata configuration for tracking transaction boundaries in change events.
#
# + enabled - Whether to emit BEGIN/END transaction events and add transaction IDs to change events
# + topic - Topic name suffix for transaction metadata events (full topic: <prefix>.<topic>)
public type TransactionMetadataConfiguration record {|
    boolean enabled = false;
    string topic = "transaction";
|};

# Column hash mask configuration for irreversibly hashing sensitive column values.
#
# + algorithm - Hash algorithm to use (e.g., SHA-256, MD5)
# + salt - Optional salt value to add to the hash for additional security
# + regexPatterns - Regex patterns matching fully-qualified column names to hash
public type ColumnHashMask record {|
    string algorithm;
    string salt?;
    string|string[] regexPatterns;
|};

# Column character mask configuration for replacing column values with asterisks.
#
# + length - Number of asterisk characters to use as replacement
# + regexPatterns - Regex patterns matching fully-qualified column names to mask
public type ColumnCharMask record {|
    int length;
    string|string[] regexPatterns;
|};

# Column truncation configuration for limiting string column length.
#
# + length - Maximum character length to truncate strings to
# + regexPatterns - Regex patterns matching fully-qualified column names to truncate
public type ColumnTruncate record {|
    int length;
    string|string[] regexPatterns;
|};

# Column transformation configuration for masking and redacting sensitive data.
#
# + maskWithHash - Hash-based masking for irreversible obfuscation of column values
# + maskWithChars - Character-based masking for replacing values with asterisks
# + truncateToChars - Truncation for limiting string column lengths
public type ColumnTransformConfiguration record {|
    ColumnHashMask[] maskWithHash?;
    ColumnCharMask[] maskWithChars?;
    ColumnTruncate[] truncateToChars?;
|};

# Topic naming configuration for controlling logical identifiers in change events.
#
# + prefix - Logical server name prefix for all topic names (typically database server name)
# + delimiter - Delimiter between topic name components (default: ".")
# + namingStrategy - Fully-qualified class name of custom topic naming strategy implementation
public type TopicConfiguration record {|
    string prefix?;
    string delimiter = ".";
    string namingStrategy = "io.debezium.schema.SchemaTopicNamingStrategy";
|};

# Data type handling configuration for binary and temporal value representation.
#
# + binaryHandlingMode - How to encode binary column data (bytes, base64, hex)
# + timePrecisionMode - How to represent temporal values (adaptive, connect, microseconds, etc.)
# + includeSchemaChanges - Whether to include schema change events
public type DataTypeConfiguration record {
    BinaryHandlingMode binaryHandlingMode = BYTES;
    TimePrecisionMode timePrecisionMode = ADAPTIVE;
};

# Error handling configuration for connector failure and recovery behavior.
#
# + maxRetries - Maximum retry attempts for retriable errors (-1 = unlimited, 0 = no retries)
# + retriableRestartWait - Wait time in seconds before restarting connector after retriable error
# + tombstonesOnDelete - Whether to emit tombstone (null value) events after delete events
public type ErrorHandlingConfiguration record {|
    int maxRetries = -1;
    decimal retriableRestartWait = 10.0;
    boolean tombstonesOnDelete = true;
|};

# Performance tuning configuration for throughput and resource optimization.
#
# + maxQueueSizeInBytes - Maximum queue size in bytes for memory-based backpressure (0 = unlimited)
# + pollInterval - Interval in seconds between polling database for new change events
# + queryFetchSize - Number of rows to fetch per database round trip (balances memory vs network)
public type PerformanceConfiguration record {|
    int maxQueueSizeInBytes = 0;
    decimal pollInterval = 0.5;
    int queryFetchSize?;
|};

# Monitoring configuration for custom MBean object name tags.
#
# + customMetricTags - Key-value pairs for custom metric tags (format: key1=value1,key2=value2)
public type MonitoringConfiguration record {|
    string customMetricTags?;
|};

# Guardrail configuration for preventing accidental capture of too many tables.
#
# + maxCollections - Maximum number of tables/collections to capture (0 = unlimited)
# + limitAction - Action when limit exceeded (fail or warn)
public type GuardrailConfiguration record {|
    int maxCollections = 0;
    GuardrailLimitAction limitAction = WARN;
|};

# Base database connection configuration for all CDC connectors.
#
# + connectorClass - Fully-qualified class name of the Debezium connector implementation
# + hostname - Database server hostname or IP address
# + port - Database server port number
# + username - Database username for authentication
# + password - Database password for authentication
# + connectTimeout - Connection timeout in seconds
# + tasksMax - Maximum number of connector tasks (most connectors use single task)
# + secure - SSL/TLS secure connection configuration
# + includedTables - Regex patterns for tables to capture (mutually exclusive with excludedTables)
# + excludedTables - Regex patterns for tables to exclude (mutually exclusive with includedTables)
# + includedColumns - Regex patterns for columns to capture (mutually exclusive with excludedColumns)
# + excludedColumns - Regex patterns for columns to exclude (mutually exclusive with includedColumns)
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

# Common CDC options for all database connectors (generic configuration).
#
# + snapshotMode - Snapshot capture mode (initial, always, when_needed, etc.)
# + eventProcessingFailureHandlingMode - How to handle event processing failures (fail, warn, skip)
# + skippedOperations - List of database operations to skip (e.g., truncate)
# + skipMessagesWithoutChange - Whether to skip events without actual data changes
# + decimalHandlingMode - How to represent decimal values (precise, double, string)
# + maxQueueSize - Maximum number of events in internal queue (backpressure control)
# + maxBatchSize - Maximum number of events per batch
# + queryTimeout - Database query timeout in seconds (0 = no timeout)
# + heartbeat - Heartbeat configuration for connection keep-alive
# + signal - Signal configuration for ad-hoc snapshots and control operations
# + transactionMetadata - Transaction boundary event configuration
# + columnTransform - Column masking and transformation configuration
# + topicConfig - Topic naming and routing configuration
# + errorHandling - Error handling and retry configuration
# + performance - Performance tuning configuration
# + monitoring - Monitoring configuration
# + guardrail - Guardrail configuration
# + additionalProperties - Additional Debezium connector properties not explicitly mapped (passed through as-is)
public type Options record {
    SnapshotMode snapshotMode = INITIAL;
    EventProcessingFailureHandlingMode eventProcessingFailureHandlingMode = WARN;
    Operation[] skippedOperations = [TRUNCATE];
    boolean skipMessagesWithoutChange = false;
    DecimalHandlingMode decimalHandlingMode = DOUBLE;
    int maxQueueSize = 8192;
    int maxBatchSize = 2048;
    decimal queryTimeout = 60;
    HeartbeatConfiguration heartbeat?;
    SignalConfiguration signal?;
    TransactionMetadataConfiguration transactionMetadata?;
    ColumnTransformConfiguration columnTransform?;
    TopicConfiguration topicConfig?;
    ErrorHandlingConfiguration errorHandling?;
    PerformanceConfiguration performance?;
    MonitoringConfiguration monitoring?;
    GuardrailConfiguration guardrail?;
    map<string|int|boolean|decimal> additionalProperties?;
};

# Represents the base configuration for the CDC engine.
#
# + engineName - The name of the CDC engine
# + internalSchemaStorage - The internal schema history configuration
# + offsetStorage - The offset storage configuration
# + livenessInterval - Time interval (in seconds) used to evaluate the liveness of the CDC listener
public type ListenerConfiguration record {|
    string engineName = "ballerina-cdc-connector";
    FileInternalSchemaStorage|KafkaInternalSchemaStorage|MemoryInternalSchemaStorage|JdbcInternalSchemaStorage|RedisInternalSchemaStorage|AmazonS3InternalSchemaStorage|AzureBlobInternalSchemaStorage|RocketMQInternalSchemaStorage internalSchemaStorage = <FileInternalSchemaStorage>{};
    FileOffsetStorage|KafkaOffsetStorage|MemoryOffsetStorage|JdbcOffsetStorage|RedisOffsetStorage offsetStorage = <FileOffsetStorage>{};
    decimal livenessInterval = 60.0;
|};
