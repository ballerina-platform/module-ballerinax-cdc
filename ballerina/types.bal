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
# + ALWAYS - Take a snapshot on every connector startup.
# + INITIAL - Take a snapshot only on initial startup, then stream changes.
# + INITIAL_ONLY - Take a snapshot on initial startup, then stop.
# + NO_DATA - Snapshot the schema only, without emitting READ events for existing rows.
# + RECOVERY - Take a snapshot to restore lost schema history.
# + WHEN_NEEDED - Take a snapshot only when offsets are missing or invalid.
# + CONFIGURATION_BASED - Take a snapshot controlled by configuration properties.
# + CUSTOM - Take a snapshot using a custom implementation.
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

# SSL/TLS configuration for database connections.
#
# + sslMode - SSL mode controlling the connection security level
# + keyStore - Client keystore for mutual TLS authentication
# + trustStore - Truststore for verifying the server certificate
public type SecureDatabaseConnection record {|
    SslMode sslMode = PREFERRED;
    crypto:KeyStore keyStore?;
    crypto:TrustStore trustStore?;
|};

# SSL/TLS configuration for secure Redis connections.
# The presence of this configuration indicates that SSL is enabled for the Redis connection.
#
# + cert - Truststore configuration or certificate file path for server verification
# + key - Keystore configuration for client certificate authentication (mTLS)
# + verifyHostName - Whether to verify the Redis server's hostname against the certificate
public type RedisSecureSocket record {|
    crypto:TrustStore|string cert?;
    crypto:KeyStore key?;
    boolean verifyHostName = false;
|};

# Retry configuration for Redis connections.
#
# + initialDelay - Initial delay in seconds before the first retry
# + maxDelay - Maximum delay in seconds between retries
# + maxAttempts - Maximum number of retry attempts
public type RedisRetryConfig record {|
    decimal initialDelay = 0.3;
    decimal maxDelay = 10.0;
    int maxAttempts = 10;
|};

# Wait configuration for Redis replication acknowledgement.
#
# + enabled - Whether to wait for replication acknowledgement
# + timeout - Timeout in seconds for replication wait
# + retryEnabled - Whether to retry after a failed replication wait
# + retryDelay - Delay in seconds between replication wait retries
public type RedisWaitConfig record {|
    boolean enabled = false;
    decimal timeout = 1.0;
    boolean retryEnabled = false;
    decimal retryDelay = 1.0;
|};

# Represents the internal schema history configuration.
#
# + className - Fully-qualified class name of the schema history implementation
# + topicPrefix - Prefix for topic names used in Kafka-based schema history
type SchemaHistoryInternal record {|
    string className;
    string topicPrefix = "bal_cdc_schema_history";
|};

# File-based schema history storage configuration.
#
# + className - Fully-qualified class name of the file schema history implementation
# + fileName - Path to the schema history file
public type FileInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.file.history.FileSchemaHistory";
    string fileName = "tmp/dbhistory.dat";
|};

# Kafka-based schema history storage configuration.
#
# + className - Fully-qualified class name of the Kafka schema history implementation
# + topicName - Kafka topic for storing schema history
# + bootstrapServers - Kafka bootstrap servers
# + recoveryPollInterval - Interval in seconds between recovery polls
# + recoveryAttempts - Maximum poll attempts during schema history recovery
# + queryTimeout - Timeout in seconds for Kafka queries
# + createTimeout - Timeout in seconds for topic creation
# + securityProtocol - Kafka security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL)
# + auth - SASL authentication credentials; required for SASL_PLAINTEXT and SASL_SSL
# + secureSocket - SSL/TLS configuration with truststore and optional keystore for mTLS
public type KafkaInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.kafka.history.KafkaSchemaHistory";
    string topicName = "bal_cdc_internal_schema_history";
    string|string[] bootstrapServers;
    decimal recoveryPollInterval = 0.1;
    int recoveryAttempts = 100;
    decimal queryTimeout = 0.003;
    decimal createTimeout = 0.03;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# In-memory schema history storage configuration (data is lost on restart).
#
# + className - Fully-qualified class name of the memory schema history implementation
public type MemoryInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.relational.history.MemorySchemaHistory";
|};

# JDBC-based schema history storage configuration.
#
# + className - Fully-qualified class name of the JDBC schema history implementation
# + url - JDBC connection URL
# + username - Database username
# + password - Database password
# + retryDelay - Delay in seconds between connection retry attempts
# + retryMaxAttempts - Maximum connection retry attempts
# + tableName - Schema history table name
# + tableDdl - DDL for creating the schema history table
# + tableSelect - SELECT query for reading schema history
# + tableInsert - INSERT query for writing schema history entries
# + tableDelete - DELETE query for removing schema history entries
public type JdbcInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.jdbc.history.JdbcSchemaHistory";
    string url;
    string username?;
    string password?;
    decimal retryDelay = 3.0;
    int retryMaxAttempts = 5;
    string tableName = "debezium_database_history";
    string tableDdl?;
    string tableSelect?;
    string tableInsert?;
    string tableDelete?;
|};

# Redis-based schema history storage configuration.
#
# + className - Fully-qualified class name of the Redis schema history implementation
# + key - Redis key for storing the schema history
# + address - Redis server address (host:port)
# + username - Redis username for authentication
# + password - Redis password for authentication
# + dbIndex - Redis database index
# + secureSocket - SSL/TLS configuration; if present, SSL is enabled for the connection
# + connectTimeout - Connection timeout in seconds
# + socketTimeout - Socket read/write timeout in seconds
# + retryConfig - Retry configuration for Redis connection attempts
# + waitConfig - Wait configuration for Redis replication acknowledgement
# + clusterEnabled - Whether Redis cluster mode is enabled
public type RedisInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.redis.history.RedisSchemaHistory";
    string key = "metadata:debezium:schema_history";
    string address;
    string username?;
    string password?;
    int dbIndex = 0;
    RedisSecureSocket secureSocket?;
    decimal connectTimeout = 2.0;
    decimal socketTimeout = 2.0;
    RedisRetryConfig retryConfig = {};
    RedisWaitConfig waitConfig = {};
    boolean clusterEnabled = false;
|};

# Amazon S3-based schema history storage configuration.
#
# + className - Fully-qualified class name of the S3 schema history implementation
# + accessKeyId - AWS access key ID for authentication
# + secretAccessKey - AWS secret access key for authentication
# + region - AWS region of the S3 bucket
# + bucketName - S3 bucket name for schema history
# + objectName - S3 object (file) name within the bucket
# + endpoint - Custom S3-compatible endpoint URL; uses the AWS endpoint if not set
public type AmazonS3InternalSchemaStorage record {|
    *SchemaHistoryInternal;
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
# + connectionString - Azure Storage connection string
# + accountName - Azure Storage account name
# + containerName - Azure Blob container name for schema history
# + blobName - Blob (file) name within the container
public type AzureBlobInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.azure.blob.history.AzureBlobSchemaHistory";
    string connectionString;
    string accountName;
    string containerName;
    string blobName;
|};

# RocketMQ-based schema history storage configuration.
#
# + className - Fully-qualified class name of the RocketMQ schema history implementation
# + topicName - RocketMQ topic for schema history
# + nameServerAddress - RocketMQ name server address
# + aclEnabled - Whether ACL authentication is enabled
# + accessKey - Access key for ACL authentication
# + secretKey - Secret key for ACL authentication
# + recoveryAttempts - Maximum recovery attempts when reading schema history
# + recoveryPollInterval - Interval in seconds between recovery poll attempts
# + storeRecordTimeout - Timeout in seconds for storing schema history records
public type RocketMQInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.rocketmq.history.RocketMqSchemaHistory";
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
# + flushInterval - Interval in seconds between offset flushes
# + flushTimeout - Timeout in seconds for an offset flush operation
type OffsetStorageInternal record {|
    decimal flushInterval = 60;
    decimal flushTimeout = 5;
|};

# File-based offset storage configuration.
#
# + className - Fully-qualified class name of the file offset storage implementation
# + fileName - Path to the offset storage file
public type FileOffsetStorage record {|
    *OffsetStorageInternal;
    string className = "org.apache.kafka.connect.storage.FileOffsetBackingStore";
    string fileName = "tmp/debezium-offsets.dat";
|};

# Kafka-based offset storage configuration.
#
# + className - Fully-qualified class name of the Kafka offset storage implementation
# + bootstrapServers - Kafka bootstrap servers
# + topicName - Kafka topic for storing offsets
# + partitions - Number of partitions for the offset topic
# + replicationFactor - Replication factor for the offset topic
# + securityProtocol - Kafka security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL)
# + auth - SASL authentication credentials; required for SASL_PLAINTEXT and SASL_SSL
# + secureSocket - SSL/TLS configuration with truststore and optional keystore for mTLS
public type KafkaOffsetStorage record {|
    *OffsetStorageInternal;
    string className = "org.apache.kafka.connect.storage.KafkaOffsetBackingStore";
    string|string[] bootstrapServers;
    string topicName = "bal_cdc_offsets";
    int partitions = 1;
    int replicationFactor = 2;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# In-memory offset storage configuration (data is lost on restart).
#
# + className - Fully-qualified class name of the memory offset storage implementation
public type MemoryOffsetStorage record {|
    *OffsetStorageInternal;
    string className = "org.apache.kafka.connect.storage.MemoryOffsetBackingStore";
|};

# Redis-based offset storage configuration.
#
# + className - Fully-qualified class name of the Redis offset storage implementation
# + key - Redis key for storing offsets
# + address - Redis server address (host:port)
# + username - Redis username for authentication
# + password - Redis password for authentication
# + dbIndex - Redis database index
# + secureSocket - SSL/TLS configuration; if present, SSL is enabled for the connection
# + connectTimeout - Connection timeout in seconds
# + socketTimeout - Socket read/write timeout in seconds
# + retryConfig - Retry configuration for Redis connection attempts
# + waitConfig - Wait configuration for Redis replication acknowledgement
# + clusterEnabled - Whether Redis cluster mode is enabled
public type RedisOffsetStorage record {|
    *OffsetStorageInternal;
    string className = "io.debezium.storage.redis.offset.RedisOffsetBackingStore";
    string key = "metadata:debezium:offsets";
    string address;
    string username?;
    string password?;
    int dbIndex = 0;
    RedisSecureSocket secureSocket?;
    decimal connectTimeout = 2.0;
    decimal socketTimeout = 2.0;
    RedisRetryConfig retryConfig = {};
    RedisWaitConfig waitConfig = {};
    boolean clusterEnabled = false;
|};

# JDBC-based offset storage configuration.
#
# + className - Fully-qualified class name of the JDBC offset storage implementation
# + url - JDBC connection URL
# + username - Database username
# + password - Database password
# + retryDelay - Delay in seconds between connection retry attempts
# + retryMaxAttempts - Maximum connection retry attempts
# + tableName - Offset storage table name
# + tableDdl - DDL for creating the offset storage table
# + tableSelect - SELECT query for reading offsets
# + tableInsert - INSERT query for creating new offsets
# + tableDelete - DELETE query for removing offsets
public type JdbcOffsetStorage record {|
    *OffsetStorageInternal;
    string className = "io.debezium.storage.jdbc.offset.JdbcOffsetBackingStore";
    string url;
    string username?;
    string password?;
    decimal retryDelay = 3.0;
    int retryMaxAttempts = 5;
    string tableName = "debezium_offset_storage";
    string tableDdl?;
    string tableSelect?;
    string tableInsert?;
    string tableDelete?;
|};

# Heartbeat configuration for detecting idle or stale connections.
#
# + interval - Interval in seconds between heartbeats (0 = disabled)
# + actionQuery - SQL query executed with each heartbeat to keep the connection active
public type HeartbeatConfiguration record {|
    decimal interval = 0.0;
    string actionQuery?;
|};

# Base signal configuration for ad-hoc snapshots and runtime control.
#
# + enabledChannels - Signal channels to enable (source, kafka, file, jmx)
# + dataCollection - Fully-qualified table name for source-based signals
public type CommonSignalConfiguration record {|
    SignalChannel[] enabledChannels = [SOURCE];
    string dataCollection?;
|};

# Kafka-based signal configuration.
#
# + topicName - Kafka topic for signal messages
# + bootstrapServers - Kafka bootstrap servers for the signal consumer
# + groupId - Consumer group ID for reading signal messages
# + securityProtocol - Kafka security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL)
# + auth - SASL authentication configuration for the signal consumer
# + secureSocket - SSL/TLS configuration for the signal consumer
public type KafkaSignalConfiguration record {|
    *CommonSignalConfiguration;
    string topicName?;
    string|string[] bootstrapServers?;
    string groupId?;
    kafka:SecurityProtocol securityProtocol = kafka:PROTOCOL_PLAINTEXT;
    kafka:AuthenticationConfiguration auth?;
    kafka:SecureSocket secureSocket?;
|};

# File-based signal configuration.
#
# + fileName - Path to the signal file monitored for changes
public type FileSignalConfiguration record {|
    *CommonSignalConfiguration;
    string fileName = "file-signals.txt";
|};

# Signal configuration supporting either file-based or Kafka-based signaling.
public type SignalConfiguration FileSignalConfiguration|KafkaSignalConfiguration;

# Incremental (non-blocking) snapshot configuration.
#
# + chunkSize - Number of rows per snapshot chunk
# + watermarkingStrategy - Strategy for marking chunk boundaries
# + allowSchemaChanges - Whether DDL changes are allowed during incremental snapshot
public type IncrementalSnapshotConfiguration record {|
    int chunkSize = 1024;
    IncrementalSnapshotWatermarkingStrategy watermarkingStrategy = INSERT_INSERT;
    boolean allowSchemaChanges = false;
|};

# Extended snapshot configuration for fine-tuning snapshot behavior.
#
# + delay - Delay in seconds before starting the snapshot
# + fetchSize - Number of rows fetched per database round trip during snapshot
# + maxThreads - Maximum threads for parallel snapshot operations
# + includeCollectionList - Regex patterns for tables/collections to include in the snapshot
# + incrementalConfig - Incremental snapshot configuration
public type ExtendedSnapshotConfiguration record {
    decimal delay?;
    int fetchSize?;
    int maxThreads = 1;
    string|string[] includeCollectionList?;
    IncrementalSnapshotConfiguration incrementalConfig?;
};

# Extended snapshot configuration for relational databases.
#
# + isolationMode - Transaction isolation level during snapshot
# + lockingMode - Table locking strategy during snapshot
# + selectStatementOverrides - Custom SELECT statements per table for filtering snapshot data
# + queryMode - Query strategy for snapshot execution
public type RelationalExtendedSnapshotConfiguration record {|
    *ExtendedSnapshotConfiguration;
    SnapshotIsolationMode isolationMode?;
    SnapshotLockingMode lockingMode?;
    string|string[] selectStatementOverrides?;
    SnapshotQueryMode queryMode?;
|};

# Transaction boundary event configuration.
#
# + enabled - Whether to emit BEGIN/END transaction events with transaction IDs on change events
# + topicName - Topic name suffix for transaction metadata events (full topic: `<prefix>.<topicName>`)
public type TransactionMetadataConfiguration record {|
    boolean enabled = false;
    string topicName = "transaction";
|};

# Hash-based column masking configuration for irreversibly hashing sensitive column values.
#
# + algorithm - Hash algorithm (e.g., SHA-256, MD5)
# + salt - Salt added to the hash for extra security
# + regexPatterns - Fully-qualified column name patterns to hash
public type ColumnHashMask record {|
    string algorithm;
    string salt;
    string|string[] regexPatterns;
|};

# Character-based column masking configuration.
#
# + length - Number of mask characters replacing the original value
# + regexPatterns - Fully-qualified column name patterns to mask
public type ColumnCharMask record {|
    int length;
    string|string[] regexPatterns;
|};

# Column truncation configuration.
#
# + length - Maximum character length after truncation
# + regexPatterns - Fully-qualified column name patterns to truncate
public type ColumnTruncate record {|
    int length;
    string|string[] regexPatterns;
|};

# Column masking and transformation configuration.
#
# + maskWithHash - Hash-based masking for irreversible column value hashing
# + maskWithChars - Character-based masking with a fixed-length replacement string
# + truncateToChars - Truncation to a fixed string length
public type ColumnTransformConfiguration record {|
    ColumnHashMask[] maskWithHash?;
    ColumnCharMask[] maskWithChars?;
    ColumnTruncate[] truncateToChars?;
|};

# Topic naming configuration for change event topics.
#
# + delimiter - Delimiter between topic name components
# + namingStrategy - Fully-qualified class name of a custom topic naming strategy
public type TopicConfiguration record {|
    string delimiter = ".";
    string namingStrategy = "io.debezium.schema.SchemaTopicNamingStrategy";
|};

# Data type handling configuration.
#
# + binaryHandlingMode - Encoding mode for binary column data (bytes, base64, hex)
# + timePrecisionMode - Representation mode for temporal values
public type DataTypeConfiguration record {
    BinaryHandlingMode binaryHandlingMode = BYTES;
    TimePrecisionMode timePrecisionMode = ADAPTIVE;
};

# Error handling configuration for connector failure and recovery behavior.
#
# + maxRetryAttempts - Maximum retry attempts for retriable errors (-1 = unlimited, 0 = disabled)
# + retriableRestartWait - Wait time in seconds before restarting after a retriable error
# + tombstonesOnDelete - Whether to emit tombstone events after delete events
public type ErrorHandlingConfiguration record {|
    int maxRetryAttempts = -1;
    decimal retriableRestartWait = 10.0;
    boolean tombstonesOnDelete = true;
|};

# Performance tuning configuration.
#
# + maxQueueSizeInBytes - Maximum queue size in bytes for memory-based backpressure (0 = unlimited)
# + pollInterval - Interval in seconds between database polls for new events
# + queryFetchSize - Number of rows fetched per database round trip
public type PerformanceConfiguration record {|
    int maxQueueSizeInBytes = 0;
    decimal pollInterval = 0.5;
    int queryFetchSize?;
|};

# Monitoring configuration for custom metric tags.
#
# + customMetricTags - Custom metric tag pairs in `key=value` format (comma-separated)
public type MonitoringConfiguration record {|
    string customMetricTags?;
|};

# Guardrail configuration to prevent accidentally capturing too many tables.
#
# + maxCollections - Maximum number of tables/collections to capture (0 = unlimited)
# + limitAction - Action taken when the limit is exceeded (fail or warn)
public type GuardrailConfiguration record {|
    int maxCollections = 0;
    GuardrailLimitAction limitAction = WARN;
|};

# Base database connection configuration for all CDC connectors.
#
# + connectorClass - Fully-qualified class name of the Debezium connector
# + hostname - Database server hostname or IP address
# + port - Database server port number
# + username - Database username for authentication
# + password - Database password for authentication
# + connectTimeout - Connection timeout in seconds
# + tasksMax - Maximum number of connector tasks
# + secure - SSL/TLS connection configuration
# + includedTables - Regex patterns for tables to capture (mutually exclusive with `excludedTables`)
# + excludedTables - Regex patterns for tables to exclude (mutually exclusive with `includedTables`)
# + includedColumns - Regex patterns for columns to capture (mutually exclusive with `excludedColumns`)
# + excludedColumns - Regex patterns for columns to exclude (mutually exclusive with `includedColumns`)
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

# Common CDC options applicable to all database connectors.
#
# + snapshotMode - Initial snapshot behavior (initial, always, no_data, etc.)
# + eventProcessingFailureHandlingMode - How to handle event processing failures
# + skippedOperations - Database operations to skip publishing
# + skipMessagesWithoutChange - Whether to discard events with no data changes
# + decimalHandlingMode - Representation mode for decimal values
# + maxQueueSize - Maximum number of events in the internal queue
# + maxBatchSize - Maximum number of events per processing batch
# + queryTimeout - Database query timeout in seconds
# + heartbeat - Heartbeat configuration for connection liveness
# + signal - Signal channel configuration for ad-hoc control
# + transactionMetadata - Transaction boundary event configuration
# + columnTransform - Column masking and transformation configuration
# + topicConfig - Topic naming and routing configuration
# + errorHandling - Error handling and retry configuration
# + performance - Performance tuning configuration
# + monitoring - Monitoring and metric configuration
# + guardrail - Guardrail configuration to prevent over-capture
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

# Union type representing all supported internal schema history storage configurations.
public type InternalSchemaStorage FileInternalSchemaStorage|KafkaInternalSchemaStorage|MemoryInternalSchemaStorage|JdbcInternalSchemaStorage|RedisInternalSchemaStorage|AmazonS3InternalSchemaStorage|AzureBlobInternalSchemaStorage|RocketMQInternalSchemaStorage;

# Union type representing all supported offset storage configurations.
public type OffsetStorage FileOffsetStorage|KafkaOffsetStorage|MemoryOffsetStorage|JdbcOffsetStorage|RedisOffsetStorage;

# Base CDC listener configuration.
#
# + engineName - Debezium engine instance name
# + internalSchemaStorage - Schema history storage configuration
# + offsetStorage - Offset storage configuration
# + livenessInterval - Interval in seconds for checking CDC listener liveness
public type ListenerConfiguration record {
    string engineName = "ballerina-cdc-connector";
    InternalSchemaStorage internalSchemaStorage = <FileInternalSchemaStorage>{};
    OffsetStorage offsetStorage = <FileOffsetStorage>{};
    decimal livenessInterval = 60.0;
};
