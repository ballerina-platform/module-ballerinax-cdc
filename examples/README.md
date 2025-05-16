# Examples

The `cdc` module provides practical examples illustrating its usage in various real-world scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples) to understand how to capture and process database change events effectively.

1. [Fraud Detection](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/fraud-detection) - Detect suspicious transactions in a financial database and send fraud alerts via email. This example showcases how to integrate the CDC module with the Gmail connector to notify stakeholders of potential fraud.

2. [Cache Management](https://github.com/ballerina-platform/module-ballerinax-cdc/tree/main/examples/cache-management) - Synchronize a Redis cache with changes in a MySQL database. It listens to changes in the `products`, `vendors`, and `product_reviews` tables and updates the Redis cache accordingly.

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
