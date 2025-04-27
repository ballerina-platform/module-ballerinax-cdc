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

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.Optional;

import static io.ballerina.lib.cdc.utils.Constants.EventMembers.DB;
import static io.ballerina.lib.cdc.utils.Constants.EventMembers.OP;
import static io.ballerina.lib.cdc.utils.Constants.EventMembers.SOURCE;
import static io.ballerina.lib.cdc.utils.Constants.EventMembers.TABLE;

/**
 * Represents the payload of a CDC event.
 */
public class Payload {

    private final JsonObject payload;

    public Payload(JsonObject payload) {
        this.payload = payload;
    }

    public JsonObject getPayloadMember(String key) {
        return payload.getAsJsonObject(key);
    }

    public String getDatabase() {
        return getSourceMember(DB);
    }

    public String getTable() {
        return getSourceMember(TABLE);
    }

    public String getOp() {
        return Optional.ofNullable(payload.get(OP))
                .map(JsonElement::getAsString)
                .orElse(null);
    }

    @Override
    public String toString() {
        return this.payload.toString();
    }

    private JsonObject getSource() {
        return payload.getAsJsonObject(SOURCE);
    }

    private String getSourceMember(String key) {
        return Optional.ofNullable(getSource())
                .map(source -> source.get(key))
                .map(JsonElement::getAsString)
                .orElse(null);
    }
}
