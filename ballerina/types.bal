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

public type AmazonS3InternalSchemaStorage record {|
    // *SchemaHistoryInternal;
    string className = "io.debezium.storage.s3.history.S3SchemaHistory";
    string accessKeyId?;
    string secretAcessKey?;
    string region?;
    string bucketName;
    string objectName;
    string Endpoint?;
|};

public type AzureBlobInternalSchemaStorage record {|
    // *SchemaHistoryInternal;
    string className = "io.debezium.storage.azure.blob.history.AzureBlobSchemaHistory";
    string connectionString;
    string accountName;
    string containerName;
    string blobName;
|};

public type RocketMQInternalSchemaStorage record {|
    // *SchemaHistoryInternal;
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

# Represents heartbeat configuration for maintaining connection liveness.
#
# + intervalMs - The interval in seconds between heartbeat messages (0 = disabled)
# + actionQuery - Optional SQL query to execute with each heartbeat
public type HeartbeatConfiguration record {|
    decimal interval = 0.0;
    string actionQuery?;
|};

# Represents signal configuration for control operations.
#
# + enabledChannels - The list of enabled signal channels
# + dataCollection - The data collection (table) for source signals
public type CommonSignalConfiguration record {|
    SignalChannel[] enabledChannels = [SOURCE];
    string dataCollection?;
|};

# Represents Kafka signal configuration.
#
# + topic - The Kafka topic name for signals
# + bootstrapServers - The Kafka bootstrap servers
# + groupId - The consumer group ID
# + consumerProperties - Additional Kafka consumer properties
public type KafkaSignalConfiguration record {|
    *CommonSignalConfiguration;
    string topic?;
    string|string[] bootstrapServers?;
    string groupId?;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# Represents file signal configuration.
#
# + filePath - The path to the signal file
public type FileSignalConfiguration record {|
    *CommonSignalConfiguration;
    string filePath = "file-signals.txt";
|};

public type SignalConfiguration FileSignalConfiguration|KafkaSignalConfiguration;

# Represents incremental snapshot configuration.
#
# + chunkSize - The maximum number of rows per chunk
# + watermarkingStrategy - The watermarking strategy to use
# + allowSchemaChanges - Whether to allow schema changes during snapshots
public type IncrementalSnapshotConfiguration record {|
    int chunkSize = 1024;
    IncrementalSnapshotWatermarkingStrategy watermarkingStrategy = INSERT_INSERT;
    boolean allowSchemaChanges = false;
|};

# Represents extended snapshot configuration.
#
# + delay - Delay in seconds before starting snapshot
# + fetchSize - The number of rows to fetch in each batch
# + maxThreads - Maximum number of threads for parallel snapshots
# + includeCollectionList - List of collections to include in snapshot
# + incrementalConfig - Incremental snapshot configuration
public type ExtendedSnapshotConfiguration record {
    decimal delay?;
    int fetchSize?;
    int maxThreads = 1;
    string|string[] includeCollectionList?;
    IncrementalSnapshotConfiguration incrementalConfig?;
};

# Represents extended snapshot configuration for relational databases.
# 
# + isolationMode - The transaction isolation mode for snapshots
# + lockingMode - The locking mode for snapshots
# + selectStatementOverrides - Custom SELECT statements for specific tables
# + queryMode - The query mode for snapshots
public type RelationalExtendedSnapshotConfiguration record {|
    *ExtendedSnapshotConfiguration;
    SnapshotIsolationMode isolationMode?;
    SnapshotLockingMode lockingMode?;
    string|string[] selectStatementOverrides?;
    SnapshotQueryMode queryMode?;
|};

# Represents transaction metadata configuration.
#
# + enabled - Whether transaction metadata is enabled
# + topic - The topic name for transaction metadata
public type TransactionMetadataConfiguration record {|
    boolean enabled = false;
    string topic = "transaction";
|};

# Represents column hash mask configuration.
#
# + algorithm - The hash algorithm to use
# + columns - The columns to apply the hash mask to
# + salt - Optional salt for hashing
public type ColumnHashMask record {|
    string algorithm;
    string salt?;
    string|string[] regexPatterns;
|};

public type ColumnCharMask record {|
    int length;
    string|string[] regexPatterns;
|};

public type ColumnTruncate record {|
    int length;
    string|string[] regexPatterns;
|};

# Represents column transformation configuration.
#
# + maskWithHash - Hash-based masking configurations
# + maskWithChars - Character-based masking (column -> replacement chars)
# + truncateToChars - Truncation configurations (column -> max length)
public type ColumnTransformConfiguration record {|
    ColumnHashMask[] maskWithHash?;
    ColumnCharMask[] maskWithChars?;
    ColumnTruncate[] truncateToChars?;
|};

# Represents topic naming configuration.
#
# + prefix - The topic prefix
# + delimiter - The delimiter character between prefix and table name
# + namingStrategy - The fully-qualified class name of the topic naming strategy
public type TopicConfiguration record {|
    string prefix?;
    string delimiter = ".";
    string namingStrategy = "io.debezium.schema.SchemaTopicNamingStrategy";
|};

# Represents data type handling configuration.
#
# + binaryHandlingMode - How to encode binary data
# + timePrecisionMode - How to represent time values
# + includeSchemaChanges - Whether to include schema change events
public type DataTypeConfiguration record {
    BinaryHandlingMode binaryHandlingMode = BYTES;
    TimePrecisionMode timePrecisionMode = ADAPTIVE;
};

# Represents error handling configuration.
#
# + maxRetries - Maximum number of retries for errors (-1 = infinite)
# + retriableRestartWait - Wait time before retrying in seconds
# + tombstonesOnDelete - Whether to emit tombstone events on delete
public type ErrorHandlingConfiguration record {|
    int maxRetries = -1;
    decimal retriableRestartWait = 10.0;
    boolean tombstonesOnDelete = true;
|};

# Represents performance tuning configuration.
#
# + maxQueueSizeInBytes - Maximum queue size in bytes (0 = use record count)
# + pollInterval - Polling interval in seconds
# + queryFetchSize - Number of rows to fetch per query
public type PerformanceConfiguration record {|
    int maxQueueSizeInBytes = 0;
    decimal pollInterval = 0.5;
    int queryFetchSize?;
|};

# Represents monitoring configuration.
#
# + customMetricTags - Custom tags for metrics
public type MonitoringConfiguration record {|
    string customMetricTags?;
|};

# Represents guardrail configuration.
#
# + maxCollections - Maximum number of collections to monitor (0 = unlimited)
# + limitAction - Action to take when limit is reached
public type GuardrailConfiguration record {|
    int maxCollections = 0;
    GuardrailLimitAction limitAction = WARN;
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
# + heartbeat - Heartbeat configuration
# + signal - Signal configuration
# + transactionMetadata - Transaction metadata configuration
# + columnTransform - Column transformation configuration
# + topicConfig - Topic naming configuration
# + errorHandling - Error handling configuration
# + performance - Performance tuning configuration
# + monitoring - Monitoring configuration
# + guardrail - Guardrail configuration
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
