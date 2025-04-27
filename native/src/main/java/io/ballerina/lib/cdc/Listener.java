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
package io.ballerina.lib.cdc;

import io.ballerina.lib.cdc.models.Service;
import io.ballerina.lib.cdc.utils.Constants.BallerinaErrors;
import io.ballerina.lib.cdc.utils.Constants.NativeDataKeys;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.debezium.engine.ChangeEvent;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.format.Json;

import java.io.IOException;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static io.ballerina.lib.cdc.utils.Constants.ANN_CONFIG_TABLES;
import static io.ballerina.lib.cdc.utils.Constants.ANN_NAME_EVENTS_FROM;
import static io.ballerina.lib.cdc.utils.Constants.COLON;
import static io.ballerina.lib.cdc.utils.ErrorUtils.createCdcError;
import static io.ballerina.lib.cdc.utils.ErrorUtils.createError;
import static io.ballerina.lib.cdc.utils.ModuleUtils.getPackageIdentifier;
import static io.debezium.engine.DebeziumEngine.create;

/**
 * This class contains utility functions for the cdc:Listener object.
 */
public class Listener {

    public static Object attach(BObject listener, BObject service) {
        Object serviceMap = listener.getNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP);
        Object serviceConfigAnn = getServiceConfigAnnotation(service);

        ConcurrentHashMap<String, Service> updatedServiceMap = initializeServiceMap(serviceMap);

        if (serviceConfigAnn == null) {
            handleSingleServiceAttachment(serviceMap, updatedServiceMap, service);
        } else {
            updateServiceMap(serviceConfigAnn, service, updatedServiceMap);
        }

        listener.addNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP, updatedServiceMap);
        return true;
    }

    private static Object getServiceConfigAnnotation(BObject service) {
        return ((ObjectType) TypeUtils.getReferredType(TypeUtils.getType(service))).getAnnotation(
                StringUtils.fromString(getPackageIdentifier() + COLON + ANN_NAME_EVENTS_FROM));
    }

    @SuppressWarnings("unchecked")
    private static ConcurrentHashMap<String, Service> initializeServiceMap(Object serviceMap) {
        if (serviceMap != null) {
            return (ConcurrentHashMap<String, Service>) serviceMap;
        }
        return new ConcurrentHashMap<>();
    }

    private static void handleSingleServiceAttachment(Object serviceMap,
                                                      ConcurrentHashMap<String, Service> updatedServiceMap,
                                                      BObject service) {
        if (serviceMap != null) {
            throw createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR, "The 'cdc:ServiceConfig' annotation " +
                    "is mandatory when attaching multiple services to the 'cdc:Listener'.");
        }
        updatedServiceMap.put(NativeDataKeys.SERVICE_MAP_ALL, new Service(service));
    }

    private static void updateServiceMap(Object serviceConfigAnn, BObject service,
                                         ConcurrentHashMap<String, Service> updatedServiceMap) {
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

    private static void addServiceToMap(BObject service, String table,
                                        ConcurrentHashMap<String, Service> updatedServiceMap) {
        if (updatedServiceMap.containsKey(table)) {
            throw createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                    "Multiple services cannot be used to receive events from the same table '" + table + "'.");
        }
        updatedServiceMap.put(table, new Service(service));
    }

    public static Object detach(BObject listener, BObject service) {
        Object serviceMap = listener.getNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP);
        Object serviceConfigAnn = getServiceConfigAnnotation(service);

        if (serviceConfigAnn == null) {
            return removeSingleServiceFromMap(listener, serviceMap);
        } else {
            return removeServiceFromMap(listener, serviceMap, serviceConfigAnn);
        }
    }

    private static boolean removeSingleServiceFromMap(BObject listener, Object serviceMap) {
        if (serviceMap == null) {
            throw createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                    "Cannot detach a service that is not attached to the listener.");
        }
        listener.addNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP, null);
        return false;
    }

    private static boolean removeServiceFromMap(BObject listener, Object serviceMap, Object serviceConfigAnn) {
        ConcurrentHashMap<String, Service> updatedServiceMap = initializeServiceMap(serviceMap);
        Object tableConfig = ((BMap<?, ?>) serviceConfigAnn).get(ANN_CONFIG_TABLES);

        if (TypeUtils.getType(tableConfig).getTag() == TypeTags.ARRAY_TAG) {
            for (String table : ((BArray) tableConfig).getStringArray()) {
                updatedServiceMap.remove(table);
            }
        } else {
            updatedServiceMap.remove(((BString) tableConfig).getValue());
        }

        if (updatedServiceMap.isEmpty()) {
            listener.addNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP, null);
            return false;
        } else {
            listener.addNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP, updatedServiceMap);
            return true;
        }
    }

    public static Object start(Environment environment, BObject listener, BMap<BString, Object> config) {
        Properties engineProperties = populateEngineProperties(config);
        @SuppressWarnings("unchecked")
        ConcurrentHashMap<String, Service> serviceMap = (ConcurrentHashMap<String, Service>) listener
                .getNativeData(NativeDataKeys.TABLE_TO_SERVICE_MAP);

        try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
            EngineResult result = new EngineResult();
            DebeziumEngine<ChangeEvent<String, String>> engine = create(Json.class)
                    .using(engineProperties)
                    .notifying(new BalChangeConsumer(serviceMap, environment.getRuntime()))
                    .using((success, message, error) -> {
                        result.success = success;
                        result.message = message;
                        result.error = error;
                        result.latch.countDown();
                    })
                    .build();
            executor.execute(engine);

            result.latch.await();
            if (result.success) {
                listener.addNativeData(NativeDataKeys.DEBEZIUM_ENGINE, engine);
                listener.addNativeData(NativeDataKeys.EXECUTOR_SERVICE, executor);
            } else {
                String errorMessage = result.message != null ? result.message
                        : (result.error != null ? result.error.getMessage() : "Unknown error");
                throw createCdcError("Failed to start the Debezium engine: " + errorMessage);
            }
        } catch (InterruptedException e) {
            throw createCdcError("Failed to start the Debezium engine: " + e.getMessage());
        }
        return null;
    }

    // Helper class to store result
    static class EngineResult {
        CountDownLatch latch = new CountDownLatch(1);
        boolean success = false;
        String message = null;
        Throwable error = null;
    }

    private static Properties populateEngineProperties(BMap<BString, Object> config) {
        Properties engineProperties = new Properties();
        for (Map.Entry<BString, Object> configEntry : config.entrySet()) {
            engineProperties.setProperty(configEntry.getKey().getValue(), configEntry.getValue().toString());
        }
        return engineProperties;
    }

    public static Object gracefulStop(BObject listener) {
        Object debEngine = listener.getNativeData(NativeDataKeys.DEBEZIUM_ENGINE);
        if (debEngine != null) {
            try {
                ((DebeziumEngine<?>) debEngine).close();
                listener.addNativeData(NativeDataKeys.DEBEZIUM_ENGINE, null);
            } catch (IOException e) {
                throw createCdcError("Failed to stop the Debezium engine: " + e.getMessage());
            }
        }
        return null;
    }

    public static Object immediateStop(BObject listener) {
        Object executor = listener.getNativeData(NativeDataKeys.EXECUTOR_SERVICE);
        if (executor != null) {
            try {
                ((ExecutorService) executor).shutdownNow();
                listener.addNativeData(NativeDataKeys.EXECUTOR_SERVICE, null);
            } catch (Exception e) {
                throw createCdcError("Failed to stop the Debezium engine: " + e.getMessage());
            }
        }
        return null;
    }
}
