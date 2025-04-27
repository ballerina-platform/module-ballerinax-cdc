/*
 * Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.lib.cdc.models;

import io.ballerina.runtime.api.types.Type;

/**
 * Represents a CDC method with its parameter types and properties.
 *
 * @param beforeParamType The type of the "before" parameter, if applicable.
 * @param afterParamType  The type of the "after" parameter, if applicable.
 * @param hasTableName    Indicates if the method has a table name parameter.
 * @param isIsolated      Indicates if the method is isolated.
 */
public record Method(Type beforeParamType, Type afterParamType,
                     boolean hasTableName, boolean isIsolated) {

    /**
     * Checks if the method has a "before" parameter.
     *
     * @return True if the method has a "before" parameter, false otherwise.
     */
    public boolean hasBeforeParam() {
        return beforeParamType != null;
    }

    /**
     * Checks if the method has an "after" parameter.
     *
     * @return True if the method has an "after" parameter, false otherwise.
     */
    public boolean hasAfterParam() {
        return afterParamType != null;
    }
}
