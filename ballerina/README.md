## Overview

The Ballerina Change Data Capture (CDC) module provides APIs to capture and process database change events in real-time. This module enables developers to define services that handle change capture events such as inserts, updates, and deletes. It is built on top of the Debezium framework and supports popular databases like MySQL and Microsoft SQL Server.

With the CDC module, you can:
- Capture real-time changes from databases.
- Process and react to database events programmatically.
- Build event-driven applications with ease.

## Quickstart

### Step 1: Import Required Modules

Add the following imports to your Ballerina program:

- `ballerinax/cdc`: Core module that provides APIs to capture and process database change events.
- `ballerinax/mysql`: Provides MySQL-specific listener and types for CDC. Replace with the corresponding module for your database if needed.
- `ballerinax/mysql.cdc.driver as _`: Debezium-based driver for MySQL CDC. Use the appropriate driver for your database (e.g., `mssql.cdc.driver`, `postgresql.cdc.driver`, or `oracledb.cdc.driver`).

```ballerina
import ballerinax/cdc;
import ballerinax/mysql;
import ballerinax/mysql.cdc.driver as _;
```

### Step 2: Configure the CDC Listener

Create a CDC listener for your MySQL database by specifying the connection details:

```ballerina
listener mysql:CdcListener mysqlListener = new ({
    database: {
        hostname: "localhost",
        port: 3306,
        username: "username",
        password: "password",
        includedDatabases: ["inventory"]
    }
});
```

### Step 3: Define the CDC Service

Implement a `cdc:Service` to handle database change events:

```ballerina
service on mysqlListener {

    remote function onRead(record {} after) returns cdc:Error? {
        // Handle the read event
        log:printInfo(`Record read: ${after}`);
    }

    remote function onCreate(record {} after) returns cdc:Error? {
        // Handle the create event
        log:printInfo(`Record created: ${after}`);
    }

    remote function onUpdate(record {} before, record {} after) returns cdc:Error? {
        // Handle the update event
        log:printInfo(`Record updated from: ${before}, to ${after}`);
    }

    remote function onDelete(record {} before) returns cdc:Error? {
        // Handle the delete event
        log:printInfo(`Record deleted: ${before}`);
    }
}
```

### Step 4: Run the Application

Run your Ballerina application:

```bash
bal run
```

## Examples

The `cdc` module provides practical examples illustrating its usage in various real-world scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples) to understand how to capture and process database change events effectively.

1. [Fraud Detection](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/fraud-detection) - Detect suspicious transactions in a financial database and send fraud alerts via email. This example showcases how to integrate the CDC module with the Gmail connector to notify stakeholders of potential fraud.

2. [Cache Management](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/cache-management) - Synchronize a Redis cache with changes in a MySQL database. It listens to changes in the `products`, `vendors`, and `product_reviews` tables and updates the Redis cache accordingly.
