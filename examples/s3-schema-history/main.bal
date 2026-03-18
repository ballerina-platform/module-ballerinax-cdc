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
import ballerinax/cdc.schema.aws.s3.driver as _;
import ballerinax/mysql;
import ballerinax/mysql.cdc.driver as _;

configurable string hostname;
configurable string username;
configurable string password;
configurable string accessKeyId;
configurable string secretAccessKey;
configurable string region;

listener mysql:CdcListener auditDbListener = new (
    database = {
        hostname,
        port: 3306,
        username,
        password,
        includedDatabases: "audit_db"
    },
    internalSchemaStorage = {
        accessKeyId,
        secretAccessKey,
        region,
        bucketName: "cdc-schema-history",
        objectName: "schema/schema-history.json"
    },
    options = {
        snapshotMode: cdc:NO_DATA
    }
);

@cdc:ServiceConfig {
    tables: "audit_db.audit_log"
}
service cdc:Service on auditDbListener {

    remote function onCreate(AuditEntry after, string tableName) returns error? {
        do {
            log:printInfo(string `Audit entry created: ID: ${after.entry_id}, Entity: ${after.entity_type}#${after.entity_id}, Action: ${after.action}, By: ${after.changed_by}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onUpdate(AuditEntry before, AuditEntry after, string tableName) returns error? {
        do {
            log:printInfo(string `Audit entry updated: ID: ${after.entry_id}, Action changed from '${before.action}' to '${after.action}'`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onDelete(AuditEntry before, string tableName) returns error? {
        do {
            log:printInfo(string `Audit entry removed: ID: ${before.entry_id}, Entity: ${before.entity_type}#${before.entity_id}`);
        } on fail error err {
            return error("unhandled error", err);
        }
    }

    remote function onError(cdc:Error e) returns error? {
        log:printError(string `Error occurred while processing audit log change events: ${e.message()}`);
    }
}

type AuditEntry record {|
    int entry_id;
    string entity_type;
    int entity_id;
    string action;
    string changed_by;
    string changed_at;
|};
