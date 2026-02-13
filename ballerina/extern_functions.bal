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

import ballerina/jballerina.java;

# Attach point to call the native CDC listener attach method.
#
# + cdcListener - the cdc listener object  
# + cdcService - the cdc service object
# + return - an error if the service cannot be attached, or `()` if successful
public isolated function externAttach(Listener cdcListener, Service cdcService) returns Error? = @java:Method {
    name: "attach",
    'class: "io.ballerina.lib.cdc.Listener"
} external;

# Attach point to call the native CDC listener detach method.
#
# + cdcListener - the cdc listener object
# + cdcService - the configuration map
# + return - an error if the service cannot be detached, or `()` if successful
public isolated function externDetach(Listener cdcListener, Service cdcService) returns Error? = @java:Method {
    name: "detach",
    'class: "io.ballerina.lib.cdc.Listener"
} external;

# Attach point to call the native CDC listener start method.
#
# + cdcListener - the cdc listener object
# + config - the configuration map containing debezium properties
# + return - an error if the listener cannot be started, or `()` if successful
public isolated function externStart(Listener cdcListener, map<anydata> config) returns Error? = @java:Method {
    name: "start",
    'class: "io.ballerina.lib.cdc.Listener"
} external;

# Attach point to call the native CDC listener gracefulStop method.
#
# + cdcListener - the cdc listener object
# + return - an error if the listener cannot be stopped, or `()` if successful
public isolated function externGracefulStop(Listener cdcListener) returns Error? = @java:Method {
    name: "gracefulStop",
    'class: "io.ballerina.lib.cdc.Listener"
} external;

# Attach point to call the native CDC listener immediateStop method.
#
# + cdcListener - the cdc listener object
# + return - an error if the listener cannot be stopped, or `()` if successful
public isolated function externImmediateStop(Listener cdcListener) returns Error? = @java:Method {
    name: "immediateStop",
    'class: "io.ballerina.lib.cdc.Listener"
} external;


# Checks whether the given CDC listener is live.
#
# + cdc - The CDC listener instance to be checked
# + return - Returns `true` if the listener is considered live, `false` otherwise,
# or an error if the liveness check fail
public isolated function isLive(Listener cdc) returns boolean|Error = @java:Method {
    'class: "io.ballerina.lib.cdc.Listener"
} external;

public isolated function externGetAdditionalConfigKeys(Options options, typedesc<Options> optionsSubType) returns string[] = @java:Method {
    name: "getAdditionalConfigKeys",
    'class: "io.ballerina.lib.cdc.utils.Utils"
} external;
