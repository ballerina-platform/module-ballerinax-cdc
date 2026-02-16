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
import ballerina/random;

# Represents a Ballerina CDC MySQL Listener.
public isolated class MockListener {
    *Listener;

    private final map<anydata> & readonly config;
    private boolean isStarted = false;
    private boolean hasAttachedService = false;

    # Initializes the MySQL listener with the given configuration.
    #
    # + config - The configuration for the MySQL connector
    public isolated function init(*MySqlListenerConfiguration config) {
        map<string> debeziumConfigs = {};
        populateDebeziumProperties({
                                       engineName: config.engineName,
                                       offsetStorage: config.offsetStorage,
                                       internalSchemaStorage: config.internalSchemaStorage
                                   }, debeziumConfigs);
        populateDatabaseConfigurations({
                                           connectorClass: config.database.connectorClass,
                                           hostname: config.database.hostname,
                                           port: config.database.port,
                                           username: config.database.username,
                                           password: config.database.password,
                                           connectTimeout: config.database.connectTimeout,
                                           tasksMax: config.database.tasksMax,
                                           secure: config.database.secure,
                                           includedTables: config.database.includedTables,
                                           excludedTables: config.database.excludedTables,
                                           includedColumns: config.database.includedColumns,
                                           excludedColumns: config.database.excludedColumns
                                       }, debeziumConfigs);
        populateMySqlConfigurations(config.database, configMap);
        populateMySqlOptions(config.options, configMap);
        debeziumConfigs["database.server.id"] = "100000";
        map<anydata> listenerConfigs = {
            ...debeziumConfigs
        };
        listenerConfigs["livenessInterval"] = config.livenessInterval;
        self.config = listenerConfigs.cloneReadOnly();
    }

    # Attaches a CDC service to the MySQL listener.
    #
    # + s - The CDC service to attach
    # + name - Attachment points
    # + return - An error if the service cannot be attached, or `()` if successful
    public isolated function attach(Service s, string[]|string? name = ()) returns Error? {
        check externAttach(self, s);
    }

    # Starts the MySQL listener.
    #
    # + return - An error if the listener cannot be started, or `()` if successful
    public isolated function 'start() returns Error? {
        check externStart(self, self.config);
    }

    # Detaches a CDC service from the MySQL listener.
    #
    # + s - The CDC service to detach
    # + return - An error if the service cannot be detached, or `()` if successful
    public isolated function detach(Service s) returns Error? {
        check externDetach(self, s);
    }

    # Stops the MySQL listener gracefully.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function gracefulStop() returns Error? {
        check externGracefulStop(self);
    }

    # Stops the MySQL listener immediately.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function immediateStop() returns Error? {
        check externImmediateStop(self);
    }
}

const string MYSQL_DATABASE_SERVER_ID = "database.server.id";
const string MYSQL_DATABASE_INCLUDE_LIST = "database.include.list";
const string MYSQL_DATABASE_EXCLUDE_LIST = "database.exclude.list";

// MySQL-specific options (mimics actual MySQL module)
public type MySqlOptions record {|
    *Options;
    // MySQL-specific options can be added here
|};

public type MySqlListenerConfiguration record {|
    MySqlDatabaseConnection database;
    MySqlOptions options = {};
    *ListenerConfiguration;
|};

public type MySqlDatabaseConnection record {|
    *DatabaseConnection;
    string connectorClass = "io.debezium.connector.mysql.MySqlConnector";
    string hostname = "localhost";
    int port = 3306;
    string databaseServerId = (checkpanic random:createIntInRange(0, 100000)).toString();
    string|string[] includedDatabases?;
    string|string[] excludedDatabases?;
    int tasksMax = 1;
    SecureDatabaseConnection secure = {};
|};

// Populates MySQL-specific configurations
isolated function populateMySqlConfigurations(MySqlDatabaseConnection connection, map<string> configMap) {
    configMap[MYSQL_DATABASE_SERVER_ID] = connection.databaseServerId.toString();

    string|string[]? includedDatabases = connection.includedDatabases;
    if includedDatabases !is () {
        configMap[MYSQL_DATABASE_INCLUDE_LIST] = includedDatabases is string ? includedDatabases : string:'join(",", ...includedDatabases);
    }

    string|string[]? excludedDatabases = connection.excludedDatabases;
    if excludedDatabases !is () {
        configMap[MYSQL_DATABASE_EXCLUDE_LIST] = excludedDatabases is string ? excludedDatabases : string:'join(",", ...excludedDatabases);
    }
}

// Populates MySQL-specific options
isolated function populateMySqlOptions(MySqlOptions options, map<string> configMap) {
    // Populate common options from cdc module
    populateOptions(options, configMap, typeof options);

    // MySQL-specific options would be populated here if any
}
