// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/crypto;
import ballerina/random;

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
public type KafkaInternalSchemaStorage record {|
    *SchemaHistoryInternal;
    string className = "io.debezium.storage.kafka.history.KafkaSchemaHistory";
    string topicName = "bal_cdc_internal_schema_history";
    string|string[] bootstrapServers;
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
public type KafkaOffsetStorage record {|
    *OffsetStorage;
    string className = "org.apache.kafka.connect.storage.KafkaOffsetBackingStore";
    string|string[] bootstrapServers;
    string topicName = "bal_cdc_offsets";
    int partitions = 1;
    int replicationFactor = 2;
|};

# Represents the base configuration for a database connection.
#
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

# Represents the configuration for a MySQL database connection.
#
# + hostname - The hostname of the MySQL server
# + port - The port number of the MySQL server
# + databaseServerId - The unique identifier for the MySQL server
# + includedDatabases - A list of regular expressions matching fully-qualified database identifiers to capture changes from (should not be used alongside databaseExclude)
# + excludedDatabases - A list of regular expressions matching fully-qualified database identifiers to exclude from change capture (should not be used alongside databaseInclude)
# + tasksMax - The maximum number of tasks to create for this connector. Because the MySQL connector always uses a single task, changing the default value has no effect
# + secure - The connector establishes an encrypted connection if the server supports secure connections
public type MySqlDatabaseConnection record {|
    *DatabaseConnection;
    string hostname = "localhost";
    int port = 3306;
    string databaseServerId = (checkpanic random:createIntInRange(0, 100000)).toString();
    string|string[] includedDatabases?;
    string|string[] excludedDatabases?;
    int tasksMax = 1;
    SecureDatabaseConnection secure = {};
|};

# Represents the configuration for an MSSQL database connection.
#
# + hostname - The hostname of the MSSQL server
# + port - The port number of the MSSQL server
# + databaseInstance - The name of the database instance
# + databaseNames - A list of database names to capture changes from
# + includedSchemas - A list of regular expressions matching fully-qualified schema identifiers to capture changes from
# + excludedSchemas - A list of regular expressions matching fully-qualified schema identifiers to exclude from change capture
# + tasksMax - The maximum number of tasks to create for this connector. If the `databaseNames` contains more than one element, you can increase the value of this property to a number less than or equal to the number of elements in the list
public type MsSqlDatabaseConnection record {|
    *DatabaseConnection;
    string hostname = "localhost";
    int port = 1433;
    string databaseInstance?;
    string|string[] databaseNames;
    string|string[] includedSchemas?;
    string|string[] excludedSchemas?;
    int tasksMax = 1;
|};

# Represents the base configuration for the CDC engine.
#
# + engineName - The name of the CDC engine
# + connectorClass - The class name of the connector implementation to use
# + maxQueueSize - The maximum size of the queue for events
# + maxBatchSize - The maximum size of the batch for events
# + queryTimeout - Specifies the time, in seconds, that the connector waits for a query to complete. Set the value to 0 (zero) to remove the timeout l
# + internalSchemaStorage - The internal schema history configuration
# + offsetStorage - The offset storage configuration
# + eventProcessingFailureHandlingMode - The mode for handling event processing failures
# + snapshotMode - The mode for capturing snapshots
# + skippedOperations - The list of operations to skip
# + skipMessagesWithoutChange - Whether to skip messages without changes
# + sendTombstonesOnDelete - Whether to include tombstones on delete operations
# + decimalHandlingMode - The mode for handling decimal values from the database
public type ListenerConfiguration record {|
    string engineName = "ballerina-cdc-connector";
    string connectorClass;
    int maxQueueSize = 8192;
    int maxBatchSize = 2048;
    decimal queryTimeout = 60;
    FileInternalSchemaStorage|KafkaInternalSchemaStorage internalSchemaStorage = {};
    FileOffsetStorage|KafkaOffsetStorage offsetStorage = {};
    EventProcessingFailureHandlingMode eventProcessingFailureHandlingMode = WARN;
    SnapshotMode snapshotMode = INITIAL;
    Operation[] skippedOperations = [TRUNCATE];
    boolean skipMessagesWithoutChange = false;
    boolean sendTombstonesOnDelete = false;
    DecimalHandlingMode decimalHandlingMode = DOUBLE;
|};

# Represents the configuration for a MySQL CDC connector.
#
# + connectorClass - The class name of the MySQL connector implementation to use
# + database - The MySQL database connection configuration
public type MySqlListenerConfiguration record {|
    *ListenerConfiguration;
    string connectorClass = "io.debezium.connector.mysql.MySqlConnector";
    MySqlDatabaseConnection database;
|};

# Represents the configuration for an MSSQL CDC connector.
#
# + connectorClass - The class name of the MSSQL connector implementation to use
# + database - The MSSQL database connection configuration
public type MsSqlListenerConfiguration record {|
    *ListenerConfiguration;
    string connectorClass = "io.debezium.connector.sqlserver.SqlServerConnector";
    MsSqlDatabaseConnection database;
|};
