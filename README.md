Ballerina CDC Connector
===================

  [![Build](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/build-timestamped-master.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdc/actions/workflows/build-timestamped-master.yml)
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
