Ballerina CDC Connector
===================

  [![Build](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/ci.yml)
  [![Trivy](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/trivy-scan.yml)
  [![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-cdc/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-cdc)
  [![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/build-with-bal-test-graalvm.yml)
  [![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-cdc.svg)](https://github.com/ballerina-platform/module-ballerinax-cdc/commits/main)
  [![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/cdc.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fcdc)

The Ballerina Change Data Capture (CDC) module provides APIs to capture and process database change events in real-time. This module enables developers to define services that handle change capture events such as inserts, updates, and deletes. It is built on top of the Debezium framework and supports popular databases like MySQL and Microsoft SQL Server.

With the CDC module, you can:
- Capture real-time changes from databases.
- Process and react to database events programmatically.
- Build event-driven applications with ease.

## Setup guide

### 1. Enable CDC for MySQL

1. **Verify Binary Logging**:
   - Run the following command to ensure binary logging is enabled:
     ```sql
     SHOW VARIABLES LIKE 'log_bin';
     ```

2. **Enable Binary Logging**:
   - Add the following lines to the MySQL configuration file (`my.cnf` or `my.ini`):
     ```ini
     [mysqld]
     log-bin=mysql-bin
     binlog-format=ROW
     server-id=1
     ```
   - Restart the MySQL server to apply the changes:
     ```bash
     sudo service mysql restart
     ```
     Or, if you are using Homebrew on macOS:
     ```bash
     brew services restart mysql
     ```

### 2. Enable CDC for Microsoft SQL Server

1. **Ensure SQL Server Agent is Enabled**:
   - The SQL Server Agent must be running to use CDC. Start the agent if it is not already running.

2. **Enable CDC for the Database**:
   - Run the following command to enable CDC for the database:
     ```sql
     USE <your_database_name>;
     EXEC sys.sp_cdc_enable_db;
     ```

3. **Enable CDC for Specific Tables**:
   - Enable CDC for the required tables by specifying the schema and table name:
     ```sql
     EXEC sys.sp_cdc_enable_table
         @source_schema = 'your_schema_name',
         @source_name = 'your_table_name',
         @role_name = NULL;
     ```

4. **Verify CDC Configuration**:
   - Run the following query to verify that CDC is enabled for the database:
     ```sql
     SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'your_database_name';
     ```

### 3. Enable CDC for PostgreSQL Server

1. **Enable Logical Replication**:
   - Add the following lines to the PostgreSQL configuration file (`postgresql.conf`):
     ```ini
     wal_level = logical
     max_replication_slots = 4
     max_wal_senders = 4
     ```
   - Restart the PostgreSQL server to apply the changes:
     ```bash
     sudo service postgresql restart
     ```

### 4. Enable CDC for Oracle Database

To enable CDC for Oracle Database, follow these steps:

1. **Enable Supplemental Logging**:
   - Supplemental logging must be enabled to capture changes in the database. Run the following SQL command:
     ```sql
     ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
     ```

2. **Create a Change Table**:
   - Use the `DBMS_LOGMNR_CDC_PUBLISH.CREATE_CHANGE_TABLE` procedure to create a change table for capturing changes. Replace `<schema_name>` and `<table_name>` with your schema and table names:
     ```sql
     BEGIN
         DBMS_LOGMNR_CDC_PUBLISH.CREATE_CHANGE_TABLE(
             owner_name         => '<schema_name>',
             change_table_name  => 'cdc_<table_name>',
             source_schema_name => '<schema_name>',
             source_table_name  => '<table_name>',
             column_type_list   => 'id NUMBER, name VARCHAR2(100), updated_at DATE',
             capture_values     => 'ALL',
             rs_id              => 'Y',
             row_id             => 'Y',
             user_id            => 'Y',
             timestamp          => 'Y',
             object_id          => 'Y',
             source_colmap      => 'Y'
         );
     END;
     ```

3. **Start Change Data Capture**:
   - Use the `DBMS_LOGMNR_CDC_SUBSCRIBE.START_SUBSCRIPTION` procedure to start capturing changes:
     ```sql
     BEGIN
         DBMS_LOGMNR_CDC_SUBSCRIBE.START_SUBSCRIPTION(
             subscription_name => 'cdc_subscription'
         );
     END;
     ```

4. **Grant Necessary Permissions**:
   - Ensure the user has the necessary permissions to use CDC:
     ```sql
     GRANT EXECUTE ON DBMS_LOGMNR TO <username>;
     GRANT SELECT ON V$LOGMNR_CONTENTS TO <username>;
     ```

5. **Verify CDC Configuration**:
   - Run the following query to verify that CDC is enabled for the database:
     ```sql
     SELECT * FROM DBA_LOGMNR_CDC_PUBLISH;
     ```

6. **Stop Change Data Capture (Optional)**:
   - To stop CDC, use the `DBMS_LOGMNR_CDC_SUBSCRIBE.STOP_SUBSCRIPTION` procedure:
     ```sql
     BEGIN
         DBMS_LOGMNR_CDC_SUBSCRIBE.STOP_SUBSCRIPTION(
             subscription_name => 'cdc_subscription'
         );
     END;
     ```

## Quickstart

### Step 1: Import the Module

Import the CDC module into your Ballerina program:

```ballerina
import ballerinax/cdc;
```

### Step 2: Import the CDC MySQL Driver

Import the CDC MySQL Driver module into your Ballerina program:

```ballerina
import ballerinax/cdc.mysql.driver as _;
```

### Step 3: Configure the Listener

Create a CDC listener for your database. For example, to create a MySQL listener:

```ballerina
listener cdc:MySqlListener mysqlListener = new ({
    hostname: "localhost",
    port: 3306,
    username: "username",
    password: "password",
    databaseInclude: ["inventory"]
});
```

### Step 4: Define the Service

Define a CDC service to handle database change events:

```ballerina
service cdcService on mysqlListener {

    remote function onRead(record {} after) returns error? {
        // Handle the read event
        log:printInfo(`Record read: ${after}`);
    }

    remote function onCreate(record {} after) returns error? {
        // Handle the create event
        log:printInfo(`Record created: ${after}`);
    }

    remote function onUpdate(record {} before, record {} after) returns error? {
        // Handle the update event
        log:printInfo(`Record updated from: ${before}, to ${after}`);
    }

    remote function onDelete(record {} before) returns error? {
        // Handle the delete event
        log:printInfo(`Record deleted: ${before}`);
    }
}
```

### Step 5: Run the Application

Run your Ballerina application:

```ballerina
bal run
```

## Examples


## Issues and projects

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, start new discussions, view project boards, etc., visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

This repository only contains the source code for the package.

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

   * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   * [OpenJDK](https://adoptium.net/)

    > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Docker](https://www.docker.com/get-started).

    > **Note**: Ensure that the Docker daemon is running before executing any tests.

3. Export your GitHub personal access token with read package permissions as follows.
        
        export packageUser=<Username>
        export packagePAT=<Personal access token>

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To debug package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

5. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

6. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

7. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`cdc` package](https://lib.ballerina.io/ballerinax/cdc/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
