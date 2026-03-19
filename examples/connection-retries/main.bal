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

configurable string hostname = ?;
configurable string username = ?;
configurable string password = ?;

type Order record {|
    int order_id;
    int customer_id;
    decimal total;
    string status;
    string created_at;
|};

listener mysql:CdcListener orderDbListener = new (
    database = {
        hostname,
        port: 3306,
        username,
        password,
        includedDatabases: "order_db"
    },
    options = {
        snapshotMode: cdc:NO_DATA,
        connectionRetryConfig: {
            maxAttempts: 10,
            retryInitialDelay: 1,
            retryMaxDelay: 30
        }
    }
);

@cdc:ServiceConfig {
    tables: "order_db.orders"
}
service cdc:Service on orderDbListener {

    remote function onCreate(Order after, string tableName) returns error? {
        do {
            log:printInfo(string `Order created: ID: ${after.order_id}, Customer: ${after.customer_id}, Total: $${after.total}, Status: ${after.status}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onUpdate(Order before, Order after, string tableName) returns error? {
        do {
            log:printInfo(string `Order updated: ID: ${after.order_id}, Status changed from '${before.status}' to '${after.status}'`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onDelete(Order before, string tableName) returns error? {
        do {
            log:printInfo(string `Order deleted: ID: ${before.order_id}, Customer: ${before.customer_id}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onError(cdc:Error e) returns error? {
        log:printError(string `Error occurred while processing order change events: ${e.message()}`);
    }
}
