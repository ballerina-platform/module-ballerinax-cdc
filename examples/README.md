# Examples

The `cdc` module provides practical examples illustrating its usage in various real-world scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples) to understand how to capture and process database change events effectively.

1. [Fraud Detection](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/fraud-detection) - Detect suspicious transactions in a financial database and send fraud alerts via email. This example showcases how to integrate the CDC module with the Gmail connector to notify stakeholders of potential fraud.

2. [Cache Management](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/cache-management) - Synchronize a Redis cache with changes in a MySQL database. It listens to changes in the `products`, `vendors`, and `product_reviews` tables and updates the Redis cache accordingly.

3. [Connection Retries](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/connection-retries) - Monitor an orders database with automatic reconnection on failures. This example configures exponential backoff retry logic so the service recovers gracefully from temporary database downtime.

4. [Heartbeat with Liveness](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/heartbeat-liveness) - Monitor a financial transactions table with heartbeat and liveness checking enabled. The heartbeat keeps the database connection alive during idle periods, and the liveness check validates if the CDC listener remains active.

5. [Kafka Offset and Schema Storage](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/kafka-offset-schema) - Synchronize inventory changes using Apache Kafka for both offset storage and schema history. This enables reliable distributed state management where the service can resume processing after a restart without missing or duplicating events.

6. [S3 Schema History](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/s3-schema-history) - Capture audit log changes with Amazon S3-backed schema history storage. This cloud-native approach stores database schema evolution in S3, removing the need for self-hosted schema history infrastructure.

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the Examples with the Local Module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
