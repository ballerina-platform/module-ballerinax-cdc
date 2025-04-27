# Cache Management

This example demonstrates how to use the Ballerina Change Data Capture (CDC) module to synchronize a Redis cache with changes in a MySQL database. It listens to changes in the `products`, `vendors`, and `product_reviews` tables and updates the Redis cache accordingly.

## Setup Guide

### 1. MySQL Database

1. Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/cdc/latest#setup-guide) for the necessary steps to enable CDC in the MySQL server.

2. Add the necessary schema and data using the `setup.sql` script:
   ```bash
   mysql -u <username> -p < db_scripts/setup.sql
   ```

### 2. Redis Server

Ensure a Redis server is running on `localhost:6379`.

### 3. Configuration

Configure MySQL database credentials in the `Config.toml` file located in the example directory:

```toml
username = "<DB Username>"
password = "<DB Password>"
```

Replace `<DB Username>` and `<DB Password>` with your MySQL database credentials.

## Setup Guide: Using Docker Compose

You can use Docker Compose to set up both MySQL and Redis services for this example. Follow these steps:

### 1. Start the services

Run the following command to start both MySQL and Redis services:

```bash
docker-compose up -d
```

### 2. Verify the services

Ensure both `mysql` and `redis` services are in a healthy state:

```bash
docker-compose ps
```

### 3. Configuration

Ensure the `Config.toml` file is updated with the following credentials:

```toml
username = "cdc_user"
password = "cdc_password"
```

## Run the Example

1. Execute the following command to run the example:

   ```bash
   bal run
   ```

2. Use the provided `test.sql` script to insert sample transactions into the `products`, `vendors`, and `product_reviews` tables to test the synchronization. Run the following command:

   ```bash
   mysql -u <username> -p < db_scripts/test.sql
   ```

If using docker services,

   ```bash
   docker exec -i mysql-cdc mysql -u cdc_user -pcdc_password < db-scripts/test.sql
   ```
