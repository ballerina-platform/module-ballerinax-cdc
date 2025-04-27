-- -- Grant Necessary Permissions
ALTER SYSTEM SET db_recovery_file_dest_size = 10G;
-- ALTER SYSTEM SET db_recovery_file_dest = '/opt/oracle/oradata/ORCLCDB' scope=spfile;
SHUTDOWN IMMEDIATE
STARTUP MOUNT
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ARCHIVE LOG LIST;

ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;


ALTER SESSION SET CONTAINER=ORCLPDB1;

-- Create a new Debezium user
CREATE USER debezium IDENTIFIED BY "debezium_password";

-- Grant necessary privileges to the Debezium user
GRANT CONNECT, RESOURCE TO debezium;

-- Grant the following system privileges for CDC capture
GRANT CREATE SESSION TO debezium;
GRANT ALTER SESSION TO debezium;

GRANT EXECUTE ON DBMS_LOGMNR TO debezium;
GRANT SELECT ANY TABLE TO debezium;
GRANT SELECT_CATALOG_ROLE TO debezium;
GRANT EXECUTE_CATALOG_ROLE TO debezium;
GRANT SELECT ANY TRANSACTION TO debezium;
GRANT LOGMINING TO debezium;
GRANT SELECT ANY DICTIONARY TO debezium;

ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

-- transactions table
CREATE TABLE transactions ( tx_id INT PRIMARY KEY,  user_id INT, amount DECIMAL(10,2), status VARCHAR2(50), created_at TIMESTAMP);

-- Sample data
INSERT INTO transactions (tx_id, user_id, amount, status, created_at) VALUES 
(1, 10, 9000.00, 'COMPLETED', TO_TIMESTAMP('2025-04-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO transactions (tx_id, user_id, amount, status, created_at) VALUES 
(7, 11, 12000.00, 'COMPLETED', TO_TIMESTAMP('2025-04-01 08:10:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO transactions (tx_id, user_id, amount, status, created_at) VALUES 
(3, 12, 4500.00, 'PENDING',   TO_TIMESTAMP('2025-04-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS'));

-- sqlplus ORCLPDB1.localdomain as sysdba
-- show parameter db_recovery_file_dest
-- 