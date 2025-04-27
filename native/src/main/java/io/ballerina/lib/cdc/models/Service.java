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
package io.ballerina.lib.cdc.models;

import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BObject;

import java.util.HashMap;
import java.util.Map;

import static io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames.ON_CREATE;
import static io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames.ON_DELETE;
import static io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames.ON_ERROR;
import static io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames.ON_READ;
import static io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames.ON_TRUNCATE;
import static io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames.ON_UPDATE;


/**
 * Represents a CDC service and its associated methods.
 */
public class Service {

    private final BObject service;
    private final Map<String, Method> methods = new HashMap<>();
    private final boolean isServiceIsolated;
    private final boolean isOnErrorPresent;
    private final boolean isOnErrorMethodIsolated;

    /**
     * Constructs a Service object by analyzing the given Ballerina service object.
     * */
    public Service(BObject service) {
        this.service = service;
        ObjectType serviceType = (ObjectType) TypeUtils.getReferredType(TypeUtils.getType(service));
        this.isServiceIsolated = serviceType.isIsolated();

        boolean onErrorPresent = false;
        boolean onErrorIsolated = false;

        for (MethodType method : serviceType.getMethods()) {
            String methodName = method.getName();
            Parameter[] parameters = method.getParameters();
            boolean isolated = method.isIsolated();

            switch (methodName) {
                case ON_READ, ON_CREATE -> addMethod(methodName, null, parameters[0].type,
                        parameters.length == 2, isolated);
                case ON_DELETE -> addMethod(methodName, parameters[0].type, null,
                        parameters.length == 2, isolated);
                case ON_UPDATE -> addMethod(methodName, parameters[0].type, parameters[1].type,
                        parameters.length == 3, isolated);
                case ON_TRUNCATE -> addMethod(methodName, null, null,
                        parameters.length == 1, isolated);
                case ON_ERROR -> {
                    onErrorPresent = true;
                    onErrorIsolated = isolated;
                }
                default -> {
                    // Ignore other methods
                }
            }
        }

        this.isOnErrorPresent = onErrorPresent;
        this.isOnErrorMethodIsolated = onErrorIsolated;
    }

    private void addMethod(String methodName, Type beforeType, Type afterType, boolean hasTable, boolean isolated) {
        this.methods.put(methodName, new Method(beforeType, afterType, hasTable, isolated));
    }

    public BObject getService() {
        return this.service;
    }

    public boolean isIsolated() {
        return this.isServiceIsolated;
    }

    public boolean isOnErrorPresent() {
        return this.isOnErrorPresent;
    }

    public boolean isOnErrorMethodIsolated() {
        return this.isOnErrorMethodIsolated;
    }

    public Method getMethod(String functionName) {
        return this.methods.get(functionName);
    }
}
