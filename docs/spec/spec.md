# Specification: Ballerina CDC Library

_Authors_: [@niveathika](https://github.com/niveathika) \
_Reviewers_: [@daneshk](https://github.com/daneshk) [@ThisaruGuruge](https://github.com/ThisaruGuruge) \
_Created_: 2025/04/23 \
_Updated_: 2025/05/19 \
_Edition_: Swan Lake 

## Introduction

This is the specification for the CDC (Change Data Capture) package of the [Ballerina language](https://ballerina.io), which provides functionalities to capture and process changes in data sources in real time. The package enables developers to build applications that respond to insert, update, and delete events by integrating seamlessly with various databases and messaging systems.

The CDC library specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` on GitHub.

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

## Contents

- [Specification: Ballerina CDC Library](#specification-ballerina-cdc-library)
  - [Introduction](#introduction)
  - [Contents](#contents)
  - [1. Overview](#1-overview)
  - [2. Components](#2-components)
          - [Example: Importing the CDC Package](#example-importing-the-cdc-package)
    - [2.1 Listener](#21-listener)
    - [2.2 Service](#22-service)
          - [Example: Service](#example-service)
      - [2.2.1 Service Type](#221-service-type)
      - [2.2.2 Service Declaration](#222-service-declaration)
          - [Example: Service Declaration](#example-service-declaration)
      - [2.2.3 Service Object Declaration](#223-service-object-declaration)
          - [Example: Service Object Declaration](#example-service-object-declaration)
      - [2.2.4 Service Structure](#224-service-structure)
        - [2.2.4.1 `onRead`](#2241-onread)
        - [2.2.4.2 `onCreate`](#2242-oncreate)
        - [2.2.4.3 `onUpdate`](#2243-onupdate)
        - [2.2.4.4 `onDelete`](#2244-ondelete)
        - [2.2.4.5 `onTruncate`](#2245-ontruncate)
        - [2.2.4.6 `onError`](#2246-onerror)
      - [2.2.5 Service Configuration](#225-service-configuration)
    - [2.2 Using health checks](#23-using-health-checks) 
  - [3. Errors](#3-errors)
    - [3.1 Service Error Handling](#31-service-error-handling)
          - [Example: `onCreate` Throwing an Error](#example-oncreate-throwing-an-error)
    - [3.2 Errors](#32-errors)
      - [3.2.1 Generic `Error`](#321-generic-error)
      - [3.2.2 Operation Not Permitted Error](#322-operation-not-permitted-error)
          - [Example: Handling `OperationNotPermitted` Error](#example-handling-operationnotpermitted-error)
      - [3.2.3 Event Processing Error](#323-event-processing-error)
        - [3.2.3.1 Event Processing Error Detail Record](#3231-event-processing-error-detail-record)
          - [Example: Accessing Event Processing Error Details](#example-accessing-event-processing-error-details)
      - [3.2.4 Payload Binding Error](#324-payload-binding-error)
  - [4. Annotations](#4-annotations)
    - [4.1 Service Config](#41-service-config)
      - [4.1.1 Tables](#411-tables)
          - [Example: Multiple Services with Table Configuration](#example-multiple-services-with-table-configuration)

## 1. Overview

The Ballerina CDC (Change Data Capture) library provides a robust framework for capturing and processing changes in data sources in real time. It is designed to enable developers to build reactive applications that respond to database events such as inserts, updates, and deletes. By leveraging the CDC library, developers can seamlessly integrate with databases like MySQL and MSSQL to monitor and act on data changes.

The library offers two primary components: listeners and services. Listeners, such as `MySqlListener` and `MsSqlListener`, are responsible for capturing changes from the database. Services, on the other hand, define the logic for processing these changes. Together, these components provide a flexible and efficient way to handle data change events.

The CDC library also includes features for error handling, configuration, and annotations, ensuring that developers have the tools they need to build reliable and maintainable applications. With its focus on real-time data processing, the Ballerina CDC library is an essential tool for modern data-driven applications.

## 2. Components

This section describes the components of the Ballerina CDC package. To use the Ballerina CDC package, a user must import the Ballerina CDC package first.

###### Example: Importing the CDC Package

```ballerina
import ballerinax/cdc;
```

### 2.1 Listener

The Ballerina CDC package provides a generic `Listener` object, which serves as the foundation for capturing change data events. Each supported database (such as MySQL, MSSQL, PostgreSQL, etc.) implements its own specific listener by extending this base `Listener` object.

These database-specific listeners internally call the publicly available extern functions (`externAttach()`, `externDetach()`, `externStart()`, `externGracefulStop()`, `externImmediateStop()`) provided by the CDC module to interact with the underlying change data capture mechanisms.

Common configuration records such as `ListenerConfiguration` and `DatabaseConnection` are available in the CDC module. Utility methods are also provided to convert these configurations into Debezium-compatible properties maps, making integration with Debezium seamless. Any additional properties or configurations that are specific to a particular database must be implemented within the respective database modules.

This design allows the CDC package to support multiple databases while maintaining a consistent and extensible API for users.

### 2.2 Service

After initializing the listener, a service must be attached to it. The `Service` contains the functionality to process and capture CDC events, enabling the handling of changes in data sources. 

Note that attaching the same service to multiple listeners is prohibited and will result in a compilation error.

###### Example: Service

```ballerina
service cdc:Service on new cdc:MySqlListener (
    database = {
        username,
        password,
        databaseInclude: ["store_db"]
    }) {

}
```

In the above [example](#example-service), a cdc service is attached to a cdc listener. This is syntactic sugar to declare a service and attach it to a cdc listener.

#### 2.2.1 Service Type

The following distinct service type is provided by the Ballerina CDC package that can be used by the users. It can be referred to as `cdc:Service`. Since the language support is yet to be implemented for the service typing, service validation is done using the Ballerina CDC compiler plugin.

```ballerina
public type Service distinct service object {
    remote function onRead(record{} after) {
    }
    remote function onCreate(record{} after) {
    }
    remote function onUpdate(record{} before, record{} after) {
    }
    remote function onDelete(record{} before) {
    }
};
```

The functions supported in the service are explained in more detail in Service Structure.

#### 2.2.2 Service Declaration

The [service declaration](https://ballerina.io/spec/lang/2021R1/#section_10.2.2) is syntactic sugar for creating a service. This is the most-used approach for creating a service.

###### Example: Service Declaration

```ballerina
service cdc:Service on new cdc:MySqlListener (
    database = {
        username,
        password,
        databaseInclude: ["store_db"]
    }) {

}
```
These structure are described in the [Service Structure](#224-service-structure) section.

#### 2.2.3 Service Object Declaration

A service can be instantiated using the service object. This approach provides full control of the service life cycle to the user. The listener life cycle methods can be used to handle this.

###### Example: Service Object Declaration

```ballerina
cdc:Service cdcService = service object {
}

public function main() returns error? {
    cdc:Listener cdcListener = check new (9090);
    check cdcListener.attach(cdcService);
    check cdcListener.'start();
    runtime:registerListener(cdcListener);
}
```

>**Note:** The service object declaration is only supported when the service object is defined in global scope. If the service object is defined anywhere else, the schema generation will fail. This is due to a known current limitation in the Ballerina language.

#### 2.2.4 Service Structure

The Ballerina CDC service requires at least one of the following remote functions to be implemented: `onRead`, `onCreate`, `onUpdate`, or `onDelete`. These functions define the logic for handling specific types of database events. Additionally, an optional `onError` function can be implemented to handle errors during event processing.

Any errors returned from these methods will be logged and the service will continue processing subsequent events. This ensures that the service remains operational even when encountering errors.

##### 2.2.4.1 `onRead`

Handles events triggered when a record is read from the database.

```ballerina
remote function onRead(record {} after) returns error? {
    // Logic to handle read events
}
```

- **Parameter Type**: 
    - `after` (mandatory) - The record after the read operation. This can be an anonymous record or a typed record.
    - `tableName` (optional) - A `string` parameter that provides the table name from which event originated.

- **Return Type**: Optional. Can be one of the following:
    - `cdc:Error`
    - `error`
    - `()`
    - A combination of the above.

##### 2.2.4.2 `onCreate`

Handles events triggered when a new record is created in the database.

```ballerina
remote function onCreate(record {} after) returns error? {
    // Logic to handle create events
}
```

- **Parameter Type**: 
    - `after` (mandatory) - The record after the create operation. This can be an anonymous record or a typed record.
    - `tableName` (optional) - A `string` parameter that provides the table name from which event originated.

- **Return Type**: Optional. Can be one of the following:
    - `cdc:Error`
    - `error`
    - `()`
    - A combination of the above.

##### 2.2.4.3 `onUpdate`

Handles events triggered when an existing record is updated in the database.

```ballerina
remote function onUpdate(record {} before, record {} after) returns error? {
    // Logic to handle update events
}
```

- **Parameter Type**: 
    - `before` (mandatory) - The record before the read operation. This can be an anonymous record or a typed record.
    - `after` (mandatory) - The record after the update operation. This can be an anonymous record or a typed record.
    - `tableName` (optional) - A `string` parameter that provides the table name from which event originated.

- **Return Type**: Optional. Can be one of the following:
    - `cdc:Error`
    - `error`
    - `()`
    - A combination of the above.

##### 2.2.4.4 `onDelete`

Handles events triggered when a record is deleted from the database.

```ballerina
remote function onDelete(record {} before) returns error? {
    // Logic to handle delete events
}
```

- **Parameter Type**: 
    - `before` (mandatory) - The record before the read operation. This can be an anonymous record or a typed record.
    - `tableName` (optional) - A `string` parameter that provides the table name from which event originated.
    
- **Return Type**: Optional. Can be one of the following:
    - `cdc:Error`
    - `error`
    - `()`
    - A combination of the above.

##### 2.2.4.5 `onTruncate`

Handles events triggered when a table is truncated. This is only available for `cdc:PostgreSqlListener`

```ballerina
remote function onTruncate() returns error? {
}
```

- **Parameter Type**: 
    - `tableName` (optional) - A `string` parameter that provides the table name from which event originated.
    
- **Return Type**: Optional. Can be one of the following:
    - `cdc:Error`
    - `error`
    - `()`
    - A combination of the above.

##### 2.2.4.6 `onError`

Handles errors that occur during event processing before mandatory functions are invoked.

```ballerina
remote function onError(cdc:Error e) {
    // Logic to handle errors
}
```

- **Parameter**: `e` (mandatory) - The error encountered during event processing.

- **Return Type**: Optional. Can be one of the following:
    - `cdc:Error`
    - `error`
    - `()`
    - A combination of the above.

#### 2.2.5 Service Configuration

The `cdc:ServiceConfig` annotation can be used to provide additional configurations to the CDC service. These configurations are described in the [Service Configuration](#41-service-config) section.

### 2.3 Using health checks

In a distributed deployment, health checks are essential for monitoring the state of the CDC listener and enabling automated recovery mechanisms. If the listener becomes unhealthy, the orchestrator (e.g., Kubernetes) can restart the service based on the reported health status.

To support this, the `isLive` function is provided to determine the liveness of a given CDC listener instance.

```ballerina
# Checks whether the given CDC listener is live.
#
# + cdc - The CDC listener instance to be checked
# + return - Returns `true` if the listener is considered live, `false` otherwise,
#            or an error if the liveness check fails
public function isLive(cdc: Listener cdc) returns boolean|Error;
```

The following example demonstrates how the `isLive` function can be integrated with an HTTP-based liveness probe:

```ballerina
listener cdc:Listener mssqlCdc = ...;

// HTTP-based liveness probe
service on new http:Listener(...) {

    resource function get liveness() returns http:Ok|http:ServiceUnavailable|error {
        boolean isLive = check cdc:isLive(mssqlCdc);
        if isLive {
            return http:OK;
        }
        return http:SERVICE_UNAVAILABLE;
    }
}
```

## 3. Errors

### 3.1 Service Error Handling

A CDC service functions can return errors to leverage the default error handling mechanism. If the `onError` function is defined in the service, it will be invoked to handle the error. Otherwise, the error will be logged, and the service will continue processing subsequent events. This ensures that the service remains operational even when encountering errors.

###### Example: `onCreate` Throwing an Error

```ballerina
service cdc:Service on mysqlListener {
    remote function onCreate(record {} after) returns error? {
        if !isValidRecord(after) {
            return error("Invalid record data");
        }
        // Process the valid record
    }

    remote function onError(cdc:Error e) {
        log:printError("Error occurred: ", 'error = e);
    }
}

function isValidRecord(record {} rec) returns boolean {
    // Perform validation logic
    return rec.hasKey("id") && rec.hasKey("name");
}
```

In this example, the `onCreate` function validates the incoming record. If the record is invalid, an error is returned, which is then handled by the `onError` function.

### 3.2 Errors

The Ballerina CDC service may encounter various errors during the listener lifecycle. These errors can be handled in the `onError` method of the service. The errors are categorized as follows:

#### 3.2.1 Generic `Error`

Represents a generic error that occurs during application execution. This error can be used as a base class for more specific error types or as a general-purpose exception when no other specific error applies.

#### 3.2.2 Operation Not Permitted Error

The `OperationNotPermitted` error occurs when an operation is attempted that is not allowed based on the current state or configuration of the CDC listener or service. This error is typically encountered in scenarios such as:

- Attempting to attach a service to a listener that is already started.
- Attempting to start a listener that is already running.
- Attempting to detach a service from a listener that is not running.

These errors are thrown to ensure the integrity and proper functioning of the CDC service.

###### Example: Handling `OperationNotPermitted` Error

```ballerina
listener cdc:MySqlListener mysqlListener = new ({
    hostname: "localhost",
    port: 3306,
    username: "cdc_user",
    password: "cdc_pass"
});

service cdc:Service on mysqlListener {
    remote function onCreate(record {} after) {
        // Handle event
    }
}

public function main() returns error? {
    // Attempting to start the listener again will result in an OperationNotPermitted error
    check mysqlListener.'start(); // First start
    check mysqlListener.'start(); // Throws OperationNotPermitted error
}
```

To avoid this error, ensure that operations are performed in the correct sequence and state.

#### 3.2.3 Event Processing Error

Errors that occur while processing events from the database can be caused by invalid data, application logic issues, or unexpected runtime conditions. For example, payload binding errors may arise if the incoming data format from Debezium does not match the expected schema. To mitigate such issues, it is recommended to validate and sanitize the payload before processing it. 

If a service function encounters an error, the listener invokes the `onError` function if it is defined in the service. The `onError` function allows developers to handle errors in a custom manner. If the `onError` function is not present, the listener logs the error and continues processing subsequent events. This ensures uninterrupted operation of the listener and the service.

##### 3.2.3.1 Event Processing Error Detail Record

The `cdc:EventProcessingErrorDetail` provides additional information to help users process errors effectively. This record includes a `payload` field, which contains the original payload that caused the error. By examining the `payload`, users can identify and address issues in the data or application logic.

###### Example: Accessing Event Processing Error Details

```ballerina
service cdc:Service on mysqlListener {
    remote function onError(cdc:Error e) returns error? {
        if e is EventProcessingError {
            log:printInfo("Error occured while processing the event from database.");
            log:printInfo("Original Event: " + e.detail().payload.toJsonString());
        }
    }
}
```

In the above example, the `cdc:EventProcessingErrorDetail` is used to include the problematic payload in the error, enabling better debugging and error handling.

#### 3.2.4 Payload Binding Error

This issue arises when the expected type does not align with the received data. A typical example is handling decimal values. By default, decimal values are mapped to the Ballerina `decimal` type. However, if the user requires a specific precision, Debezium may represent this as a `byte`. Such a mismatch can lead to an error.

## 4. Annotations

### 4.1 Service Config

The `cdc:ServiceConfig` annotation allows configuring the behavior of a specific CDC service. These configurations are applied directly to the service.

This annotation includes the following field:

#### 4.1.1 Tables

The `tables` field is used to specify the tables from which events should be captured. It enables grouping events from multiple tables into a single service. 

This field is particularly useful when multiple services are attached to a single listener, as it allows each service to handle events from specific tables. For example, one service can handle events from the `products` table, while another service handles events from the `orders` table. This ensures a clear separation of responsibilities between services.

If only a single service is attached to the listener, the `tables` field is not required, as the service will automatically handle all events captured by the listener.

###### Example: Multiple Services with Table Configuration

```ballerina
@cdc:ServiceConfig {
    tables: "products"
}
service on cdcListener {
    // Handles events from the 'products' table
}

@cdc:ServiceConfig {
    tables: "orders"
}
service on cdcListener {
    // Handles events from the 'orders' table
}
```
