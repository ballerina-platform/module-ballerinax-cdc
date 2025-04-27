// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

# Represents the details of an error that occurred during event processing.
#
# + payload - The JSON payload associated with the error
public type EventProcessingErrorDetail record {
    json payload;
};

# Defines the common error type for the CDC module.
public type Error distinct error;

# Represents an error that occurred during event processing.
public type EventProcessingError distinct (Error & error<EventProcessingErrorDetail>);

# Represents an error that occurred due to payload binding issues.
public type PayloadBindingError distinct EventProcessingError;

# Represents an error that occurred due to an operation not being permitted.
public type OperationNotPermittedError distinct Error;
