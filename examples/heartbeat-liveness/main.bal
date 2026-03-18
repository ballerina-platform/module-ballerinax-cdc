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

listener mysql:CdcListener financeDbListener = new (
    database = {
        hostname,
        port: 3306,
        username,
        password,
        includedDatabases: "finance_db",
        excludedTables: "finance_db.debezium_heartbeat"
    },
    options = {
        snapshotMode: cdc:NO_DATA,
        heartbeatConfig: {
            interval: 5,
            actionQuery: "UPDATE finance_db.debezium_heartbeat SET ts = NOW() WHERE id = 1"
        }
    },
    livenessInterval = 10
);

@cdc:ServiceConfig {
    tables: "finance_db.transactions"
}
service cdc:Service on financeDbListener {

    remote function onCreate(Transaction after, string tableName) returns error? {
        do {
            log:printInfo(string `Transaction recorded: ID: ${after.tx_id}, Account: ${after.account_id}, Amount: $${after.amount}, Type: ${after.'type}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onUpdate(Transaction before, Transaction after, string tableName) returns error? {
        do {
            log:printInfo(string `Transaction updated: ID: ${after.tx_id}, Status changed from '${before.status}' to '${after.status}'`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onDelete(Transaction before, string tableName) returns error? {
        do {
            log:printInfo(string `Transaction removed: ID: ${before.tx_id}, Account: ${before.account_id}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onError(cdc:Error e) returns error? {
        log:printError(string `Error occurred while processing transaction change events: ${e.message()}`);
    }
}

type Transaction record {|
    int tx_id;
    int account_id;
    decimal amount;
    string 'type;
    string status;
    string created_at;
|};
