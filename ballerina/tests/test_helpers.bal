// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

// Sample database options for testing (mimics database-specific modules)
public type SampleDBOptions record {|
    *Options;
    // Sample-specific options for testing
    ExtendedSnapshotConfiguration extendedSnapshot?;
    // Can add more sample-specific options here if needed
|};

// Sample database listener configuration for testing
public type SampleDBListenerConfiguration record {|
    *ListenerConfiguration;
    SampleDBOptions options = {};
|};

isolated function populateSampleDBDebeziumProperties(SampleDBListenerConfiguration config, map<string> actualProperties) {
    populateDebeziumProperties(config, actualProperties);
    populateSampleDBOptions(config.options, actualProperties);
}

// Populates SampleDB-specific options (mimics database-specific modules)
isolated function populateSampleDBOptions(SampleDBOptions options, map<string> configMap) {
    // Populate common options from cdc module
    populateOptions(options, configMap, typeof options);

    // Populate extended snapshot configuration if present
    ExtendedSnapshotConfiguration? extendedSnapshot = options.extendedSnapshot;
    if extendedSnapshot is ExtendedSnapshotConfiguration {
        populateExtendedSnapshotConfiguration(extendedSnapshot, configMap);
    }
}
