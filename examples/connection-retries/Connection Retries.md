# Connection Retries

This example demonstrates how to use the Ballerina CDC module to build a resilient order management service that automatically reconnects to the database when connectivity is lost. The service monitors an `orders` table and retries failed connections with exponential backoff.

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

1. Execute the following command to run the example:

   ```bash
   bal run
   ```

2. Use the provided `test.sql` script to trigger change events on the `orders` table:

   ```bash
   mysql -u cdc_user -p < db-scripts/test.sql
   ```

   If using Docker services:

   ```bash
   docker exec -i mysql-cdc mysql -u cdc_user -pcdc_password < db-scripts/test.sql
   ```

3. To test connection retries, stop and restart the MySQL container while the service is running:

   ```bash
   docker-compose stop mysql
   # Wait a few seconds, then restart
   docker-compose start mysql
   ```

   The service will automatically reconnect using the configured retry policy (up to 10 attempts with exponential backoff between 1 and 30 seconds).
