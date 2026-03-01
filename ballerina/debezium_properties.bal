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
const string MESSAGE_KEY_COLUMNS = "message.key.columns";
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
const string SOURCE = "source";
const string KAFKA = "kafka";
const string FILE = "file";
const string JMX = "jmx";
const string SIGNAL_ENABLED_CHANNELS = "signal.enabled.channels";
const string SIGNAL_DATA_COLLECTION = "signal.data.collection";
const string SIGNAL_KAFKA_TOPIC = "signal.kafka.topic";
const string SIGNAL_KAFKA_BOOTSTRAP_SERVERS = "signal.kafka.bootstrap.servers";
const string SIGNAL_KAFKA_GROUP_ID = "signal.kafka.groupId";
const string SIGNAL_KAFKA_POLL_TIMEOUT = "signal.kafka.poll.timeout.ms";
const string SIGNAL_FILE = "signal.file";

// Signal Kafka consumer pass-through properties
// (prefix: signal.consumer.* per KafkaSignalChannel implementation)
const string SIGNAL_CONSUMER_SECURITY_PROTOCOL = "signal.consumer.security.protocol";
const string SIGNAL_CONSUMER_SASL_MECHANISM = "signal.consumer.sasl.mechanism";
const string SIGNAL_CONSUMER_SASL_JAAS_CONFIG = "signal.consumer.sasl.jaas.config";
const string SIGNAL_CONSUMER_SSL_KEYSTORE_LOCATION = "signal.consumer.ssl.keystore.location";
const string SIGNAL_CONSUMER_SSL_KEYSTORE_PASSWORD = "signal.consumer.ssl.keystore.password";
const string SIGNAL_CONSUMER_SSL_KEYSTORE_TYPE = "signal.consumer.ssl.keystore.type";
const string SIGNAL_CONSUMER_SSL_KEYSTORE_CERTIFICATE_CHAIN = "signal.consumer.ssl.keystore.certificate.chain";
const string SIGNAL_CONSUMER_SSL_KEYSTORE_KEY = "signal.consumer.ssl.keystore.key";
const string SIGNAL_CONSUMER_SSL_KEY_PASSWORD = "signal.consumer.ssl.key.password";
const string SIGNAL_CONSUMER_SSL_TRUSTSTORE_LOCATION = "signal.consumer.ssl.truststore.location";
const string SIGNAL_CONSUMER_SSL_TRUSTSTORE_PASSWORD = "signal.consumer.ssl.truststore.password";
const string SIGNAL_CONSUMER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM = "signal.consumer.ssl.endpoint.identification.algorithm";
const string SIGNAL_CONSUMER_SSL_TRUSTSTORE_TYPE = "signal.consumer.ssl.truststore.type";
const string SIGNAL_CONSUMER_SSL_CIPHER_SUITES = "signal.consumer.ssl.cipher.suites";
const string SIGNAL_CONSUMER_SSL_PROTOCOL = "signal.consumer.ssl.protocol";
const string SIGNAL_CONSUMER_SSL_ENABLED_PROTOCOLS = "signal.consumer.ssl.enabled.protocols";
const string SIGNAL_CONSUMER_SSL_PROVIDER = "signal.consumer.ssl.provider";

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
const string ERRORS_RETRY_DELAY_MAX_MS = "errors.retry.delay.max.ms";

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
