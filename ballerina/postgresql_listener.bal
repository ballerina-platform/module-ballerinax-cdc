// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java as java;

# Represents a Ballerina CDC PostgreSql Listener.
public isolated class PostgreSqlListener {

    private final map<string> & readonly config;
    private boolean isStarted = false;
    private boolean hasAttachedService = false;

    # Initializes the PostgreSql listener with the given configuration.
    #
    # + config - The configuration for the PostgreSql connector
    public isolated function init(*PostgresListenerConfiguration config) {
        self.config = getDebeziumProperties(config);
    }

    # Attaches a CDC service to the PostgreSql listener.
    #
    # + s - The CDC service to attach
    # + name - Attachment points
    # + return - An error if the service cannot be attached, or `()` if successful
    public isolated function attach(Service s, string[]|string? name = ()) returns Error? {
        lock {
            if self.isStarted {
                return error OperationNotPermittedError("Cannot attach CDC service to the listener once it is running.");
            }
        }
        check externAttach(self, s);
        lock {
            self.hasAttachedService = true;
        }
    }

    # Starts the PostgreSql listener.
    #
    # + return - An error if the listener cannot be started, or `()` if successful
    public isolated function 'start() returns Error? {
        lock {
            if !self.hasAttachedService {
                return error OperationNotPermittedError("Cannot start the listener without at least one attached service.");
            }
        }
        check externStart(self, self.config);
        lock {
            self.isStarted = true;
        }
    }

    # Detaches a CDC service from the PostgreSql listener.
    #
    # + s - The CDC service to detach
    # + return - An error if the service cannot be detached, or `()` if successful
    public isolated function detach(Service s) returns Error? {
        lock {
            if self.isStarted {
                return error OperationNotPermittedError("Cannot detach a service from the listener once it is running.");
            }
            if !self.hasAttachedService {
                return;
            }
        }
        boolean result = check externDetach(self, s);
        lock {
            self.hasAttachedService = result;
        }
    }

    # Stops the PostgreSql listener gracefully.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function gracefulStop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.cdc.Listener"
    } external;

    # Stops the PostgreSql listener immediately.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function immediateStop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.cdc.Listener"
    } external;
}
