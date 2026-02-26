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

    private final map<string> & readonly debeziumConfigs;
    private final map<anydata> & readonly listenerConfigs;
    private boolean isStarted = false;
    private boolean hasAttachedService = false;

    # Initializes the MySQL listener with the given configuration.
    #
    # + config - The configuration for the MySQL connector
    public isolated function init(*MySqlListenerConfiguration config) {
        map<string> debeziumConfigs = {};
        map<anydata> listenerConfigs = {};
        populateMySqlDebeziumProperties(config, debeziumConfigs);
        populateListenerProperties(config, listenerConfigs);
        self.debeziumConfigs = debeziumConfigs.cloneReadOnly();
        self.listenerConfigs = listenerConfigs.cloneReadOnly();
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
        check externStart(self, self.debeziumConfigs, self.listenerConfigs);
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
    string|string[] includedTables?;
    string|string[] excludedTables?;
    string|string[] includedColumns?;
    string|string[] excludedColumns?;
    int tasksMax = 1;
    SecureDatabaseConnection secure = {};
|};

isolated function populateMySqlDebeziumProperties(MySqlListenerConfiguration config, map<string> debeziumConfigs) {
    populateDebeziumProperties({
        engineName: config.engineName,
        offsetStorage: config.offsetStorage,
        internalSchemaStorage: config.internalSchemaStorage
        }, debeziumConfigs);
    populateMySqlDatabaseConfigurations(config.database, debeziumConfigs);
    populateMySqlOptions(config.options, debeziumConfigs);
}

isolated function populateMySqlDatabaseConfigurations(MySqlDatabaseConnection database, map<string> debeziumConfigs) {
    // Populate generic CDC connection fields
    populateDatabaseConfigurations({
        connectorClass: database.connectorClass,
        hostname: database.hostname,
        port: database.port,
        username: database.username,
        password: database.password,
        connectTimeout: database.connectTimeout,
        tasksMax: database.tasksMax,
        secure: database.secure
        }, debeziumConfigs);

    // Populate MySQL-specific relational filtering
    populateTableAndColumnConfigurations(
        database.includedTables,
        database.excludedTables,
        database.includedColumns,
        database.excludedColumns,
        debeziumConfigs
    );

    debeziumConfigs[MYSQL_DATABASE_SERVER_ID] = database.databaseServerId.toString();
    string|string[]? includedDatabases = database.includedDatabases;
    if includedDatabases !is () {
        debeziumConfigs[MYSQL_DATABASE_INCLUDE_LIST] = includedDatabases is string ? includedDatabases : string:'join(",", ...includedDatabases);
    }
    string|string[]? excludedDatabases = database.excludedDatabases;
    if excludedDatabases !is () {
        debeziumConfigs[MYSQL_DATABASE_EXCLUDE_LIST] = excludedDatabases is string ? excludedDatabases : string:'join(",", ...excludedDatabases);
    }
}

// Populates MySQL-specific options
isolated function populateMySqlOptions(MySqlOptions options, map<string> debeziumConfigs) {
    // MySQL-specific options would be populated here if any

    // Populate common options from cdc module
    populateOptions(options, debeziumConfigs, typeof options);
}
