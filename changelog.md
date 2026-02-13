# Changelog

This file contains all the notable changes done to the Ballerina `cdc` package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

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
