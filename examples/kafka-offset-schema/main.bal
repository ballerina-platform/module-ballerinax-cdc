// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.org).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerinax/cdc;
import ballerinax/mysql;
import ballerinax/mysql.cdc.driver as _;

configurable string hostname;
configurable string username;
configurable string password;
configurable string kafkaBootstrapServers;

listener mysql:CdcListener inventoryListener = new (
    database = {
        hostname,
        port: 3306,
        username,
        password,
        includedDatabases: "inventory_db"
    },
    offsetStorage = <cdc:KafkaOffsetStorage>{
        bootstrapServers: kafkaBootstrapServers,
        topicName: "cdc-offsets",
        replicationFactor: 1
    },
    internalSchemaStorage = <cdc:KafkaInternalSchemaStorage>{
        bootstrapServers: kafkaBootstrapServers,
        topicName: "cdc-schema-history"
    },
    options = {
        snapshotMode: cdc:NO_DATA
    }
);

@cdc:ServiceConfig {
    tables: "inventory_db.products"
}
service cdc:Service on inventoryListener {

    remote function onCreate(Product after, string tableName) returns error? {
        do {
            log:printInfo(string `Product added: ID: ${after.product_id}, Name: ${after.name}, Stock: ${after.quantity}, Price: $${after.price}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onUpdate(Product before, Product after, string tableName) returns error? {
        do {
            log:printInfo(string `Product updated: ID: ${after.product_id}, Stock changed from ${before.quantity} to ${after.quantity}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onDelete(Product before, string tableName) returns error? {
        do {
            log:printInfo(string `Product removed: ID: ${before.product_id}, Name: ${before.name}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onError(cdc:Error e) returns error? {
        log:printError(string `Error occurred while processing inventory change events: ${e.message()}`);
    }
}

type Product record {|
    int product_id;
    string name;
    int quantity;
    decimal price;
    string category;
|};
