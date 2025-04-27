## Overview

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

The `cdc` module provides practical examples illustrating its usage in various real-world scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples) to understand how to capture and process database change events effectively.

1. [Fraud Detection](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/fraud-detection) - Detect suspicious transactions in a financial database and send fraud alerts via email. This example showcases how to integrate the CDC module with the Gmail connector to notify stakeholders of potential fraud.

2. [Cache Management](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/cache-management) - Synchronize a Redis cache with changes in a MySQL database. It listens to changes in the `products`, `vendors`, and `product_reviews` tables and updates the Redis cache accordingly.
