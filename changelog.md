# Changelog

This file contains all the notable changes done to the Ballerina `cdc` package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Fixed GraalVM native image builds failing with `An object of type 'org.slf4j.jul.JDK14LoggerAdapter' was found in the image heap` when a dependency such as `netty-codec-http` initializes Netty at build time, by initializing slf4j at build time.

## [1.4.1]

### Changed
- Fixed the Debezium engine failing to start in GraalVM native images with `Could not initialize class io.debezium.embedded.EmbeddedWorkerConfig`, by registering the Kafka OAuth JWT default classes for reflection, including the Debezium `build.version` resources, and registering the file offset store types for serialization.
- Upgraded the bundled `snappy-java` to 1.1.10.12 to address CVE-2026-108106, CVE-2026-93451 and CVE-2026-116590.

## [1.4.0]

### Changed
- Upgraded the embedded Debezium runtime to 3.5.1.Final.
- Fixed `Listener.start()` to surface Debezium engine startup failures immediately instead of hanging forever.
- Fixed `Listener.gracefulStop()` to wait (bounded by a timeout, escalating to a forced shutdown) for the executor to actually terminate instead of returning immediately, and to report an error rather than discard the executor if it still hasn't terminated.

### Deprecated
- Deprecated the `SCHEMA_ONLY` snapshot mode in favor of `NO_DATA` (Debezium removed `schema_only` in 3.3 / DBZ-8171); `SCHEMA_ONLY` is still accepted and mapped to `no_data`.

## [1.3.2]

### Changed
- Fix liveness check to report not-live immediately after the listener stops

## [1.3.1]

### Changed
- Downgrade no-such-function error when user hasn't created a method, to a warning

## [1.3.0]

### Added
- [Introduce additional Debezium properties](https://github.com/ballerina-platform/ballerina-library/issues/8572)

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
