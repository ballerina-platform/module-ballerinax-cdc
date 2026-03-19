CREATE DATABASE IF NOT EXISTS finance_db;

-- Grant CDC replication privileges to cdc_user
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'cdc_user'@'%';
FLUSH PRIVILEGES;

USE finance_db;

-- transactions table
CREATE TABLE transactions (
    tx_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    type VARCHAR(20) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Heartbeat table for Debezium liveness: the actionQuery updates this row every
-- heartbeat interval to generate periodic binlog activity during idle periods,
-- ensuring isLive() stays true even when no application data is changing.
CREATE TABLE debezium_heartbeat (
    id INT PRIMARY KEY,
    ts DATETIME NOT NULL
);
INSERT INTO debezium_heartbeat VALUES (1, NOW());

-- Grant cdc_user write access for the heartbeat actionQuery
GRANT INSERT, UPDATE ON finance_db.debezium_heartbeat TO 'cdc_user'@'%';
FLUSH PRIVILEGES;

