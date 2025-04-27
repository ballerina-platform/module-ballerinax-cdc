// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
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
import ballerina/jballerina.java as java;

# Represents a Ballerina CDC MSSQL Listener.
public class MsSqlListener {

    private map<string> config;
    private boolean isStarted = false;
    private boolean hasAttachedService = false;

    # Initializes the MSSQL listener with the given configuration.
    #
    # + config - The configuration for the MSSQL connector
    public isolated function init(*MsSqlListenerConfiguration config) {
        self.config = getDebeziumProperties(config);
    }

    # Attaches a CDC service to the MSSQL listener.
    #
    # + s - The CDC service to attach
    # + name - Attachment points
    # + return - An error if the service cannot be attached, or `()` if successful
    public isolated function attach(Service s, string[]|string? name = ()) returns Error? {
        if (self.isStarted) {
            return error OperationNotPermittedError("Cannot attach CDC service to the listener once it is running.");
        }
        check externAttach(self, s);
        self.hasAttachedService = true;
    }

    # Starts the MSSQL listener.
    #
    # + return - An error if the listener cannot be started, or `()` if successful
    public isolated function 'start() returns Error? {
        if (!self.hasAttachedService) {
            return error OperationNotPermittedError("Cannot start CDC listener without at least one attached service.");
        }
        check externStart(self, self.config);
        self.isStarted = true;
    }

    # Detaches a CDC service from the MSSQL listener.
    #
    # + s - The CDC service to detach
    # + return - An error if the service cannot be detached, or `()` if successful
    public isolated function detach(Service s) returns Error? {
        if (self.isStarted) {
            return error OperationNotPermittedError("Cannot detach CDC service from the listener once it is running.");
        }
        boolean|Error result = externDetach(self, s);
        if result is Error {
            return result;
        }
        self.hasAttachedService = result;
    }

    # Stops the MSSQL listener gracefully.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function gracefulStop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.cdc.Listener"
    } external;

    # Stops the MSSQL listener immediately.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function immediateStop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.cdc.Listener"
    } external;
}
