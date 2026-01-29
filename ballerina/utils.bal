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
const string TOPIC_PREFIX = "topic.prefix";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_BOOTSTRAP_SERVERS = "schema.history.internal.kafka.bootstrap.servers";
const string SCHEMA_HISTORY_INTERNAL_KAFKA_TOPIC = "schema.history.internal.kafka.topic";
const string SCHEMA_HISTORY_INTERNAL_FILE_FILENAME = "schema.history.internal.file.filename";
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

# Processes the given configuration and populates the map with the necessary debezium properties.
#
# + config - listener configuration
# + configMap - map to populate with debezium properties
public isolated function populateDebeziumProperties(ListenerConfiguration config, map<string> configMap) {

    configMap[NAME] = config.engineName;

    populateSchemaHistoryConfigurations(config.internalSchemaStorage, configMap);

    populateOffsetStorageConfigurations(config.offsetStorage, configMap);

    populateOptions(config.options, configMap);

    // The following values cannot be overridden by the user
    configMap[TOMBSTONES_ON_DELETE] = "false";
    configMap[INCLUDE_SCHEMA_CHANGES] = "false";
}

isolated function populateSchemaHistoryConfigurations(FileInternalSchemaStorage|KafkaInternalSchemaStorage schemaHistoryInternal, map<string> configMap) {
    configMap[SCHEMA_HISTORY_INTERNAL] = schemaHistoryInternal.className;
    configMap[TOPIC_PREFIX] = schemaHistoryInternal.topicPrefix;

    if schemaHistoryInternal is KafkaInternalSchemaStorage {
        string|string[] bootstrapServers = schemaHistoryInternal.bootstrapServers;
        configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_BOOTSTRAP_SERVERS] = bootstrapServers is string ? bootstrapServers : string:'join(",", ...bootstrapServers);
        configMap[SCHEMA_HISTORY_INTERNAL_KAFKA_TOPIC] = schemaHistoryInternal.topicName;

        kafka:SecurityProtocol? securityProtocol = schemaHistoryInternal.securityProtocol;
        if securityProtocol is kafka:SecurityProtocol {
            configMap[SCHEMA_HISTORY_PRODUCER_SECURITY_PROTOCOL] = securityProtocol;
            configMap[SCHEMA_HISTORY_CONSUMER_SECURITY_PROTOCOL] = securityProtocol;
        }

        kafka:AuthenticationConfiguration? auth = schemaHistoryInternal.auth;
        if auth is kafka:AuthenticationConfiguration {
            populateSchemaHistoryAuthConfigurations(auth, configMap);
        }

        kafka:SecureSocket? secureSocket = schemaHistoryInternal.secureSocket;
        if secureSocket is kafka:SecureSocket {
            populateSchemaHistorySecureSocketConfigurations(secureSocket, configMap);
        }
    } else {
        configMap[SCHEMA_HISTORY_INTERNAL_FILE_FILENAME] = schemaHistoryInternal.fileName;
    }
}

isolated function populateOffsetStorageConfigurations(FileOffsetStorage|KafkaOffsetStorage offsetStorage, map<string> configMap) {
    configMap[OFFSET_STORAGE] = offsetStorage.className;
    configMap[OFFSET_FLUSH_INTERVAL_MS] = getMillisecondValueOf(offsetStorage.flushInterval);
    configMap[OFFSET_FLUSH_TIMEOUT_MS] = getMillisecondValueOf(offsetStorage.flushTimeout);

    if offsetStorage is KafkaOffsetStorage {
        string|string[] offsetStorageBootstrapServers = offsetStorage.bootstrapServers;
        configMap[OFFSET_BOOTSTRAP_SERVERS] = offsetStorageBootstrapServers is string ? offsetStorageBootstrapServers : string:'join(",", ...offsetStorageBootstrapServers);
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
    } else {
        configMap[OFFSET_STORAGE_FILE_FILENAME] = offsetStorage.fileName;
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
        // cert is string - assume PEM format certificate
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_TRUSTSTORE_TYPE] = "PEM";
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    // Handle keystore configuration
    record {|crypto:KeyStore keyStore; string keyPassword?;|}|kafka:CertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is kafka:CertKey {
        // keyConfig is CertKey - use PEM format
        // Read certificate and key file contents
        string|error certContent = readFileContent(keyConfig.certFile);
        string|error keyContent = readFileContent(keyConfig.keyFile);

        if certContent is error {
            log:printError(string `Error reading certificate file: ${keyConfig.certFile}`, certContent);
        }
        if keyContent is error {
            log:printError(string `Error reading key file: ${keyConfig.keyFile}`, keyContent);
        }

        // Only configure if both files were read successfully
        if certContent is string && keyContent is string {
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_KEY] = keyContent;
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_KEY] = keyContent;

            // Set key password if provided
            string? keyPassword = keyConfig.keyPassword;
            if keyPassword is string {
                configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEY_PASSWORD] = keyPassword;
                configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEY_PASSWORD] = keyPassword;
            }
        }
    }

    // Handle cipher suites
    string[]? ciphers = secure.ciphers;
    if ciphers is string[] && ciphers.length() > 0 {
        string cipherSuites = string:'join(",", ...ciphers);
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_CIPHER_SUITES] = cipherSuites;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_CIPHER_SUITES] = cipherSuites;
    }

    // Handle SSL/TLS protocol configuration
    var protocolConfig = secure.protocol;
    if protocolConfig is record {| kafka:Protocol name; string[] versions?; |} {
        // Map the default protocol (e.g., TLS)
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_PROTOCOL] = protocolConfig.name.toString();
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_PROTOCOL] = protocolConfig.name.toString();

        // Map enabled protocol versions
        string[]? versions = protocolConfig.versions;
        if versions is string[] && versions.length() > 0 {
            string enabledProtocols = string:'join(",", ...versions);
            configMap[SCHEMA_HISTORY_PRODUCER_SSL_ENABLED_PROTOCOLS] = enabledProtocols;
            configMap[SCHEMA_HISTORY_CONSUMER_SSL_ENABLED_PROTOCOLS] = enabledProtocols;
        }
    }

    // Handle security provider
    string? provider = secure.provider;
    if provider is string {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_PROVIDER] = provider;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_PROVIDER] = provider;
    }
}

isolated function populateOffsetAuthConfigurations(kafka:AuthenticationConfiguration auth, map<string> configMap) {
    // Set SASL configurations if provided
    configMap[OFFSET_SASL_MECHANISM] = auth.mechanism;

    // Generate JAAS config from username and password based on mechanism
    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[OFFSET_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateOffsetSecureSocketConfigurations(kafka:SecureSocket secure, map<string> configMap) {
    crypto:TrustStore|string cert = secure.cert;
    if cert is crypto:TrustStore {
        configMap[OFFSET_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[OFFSET_SSL_TRUSTSTORE_PASSWORD] = cert.password;
    } else {
        // cert is string - assume PEM format certificate
        configMap[OFFSET_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[OFFSET_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    // Handle keystore configuration
    record {| crypto:KeyStore keyStore; string keyPassword?;|}|kafka:CertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[OFFSET_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[OFFSET_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is kafka:CertKey {
        // keyConfig is CertKey - use PEM format
        // Read certificate and key file contents
        string|error certContent = readFileContent(keyConfig.certFile);
        string|error keyContent = readFileContent(keyConfig.keyFile);

        if certContent is error {
            log:printError(string `Error reading certificate file: ${keyConfig.certFile}`, certContent);
        }
        if keyContent is error {
            log:printError(string `Error reading key file: ${keyConfig.keyFile}`, keyContent);
        }

        // Only configure if both files were read successfully
        if certContent is string && keyContent is string {
            configMap[OFFSET_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[OFFSET_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[OFFSET_SSL_KEYSTORE_KEY] = keyContent;

            // Set key password if provided
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

isolated function populateOptions(Options options, map<string> configMap) {
    configMap[MAX_QUEUE_SIZE] = options.maxQueueSize.toString();
    configMap[MAX_BATCH_SIZE] = options.maxBatchSize.toString();
    configMap[EVENT_PROCESSING_FAILURE_HANDLING_MODE] = options.eventProcessingFailureHandlingMode;
    configMap[SNAPSHOT_MODE] = options.snapshotMode;
    configMap[SKIPPED_OPERATIONS] = string:'join(",", ...options.skippedOperations);
    configMap[SKIP_MESSAGES_WITHOUT_CHANGE] = options.skipMessagesWithoutChange.toString();
    configMap[DECIMAL_HANDLING_MODE] = options.decimalHandlingMode;
    configMap[DATABASE_QUERY_TIMEOUTS_MS] = getMillisecondValueOf(options.queryTimeout);
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

    if connection.connectTimeout !is () {
        configMap[CONNECT_TIMEOUT_MS] = getMillisecondValueOf(connection.connectTimeout ?: 0);
    }

    populateSslConfigurations(connection, configMap);
    populateTableAndColumnConfigurations(connection, configMap);
}

isolated function populateSslConfigurations(DatabaseConnection connection, map<string> configMap) {
    SecureDatabaseConnection? secure = connection.secure;
    if secure !is () {
        configMap[DATABASE_SSL_MODE] = secure.sslMode.toString();

        crypto:KeyStore? keyStore = secure.keyStore;
        if keyStore !is () {
            configMap[DATABASE_SSL_KEYSTORE] = keyStore.path;
            configMap[DATABASE_SSL_KEYSTORE_PASSWORD] = keyStore.password;
        }

        crypto:TrustStore? trustStore = secure.trustStore;
        if trustStore !is () {
            configMap[DATABASE_SSL_TRUSTSTORE] = trustStore.path;
            configMap[DATABASE_SSL_TRUSTSTORE_PASSWORD] = trustStore.password;
        }
    }
}

// Populates table and column inclusion/exclusion configurations
isolated function populateTableAndColumnConfigurations(DatabaseConnection connection, map<string> configMap) {
    string|string[]? includedTables = connection.includedTables;
    if includedTables !is () {
        configMap[TABLE_INCLUDE_LIST] = includedTables is string ? includedTables : string:'join(",", ...includedTables);
    }

    string|string[]? excludedTables = connection.excludedTables;
    if excludedTables !is () {
        configMap[TABLE_EXCLUDE_LIST] = excludedTables is string ? excludedTables : string:'join(",", ...excludedTables);
    }

    string|string[]? includedColumns = connection.includedColumns;
    if includedColumns !is () {
        configMap[COLUMN_INCLUDE_LIST] = includedColumns is string ? includedColumns : string:'join(",", ...includedColumns);
    }

    string|string[]? excludedColumns = connection.excludedColumns;
    if excludedColumns !is () {
        configMap[COLUMN_EXCLUDE_LIST] = excludedColumns is string ? excludedColumns : string:'join(",", ...excludedColumns);
    }
}

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}

isolated function generateJaasConfig(kafka:AuthenticationMechanism mechanism, string username, string password) returns string {
    // Generate JAAS config based on the SASL mechanism
    // Only PLAIN and SCRAM mechanisms are supported (username/password based)
    string loginModule;

    if mechanism == kafka:AUTH_SASL_PLAIN {
        loginModule = "org.apache.kafka.common.security.plain.PlainLoginModule";
    } else if mechanism == kafka:AUTH_SASL_SCRAM_SHA_256 || mechanism == kafka:AUTH_SASL_SCRAM_SHA_512 {
        loginModule = "org.apache.kafka.common.security.scram.ScramLoginModule";
    }
    return string `${loginModule} required username="${username}" password="${password}";`;
}

isolated function readFileContent(string filePath) returns string|error {
    return io:fileReadString(filePath);
}
