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

        KafkaSecurityProtocol? securityProtocol = offsetStorage.securityProtocol;
        if securityProtocol is KafkaSecurityProtocol {
            configMap[OFFSET_SECURITY_PROTOCOL] = securityProtocol;
        }

        KafkaAuthenticationConfiguration? auth = offsetStorage.auth;
        if auth is KafkaAuthenticationConfiguration {
            populateOffsetAuthConfigurations(auth, configMap);
        }

        KafkaSecureSocket? secureSocket = offsetStorage.secureSocket;
        if secureSocket is KafkaSecureSocket {
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

    KafkaSecurityProtocol? securityProtocol = storage.securityProtocol;
    if securityProtocol is KafkaSecurityProtocol {
        configMap[SCHEMA_HISTORY_PRODUCER_SECURITY_PROTOCOL] = securityProtocol;
        configMap[SCHEMA_HISTORY_CONSUMER_SECURITY_PROTOCOL] = securityProtocol;
    }

    KafkaAuthenticationConfiguration? auth = storage.auth;
    if auth is KafkaAuthenticationConfiguration {
        populateSchemaHistoryAuthConfigurations(auth, configMap);
    }

    KafkaSecureSocket? secureSocket = storage.secureSocket;
    if secureSocket is KafkaSecureSocket {
        populateSchemaHistorySecureSocketConfigurations(secureSocket, configMap);
    }
}

isolated function populateSchemaHistoryAuthConfigurations(KafkaAuthenticationConfiguration auth, map<string> configMap) {
    configMap[SCHEMA_HISTORY_PRODUCER_SASL_MECHANISM] = auth.mechanism;
    configMap[SCHEMA_HISTORY_CONSUMER_SASL_MECHANISM] = auth.mechanism;

    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[SCHEMA_HISTORY_PRODUCER_SASL_JAAS_CONFIG] = jaasConfig;
    configMap[SCHEMA_HISTORY_CONSUMER_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateSchemaHistorySecureSocketConfigurations(KafkaSecureSocket secure, map<string> configMap) {
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

    record {|crypto:KeyStore keyStore; string keyPassword?;|}|KafkaSecureSocketCertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SCHEMA_HISTORY_PRODUCER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SCHEMA_HISTORY_CONSUMER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is KafkaSecureSocketCertKey {
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
    if protocolConfig is record {| KafkaSecureSocketProtocol name; string[] versions?; |} {
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

isolated function populateOffsetAuthConfigurations(KafkaAuthenticationConfiguration auth, map<string> configMap) {
    configMap[OFFSET_SASL_MECHANISM] = auth.mechanism;
    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[OFFSET_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateOffsetSecureSocketConfigurations(KafkaSecureSocket secure, map<string> configMap) {
    crypto:TrustStore|string cert = secure.cert;
    if cert is crypto:TrustStore {
        configMap[OFFSET_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[OFFSET_SSL_TRUSTSTORE_PASSWORD] = cert.password;
    } else {
        configMap[OFFSET_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[OFFSET_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    record {| crypto:KeyStore keyStore; string keyPassword?;|}|KafkaSecureSocketCertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[OFFSET_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[OFFSET_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is KafkaSecureSocketCertKey {
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

    record {| KafkaSecureSocketProtocol name; string[] versions?; |}? protocolConfig = secure.protocol;
    if protocolConfig is record {| KafkaSecureSocketProtocol name; string[] versions?; |} {
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

    HeartbeatConfiguration? heartbeatConfig = options.heartbeatConfig;
    if heartbeatConfig is HeartbeatConfiguration {
        populateHeartbeatConfiguration(heartbeatConfig, configMap);
    }

    SignalConfiguration? signalConfig = options.signalConfig;
    if signalConfig is SignalConfiguration {
        populateSignalConfiguration(signalConfig, configMap);
    }

    TransactionMetadataConfiguration? transactionMetadataConfig = options.transactionMetadataConfig;
    if transactionMetadataConfig is TransactionMetadataConfiguration {
        populateTransactionMetadataConfiguration(transactionMetadataConfig, configMap);
    }

    ColumnTransformConfiguration? columnTransformConfig = options.columnTransformConfig;
    if columnTransformConfig is ColumnTransformConfiguration {
        populateColumnTransformConfiguration(columnTransformConfig, configMap);
    }

    TopicConfiguration? topicConfig = options.topicConfig;
    if topicConfig is TopicConfiguration {
        populateTopicConfiguration(topicConfig, configMap);
    }

    ConnectionRetryConfiguration? connectionRetryConfig = options.connectionRetryConfig;
    if connectionRetryConfig is ConnectionRetryConfiguration {
        populateErrorHandlingConfiguration(connectionRetryConfig, configMap);
    }

    PerformanceConfiguration? performanceConfig = options.performanceConfig;
    if performanceConfig is PerformanceConfiguration {
        populatePerformanceConfiguration(performanceConfig, configMap);
    }

    MonitoringConfiguration? monitoringConfig = options.monitoringConfig;
    if monitoringConfig is MonitoringConfiguration {
        populateMonitoringConfiguration(monitoringConfig, configMap);
    }

    GuardrailConfiguration? guardrailConfig = options.guardrailConfig;
    if guardrailConfig is GuardrailConfiguration {
        populateGuardrailConfiguration(guardrailConfig, configMap);
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

# Populates table and column filtering configurations (relational databases only).
#
# + includedTables - Regex patterns for tables to include
# + excludedTables - Regex patterns for tables to exclude
# + includedColumns - Regex patterns for columns to include
# + excludedColumns - Regex patterns for columns to exclude
# + configMap - map to populate with filtering configurations
public isolated function populateTableAndColumnConfigurations(
        string|string[]? includedTables,
        string|string[]? excludedTables,
        string|string[]? includedColumns,
        string|string[]? excludedColumns,
        map<string> configMap) {

    if includedTables is string {
        configMap[TABLE_INCLUDE_LIST] = includedTables;
    } else if includedTables is string[] {
        configMap[TABLE_INCLUDE_LIST] = string:'join(",", ...includedTables);
    }

    if excludedTables is string {
        configMap[TABLE_EXCLUDE_LIST] = excludedTables;
    } else if excludedTables is string[] {
        configMap[TABLE_EXCLUDE_LIST] = string:'join(",", ...excludedTables);
    }

    if includedColumns is string {
        configMap[COLUMN_INCLUDE_LIST] = includedColumns;
    } else if includedColumns is string[] {
        configMap[COLUMN_INCLUDE_LIST] = string:'join(",", ...includedColumns);
    }

    if excludedColumns is string {
        configMap[COLUMN_EXCLUDE_LIST] = excludedColumns;
    } else if excludedColumns is string[] {
        configMap[COLUMN_EXCLUDE_LIST] = string:'join(",", ...excludedColumns);
    }
}

# Populates message.key.columns configuration (relational databases only).
# This property specifies the columns to use for the message key in change events.
#
# + messageKeyColumns - Composite message key columns specification
# + configMap - map to populate with message key columns configuration
public isolated function populateMessageKeyColumnsConfiguration(
        string? messageKeyColumns,
        map<string> configMap) {

    if messageKeyColumns !is () {
        configMap[MESSAGE_KEY_COLUMNS] = messageKeyColumns;
    }
}

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}

isolated function generateJaasConfig(KafkaAuthenticationMechanism mechanism, string username, string password) returns string {
    string loginModule;
    if mechanism == AUTH_SASL_PLAIN {
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
    string[] enabledChannels = [];

    SourceSignalConfiguration? sourceConfig = config.sourceConfig;
    if sourceConfig is SourceSignalConfiguration {
        enabledChannels.push(SOURCE);
        configMap[SIGNAL_DATA_COLLECTION] = sourceConfig.dataCollectionTable;
    }

    KafkaSignalConfiguration? kafkaConfig = config.kafkaConfig;
    if kafkaConfig is KafkaSignalConfiguration {
        enabledChannels.push(KAFKA);
        configMap[SIGNAL_KAFKA_TOPIC] = kafkaConfig.topicName;

        string|string[]? bootstrapServers = kafkaConfig.bootstrapServers;
        if bootstrapServers is string {
            configMap[SIGNAL_KAFKA_BOOTSTRAP_SERVERS] = bootstrapServers;
        } else if bootstrapServers is string[] {
            configMap[SIGNAL_KAFKA_BOOTSTRAP_SERVERS] = string:'join(",", ...bootstrapServers);
        }

        configMap[SIGNAL_KAFKA_GROUP_ID] = kafkaConfig.groupId;

        KafkaSecurityProtocol? securityProtocol = kafkaConfig.securityProtocol;
        if securityProtocol is KafkaSecurityProtocol {
            configMap[SIGNAL_CONSUMER_SECURITY_PROTOCOL] = securityProtocol;
        }

        KafkaAuthenticationConfiguration? auth = kafkaConfig.auth;
        if auth is KafkaAuthenticationConfiguration {
            populateSignalConsumerAuthConfigurations(auth, configMap);
        }

        KafkaSecureSocket? secureSocket = kafkaConfig.secureSocket;
        if secureSocket is KafkaSecureSocket {
            populateSignalConsumerSecureSocketConfigurations(secureSocket, configMap);
        }

        configMap[SIGNAL_KAFKA_POLL_TIMEOUT] = getMillisecondValueOf(kafkaConfig.pollTimeout);
    }

    FileSignalConfiguration? fileConfig = config.fileConfig;
    if fileConfig is FileSignalConfiguration {
        enabledChannels.push(FILE);
        configMap[SIGNAL_FILE] = fileConfig.fileName;
    }

    JmxSignalConfiguration? jmxConfig = config.jmxConfig;
    if jmxConfig is JmxSignalConfiguration {
        enabledChannels.push(JMX);
        // JMX requires no additional configuration
    }

    if enabledChannels.length() > 0 {
        configMap[SIGNAL_ENABLED_CHANNELS] = string:'join(",", ...enabledChannels);
    }
}

isolated function populateSignalConsumerAuthConfigurations(KafkaAuthenticationConfiguration auth, map<string> configMap) {
    configMap[SIGNAL_CONSUMER_SASL_MECHANISM] = auth.mechanism;
    string jaasConfig = generateJaasConfig(auth.mechanism, auth.username, auth.password);
    configMap[SIGNAL_CONSUMER_SASL_JAAS_CONFIG] = jaasConfig;
}

isolated function populateSignalConsumerSecureSocketConfigurations(KafkaSecureSocket secure, map<string> configMap) {
    crypto:TrustStore|string cert = secure.cert;
    if cert is crypto:TrustStore {
        configMap[SIGNAL_CONSUMER_SSL_TRUSTSTORE_LOCATION] = cert.path;
        configMap[SIGNAL_CONSUMER_SSL_TRUSTSTORE_PASSWORD] = cert.password;
    } else {
        configMap[SIGNAL_CONSUMER_SSL_TRUSTSTORE_LOCATION] = cert;
        configMap[SIGNAL_CONSUMER_SSL_TRUSTSTORE_TYPE] = "PEM";
    }

    record {|crypto:KeyStore keyStore; string keyPassword?;|}|KafkaSecureSocketCertKey? keyConfig = secure.key;
    if keyConfig is record {| crypto:KeyStore keyStore; string keyPassword?; |} {
        configMap[SIGNAL_CONSUMER_SSL_KEYSTORE_LOCATION] = keyConfig.keyStore.path;
        configMap[SIGNAL_CONSUMER_SSL_KEYSTORE_PASSWORD] = keyConfig.keyStore.password;
    } else if keyConfig is KafkaSecureSocketCertKey {
        string|error certContent = readFileContent(keyConfig.certFile);
        string|error keyContent = readFileContent(keyConfig.keyFile);
        if certContent is error {
            log:printError(string `Error reading certificate file: ${keyConfig.certFile}`, certContent);
        }
        if keyContent is error {
            log:printError(string `Error reading key file: ${keyConfig.keyFile}`, keyContent);
        }
        if certContent is string && keyContent is string {
            configMap[SIGNAL_CONSUMER_SSL_KEYSTORE_TYPE] = "PEM";
            configMap[SIGNAL_CONSUMER_SSL_KEYSTORE_CERTIFICATE_CHAIN] = certContent;
            configMap[SIGNAL_CONSUMER_SSL_KEYSTORE_KEY] = keyContent;

            string? keyPassword = keyConfig.keyPassword;
            if keyPassword is string {
                configMap[SIGNAL_CONSUMER_SSL_KEY_PASSWORD] = keyPassword;
            }
        }
    }

    string[]? ciphers = secure.ciphers;
    if ciphers is string[] && ciphers.length() > 0 {
        configMap[SIGNAL_CONSUMER_SSL_CIPHER_SUITES] = string:'join(",", ...ciphers);
    }

    record {| KafkaSecureSocketProtocol name; string[] versions?; |}? protocolConfig = secure.protocol;
    if protocolConfig is record {| KafkaSecureSocketProtocol name; string[] versions?; |} {
        configMap[SIGNAL_CONSUMER_SSL_PROTOCOL] = protocolConfig.name.toString();
        string[]? versions = protocolConfig.versions;
        if versions is string[] && versions.length() > 0 {
            configMap[SIGNAL_CONSUMER_SSL_ENABLED_PROTOCOLS] = string:'join(",", ...versions);
        }
    }

    string? provider = secure.provider;
    if provider is string {
        configMap[SIGNAL_CONSUMER_SSL_PROVIDER] = provider;
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
public isolated function populateErrorHandlingConfiguration(ConnectionRetryConfiguration config, map<string> configMap) {
    configMap[ERRORS_MAX_RETRIES] = config.maxAttempts.toString();
    configMap[ERRORS_RETRY_DELAY_INITIAL_MS] = getMillisecondValueOf(config.retryInitialDelay);
    configMap[ERRORS_RETRY_DELAY_MAX_MS] = getMillisecondValueOf(config.retryMaxDelay);
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

# Populates guardrailConfig configuration properties.
#
# + config - guardrailConfig configuration
# + configMap - map to populate with guardrailConfig properties
public isolated function populateGuardrailConfiguration(GuardrailConfiguration config, map<string> configMap) {
    // Note: Debezium doesn't have direct guardrailConfig properties
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

    configMap[SCHEMA_HISTORY_INTERNAL_JDBC_RETRY_DELAY_MS] = getMillisecondValueOf(storage.retryConfig.retryDelay);
    configMap[SCHEMA_HISTORY_INTERNAL_JDBC_RETRY_MAX_ATTEMPTS] = storage.retryConfig.maxAttempts.toString();
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
    RedisWaitConfiguration? waitConfig = storage.waitConfig;
    if waitConfig is RedisWaitConfiguration {
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_ENABLED] = "true";
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_TIMEOUT_MS] = getMillisecondValueOf(waitConfig.timeout);
        decimal? retryDelay = waitConfig.retryDelay;
        if retryDelay is decimal {
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_ENABLED] = "true";
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_DELAY_MS] = getMillisecondValueOf(retryDelay);
        } else {
            configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_RETRY_ENABLED] = "false";
        }
    } else {
        configMap[SCHEMA_HISTORY_INTERNAL_REDIS_WAIT_ENABLED] = "false";
    }
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
    string? accountName = storage.accountName;
    if accountName is string {
        configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_ACCOUNT_NAME] = accountName;
    }
    configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_CONTAINER_NAME] = storage.containerName;
    string? blobName = storage.blobName;
    if blobName is string {
        configMap[SCHEMA_HISTORY_INTERNAL_AZURE_STORAGE_BLOB_NAME] = blobName;
    }
}

# Populates RocketMQ schema history configuration properties.
#
# + storage - RocketMQ schema history configuration
# + configMap - map to populate with RocketMQ schema history properties
public isolated function populateRocketMQSchemaHistoryConfiguration(RocketMQInternalSchemaStorage storage, map<string> configMap) {
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_TOPIC] = storage.topicName;
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_NAMESRV_ADDR] = storage.nameServerAddress;
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_ACL_ENABLED] = storage.aclEnabled.toString();
    string? accessKey = storage.accessKey;
    if accessKey is string {
        configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_ACCESS_KEY] = accessKey;
    }
    string? secretKey = storage.secretKey;
    if secretKey is string {
        configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_SECRET_KEY] = secretKey;
    }
    int? recoveryAttempts = storage.recoveryAttempts;
    if recoveryAttempts is int {
        configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_RECOVERY_ATTEMPTS] = recoveryAttempts.toString();
    }
    configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_RECOVERY_POLL_INTERVAL_MS] = getMillisecondValueOf(storage.recoveryPollInterval);
    decimal? storeRecordTimeout = storage.storeRecordTimeout;
    if storeRecordTimeout is decimal {
        configMap[SCHEMA_HISTORY_INTERNAL_ROCKETMQ_STORE_RECORD_TIMEOUT] = getMillisecondValueOf(storeRecordTimeout);
    }
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
    RedisWaitConfiguration? waitConfig = storage.waitConfig;
    if waitConfig is RedisWaitConfiguration {
        configMap[OFFSET_STORAGE_REDIS_WAIT_ENABLED] = "true";
        configMap[OFFSET_STORAGE_REDIS_WAIT_TIMEOUT_MS] = getMillisecondValueOf(waitConfig.timeout);
        decimal? retryDelay = waitConfig.retryDelay;
        if retryDelay is decimal {
            configMap[OFFSET_STORAGE_REDIS_WAIT_RETRY_ENABLED] = "true";
            configMap[OFFSET_STORAGE_REDIS_WAIT_RETRY_DELAY_MS] = getMillisecondValueOf(retryDelay);
        } else {
            configMap[OFFSET_STORAGE_REDIS_WAIT_RETRY_ENABLED] = "false";
        }
    } else {
        configMap[OFFSET_STORAGE_REDIS_WAIT_ENABLED] = "false";
    }
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

    configMap[OFFSET_STORAGE_JDBC_RETRY_DELAY_MS] = getMillisecondValueOf(storage.retryConfig.retryDelay);
    configMap[OFFSET_STORAGE_JDBC_RETRY_MAX_ATTEMPTS] = storage.retryConfig.maxAttempts.toString();
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

# Populates additional configuration properties from options record.
# Supports primitive types (string, int, boolean, decimal, float) which are converted to strings.
# Complex types (arrays, records, maps) are rejected and logged as errors.
#
# + options - Options record containing additional properties
# + configMap - Map to populate with additional configuration properties
# + optionsSubType - Type descriptor for the options subtype
isolated function populateAdditionalConfigurations(Options options, map<string> configMap, typedesc<Options> optionsSubType) {
    string[] additionalConfigKeys = getAdditionalConfigKeys(options, optionsSubType);
    foreach string key in additionalConfigKeys {
        anydata value = options[key];

        // Convert supported primitive types to string
        if value is string {
            configMap[key] = value;
        } else if value is int|boolean|decimal|float {
            configMap[key] = value.toString();
        } else {
            // Log error for unsupported types (arrays, records, etc.)
            log:printError(string `Unsupported additional configuration type for option ${key}: ${value.toBalString()}. Only string, int, boolean, decimal, and float values are supported.`);
            continue;
        }
    }
}

isolated function getAdditionalConfigKeys(Options options, typedesc<Options> optionsSubType) returns string[] => externGetAdditionalConfigKeys(options, optionsSubType);
