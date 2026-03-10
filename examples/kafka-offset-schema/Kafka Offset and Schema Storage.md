# Kafka Offset and Schema Storage

This example demonstrates how to use the Ballerina CDC module to synchronize inventory changes with durable, distributed state management backed by Apache Kafka. Kafka is used for both offset storage (to resume from the last processed position after a restart) and schema history storage (to track database schema evolution over time).

## Setup Guide

### 1. MySQL Database

1. Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/mysql/latest#setup-guide) for the necessary steps to enable CDC in the MySQL server.

2. Add the necessary schema using the `setup.sql` script:
   ```bash
   mysql -u <username> -p < db-scripts/setup.sql
   ```

### 2. Apache Kafka

Set up a running Kafka broker and note its bootstrap server address (e.g., `localhost:9092`). Create the required topics with the appropriate cleanup policies:

```bash
# Offset topic — must use compact cleanup policy
kafka-topics.sh --create --topic cdc-offsets \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 --partitions 1 \
  --config cleanup.policy=compact

# Schema history topic — must use delete cleanup policy with no retention limit
kafka-topics.sh --create --topic cdc-schema-history \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 --partitions 1 \
  --config cleanup.policy=delete \
  --config retention.ms=-1
```

### 3. Configuration

Configure the credentials in the `Config.toml` file located in the example directory:

```toml
hostname = "<DB Hostname>"
username = "<DB Username>"
password = "<DB Password>"
kafkaBootstrapServers = "<Kafka Bootstrap Servers>"
```

## Setup Guide: Using Docker Compose

You can use Docker Compose to set up MySQL, Zookeeper, Kafka, and the required Kafka topics for this example.

### 1. Start the services

Run the following command to start all services:

```bash
docker-compose up -d
```

### 2. Verify the services

Ensure all services are in a healthy state. The `kafka-setup` service will automatically create the `cdc-offsets` (compact) and `cdc-schema-history` (delete) topics after Kafka is ready, then exit.

```bash
docker-compose ps
```

### 3. Configuration

Ensure the `Config.toml` file is updated with the following credentials:

```toml
hostname = "localhost"
username = "cdc_user"
password = "cdc_password"
kafkaBootstrapServers = "localhost:9092"
```

## Run the Example

1. Execute the following command to run the example:

   ```bash
   bal run
   ```

2. Use the provided `test.sql` script to trigger change events on the `products` table:

   ```bash
   mysql -u <username> -p < db-scripts/test.sql
   ```

   If using Docker services:

   ```bash
   docker exec -i mysql-cdc mysql -u cdc_user -pcdc_password < db-scripts/test.sql
   ```

3. Stop and restart the service to verify that Kafka-backed offset storage resumes processing from where it left off, with no duplicate or missed events.
