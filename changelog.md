# Changelog

This file contains all the notable changes done to the Ballerina `cdc` package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0]

### Added
- New offset storage backends: Memory, JDBC, Redis
- New schema history storage backends: Memory, JDBC, Redis, Amazon S3, Azure Blob, RocketMQ
- Built-in Kafka configuration types (`KafkaSecurityProtocol`, `KafkaAuthenticationConfiguration`, `KafkaSecureSocket`) — removes dependency on `ballerinax/kafka`
- `HeartbeatConfiguration` support for idle connection detection
- `SignalConfiguration` for runtime connector control (database table, Kafka, file, JMX)
- `TransactionMetadataConfiguration` for transaction boundary event tracking
- `ColumnTransformConfiguration` for column masking (`ColumnHashMask`, `ColumnCharMask`) and truncation (`ColumnTruncate`)
- `TopicConfiguration` for topic naming and routing customization
- `ConnectionRetryConfiguration` for disconnect retry behavior
- `PerformanceConfiguration` for batch size, poll interval, and queue tuning
- `MonitoringConfiguration` for custom metric tags
- `GuardrailConfiguration` for limiting captured tables/columns with configurable limit actions

### Changed
- `ListenerConfiguration` and `Options` changed to open records to allow passing raw Debezium properties
- `OffsetStorage` union expanded to include Memory, JDBC, and Redis backends
- `InternalSchemaStorage` union expanded to include Memory, JDBC, Redis, S3, Azure Blob, and RocketMQ backends
- Table/column filtering fields (`includedTables`, `excludedTables`, `includedColumns`, `excludedColumns`) moved from `cdc:DatabaseConnection` to database-specific connection types

## [1.2.0]

### Added
- [Introduce a mechanism to detect whether the CDC engine is running](https://github.com/ballerina-platform/ballerina-library/issues/8589)

## [1.1.0]

### Added
- Authentication support for schema storage and offset storage with Kafka

### Changed
- Fix documentation

## [1.0.3] - 2025-05-29

### Changed
- Fixed schema not included in service map key
- Fix data binding error being invoked incorrectly
- Fix payload member throwing null pointer exception

## [1.0.2] - 2025-05-27

### Added
- GraalVM configurations for MSSQL

## [1.0.1] - 2025-05-26

### Added
- GraalVM configurations

## [1.0.0] - 2025-05-22

### Added
- Base cdc:Service, utils, types and compiler plugin
