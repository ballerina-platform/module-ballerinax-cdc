# S3 Schema History

This example demonstrates how to use the Ballerina CDC module to capture audit log changes with Amazon S3 as the durable schema history storage backend. Storing schema history in S3 enables cloud-native deployments where no local or self-hosted storage infrastructure is needed.

> **Note:** The S3 bucket (`cdc-schema-history`) must be created in your AWS account before running this example. The CDC connector does not create the bucket automatically.

## Prerequisites

- An AWS account with an S3 bucket named `cdc-schema-history` (or your chosen bucket name) created in your target region.
- AWS credentials (access key ID, secret access key, and region) with read/write permissions on the bucket.

## Setup Guide

### 1. MySQL Database

1. Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/mysql/latest#setup-guide) for the necessary steps to enable CDC in the MySQL server.

2. Add the necessary schema using the `setup.sql` script:
   ```bash
   mysql -u <username> -p < db-scripts/setup.sql
   ```

### 2. Configuration

Configure the MySQL Database and AWS credentials in the `Config.toml` file located in the example directory:

```toml
hostname = "<DB Hostname>"
username = "<DB Username>"
password = "<DB Password>"
accessKeyId = "<AWS Access Key ID>"
secretAccessKey = "<AWS Secret Access Key>"
region = "<AWS Region>"
```

## Setup Guide: Using Docker Compose

You can use Docker Compose to set up MySQL for this example. S3 is an external AWS service and does not require local Docker setup.

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
accessKeyId = "<AWS Access Key ID>"
secretAccessKey = "<AWS Secret Access Key>"
region = "<AWS Region>"
```

## Run the Example

1. Execute the following command to run the example:

   ```bash
   bal run
   ```

2. Use the provided `test.sql` script to trigger change events on the `audit_log` table:

   ```bash
   mysql -u <username> -p < db-scripts/test.sql
   ```

   If using Docker services:

   ```bash
   docker exec -i mysql-cdc mysql -u cdc_user -pcdc_password < db-scripts/test.sql
   ```

3. Verify the schema history file was written to your S3 bucket at `schema/schema-history.json`.
