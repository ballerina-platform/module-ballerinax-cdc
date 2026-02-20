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
import ballerina/io;
import ballerina/log;
import ballerinax/kafka;

const string NAME = "name";
const string CONNECTOR_CLASS = "connector.class";
const string TASKS_MAX = "tasks.max";
const string MAX_QUEUE_SIZE = "max.queue.size";
const string MAX_BATCH_SIZE = "max.batch.size";
const string EVENT_PROCESSING_FAILURE_HANDLING_MODE = "event.processing.failure.handling.mode";
const string SNAPSHOT_MODE = "snapshot.mode";
const string SKIPPED_OPERATIONS = "skipped.operations";
const string SKIP_MESSAGES_WITHOUT_CHANGE = "skip.messages.without.change";
const string DATABASE_HOSTNAME = "database.hostname";
const string DATABASE_PORT = "database.port";
const string DATABASE_USER = "database.user";
const string DATABASE_PASSWORD = "database.password";
const string DATABASE_QUERY_TIMEOUTS_MS = "database.query.timeout.ms";
const string DECIMAL_HANDLING_MODE = "decimal.handling.mode";
const string CONNECT_TIMEOUT_MS = "connect.timeout.ms";
const string TABLE_INCLUDE_LIST = "table.include.list";
const string TABLE_EXCLUDE_LIST = "table.exclude.list";
const string COLUMN_INCLUDE_LIST = "column.include.list";
const string COLUMN_EXCLUDE_LIST = "column.exclude.list";
const string DATABASE_SSL_MODE = "database.ssl.mode";
const string DATABASE_SSL_KEYSTORE = "database.ssl.keystore";
const string DATABASE_SSL_KEYSTORE_PASSWORD = "database.ssl.keystore.password";
const string DATABASE_SSL_TRUSTSTORE = "database.ssl.truststore";
const string DATABASE_SSL_TRUSTSTORE_PASSWORD = "database.ssl.truststore.password";
const string SCHEMA_HISTORY_INTERNAL = "schema.history.internal";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_BOOTSTRAP_SERVERS = "schema.history.internal.kafka.bootstrap.servers";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_TOPIC = "schema.history.internal.kafka.topic";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_RECOVERY_POLL_INTERVAL_MS = "schema.history.internal.kafka.recovery.poll.interval.ms";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_RECOVERY_ATTEMPTS = "schema.history.internal.kafka.recovery.attempts";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_QUERY_TIMEOUT_MS = "schema.history.internal.kafka.query.timeout.ms";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_CREATE_TIMEOUT_MS = "schema.history.internal.kafka.create.timeout.ms";
const string SCHEMA_HISTORY_INTERNAL_FILE_FILENAME = "schema.history.internal.file.filename";

// JDBC schema history properties
const string SCHEMA_HISTORY_INTERNAL_JDBC_URL = "schema.history.internal.jdbc.url";
const string SCHEMA_HISTORY_INTERNAL_JDBC_USER = "schema.history.internal.jdbc.user";
const string SCHEMA_HISTORY_INTERNAL_JDBC_PASSWORD = "schema.history.internal.jdbc.password";
const string SCHEMA_HISTORY_INTERNAL_JDBC_RETRY_DELAY_MS = "schema.history.internal.jdbc.retry.delay.ms";
const string SCHEMA_HISTORY_INTERNAL_JDBC_RETRY_MAX_ATTEMPTS = "schema.history.internal.jdbc.retry.max.attempts";
const string SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_NAME = "schema.history.internal.jdbc.schema.history.table.name";
const string SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_DDL = "schema.history.internal.jdbc.schema.history.table.ddl";
const string SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_SELECT = "schema.history.internal.jdbc.schema.history.table.select";
const string SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_INSERT = "schema.history.internal.jdbc.schema.history.table.insert";
const string SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_DELETE = "schema.history.internal.jdbc.schema.history.table.delete";

// Redis schema history properties
const string SCHEMA_HISTORY_INTERNAL_REDIS_KEY = "schema.history.internal.redis.key";
const string SCHEMA_HISTORY_INTERNAL_REDIS_ADDRESS = "schema.history.internal.redis.address";
const string SCHEMA_HISTORY_INTERNAL_REDIS_USER = "schema.history.internal.redis.user";
const string SCHEMA_HISTORY_INTERNAL_REDIS_PASSWORD = "schema.history.internal.redis.password";
const string SCHEMA_HISTORY_INTERNAL_REDIS_DB_INDEX = "schema.history.internal.redis.db.index";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_ENABLED = "schema.history.internal.redis.ssl.enabled";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_HOSTNAME_VERIFICATION_ENABLED = "schema.history.internal.redis.ssl.hostname.verification.enabled";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE = "schema.history.internal.redis.ssl.truststore";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE_PASSWORD = "schema.history.internal.redis.ssl.truststore.password";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE_TYPE = "schema.history.internal.redis.ssl.truststore.type";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_KEYSTORE = "schema.history.internal.redis.ssl.keystore";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_KEYSTORE_PASSWORD = "schema.history.internal.redis.ssl.keystore.password";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SSL_KEYSTORE_TYPE = "schema.history.internal.redis.ssl.keystore.type";
const string SCHEMA_HISTORY_INTERNAL_REDIS_CONNECTION_TIMEOUT_MS = "schema.history.internal.redis.connection.timeout.ms";
const string SCHEMA_HISTORY_INTERNAL_REDIS_SOCKET_TIMEOUT_MS = "schema.history.internal.redis.socket.timeout.ms";
const string SCHEMA_HISTORY_INTERNAL_REDIS_RETRY_INITIAL_DELAY_MS = "schema.history.internal.redis.retry.initial.delay.ms";
const string SCHEMA_HISTORY_INTERNAL_REDIS_RETRY_MAX_DELAY_MS = "schema.history.internal.redis.retry.max.delay.ms";
const string SCHEMA_HISTORY_INTERNAL_REDIS_RETRY_MAX_ATTEMPTS = "schema.history.internal.redis.retry.max.attempts";
const string SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_ENABLED = "schema.history.internal.redis.wait.enabled";
const string SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_TIMEOUT_MS = "schema.history.internal.redis.wait.timeout.ms";
const string SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_ENABLED = "schema.history.internal.redis.wait.retry.enabled";
const string SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_DELAY_MS = "schema.history.internal.redis.wait.retry.delay.ms";
const string SCHEMA_HISTORY_INTERNAL_REDIS_CLUSTER_ENABLED = "schema.history.internal.redis.cluster.enabled";

// Amazon S3 schema history properties
const string SCHEMA_HISTORY_INTERNAL_S3_ACCESS_KEY_ID = "schema.history.internal.s3.access.key.id";
const string SCHEMA_HISTORY_INTERNAL_S3_SECRET_ACCESS_KEY = "schema.history.internal.s3.secret.access.key";
const string SCHEMA_HISTORY_INTERNAL_S3_REGION = "schema.history.internal.s3.region.name";
const string SCHEMA_HISTORY_INTERNAL_S3_BUCKET_NAME = "schema.history.internal.s3.bucket.name";
const string SCHEMA_HISTORY_INTERNAL_S3_OBJECT_NAME = "schema.history.internal.s3.object.name";
const string SCHEMA_HISTORY_INTERNAL_S3_ENDPOINT = "schema.history.internal.s3.endpoint";

// Azure Blob schema history properties
const string SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_CONNECTION_STRING = "schema.history.internal.azure.storage.connection.string";
const string SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_ACCOUNT_NAME = "schema.history.internal.azure.storage.account.name";
const string SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_CONTAINER_NAME = "schema.history.internal.azure.storage.container.name";
const string SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_BLOB_NAME = "schema.history.internal.azure.storage.blob.name";

// RocketMQ schema history properties
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_TOPIC = "schema.history.internal.rocketmq.topic";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_NAMESRV_ADDR = "schema.history.internal.rocketmq.namesrv.addr";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_ACL_ENABLED = "schema.history.internal.rocketmq.acl.enabled";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_ACCESS_KEY = "schema.history.internal.rocketmq.access.key";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_SECRET_KEY = "schema.history.internal.rocketmq.secret.key";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_RECOVERY_ATTEMPTS = "schema.history.internal.rocketmq.recovery.attempts";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_RECOVERY_POLL_INTERVAL_MS = "schema.history.internal.rocketmq.recovery.poll.interval.ms";
const string SCHEMA_HISTORY_INTERNAL_ROCKETMQ_STORE_RECORD_TIMEOUT = "schema.history.internal.rocketmq.store.record.timeout";

const string OFFSET_STORAGE = "offset.storage";
const string OFFSET_FLUSH_INTERVAL_MS = "offset.flush.interval.ms";
const string OFFSET_FLUSH_TIMEOUT_MS = "offset.flush.timeout.ms";
const string OFFSET_STORAGE_FILE_FILENAME = "offset.storage.file.filename";
const string OFFSET_BOOTSTRAP_SERVERS = "bootstrap.servers";
const string OFFSET_STORAGE_TOPIC = "offset.storage.topic";
const string OFFSET_STORAGE_PARTITIONS = "offset.storage.partitions";
const string OFFSET_STORAGE_REPLICATION_FACTOR = "offset.storage.replication.factor";
const string INCLUDE_SCHEMA_CHANGES = "include.schema.changes";
const string TOMBSTONES_ON_DELETE = "tombstones.on.delete";

// Heartbeat properties
const string HEARTBEAT_INTERVAL_MS = "heartbeat.interval.ms";
const string HEARTBEAT_ACTION_QUERY = "heartbeat.action.query";

// Signal properties
const string SIGNAL_ENABLED_CHANNELS = "signal.enabled.channels";
const string SIGNAL_DATA_COLLECTION = "signal.data.collection";
const string SIGNAL_KAFKA_TOPIC = "signal.kafka.topic";
const string SIGNAL_KAFKA_BOOTSTRAP_SERVERS = "signal.kafka.bootstrap.servers";
const string SIGNAL_KAFKA_GROUP_ID = "signal.kafka.groupId";
const string SIGNAL_FILE = "signal.file";

// Extended snapshot properties
const string SNAPSHOT_DELAY_MS = "snapshot.delay.ms";
const string SNAPSHOT_FETCH_SIZE = "snapshot.fetch.size";
const string SNAPSHOT_MAX_THREADS = "snapshot.max.threads";
const string SNAPSHOT_INCLUDE_COLLECTION_LIST = "snapshot.include.collection.list";

// Relational database extended snapshot properties
const string SNAPSHOT_ISOLATION_MODE = "snapshot.isolation.mode";
const string SNAPSHOT_LOCKING_MODE = "snapshot.locking.mode";
const string SNAPSHOT_SELECT_STATEMENT_OVERRIDES = "snapshot.select.statement.overrides";
const string SNAPSHOT_QUERY_MODE = "snapshot.query.mode";

// Incremental snapshot properties
const string INCREMENTAL_SNAPSHOT_CHUNK_SIZE = "incremental.snapshot.chunk.size";
const string INCREMENTAL_SNAPSHOT_WATERMARKING_STRATEGY = "incremental.snapshot.watermarking.strategy";
const string INCREMENTAL_SNAPSHOT_ALLOW_SCHEMA_CHANGES = "incremental.snapshot.allow.schema.changes";

// Transaction metadata properties
const string PROVIDE_TRANSACTION_METADATA = "provide.transaction.metadata";
const string TRANSACTION_TOPIC = "transaction.topic";

// Column transformation properties
const string COLUMN_MASK_HASH_WITH = "column.mask.hash.with";
const string COLUMN_MASK_WITH = "column.mask.with";
const string COLUMN_TRUNCATE_TO = "column.truncate.to";

// Topic configuration properties
const string TOPIC_PREFIX = "topic.prefix";
const string TOPIC_DELIMITER = "topic.delimiter";
const string TOPIC_NAMING_STRATEGY = "topic.naming.strategy";

// Data type properties
const string BINARY_HANDLING_MODE = "binary.handling.mode";
const string TIME_PRECISION_MODE = "time.precision.mode";

// Error handling properties
const string ERRORS_MAX_RETRIES = "errors.max.retries";
const string ERRORS_RETRY_DELAY_INITIAL_MS = "errors.retry.delay.initial.ms";

// Performance properties
const string MAX_QUEUE_SIZE_IN_BYTES = "max.queue.size.in.bytes";
const string POLL_INTERVAL_MS = "poll.interval.ms";
const string QUERY_FETCH_SIZE = "query.fetch.size";

// Monitoring properties
const string CUSTOM_METRIC_TAGS = "custom.metric.tags";

// JDBC offset storage properties
const string OFFSET_STORAGE_JDBC_URL = "offset.storage.jdbc.url";
const string OFFSET_STORAGE_JDBC_USER = "offset.storage.jdbc.user";
const string OFFSET_STORAGE_JDBC_PASSWORD = "offset.storage.jdbc.password";
const string OFFSET_STORAGE_JDBC_RETRY_DELAY_MS = "offset.storage.jdbc.retry.delay.ms";
const string OFFSET_STORAGE_JDBC_RETRY_MAX_ATTEMPTS = "offset.storage.jdbc.retry.max.attempts";
const string OFFSET_STORAGE_JDBC_TABLE_NAME = "offset.storage.jdbc.offset.table.name";
const string OFFSET_STORAGE_JDBC_TABLE_DDL = "offset.storage.jdbc.offset.table.ddl";
const string OFFSET_STORAGE_JDBC_TABLE_SELECT = "offset.storage.jdbc.offset.table.select";
const string OFFSET_STORAGE_JDBC_TABLE_INSERT = "offset.storage.jdbc.offset.table.insert";
const string OFFSET_STORAGE_JDBC_TABLE_DELETE = "offset.storage.jdbc.offset.table.delete";

// Redis offset storage properties
const string OFFSET_STORAGE_REDIS_KEY = "offset.storage.redis.key";
const string OFFSET_STORAGE_REDIS_ADDRESS = "offset.storage.redis.address";
const string OFFSET_STORAGE_REDIS_USER = "offset.storage.redis.user";
const string OFFSET_STORAGE_REDIS_PASSWORD = "offset.storage.redis.password";
const string OFFSET_STORAGE_REDIS_DB_INDEX = "offset.storage.redis.db.index";
const string OFFSET_STORAGE_REDIS_SSL_ENABLED = "offset.storage.redis.ssl.enabled";
const string OFFSET_STORAGE_REDIS_SSL_HOSTNAME_VERIFICATION_ENABLED = "offset.storage.redis.ssl.hostname.verification.enabled";
const string OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE = "offset.storage.redis.ssl.truststore";
const string OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE_PASSWORD = "offset.storage.redis.ssl.truststore.password";
const string OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE_TYPE = "offset.storage.redis.ssl.truststore.type";
const string OFFSET_STORAGE_REDIS_SSL_KEYSTORE = "offset.storage.redis.ssl.keystore";
const string OFFSET_STORAGE_REDIS_SSL_KEYSTORE_PASSWORD = "offset.storage.redis.ssl.keystore.password";
const string OFFSET_STORAGE_REDIS_SSL_KEYSTORE_TYPE = "offset.storage.redis.ssl.keystore.type";
const string OFFSET_STORAGE_REDIS_CONNECTION_TIMEOUT_MS = "offset.storage.redis.connection.timeout.ms";
const string OFFSET_STORAGE_REDIS_SOCKET_TIMEOUT_MS = "offset.storage.redis.socket.timeout.ms";
const string OFFSET_STORAGE_REDIS_RETRY_INITIAL_DELAY_MS = "offset.storage.redis.retry.initial.delay.ms";
const string OFFSET_STORAGE_REDIS_RETRY_MAX_DELAY_MS = "offset.storage.redis.retry.max.delay.ms";
const string OFFSET_STORAGE_REDIS_RETRY_MAX_ATTEMPTS = "offset.storage.redis.retry.max.attempts";
const string OFFSET_STORAGE_REDIS_WAIT_ENABLED = "offset.storage.redis.wait.enabled";
const string OFFSET_STORAGE_REDIS_WAIT_TIMEOUT_MS = "offset.storage.redis.wait.timeout.ms";
const string OFFSET_STORAGE_REDIS_WAIT_RETRY_ENABLED = "offset.storage.redis.wait.retry.enabled";
const string OFFSET_STORAGE_REDIS_WAIT_RETRY_DELAY_MS = "offset.storage.redis.wait.retry.delay.ms";
const string OFFSET_STORAGE_REDIS_CLUSTER_ENABLED = "offset.storage.redis.cluster.enabled";

// Kafka offset storage authentication properties
const string OFFSET_SECURITY_PROTOCOL = "security.protocol";
const string OFFSET_SASL_MECHANISM = "sasl.mechanism";
const string OFFSET_SASL_JAAS_CONFIG = "sasl.jaas.config";
const string OFFSET_SSL_KEYSTORE_LOCATION = "ssl.keystore.location";
const string OFFSET_SSL_KEYSTORE_PASSWORD = "ssl.keystore.password";
const string OFFSET_SSL_KEYSTORE_TYPE = "ssl.keystore.type";
const string OFFSET_SSL_KEYSTORE_CERTIFICATE_CHAIN = "ssl.keystore.certificate.chain";
const string OFFSET_SSL_KEYSTORE_KEY = "ssl.keystore.key";
const string OFFSET_SSL_KEY_PASSWORD = "ssl.key.password";
const string OFFSET_SSL_TRUSTSTORE_LOCATION = "ssl.truststore.location";
const string OFFSET_SSL_TRUSTSTORE_PASSWORD = "ssl.truststore.password";
const string OFFSET_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM = "ssl.endpoint.identification.algorithm";
const string OFFSET_SSL_TRUSTSTORE_TYPE = "ssl.truststore.type";
const string OFFSET_SSL_CIPHER_SUITES = "ssl.cipher.suites";
const string OFFSET_SSL_PROTOCOL = "ssl.protocol";
const string OFFSET_SSL_ENABLED_PROTOCOLS = "ssl.enabled.protocols";
const string OFFSET_SSL_PROVIDER = "ssl.provider";

// Kafka schema history producer authentication properties
const string SCHEMA_HISTORY_PRODUCER_SECURITY_PROTOCOL = "schema.history.internal.producer.security.protocol";
const string SCHEMA_HISTORY_PRODUCER_SASL_MECHANISM = "schema.history.internal.producer.sasl.mechanism";
const string SCHEMA_HISTORY_PRODUCER_SASL_JAAS_CONFIG = "schema.history.internal.producer.sasl.jaas.config";
const string SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_LOCATION = "schema.history.internal.producer.ssl.keystore.location";
const string SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_PASSWORD = "schema.history.internal.producer.ssl.keystore.password";
const string SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_TYPE = "schema.history.internal.producer.ssl.keystore.type";
const string SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_CERTIFICATE_CHAIN = "schema.history.internal.producer.ssl.keystore.certificate.chain";
const string SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_KEY = "schema.history.internal.producer.ssl.keystore.key";
const string SCHEMA_HISTORY_PRODUCER_SSL_KEY_PASSWORD = "schema.history.internal.producer.ssl.key.password";
const string SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_LOCATION = "schema.history.internal.producer.ssl.truststore.location";
const string SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_PASSWORD = "schema.history.internal.producer.ssl.truststore.password";
const string SCHEMA_HISTORY_PRODUCER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM = "schema.history.internal.producer.ssl.endpoint.identification.algorithm";
const string SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_TYPE = "schema.history.internal.producer.ssl.truststore.type";
const string SCHEMA_HISTORY_PRODUCER_SSL_CIPHER_SUITES = "schema.history.internal.producer.ssl.cipher.suites";
const string SCHEMA_HISTORY_PRODUCER_SSL_PROTOCOL = "schema.history.internal.producer.ssl.protocol";
const string SCHEMA_HISTORY_PRODUCER_SSL_ENABLED_PROTOCOLS = "schema.history.internal.producer.ssl.enabled.protocols";
const string SCHEMA_HISTORY_PRODUCER_SSL_PROVIDER = "schema.history.internal.producer.ssl.provider";

// Kafka schema history consumer authentication properties
const string SCHEMA_HISTORY_CONSUMER_SECURITY_PROTOCOL = "schema.history.internal.consumer.security.protocol";
const string SCHEMA_HISTORY_CONSUMER_SASL_MECHANISM = "schema.history.internal.consumer.sasl.mechanism";
const string SCHEMA_HISTORY_CONSUMER_SASL_JAAS_CONFIG = "schema.history.internal.consumer.sasl.jaas.config";
const string SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_LOCATION = "schema.history.internal.consumer.ssl.keystore.location";
const string SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_PASSWORD = "schema.history.internal.consumer.ssl.keystore.password";
const string SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_TYPE = "schema.history.internal.consumer.ssl.keystore.type";
const string SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_CERTIFICATE_CHAIN = "schema.history.internal.consumer.ssl.keystore.certificate.chain";
const string SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_KEY = "schema.history.internal.consumer.ssl.keystore.key";
const string SCHEMA_HISTORY_CONSUMER_SSL_KEY_PASSWORD = "schema.history.internal.consumer.ssl.key.password";
const string SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_LOCATION = "schema.history.internal.consumer.ssl.truststore.location";
const string SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_PASSWORD = "schema.history.internal.consumer.ssl.truststore.password";
const string SCHEMA_HISTORY_CONSUMER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM = "schema.history.internal.consumer.ssl.endpoint.identification.algorithm";
const string SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_TYPE = "schema.history.internal.consumer.ssl.truststore.type";
const string SCHEMA_HISTORY_CONSUMER_SSL_CIPHER_SUITES = "schema.history.internal.consumer.ssl.cipher.suites";
const string SCHEMA_HISTORY_CONSUMER_SSL_PROTOCOL = "schema.history.internal.consumer.ssl.protocol";
const string SCHEMA_HISTORY_CONSUMER_SSL_ENABLED_PROTOCOLS = "schema.history.internal.consumer.ssl.enabled.protocols";
const string SCHEMA_HISTORY_CONSUMER_SSL_PROVIDER = "schema.history.internal.consumer.ssl.provider";

// Signal Kafka authentication properties
const string SIGNAL_KAFKA_SECURITY_PROTOCOL = "signal.kafka.security.protocol";
const string SIGNAL_KAFKA_SASL_MECHANISM = "signal.kafka.sasl.mechanism";
const string SIGNAL_KAFKA_SASL_JAAS_CONFIG = "signal.kafka.sasl.jaas.config";
const string SIGNAL_KAFKA_SSL_KEYSTORE_LOCATION = "signal.kafka.ssl.keystore.location";
const string SIGNAL_KAFKA_SSL_KEYSTORE_PASSWORD = "signal.kafka.ssl.keystore.password";
const string SIGNAL_KAFKA_SSL_KEYSTORE_TYPE = "signal.kafka.ssl.keystore.type";
const string SIGNAL_KAFKA_SSL_KEYSTORE_CERTIFICATE_CHAIN = "signal.kafka.ssl.keystore.certificate.chain";
const string SIGNAL_KAFKA_SSL_KEYSTORE_KEY = "signal.kafka.ssl.keystore.key";
const string SIGNAL_KAFKA_SSL_KEY_PASSWORD = "signal.kafka.ssl.key.password";
const string SIGNAL_KAFKA_SSL_TRUSTSTORE_LOCATION = "signal.kafka.ssl.truststore.location";
const string SIGNAL_KAFKA_SSL_TRUSTSTORE_PASSWORD = "signal.kafka.ssl.truststore.password";
const string SIGNAL_KAFKA_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM = "signal.kafka.ssl.endpoint.identification.algorithm";
const string SIGNAL_KAFKA_SSL_TRUSTSTORE_TYPE = "signal.kafka.ssl.truststore.type";
const string SIGNAL_KAFKA_SSL_CIPHER_SUITES = "signal.kafka.ssl.cipher.suites";
const string SIGNAL_KAFKA_SSL_PROTOCOL = "signal.kafka.ssl.protocol";
const string SIGNAL_KAFKA_SSL_ENABLED_PROTOCOLS = "signal.kafka.ssl.enabled.protocols";
const string SIGNAL_KAFKA_SSL_PROVIDER = "signal.kafka.ssl.provider";

# Processes the given configuration and populates the map with the necessary debezium properties.
#
# + config - listener configuration
# + configMap - map to populate with debezium properties
public isolated function populateDebeziumProperties(ListenerConfiguration config, map<string> configMap) {
    configMap[NAME] = config.engineName;
    populateSchemaHistoryConfigurations(config.internalSchemaStorage, configMap);
    populateOffsetStorageConfigurations(config.offsetStorage, configMap);

    // The following values cannot be overridden by the user
    configMap[TOMBSTONES_ON_DELETE] = "false";
    configMap[INCLUDE_SCHEMA_CHANGES] = "false";
}

# Processes the given configuration and populates the map with the necessary listener-specific properties.
# These properties are not passed to the Debezium engine, but are used by the listener implementation for
# its internal functioning.
# 
# + config - listener configuration
# + listenerConfigMap - map to populate with listener-specific properties
public isolated function populateListenerProperties(ListenerConfiguration config, map<anydata> listenerConfigMap) {
    listenerConfigMap["livenessInterval"] = config.livenessInterval;
}

isolated function populateSchemaHistoryConfigurations(InternalSchemaStorage schemaHistoryInternal,
    map<string> configMap
) {
    configMap[SCHEMA_HISTORY_INTERNAL] = schemaHistoryInternal.className;
    configMap[TOPIC_PREFIX] = schemaHistoryInternal.topicPrefix;

    if schemaHistoryInternal is KafkaInternalSchemaStorage {
        populateKafkaSchemaHistoryConfiguration(schemaHistoryInternal, configMap);
    } else if schemaHistoryInternal is FileInternalSchemaStorage {
        configMap[SCHEMA_HISTORY_INTERNAL_FILE_FILENAME] = schemaHistoryInternal.fileName;
    } else if schemaHistoryInternal is JdbcInternalSchemaStorage {
        populateJdbcSchemaHistoryConfiguration(schemaHistoryInternal, configMap);
    } else if schemaHistoryInternal is RedisInternalSchemaStorage {
        populateRedisSchemaHistoryConfiguration(schemaHistoryInternal, configMap);
    } else if schemaHistoryInternal is AmazonS3InternalSchemaStorage {
        populateS3SchemaHistoryConfiguration(schemaHistoryInternal, configMap);
    } else if schemaHistoryInternal is AzureBlobInternalSchemaStorage {
        populateAzureBlobSchemaHistoryConfiguration(schemaHistoryInternal, configMap);
    } else if schemaHistoryInternal is RocketMQInternalSchemaStorage {
        populateRocketMQSchemaHistoryConfiguration(schemaHistoryInternal, configMap);
    }
    // MemoryInternalSchemaStorage requires no additional configuration
}

isolated function populateOffsetStorageConfigurations(
    FileOffsetStorage|KafkaOffsetStorage|MemoryOffsetStorage|RedisOffsetStorage|JdbcOffsetStorage offsetStorage,
    map<string> configMap
) {
    configMap[OFFSET_STORAGE] = offsetStorage.className;
    configMap[OFFSET_FLUSH_INTERVAL_MS] = getMillisecondValueOf(offsetStorage.flushInterval);
    configMap[OFFSET_FLUSH_TIMEOUT_MS] = getMillisecondValueOf(offsetStorage.flushTimeout);

    if offsetStorage is KafkaOffsetStorage {
        string|string[] offsetStorageBootstrapServers = offsetStorage.bootstrapServers;
        configMap[OFFSET_BOOTSTRAP_SERVERS] = offsetStorageBootstrapServers is string ?
            offsetStorageBootstrapServers : string:'join(",", ...offsetStorageBootstrapServers);
        configMap[OFFSET_STORAGE_TOPIC] = offsetStorage.topicName;
        configMap[OFFSET_STORAGE_PARTITIONS] = offsetStorage.partitions.toString();
        configMap[OFFSET_STORAGE_REPLICATION_FACTOR] = offsetStorage.replicationFactor.toString();

        kafka:SecurityProtocol? securityProtocol = offsetStorage.securityProtocol;
        if securityProtocol is kafka:SecurityProtocol {
            configMap[OFFSET_SECURITY_PROTOCOL] = securityProtocol;
        }

        kafka:AuthenticationConfiguration? auth = offsetStorage.auth;
        if auth is kafka:AuthenticationConfiguration {
            populateOffsetAuthConfigurations(auth, configMap);
        }

        kafka:SecureSocket? secureSocket = offsetStorage.secureSocket;
        if secureSocket is kafka:SecureSocket {
            populateOffsetSecureSocketConfigurations(secureSocket, configMap);
        }
    } else if offsetStorage is FileOffsetStorage {
        configMap[OFFSET_STORAGE_FILE_FILENAME] = offsetStorage.fileName;
    } else if offsetStorage is RedisOffsetStorage {
        populateRedisOffsetStorageConfiguration(offsetStorage, configMap);
    } else if offsetStorage is JdbcOffsetStorage {
        populateJdbcOffsetStorageConfiguration(offsetStorage, configMap);
    }
    // MemoryOffsetStorage requires no additional configuration
}

isolated function populateKafkaSchemaHistoryConfiguration(KafkaInternalSchemaStorage storage, map<string> configMap) {
    string|string[] bootstrapServers = storage.bootstrapServers;
    configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_BOOTSTRAP_SERVERS] = bootstrapServers is string ?
        bootstrapServers : string:'join(",", ...bootstrapServers);
    configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_TOPIC] = storage.topicName;
    configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_RECOVERY_POLL_INTERVAL_MS] = getMillisecondValueOf(storage.recoveryPollInterval);
    configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_RECOVERY_ATTEMPTS] = storage.recoveryAttempts.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_QUERY_TIMEOUT_MS] = getMillisecondValueOf(storage.queryTimeout);
    configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_CREATE_TIMEOUT_MS] = getMillisecondValueOf(storage.createTimeout);

    kafka:SecurityProtocol? securityProtocol = storage.securityProtocol;
    if securityProtocol is kafka:SecurityProtocol {
        configMap[SCHEMA_HISTORY_PRODUCER_SECURITY_PROTOCOL] = securityProtocol;
        configMap[SCHEMA_HISTORY_CONSUMER_SECURITY_PROTOCOL] = securityProtocol;
    }

    kafka:AuthenticationConfiguration? auth = storage.auth;
    if auth is kafka:AuthenticationConfiguration {
        populateSchemaHistoryAuthConfigurations(auth, configMap);
    }

    kafka:SecureSocket? secureSocket = storage.secureSocket;
    if secureSocket is kafka:SecureSocket {
        populateSchemaHistorySecureSocketConfigurations(secureSocket, configMap);
    }
}

isolated function populateSchemaHistoryAuthConfigurations(kafka:AuthenticationConfiguration auth, map<string> configMap) {
    configMap[SCHEMA_HISTORY_PRODUCER_SASL_MECHANISM] = auth.mechanism;
    configMap[SCHEMA_HISTORY_CONSUMER_SASL_MECHANISM] = auth.mechanism;

    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[SCHEMA_HISTORY_PRODUCER_SASL_JAAS_CONFIG] = jaasConfig;
    configMap[SCHEMA_HISTORY_CONSUMER_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateSchemaHistorySecureSocketConfigurations(kafka:SecureSocket secure, map<string> configMap) {
    crypto:TrustStore|string cert = secure.cert;
    if cert is crypto:TrustStore {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_PASSWORD] = cert.password;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_PASSWORD] = cert.password;
    } else {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_TYPE] = "PEM";
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    record {|crypto:KeyStore keyStore; string keyPassword?;|}|kafka:CertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is kafka:CertKey {
        string|error certContent = readFileContent(keyConfig.certFile);
        string|error keyContent = readFileContent(keyConfig.keyFile);

        if certContent is error {
            log:printError(string `Error reading certificate file: ${keyConfig.certFile}`, certContent);
        }
        if keyContent is error {
            log:printError(string `Error reading key file: ${keyConfig.keyFile}`, keyContent);
        }

        if certContent is string && keyContent is string {
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_KEY] = keyContent;
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_KEY] = keyContent;

            string? keyPassword = keyConfig.keyPassword;
            if keyPassword is string {
                configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEY_PASSWORD] = keyPassword;
                configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEY_PASSWORD] = keyPassword;
            }
        }
    }

    string[]? ciphers = secure.ciphers;
    if ciphers is string[] && ciphers.length() > 0 {
        string cipherSuites = string:'join(",", ...ciphers);
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_CIPHER_SUITES] = cipherSuites;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_CIPHER_SUITES] = cipherSuites;
    }

    var protocolConfig = secure.protocol;
    if protocolConfig is record {| kafka:Protocol name; string[] versions?; |} {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_PROTOCOL] = protocolConfig.name.toString();
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_PROTOCOL] = protocolConfig.name.toString();

        string[]? versions = protocolConfig.versions;
        if versions is string[] && versions.length() > 0 {
            string enabledProtocols = string:'join(",", ...versions);
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_ENABLED_PROTOCOLS] = enabledProtocols;
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_ENABLED_PROTOCOLS] = enabledProtocols;
        }
    }

    string? provider = secure.provider;
    if provider is string {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_PROVIDER] = provider;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_PROVIDER] = provider;
    }
}

isolated function populateOffsetAuthConfigurations(kafka:AuthenticationConfiguration auth, map<string> configMap) {
    configMap[OFFSET_SASL_MECHANISM] = auth.mechanism;
    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[OFFSET_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateOffsetSecureSocketConfigurations(kafka:SecureSocket secure, map<string> configMap) {
    crypto:TrustStore|string cert = secure.cert;
    if cert is crypto:TrustStore {
        configMap[OFFSET_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[OFFSET_SSL_TRUSTSTORE_PASSWORD] = cert.password;
    } else {
        configMap[OFFSET_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[OFFSET_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    record {| crypto:KeyStore keyStore; string keyPassword?;|}|kafka:CertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[OFFSET_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[OFFSET_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is kafka:CertKey {
        string|error certContent = readFileContent(keyConfig.certFile);
        string|error keyContent = readFileContent(keyConfig.keyFile);

        if certContent is error {
            log:printError(string `Error reading certificate file: ${keyConfig.certFile}`, certContent);
        }
        if keyContent is error {
            log:printError(string `Error reading key file: ${keyConfig.keyFile}`, keyContent);
        }

        if certContent is string && keyContent is string {
            configMap[OFFSET_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[OFFSET_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[OFFSET_SSL_KEYSTORE_KEY] = keyContent;

            string? keyPassword = keyConfig.keyPassword;
            if keyPassword is string {
                configMap[OFFSET_SSL_KEY_PASSWORD] = keyPassword;
            }
        }
    }

    string[]? ciphers = secure.ciphers;
    if ciphers is string[] && ciphers.length() > 0 {
        string cipherSuites = string:'join(",", ...ciphers);
        configMap[OFFSET_SSL_CIPHER_SUITES] = cipherSuites;
    }

    record {| kafka:Protocol name; string[] versions?;|}? protocolConfig = secure.protocol;
    if protocolConfig is record {| kafka:Protocol name; string[] versions?; |} {
        configMap[OFFSET_SSL_PROTOCOL] = protocolConfig.name.toString();
        string[]? versions = protocolConfig.versions;
        if versions is string[] && versions.length() > 0 {
            string enabledProtocols = string:'join(",", ...versions);
            configMap[OFFSET_SSL_ENABLED_PROTOCOLS] = enabledProtocols;
        }
    }

    string? provider = secure.provider;
    if provider is string {
        configMap[OFFSET_SSL_PROVIDER] = provider;
    }
}

public isolated function populateOptions(Options options, map<string> configMap, typedesc<Options> optionsSubType) {
    configMap[MAX_QUEUE_SIZE] = options.maxQueueSize.toString();
    configMap[MAX_BATCH_SIZE] = options.maxBatchSize.toString();
    configMap[EVENT_PROCESSING_FAILURE_HANDLING_MODE] = options.eventProcessingFailureHandlingMode;
    configMap[SNAPSHOT_MODE] = options.snapshotMode;
    configMap[SKIPPED_OPERATIONS] = string:'join(",", ...options.skippedOperations);
    configMap[SKIP_MESSAGES_WITHOUT_CHANGE] = options.skipMessagesWithoutChange.toString();
    configMap[DECIMAL_HANDLING_MODE] = options.decimalHandlingMode;
    configMap[DATABASE_QUERY_TIMEOUTS_MS] = getMillisecondValueOf(options.queryTimeout);

    HeartbeatConfiguration? heartbeat = options.heartbeat;
    if heartbeat is HeartbeatConfiguration {
        populateHeartbeatConfiguration(heartbeat, configMap);
    }

    SignalConfiguration? signal = options.signal;
    if signal is SignalConfiguration {
        populateSignalConfiguration(signal, configMap);
    }

    TransactionMetadataConfiguration? transactionMetadata = options.transactionMetadata;
    if transactionMetadata is TransactionMetadataConfiguration {
        populateTransactionMetadataConfiguration(transactionMetadata, configMap);
    }

    ColumnTransformConfiguration? columnTransform = options.columnTransform;
    if columnTransform is ColumnTransformConfiguration {
        populateColumnTransformConfiguration(columnTransform, configMap);
    }

    TopicConfiguration? topicConfig = options.topicConfig;
    if topicConfig is TopicConfiguration {
        populateTopicConfiguration(topicConfig, configMap);
    }

    ErrorHandlingConfiguration? errorHandling = options.errorHandling;
    if errorHandling is ErrorHandlingConfiguration {
        populateErrorHandlingConfiguration(errorHandling, configMap);
    }

    PerformanceConfiguration? performance = options.performance;
    if performance is PerformanceConfiguration {
        populatePerformanceConfiguration(performance, configMap);
    }

    MonitoringConfiguration? monitoring = options.monitoring;
    if monitoring is MonitoringConfiguration {
        populateMonitoringConfiguration(monitoring, configMap);
    }

    GuardrailConfiguration? guardrail = options.guardrail;
    if guardrail is GuardrailConfiguration {
        populateGuardrailConfiguration(guardrail, configMap);
    }

    populateAdditionalConfigurations(options, configMap, optionsSubType);
}

# Populates the database configurations in the given map.
#
# + connection - database connection configuration
# + configMap - map to populate with database configurations
public isolated function populateDatabaseConfigurations(DatabaseConnection connection, map<string> configMap) {
    configMap[CONNECTOR_CLASS] = connection.connectorClass;
    configMap[DATABASE_HOSTNAME] = connection.hostname;
    configMap[DATABASE_PORT] = connection.port.toString();
    configMap[DATABASE_USER] = connection.username;
    configMap[DATABASE_PASSWORD] = connection.password;
    configMap[TASKS_MAX] = connection.tasksMax.toString();

    decimal? connectTimeout = connection.connectTimeout;
    if connectTimeout is decimal {
        configMap[CONNECT_TIMEOUT_MS] = getMillisecondValueOf(connectTimeout);
    }

    populateSslConfigurations(connection, configMap);
    populateTableAndColumnConfigurations(connection, configMap);
}

isolated function populateSslConfigurations(DatabaseConnection connection, map<string> configMap) {
    SecureDatabaseConnection? secure = connection.secure;
    if secure is SecureDatabaseConnection {
        configMap[DATABASE_SSL_MODE] = secure.sslMode.toString();

        crypto:KeyStore? keyStore = secure.keyStore;
        if keyStore is crypto:KeyStore {
            configMap[DATABASE_SSL_KEYSTORE] = keyStore.path;
            configMap[DATABASE_SSL_KEYSTORE_PASSWORD] = keyStore.password;
        }

        crypto:TrustStore? trustStore = secure.trustStore;
        if trustStore is crypto:TrustStore {
            configMap[DATABASE_SSL_TRUSTSTORE] = trustStore.path;
            configMap[DATABASE_SSL_TRUSTSTORE_PASSWORD] = trustStore.password;
        }
    }
}

isolated function populateTableAndColumnConfigurations(DatabaseConnection connection, map<string> configMap) {
    string|string[]? includedTables = connection.includedTables;
    if includedTables is string {
        configMap[TABLE_INCLUDE_LIST] = includedTables;
    } else if includedTables is string[] {
        configMap[TABLE_INCLUDE_LIST] = string:'join(",", ...includedTables);
    }

    string|string[]? excludedTables = connection.excludedTables;
    if excludedTables is string {
        configMap[TABLE_EXCLUDE_LIST] = excludedTables;
    } else if excludedTables is string[] {
        configMap[TABLE_EXCLUDE_LIST] = string:'join(",", ...excludedTables);
    }

    string|string[]? includedColumns = connection.includedColumns;
    if includedColumns is string {
        configMap[COLUMN_INCLUDE_LIST] = includedColumns;
    } else if includedColumns is string[] {
        configMap[COLUMN_INCLUDE_LIST] = string:'join(",", ...includedColumns);
    }

    string|string[]? excludedColumns = connection.excludedColumns;
    if excludedColumns is string {
        configMap[COLUMN_EXCLUDE_LIST] = excludedColumns;
    } else if excludedColumns is string[] {
        configMap[COLUMN_EXCLUDE_LIST] = string:'join(",", ...excludedColumns);
    }
}

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}

isolated function generateJaasConfig(kafka:AuthenticationMechanism mechanism, string username, string password) returns string {
    string loginModule;
    if mechanism == kafka:AUTH_SASL_PLAIN {
        loginModule = "org.apache.kafka.common.security.plain.PlainLoginModule";
    } else {
        loginModule = "org.apache.kafka.common.security.scram.ScramLoginModule";
    }
    return string `${loginModule} required username="${username}" password="${password}";`;
}

isolated function readFileContent(string filePath) returns string|error {
    return io:fileReadString(filePath);
}

# Populates heartbeat configuration properties.
#
# + config - heartbeat configuration
# + configMap - map to populate with heartbeat properties
public isolated function populateHeartbeatConfiguration(HeartbeatConfiguration config, map<string> configMap) {
    configMap[HEARTBEAT_INTERVAL_MS] = getMillisecondValueOf(config.interval);

    string? actionQuery = config.actionQuery;
    if actionQuery is string {
        configMap[HEARTBEAT_ACTION_QUERY] = actionQuery;
    }
}

# Populates signal configuration properties.
#
# + config - signal configuration
# + configMap - map to populate with signal properties
public isolated function populateSignalConfiguration(SignalConfiguration config, map<string> configMap) {
    configMap[SIGNAL_ENABLED_CHANNELS] = string:'join(",", ...config.enabledChannels);

    string? dataCollection = config.dataCollection;
    if dataCollection is string {
        configMap[SIGNAL_DATA_COLLECTION] = dataCollection;
    }

    if config is KafkaSignalConfiguration {
        string? topicName = config.topicName;
        if topicName is string {
            configMap[SIGNAL_KAFKA_TOPIC] = topicName;
        }

        string|string[]? bootstrapServers = config.bootstrapServers;
        if bootstrapServers is string {
            configMap[SIGNAL_KAFKA_BOOTSTRAP_SERVERS] = bootstrapServers;
        } else if bootstrapServers is string[] {
            configMap[SIGNAL_KAFKA_BOOTSTRAP_SERVERS] = string:'join(",", ...bootstrapServers);
        }

        string? groupId = config.groupId;
        if groupId is string {
            configMap[SIGNAL_KAFKA_GROUP_ID] = groupId;
        }

        kafka:SecurityProtocol? securityProtocol = config.securityProtocol;
        if securityProtocol is kafka:SecurityProtocol {
            configMap[SIGNAL_KAFKA_SECURITY_PROTOCOL] = securityProtocol;
        }

        kafka:AuthenticationConfiguration? auth = config.auth;
        if auth is kafka:AuthenticationConfiguration {
            populateSignalKafkaAuthConfigurations(auth, configMap);
        }

        kafka:SecureSocket? secureSocket = config.secureSocket;
        if secureSocket is kafka:SecureSocket {
            populateSignalKafkaSecureSocketConfigurations(secureSocket, configMap);
        }
    } else {
        configMap[SIGNAL_FILE] = config.fileName;
    }
}

isolated function populateSignalKafkaAuthConfigurations(kafka:AuthenticationConfiguration auth, map<string> configMap) {
    configMap[SIGNAL_KAFKA_SASL_MECHANISM] = auth.mechanism;
    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[SIGNAL_KAFKA_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateSignalKafkaSecureSocketConfigurations(kafka:SecureSocket secure, map<string> configMap) {
    crypto:TrustStore|string cert = secure.cert;
    if cert is crypto:TrustStore {
        configMap[SIGNAL_KAFKA_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[SIGNAL_KAFKA_SSL_TRUSTSTORE_PASSWORD] = cert.password;
    } else {
        configMap[SIGNAL_KAFKA_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[SIGNAL_KAFKA_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    record {|crypto:KeyStore keyStore; string keyPassword?;|}|kafka:CertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[SIGNAL_KAFKA_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SIGNAL_KAFKA_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is kafka:CertKey {
        string|error certContent = readFileContent(keyConfig.certFile);
        string|error keyContent = readFileContent(keyConfig.keyFile);

        if certContent is string && keyContent is string {
            configMap[SIGNAL_KAFKA_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[SIGNAL_KAFKA_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[SIGNAL_KAFKA_SSL_KEYSTORE_KEY] = keyContent;

            string? keyPassword = keyConfig.keyPassword;
            if keyPassword is string {
                configMap[SIGNAL_KAFKA_SSL_KEY_PASSWORD] = keyPassword;
            }
        }
    }

    string[]? ciphers = secure.ciphers;
    if ciphers is string[] && ciphers.length() > 0 {
        configMap[SIGNAL_KAFKA_SSL_CIPHER_SUITES] = string:'join(",", ...ciphers);
    }

    record {| kafka:Protocol name; string[] versions?;|}? protocolConfig = secure.protocol;
    if protocolConfig is record {| kafka:Protocol name; string[] versions?; |} {
        configMap[SIGNAL_KAFKA_SSL_PROTOCOL] = protocolConfig.name.toString();
        string[]? versions = protocolConfig.versions;
        if versions is string[] && versions.length() > 0 {
            configMap[SIGNAL_KAFKA_SSL_ENABLED_PROTOCOLS] = string:'join(",", ...versions);
        }
    }

    string? provider = secure.provider;
    if provider is string {
        configMap[SIGNAL_KAFKA_SSL_PROVIDER] = provider;
    }
}

# Populates extended snapshot configuration properties.
#
# + config - extended snapshot configuration
# + configMap - map to populate with snapshot properties
public isolated function populateExtendedSnapshotConfiguration(ExtendedSnapshotConfiguration config, map<string> configMap) {
    decimal? delay = config.delay;
    if delay is decimal {
        configMap[SNAPSHOT_DELAY_MS] = getMillisecondValueOf(delay);
    }

    int? fetchSize = config.fetchSize;
    if fetchSize is int {
        configMap[SNAPSHOT_FETCH_SIZE] = fetchSize.toString();
    }

    configMap[SNAPSHOT_MAX_THREADS] = config.maxThreads.toString();

    string|string[]? includeCollectionList = config.includeCollectionList;
    if includeCollectionList is string {
        configMap[SNAPSHOT_INCLUDE_COLLECTION_LIST] = includeCollectionList;
    } else if includeCollectionList is string[] {
        configMap[SNAPSHOT_INCLUDE_COLLECTION_LIST] = string:'join(",", ...includeCollectionList);
    }

    IncrementalSnapshotConfiguration? incrementalConfig = config.incrementalConfig;
    if incrementalConfig is IncrementalSnapshotConfiguration {
        populateIncrementalSnapshotConfiguration(incrementalConfig, configMap);
    }
}

# Populates relational database extended snapshot configuration properties.
#
# + config - relational extended snapshot configuration
# + configMap - map to populate with relational snapshot properties
public isolated function populateRelationalExtendedSnapshotConfiguration(RelationalExtendedSnapshotConfiguration config, map<string> configMap) {
    // First populate the common extended snapshot properties
    populateExtendedSnapshotConfiguration(config, configMap);

    // Then populate relational-specific properties
    SnapshotIsolationMode? isolationMode = config.isolationMode;
    if isolationMode is SnapshotIsolationMode {
        configMap[SNAPSHOT_ISOLATION_MODE] = isolationMode;
    }

    SnapshotLockingMode? lockingMode = config.lockingMode;
    if lockingMode is SnapshotLockingMode {
        configMap[SNAPSHOT_LOCKING_MODE] = lockingMode;
    }

    string|string[]? selectStatementOverrides = config.selectStatementOverrides;
    if selectStatementOverrides is string {
        configMap[SNAPSHOT_SELECT_STATEMENT_OVERRIDES] = selectStatementOverrides;
    } else if selectStatementOverrides is string[] {
        configMap[SNAPSHOT_SELECT_STATEMENT_OVERRIDES] = string:'join(",", ...selectStatementOverrides);
    }

    SnapshotQueryMode? queryMode = config.queryMode;
    if queryMode is SnapshotQueryMode {
        configMap[SNAPSHOT_QUERY_MODE] = queryMode;
    }
}

# Populates incremental snapshot configuration properties.
#
# + config - incremental snapshot configuration
# + configMap - map to populate with incremental snapshot properties
public isolated function populateIncrementalSnapshotConfiguration(IncrementalSnapshotConfiguration config, map<string> configMap) {
    configMap[INCREMENTAL_SNAPSHOT_CHUNK_SIZE] = config.chunkSize.toString();
    configMap[INCREMENTAL_SNAPSHOT_WATERMARKING_STRATEGY] = config.watermarkingStrategy;
    configMap[INCREMENTAL_SNAPSHOT_ALLOW_SCHEMA_CHANGES] = config.allowSchemaChanges.toString();
}

# Populates transaction metadata configuration properties.
#
# + config - transaction metadata configuration
# + configMap - map to populate with transaction metadata properties
public isolated function populateTransactionMetadataConfiguration(TransactionMetadataConfiguration config, map<string> configMap) {
    configMap[PROVIDE_TRANSACTION_METADATA] = config.enabled.toString();
    configMap[TRANSACTION_TOPIC] = config.topicName;
}

# Populates column transformation configuration properties.
#
# + config - column transformation configuration
# + configMap - map to populate with column transformation properties
public isolated function populateColumnTransformConfiguration(ColumnTransformConfiguration config, map<string> configMap) {
    ColumnHashMask[]? maskWithHash = config.maskWithHash;
    if maskWithHash is ColumnHashMask[] {
        foreach var mask in maskWithHash {
            string|string[] patterns = mask.regexPatterns;
            string patternStr = patterns is string ? patterns : string:'join(", ", ...patterns);
            string hashKey = string `column.mask.hash.v2.${mask.algorithm}.with.salt.${mask.salt}`;
            configMap[hashKey] = patternStr;
        }
    }

    ColumnCharMask[]? maskWithChars = config.maskWithChars;
    if maskWithChars is ColumnCharMask[] {
        foreach var mask in maskWithChars {
            string|string[] patterns = mask.regexPatterns;
            string patternStr = patterns is string ? patterns : string:'join(", ", ...patterns);
            // Format: column.mask.with.<length>.chars = <pattern>
            string maskKey = string `column.mask.with.${mask.length}.chars`;
            configMap[maskKey] = patternStr;
        }
    }

    ColumnTruncate[]? truncateToChars = config.truncateToChars;
    if truncateToChars is ColumnTruncate[] {
        foreach var truncate in truncateToChars {
            string|string[] patterns = truncate.regexPatterns;
            string patternStr = patterns is string ? patterns : string:'join(", ", ...patterns);
            string truncateKey = string `column.truncate.to.${truncate.length}.chars`;
            configMap[truncateKey] = patternStr;
        }
    }
}

# Populates topic configuration properties.
#
# + config - topic configuration
# + configMap - map to populate with topic properties
public isolated function populateTopicConfiguration(TopicConfiguration config, map<string> configMap) {
    configMap[TOPIC_DELIMITER] = config.delimiter;
    configMap[TOPIC_NAMING_STRATEGY] = config.namingStrategy;
}

# Populates data type configuration properties.
#
# + config - data type configuration
# + configMap - map to populate with data type properties
public isolated function populateDataTypeConfiguration(DataTypeConfiguration config, map<string> configMap) {
    configMap[BINARY_HANDLING_MODE] = config.binaryHandlingMode;
    configMap[TIME_PRECISION_MODE] = config.timePrecisionMode;
}

# Populates error handling configuration properties.
#
# + config - error handling configuration
# + configMap - map to populate with error handling properties
public isolated function populateErrorHandlingConfiguration(ErrorHandlingConfiguration config, map<string> configMap) {
    configMap[ERRORS_MAX_RETRIES] = config.maxRetryAttempts.toString();
    configMap[ERRORS_RETRY_DELAY_INITIAL_MS] = getMillisecondValueOf(config.retriableRestartWait);
    configMap[TOMBSTONES_ON_DELETE] = config.tombstonesOnDelete.toString();
}

# Populates performance configuration properties.
#
# + config - performance configuration
# + configMap - map to populate with performance properties
public isolated function populatePerformanceConfiguration(PerformanceConfiguration config, map<string> configMap) {
    configMap[MAX_QUEUE_SIZE_IN_BYTES] = config.maxQueueSizeInBytes.toString();
    configMap[POLL_INTERVAL_MS] = getMillisecondValueOf(config.pollInterval);

    int? queryFetchSize = config.queryFetchSize;
    if queryFetchSize is int {
        configMap[QUERY_FETCH_SIZE] = queryFetchSize.toString();
    }
}

# Populates monitoring configuration properties.
#
# + config - monitoring configuration
# + configMap - map to populate with monitoring properties
public isolated function populateMonitoringConfiguration(MonitoringConfiguration config, map<string> configMap) {
    string? customMetricTags = config.customMetricTags;
    if customMetricTags is string {
        configMap[CUSTOM_METRIC_TAGS] = customMetricTags;
    }
}

# Populates guardrail configuration properties.
#
# + config - guardrail configuration
# + configMap - map to populate with guardrail properties
public isolated function populateGuardrailConfiguration(GuardrailConfiguration config, map<string> configMap) {
    // Note: Debezium doesn't have direct guardrail properties
    // This is a placeholder for future implementation
}

# Populates JDBC schema history configuration properties.
#
# + storage - JDBC schema history configuration
# + configMap - map to populate with JDBC schema history properties
public isolated function populateJdbcSchemaHistoryConfiguration(JdbcInternalSchemaStorage storage, map<string> configMap) {
    configMap[SCHEMA_HISTORY_INTERNAL_JDBC_URL] = storage.url;

    string? user = storage.username;
    if user is string {
        configMap[SCHEMA_HISTORY_INTERNAL_JDBC_USER] = user;
    }

    string? password = storage.password;
    if password is string {
        configMap[SCHEMA_HISTORY_INTERNAL_JDBC_PASSWORD] = password;
    }

    configMap[SCHEMA_HISTORY_INTERNAL_JDBC_RETRY_DELAY_MS] = getMillisecondValueOf(storage.retryDelay);
    configMap[SCHEMA_HISTORY_INTERNAL_JDBC_RETRY_MAX_ATTEMPTS] = storage.retryMaxAttempts.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_NAME] = storage.tableName;

    string? tableDdl = storage.tableDdl;
    if tableDdl is string {
        configMap[SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_DDL] = tableDdl;
    }

    string? tableSelect = storage.tableSelect;
    if tableSelect is string {
        configMap[SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_SELECT] = tableSelect;
    }

    string? tableInsert = storage.tableInsert;
    if tableInsert is string {
        configMap[SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_INSERT] = tableInsert;
    }

    string? tableDelete = storage.tableDelete;
    if tableDelete is string {
        configMap[SCHEMA_HISTORY_INTERNAL_JDBC_TABLE_DELETE] = tableDelete;
    }
}

# Populates Redis schema history configuration properties.
#
# + storage - Redis schema history configuration
# + configMap - map to populate with Redis schema history properties
public isolated function populateRedisSchemaHistoryConfiguration(RedisInternalSchemaStorage storage, map<string> configMap) {
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_KEY] = storage.key;
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_ADDRESS] = storage.address;

    string? user = storage.username;
    if user is string {
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_USER] = user;
    }

    string? password = storage.password;
    if password is string {
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_PASSWORD] = password;
    }

    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_DB_INDEX] = storage.dbIndex.toString();

    // Handle secure socket configuration
    RedisSecureSocket? secureSocket = storage.secureSocket;
    if secureSocket is RedisSecureSocket {
        // SSL is enabled when secureSocket is present
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_ENABLED] = "true";
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_HOSTNAME_VERIFICATION_ENABLED] = secureSocket.verifyHostName.toString();

        // Handle cert - can be crypto:TrustStore or string path
        crypto:TrustStore|string? cert = secureSocket.cert;
        if cert is crypto:TrustStore {
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE] = cert.path;
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE_PASSWORD] = cert.password;
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE_TYPE] = "JKS";
        } else if cert is string {
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE] = cert;
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_TRUSTSTORE_TYPE] = "PEM";
        }

        // Handle key - crypto:KeyStore only
        crypto:KeyStore? key = secureSocket.key;
        if key is crypto:KeyStore {
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_KEYSTORE] = key.path;
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_KEYSTORE_PASSWORD] = key.password;
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_KEYSTORE_TYPE] = "JKS";
        }
    } else {
        // SSL is disabled when secureSocket is not present
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_ENABLED] = "false";
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SSL_HOSTNAME_VERIFICATION_ENABLED] = "false";
    }

    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_CONNECTION_TIMEOUT_MS] = getMillisecondValueOf(storage.connectTimeout);
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_SOCKET_TIMEOUT_MS] = getMillisecondValueOf(storage.socketTimeout);
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_RETRY_INITIAL_DELAY_MS] = getMillisecondValueOf(storage.retryConfig.initialDelay);
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_RETRY_MAX_DELAY_MS] = getMillisecondValueOf(storage.retryConfig.maxDelay);
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_RETRY_MAX_ATTEMPTS] = storage.retryConfig.maxAttempts.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_ENABLED] = storage.waitConfig.enabled.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_TIMEOUT_MS] = getMillisecondValueOf(storage.waitConfig.timeout);
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_ENABLED] = storage.waitConfig.retryEnabled.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_DELAY_MS] = getMillisecondValueOf(storage.waitConfig.retryDelay);
    configMap[SCHEMA_HISTORY_INTERNAL_REDIS_CLUSTER_ENABLED] = storage.clusterEnabled.toString();
}

# Populates Amazon S3 schema history configuration properties.
#
# + storage - S3 schema history configuration
# + configMap - map to populate with S3 schema history properties
public isolated function populateS3SchemaHistoryConfiguration(AmazonS3InternalSchemaStorage storage, map<string> configMap) {
    string? accessKeyId = storage.accessKeyId;
    if accessKeyId is string {
        configMap[SCHEMA_HISTORY_INTERNAL_S3_ACCESS_KEY_ID] = accessKeyId;
    }

    string? secretAccessKey = storage.secretAccessKey;
    if secretAccessKey is string {
        configMap[SCHEMA_HISTORY_INTERNAL_S3_SECRET_ACCESS_KEY] = secretAccessKey;
    }

    string? region = storage.region;
    if region is string {
        configMap[SCHEMA_HISTORY_INTERNAL_S3_REGION] = region;
    }

    configMap[SCHEMA_HISTORY_INTERNAL_S3_BUCKET_NAME] = storage.bucketName;
    configMap[SCHEMA_HISTORY_INTERNAL_S3_OBJECT_NAME] = storage.objectName;

    string? endpoint = storage.endpoint;
    if endpoint is string {
        configMap[SCHEMA_HISTORY_INTERNAL_S3_ENDPOINT] = endpoint;
    }
}

# Populates Azure Blob schema history configuration properties.
#
# + storage - Azure Blob schema history configuration
# + configMap - map to populate with Azure Blob schema history properties
public isolated function populateAzureBlobSchemaHistoryConfiguration(AzureBlobInternalSchemaStorage storage, map<string> configMap) {
    configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_CONNECTION_STRING] = storage.connectionString;
    configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_ACCOUNT_NAME] = storage.accountName;
    configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_CONTAINER_NAME] = storage.containerName;
    configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_BLOB_NAME] = storage.blobName;
}

# Populates RocketMQ schema history configuration properties.
#
# + storage - RocketMQ schema history configuration
# + configMap - map to populate with RocketMQ schema history properties
public isolated function populateRocketMQSchemaHistoryConfiguration(RocketMQInternalSchemaStorage storage, map<string> configMap) {
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_TOPIC] = storage.topicName;
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_NAMESRV_ADDR] = storage.nameServerAddress;
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_ACL_ENABLED] = storage.aclEnabled.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_ACCESS_KEY] = storage.accessKey;
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_SECRET_KEY] = storage.secretKey;
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_RECOVERY_ATTEMPTS] = storage.recoveryAttempts.toString();
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_RECOVERY_POLL_INTERVAL_MS] = getMillisecondValueOf(storage.recoveryPollInterval);
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_STORE_RECORD_TIMEOUT] = getMillisecondValueOf(storage.storeRecordTimeout);
}

# Populates Redis offset storage configuration properties.
#
# + storage - Redis offset storage configuration
# + configMap - map to populate with Redis properties
public isolated function populateRedisOffsetStorageConfiguration(RedisOffsetStorage storage, map<string> configMap) {
    configMap[OFFSET_STORAGE_REDIS_KEY] = storage.key;
    configMap[OFFSET_STORAGE_REDIS_ADDRESS] = storage.address;

    string? user = storage.username;
    if user is string {
        configMap[OFFSET_STORAGE_REDIS_USER] = user;
    }

    string? password = storage.password;
    if password is string {
        configMap[OFFSET_STORAGE_REDIS_PASSWORD] = password;
    }

    configMap[OFFSET_STORAGE_REDIS_DB_INDEX] = storage.dbIndex.toString();

    // Handle secure socket configuration
    RedisSecureSocket? secureSocket = storage.secureSocket;
    if secureSocket is RedisSecureSocket {
        // SSL is enabled when secureSocket is present
        configMap[OFFSET_STORAGE_REDIS_SSL_ENABLED] = "true";
        configMap[OFFSET_STORAGE_REDIS_SSL_HOSTNAME_VERIFICATION_ENABLED] = secureSocket.verifyHostName.toString();

        // Handle cert - can be crypto:TrustStore or string path
        crypto:TrustStore|string? cert = secureSocket.cert;
        if cert is crypto:TrustStore {
            configMap[OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE] = cert.path;
            configMap[OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE_PASSWORD] = cert.password;
            configMap[OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE_TYPE] = "JKS";
        } else if cert is string {
            configMap[OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE] = cert;
            configMap[OFFSET_STORAGE_REDIS_SSL_TRUSTSTORE_TYPE] = "PEM";
        }

        // Handle key - crypto:KeyStore only
        crypto:KeyStore? key = secureSocket.key;
        if key is crypto:KeyStore {
            configMap[OFFSET_STORAGE_REDIS_SSL_KEYSTORE] = key.path;
            configMap[OFFSET_STORAGE_REDIS_SSL_KEYSTORE_PASSWORD] = key.password;
            configMap[OFFSET_STORAGE_REDIS_SSL_KEYSTORE_TYPE] = "JKS";
        }
    } else {
        // SSL is disabled when secureSocket is not present
        configMap[OFFSET_STORAGE_REDIS_SSL_ENABLED] = "false";
        configMap[OFFSET_STORAGE_REDIS_SSL_HOSTNAME_VERIFICATION_ENABLED] = "false";
    }

    configMap[OFFSET_STORAGE_REDIS_CONNECTION_TIMEOUT_MS] = getMillisecondValueOf(storage.connectTimeout);
    configMap[OFFSET_STORAGE_REDIS_SOCKET_TIMEOUT_MS] = getMillisecondValueOf(storage.socketTimeout);
    configMap[OFFSET_STORAGE_REDIS_RETRY_INITIAL_DELAY_MS] = getMillisecondValueOf(storage.retryConfig.initialDelay);
    configMap[OFFSET_STORAGE_REDIS_RETRY_MAX_DELAY_MS] = getMillisecondValueOf(storage.retryConfig.maxDelay);
    configMap[OFFSET_STORAGE_REDIS_RETRY_MAX_ATTEMPTS] = storage.retryConfig.maxAttempts.toString();
    configMap[OFFSET_STORAGE_REDIS_WAIT_ENABLED] = storage.waitConfig.enabled.toString();
    configMap[OFFSET_STORAGE_REDIS_WAIT_TIMEOUT_MS] = getMillisecondValueOf(storage.waitConfig.timeout);
    configMap[OFFSET_STORAGE_REDIS_WAIT_RETRY_ENABLED] = storage.waitConfig.retryEnabled.toString();
    configMap[OFFSET_STORAGE_REDIS_WAIT_RETRY_DELAY_MS] = getMillisecondValueOf(storage.waitConfig.retryDelay);
    configMap[OFFSET_STORAGE_REDIS_CLUSTER_ENABLED] = storage.clusterEnabled.toString();
}

# Populates JDBC offset storage configuration properties.
#
# + storage - JDBC offset storage configuration
# + configMap - map to populate with JDBC properties
public isolated function populateJdbcOffsetStorageConfiguration(JdbcOffsetStorage storage, map<string> configMap) {
    configMap[OFFSET_STORAGE_JDBC_URL] = storage.url;

    string? user = storage.username;
    if user is string {
        configMap[OFFSET_STORAGE_JDBC_USER] = user;
    }

    string? password = storage.password;
    if password is string {
        configMap[OFFSET_STORAGE_JDBC_PASSWORD] = password;
    }

    configMap[OFFSET_STORAGE_JDBC_RETRY_DELAY_MS] = getMillisecondValueOf(storage.retryDelay);
    configMap[OFFSET_STORAGE_JDBC_RETRY_MAX_ATTEMPTS] = storage.retryMaxAttempts.toString();
    configMap[OFFSET_STORAGE_JDBC_TABLE_NAME] = storage.tableName;

    string? tableDdl = storage.tableDdl;
    if tableDdl is string {
        configMap[OFFSET_STORAGE_JDBC_TABLE_DDL] = tableDdl;
    }

    string? tableSelect = storage.tableSelect;
    if tableSelect is string {
        configMap[OFFSET_STORAGE_JDBC_TABLE_SELECT] = tableSelect;
    }

    string? tableInsert = storage.tableInsert;
    if tableInsert is string {
        configMap[OFFSET_STORAGE_JDBC_TABLE_INSERT] = tableInsert;
    }

    string? tableDelete = storage.tableDelete;
    if tableDelete is string {
        configMap[OFFSET_STORAGE_JDBC_TABLE_DELETE] = tableDelete;
    }
}

isolated function populateAdditionalConfigurations(Options options, map<string> configMap, typedesc<Options> optionsSubType) {
    string[] additionalConfigKeys = getAdditionalConfigKeys(options, optionsSubType);
    foreach string key in additionalConfigKeys {
        anydata value = options[key];
        if value !is string { 
        // TODO: We should allow primitive types and convert them to string instead of restricting to string type only. 
        //We need to update/remove testNonStringAdditionalPropertiesIgnored after that change.
            log:printError(string `Invalid additional configuration type for option ${key}: ${value.toBalString()}, Only string values are allowed.`);
            continue;
        }
        configMap[key] = value;
    }
}

isolated function getAdditionalConfigKeys(Options options, typedesc<Options> optionsSubType) returns string[] => externGetAdditionalConfigKeys(options, optionsSubType);
