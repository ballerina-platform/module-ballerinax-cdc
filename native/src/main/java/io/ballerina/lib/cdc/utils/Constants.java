/*
 * Copyright (c) 2025, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package io.ballerina.lib.cdc.utils;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * This class contains constants used in the CDC module.
 */
public class Constants {

    public static final String PACKAGE = "ballerinax";
    public static final String MODULE = "cdc";
    public static final String COLON = ":";
    public static final String ANN_NAME_EVENTS_FROM = "ServiceConfig";
    public static final BString ANN_CONFIG_TABLES = StringUtils.fromString("tables");

    //data.jsondata parseAsType constants
    public static final String ENABLE_CONSTRAINT_VALIDATION = "enableConstraintValidation";
    public static final String ALLOW_DATA_PROJECTION = "allowDataProjection";
    public static final String PARSER_AS_TYPE_OPTIONS =  "Options";

    private Constants() {
    }

    public static class NativeDataKeys {
        public static final String TABLE_TO_SERVICE_MAP = "TABLE_TO_SERVICE_MAP";
        public static final String SERVICE_MAP_ALL = "*";
        public static final String DEBEZIUM_ENGINE = "DEB_ENGINE";
        public static final String EXECUTOR_SERVICE = "ExecutorService";

        private NativeDataKeys() {
        }
    }

    public static class ServiceMethodNames {
        public static final String ON_READ = "onRead";
        public static final String ON_CREATE = "onCreate";
        public static final String ON_UPDATE = "onUpdate";
        public static final String ON_DELETE = "onDelete";
        public static final String ON_TRUNCATE = "onTruncate";
        public static final String ON_ERROR = "onError";

        private ServiceMethodNames() {
        }
    }

    public static class BallerinaErrors {
        public static final String CDC_ERROR = "Error";
        public static final String EVENT_PROCESSING_ERROR = "EventProcessingError";
        public static final String PAYLOAD_BINDING_ERROR = "PayloadBindingError";
        public static final String OPERATION_NOT_PERMITTED_ERROR = "OperationNotPermittedError";
        public static final String EVENT_PROCESSING_ERROR_DETAIL = "EventProcessingErrorDetail";
        public static final String EVENT_PROCESSING_ERROR_DETAIL_PAYLOAD_FIELD = "payload";

        private BallerinaErrors() {
        }
    }

    public static class EventMembers {
        public static final String BEFORE = "before";
        public static final String AFTER = "after";
        public static final String SOURCE = "source";
        public static final String OP = "op";
        public static final String PAYLOAD = "payload";
        public static final String DB = "db";
        public static final String TABLE = "table";

        private EventMembers() {
        }
    }

    public static class DebeziumOperation {
        public static final String READ = "r";
        public static final String UPDATE = "u";
        public static final String CREATE = "c";
        public static final String DELETE = "d";
        public static final String TRUNCATE = "t";

        private DebeziumOperation() {
        }
    }
}
