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

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.lib.cdc.utils.Constants.BallerinaErrors.CDC_ERROR;
import static io.ballerina.lib.cdc.utils.Constants.BallerinaErrors.EVENT_PROCESSING_ERROR_DETAIL_PAYLOAD_FIELD;
import static io.ballerina.lib.cdc.utils.ModuleUtils.getModule;

/**
 * Utility class for creating and managing errors in the CDC module.
 */
public final class ErrorUtils {

    // Private constructor to prevent instantiation
    private ErrorUtils() {
    }

    public static BError createCdcError(String message) {
        return createError(CDC_ERROR, message, null, null);
    }

    public static BError createError(String errorType, String message) {
        return createError(errorType, message, null, null);
    }

    public static BError createError(String errorType, String message, BError cause, BMap<BString, Object> details) {
        return ErrorCreator.createError(getModule(), errorType, StringUtils.fromString(message), cause, details);
    }

    public static BMap<BString, Object> getEventProcessingErrorDetail(String record) {
        BMap<BString, Object> detail = ValueCreator.createMapValue();
        detail.put(StringUtils.fromString(EVENT_PROCESSING_ERROR_DETAIL_PAYLOAD_FIELD), JsonUtils.parse(record));
        return detail;
    }
}
