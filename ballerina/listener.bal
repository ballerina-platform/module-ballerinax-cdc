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

# Represents a Ballerina CDC MySQL Listener.
public type Listener isolated object {

    # Attaches a CDC service to the listener.
    #
    # + s - The CDC service to attach
    # + name - Attachment points
    # + return - An error if the service cannot be attached, or `()` if successful
    public isolated function attach(Service s, string[]|string? name = ()) returns Error?;

    # Starts the CDC listener.
    #
    # + return - An error if the listener cannot be started, or `()` if successful
    public isolated function 'start() returns Error?;

    # Detaches a CDC service from the listener.
    #
    # + s - The CDC service to detach
    # + return - An error if the service cannot be detached, or `()` if successful
    public isolated function detach(Service s) returns Error?;

    # Stops the listener gracefully.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function gracefulStop() returns Error?;

    # Stops the listener immediately.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function immediateStop() returns Error?;
};
