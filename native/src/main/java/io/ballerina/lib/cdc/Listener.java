/**
 * Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express q or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.lib.cdc;

import io.ballerina.lib.cdc.models.Service;
import io.ballerina.lib.cdc.utils.Constants.BallerinaErrors;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.debezium.engine.ChangeEvent;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.format.Json;

import java.io.IOException;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static io.ballerina.lib.cdc.utils.Constants.ANN_CONFIG_TABLES;
import static io.ballerina.lib.cdc.utils.Constants.ANN_NAME_EVENTS_FROM;
import static io.ballerina.lib.cdc.utils.Constants.COLON;
import static io.ballerina.lib.cdc.utils.Constants.SERVICE_MAP_ALL_KEY;
import static io.ballerina.lib.cdc.utils.ErrorUtils.createCdcError;
import static io.ballerina.lib.cdc.utils.ErrorUtils.createError;
import static io.ballerina.lib.cdc.utils.ModuleUtils.getPackageIdentifier;
import static io.debezium.engine.DebeziumEngine.create;

/**
 * This class contains utility functions for the cdc:Listener object.
 */
public class Listener {

    public static final String TABLE_TO_SERVICE_MAP_KEY = "TABLE_TO_SERVICE_MAP";
    public static final String DEBEZIUM_ENGINE_KEY = "DEB_ENGINE";
    public static final String EXECUTOR_SERVICE_KEY = "ExecutorService";

    public static Object attach(BObject listener, BObject service) {
        Object serviceMap = listener.getNativeData(TABLE_TO_SERVICE_MAP_KEY);
        Object serviceConfigAnn = getServiceConfigAnnotation(service);

        Map<String, Service> updatedServiceMap = initializeServiceMap(serviceMap);

        try {
            if (serviceConfigAnn == null) {
                handleUnAnnotatedServiceAttachment(serviceMap, updatedServiceMap, service);
            } else {
                handleUnAnnotatedServiceAttachment(serviceConfigAnn, service, updatedServiceMap);
            }
        } catch (BError e) {
            return e;
        }
        listener.addNativeData(TABLE_TO_SERVICE_MAP_KEY, updatedServiceMap);
        return null;
    }

    private static Object getServiceConfigAnnotation(BObject service) {
        return ((ObjectType) TypeUtils.getReferredType(TypeUtils.getType(service))).getAnnotation(
                StringUtils.fromString(getPackageIdentifier() + COLON + ANN_NAME_EVENTS_FROM));
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Service> initializeServiceMap(Object serviceMap) {
        if (serviceMap != null) {
            return (ConcurrentHashMap<String, Service>) serviceMap;
        }
        return new ConcurrentHashMap<>();
    }

    private static void handleUnAnnotatedServiceAttachment(Object serviceMap, Map<String, Service> updatedServiceMap,
                                                      BObject service) {
        if (serviceMap != null) {
            throw createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR, "The 'cdc:ServiceConfig' annotation " +
                    "is mandatory when attaching multiple services to the 'cdc:Listener'.");
        }
        updatedServiceMap.put(SERVICE_MAP_ALL_KEY, new Service(service));
    }

    private static void handleUnAnnotatedServiceAttachment(Object serviceConfigAnn, BObject service,
                                                           Map<String, Service> updatedServiceMap) {
        Object tableConfig = ((BMap<?, ?>) serviceConfigAnn).get(ANN_CONFIG_TABLES);
        if (TypeUtils.getType(tableConfig).getTag() == TypeTags.ARRAY_TAG) {
            for (String table : ((BArray) tableConfig).getStringArray()) {
                addServiceToMap(service, table, updatedServiceMap);
            }
        } else {
            String table = ((BString) tableConfig).getValue();
            addServiceToMap(service, table, updatedServiceMap);
        }
    }

    private static void addServiceToMap(BObject service, String table, Map<String, Service> updatedServiceMap) {
        if (updatedServiceMap.containsKey(table)) {
            throw createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                    "Multiple services cannot be used to receive events from the same table '" + table + "'.");
        }
        updatedServiceMap.put(table, new Service(service));
    }

    public static Object detach(BObject listener, BObject service) {
        Object serviceMap = listener.getNativeData(TABLE_TO_SERVICE_MAP_KEY);
        Object serviceConfigAnn = getServiceConfigAnnotation(service);

        try {
            if (serviceConfigAnn == null) {
                return removeSingleServiceFromMap(listener, serviceMap);
            } else {
                return removeServiceFromMap(listener, serviceMap, serviceConfigAnn);
            }
        } catch (BError e) {
            return e;
        }
    }

    private static boolean removeSingleServiceFromMap(BObject listener, Object serviceMap) {
        if (serviceMap == null) {
            throw createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                    "Cannot detach a service that is not attached to the listener.");
        }
        listener.addNativeData(TABLE_TO_SERVICE_MAP_KEY, null);
        return false;
    }

    private static boolean removeServiceFromMap(BObject listener, Object serviceMap, Object serviceConfigAnn) {
        Map<String, Service> updatedServiceMap = initializeServiceMap(serviceMap);
        Object tableConfig = ((BMap<?, ?>) serviceConfigAnn).get(ANN_CONFIG_TABLES);

        if (TypeUtils.getType(tableConfig).getTag() == TypeTags.ARRAY_TAG) {
            for (String table : ((BArray) tableConfig).getStringArray()) {
                updatedServiceMap.remove(table);
            }
        } else {
            updatedServiceMap.remove(((BString) tableConfig).getValue());
        }

        if (updatedServiceMap.isEmpty()) {
            listener.addNativeData(TABLE_TO_SERVICE_MAP_KEY, null);
            return false;
        } else {
            listener.addNativeData(TABLE_TO_SERVICE_MAP_KEY, updatedServiceMap);
            return true;
        }
    }

    public static Object start(Environment environment, BObject listener, BMap<BString, Object> config) {
        Properties engineProperties = populateEngineProperties(config);
        @SuppressWarnings("unchecked")
        ConcurrentHashMap<String, Service> serviceMap = (ConcurrentHashMap<String, Service>) listener
                .getNativeData(TABLE_TO_SERVICE_MAP_KEY);

        try {
            CompletableFuture<EngineResult> comFuture = new CompletableFuture<>();
            ExecutorService executor = Executors.newCachedThreadPool();
            DebeziumEngine<ChangeEvent<String, String>> engine = create(Json.class)
                    .using(engineProperties)
                    .notifying(new BalChangeConsumer(serviceMap, environment.getRuntime()))
                    .using(new DebeziumEngine.ConnectorCallback() {
                        @Override
                        public void taskStarted() {
                            EngineResult result = new EngineResult();
                            result.success = true;
                            comFuture.complete(result);
                        }
                    })
                    .using((success, message, error) -> {
                        EngineResult result = new EngineResult();
                        result.success = success;
                        result.message = message;
                        result.error = error;
                        comFuture.complete(result);
                    })
                    .build();
            executor.submit(engine);

            EngineResult engineResult = comFuture.get();
            if (engineResult.success) {
                listener.addNativeData(DEBEZIUM_ENGINE_KEY, engine);
                listener.addNativeData(EXECUTOR_SERVICE_KEY, executor);
            } else {
                String errorMessage = engineResult.message != null ? engineResult.message
                        : (engineResult.error != null ? engineResult.error.getMessage() : "Unknown error");
                return createCdcError("Failed to start the Debezium engine: " + errorMessage);
            }
            return null;
        } catch (Throwable t) {
            return createCdcError("Failed to start the Debezium engine: " + t.getMessage());
        }
    }

    private static Properties populateEngineProperties(BMap<BString, Object> config) {
        Properties engineProperties = new Properties();
        for (Map.Entry<BString, Object> configEntry : config.entrySet()) {
            engineProperties.setProperty(configEntry.getKey().getValue(), configEntry.getValue().toString());
        }
        return engineProperties;
    }

    public static Object gracefulStop(BObject listener) {
        Object debEngine = listener.getNativeData(DEBEZIUM_ENGINE_KEY);
        if (debEngine != null) {
            try {
                ((DebeziumEngine<?>) debEngine).close();
                listener.addNativeData(DEBEZIUM_ENGINE_KEY, null);
            } catch (IOException e) {
                return createCdcError("Failed to stop the Debezium engine: " + e.getMessage());
            }
        }
        return null;
    }

    public static Object immediateStop(BObject listener) {
        Object executor = listener.getNativeData(EXECUTOR_SERVICE_KEY);
        if (executor != null) {
            try {
                ((ExecutorService) executor).shutdownNow();
                listener.addNativeData(EXECUTOR_SERVICE_KEY, null);
            } catch (Exception e) {
                return createCdcError("Failed to stop the Debezium engine: " + e.getMessage());
            }
        }
        return null;
    }

    // Helper class to store result
    static class EngineResult {
        volatile boolean success = true;
        volatile String message = null;
        volatile Throwable error = null;
    }
}
