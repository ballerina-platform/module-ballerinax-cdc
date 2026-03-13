# Heartbeat with Liveness

This example demonstrates how to use the Ballerina CDC module to monitor a financial transactions table with heartbeat and liveness checking enabled. The heartbeat keeps the database connection alive during idle periods when no data changes occur, while the liveness check ensures the CDC listener remains active.

## Setup Guide

### 1. MySQL Database

1. Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/mysql/latest#setup-guide) for the necessary steps to enable CDC in the MySQL server.

2. Add the necessary schema using the `setup.sql` script:
   ```bash
   mysql -u <username> -p < db-scripts/setup.sql
   ```

### 2. Configuration

Configure the MySQL Database credentials in the `Config.toml` file located in the example directory:

```toml
hostname = "<DB Hostname>"
username = "<DB Username>"
password = "<DB Password>"
```

## Setup Guide: Using Docker Compose

You can use Docker Compose to set up MySQL for this example. Follow these steps:

### 1. Start the service

Run the following command to start the MySQL service:

```bash
docker-compose up -d
```

### 2. Verify the service

Ensure the `mysql` service is in a healthy state:

```bash
docker-compose ps
```

### 3. Configuration

Ensure the `Config.toml` file is updated with the following credentials:

```toml
hostname = "localhost"
username = "cdc_user"
password = "cdc_password"
```

## Run the Example

1. If you are restarting after a previous run (e.g., after recreating the Docker container), clear the Debezium state files first to avoid stale offset errors:

   ```bash
   rm -rf tmp/
   ```

2. Execute the following command to run the example:

   ```bash
   bal run
   ```

3. Use the provided `test.sql` script to trigger change events on the `transactions` table:

   ```bash
   mysql -u <username> -p < db-scripts/test.sql
   ```

   If using Docker services:

   ```bash
   docker exec -i mysql-cdc mysql -u cdc_user -pcdc_password < db-scripts/test.sql
   ```

4. During idle periods (no data changes), the heartbeat fires every 5 seconds. The heartbeat uses an `actionQuery` to update the `debezium_heartbeat` table, which generates periodic binlog activity so that Debezium can deliver heartbeat events even when no application data is changing. The liveness check runs every 10 seconds to verify the listener is still active.

5. Query the liveness endpoint to confirm the CDC listener is alive even when no change events are being processed:

   ```bash
   curl http://localhost:8080/liveness
   ```

   The endpoint returns `true` when the listener is live, and `false` otherwise. This lets you verify that the heartbeat is keeping the listener active during idle periods.
