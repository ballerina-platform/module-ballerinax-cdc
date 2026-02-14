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
import io.ballerina.lib.cdc.utils.ErrorUtils;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.types.ObjectType;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.debezium.engine.ChangeEvent;
import io.debezium.engine.DebeziumEngine;
import io.debezium.engine.format.Json;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Optional;
import java.util.Properties;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.locks.ReentrantLock;

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
    private static final String CHANGE_CONSUMER_KEY = "ChangeConsumer";
    private static final String COMP_CALLBACK_KEY = "CompletionCallback";
    private static final String LIVENESS_INTERVAL_KEY = "LivenessInterval";
    private static final String LISTENER_START_TIME_KEY = "ListenerStartTime";
    private static final BString LIVENESS_INTERVAL_CONFIG_KEY = StringUtils.fromString("livenessInterval");
    private static final long DEFAULT_LIVENESS_INTERVAL_MILLIS = 60000;

    public static final String TABLE_TO_SERVICE_MAP_KEY = "TABLE_TO_SERVICE_MAP";
    public static final String DEBEZIUM_ENGINE_KEY = "DEB_ENGINE";
    public static final String EXECUTOR_SERVICE_KEY = "ExecutorService";
    public static final String IS_STARTED_KEY = "isStarted";
    public static final String HAS_ATTACHED_SERVICE_KEY = "hasAttachedService";
    public static final String LISTENER_ID = "Id";
    private static final ConcurrentHashMap<Object, ReentrantLock> lockMap = new ConcurrentHashMap<>();

    public static Object attach(BObject listener, BObject service) {
        String id = getListenerId(listener);
        ReentrantLock lock = lockMap.computeIfAbsent(id, k -> new ReentrantLock());

        lock.lock();
        try {
            Object isStartedKey = listener.getNativeData(IS_STARTED_KEY);
            boolean isStarted = isStartedKey != null && ((Boolean) isStartedKey);
            if (isStarted) {
                return ErrorUtils.createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                        "Cannot attach a CDC service to the listener once it is running.");
            }

            Object serviceMap = listener.getNativeData(TABLE_TO_SERVICE_MAP_KEY);
            Object serviceConfigAnn = getServiceConfigAnnotation(service);

            Map<String, Service> updatedServiceMap = initializeServiceMap(serviceMap);
            if (serviceConfigAnn == null) {
                handleUnAnnotatedServiceAttachment(serviceMap, updatedServiceMap, service);
            } else {
                handleUnAnnotatedServiceAttachment(serviceConfigAnn, service, updatedServiceMap);
            }
            listener.addNativeData(TABLE_TO_SERVICE_MAP_KEY, updatedServiceMap);
            listener.addNativeData(HAS_ATTACHED_SERVICE_KEY, true);
            return null;
        } catch (Exception e) {
            return e;
        } finally {
            lock.unlock();
        }
    }

    public static Object detach(BObject listener, BObject service) {
        String id = getListenerId(listener);
        ReentrantLock lock = lockMap.computeIfAbsent(id, k -> new ReentrantLock());

        lock.lock();
        try {
            Object isStartedKey = listener.getNativeData(IS_STARTED_KEY);
            boolean isStarted = isStartedKey != null && ((Boolean) isStartedKey);
            if (isStarted) {
                return ErrorUtils.createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                        "Cannot detach a CDC service from the listener once it is running.");
            }

            Object hasAttachedServiceObj = listener.getNativeData(HAS_ATTACHED_SERVICE_KEY);
            boolean hasAttachedService = hasAttachedServiceObj != null && ((Boolean) hasAttachedServiceObj);
            if (hasAttachedService) {
                return null;
            }
            Object serviceMap = listener.getNativeData(TABLE_TO_SERVICE_MAP_KEY);
            Object serviceConfigAnn = getServiceConfigAnnotation(service);

            if (serviceConfigAnn == null) {
                hasAttachedService = removeSingleServiceFromMap(listener, serviceMap);
            } else {
                hasAttachedService = removeServiceFromMap(listener, serviceMap, serviceConfigAnn);
            }
            listener.addNativeData(HAS_ATTACHED_SERVICE_KEY, hasAttachedService);
            return null;
        } catch (Exception e) {
            return e;
        } finally {
            lock.unlock();
        }
    }

    public static Object start(Environment environment, BObject listener, BMap<BString, Object> config) {
        String id = getListenerId(listener);
        ReentrantLock lock = lockMap.computeIfAbsent(id, k -> new ReentrantLock());

        lock.lock();
        try {
            Object isStartedKey = listener.getNativeData(IS_STARTED_KEY);
            boolean isStarted = isStartedKey != null && ((Boolean) isStartedKey);
            if (isStarted) {
                return null;
            }

            Object hasAttachedServiceObj = listener.getNativeData(HAS_ATTACHED_SERVICE_KEY);
            boolean hasAttachedService = hasAttachedServiceObj != null && ((Boolean) hasAttachedServiceObj);
            if (!hasAttachedService) {
                return ErrorUtils.createError(BallerinaErrors.OPERATION_NOT_PERMITTED_ERROR,
                        "Cannot start the listener without at least one attached service.");
            }

            Properties engineProperties = populateEngineProperties(config);

            Long livenessInterval;
            if (config.containsKey(LIVENESS_INTERVAL_CONFIG_KEY)) {
                livenessInterval = ((BDecimal) config.get(LIVENESS_INTERVAL_CONFIG_KEY))
                        .decimalValue()
                        .multiply(BigDecimal.valueOf(1000))
                        .longValue();
            } else {
                livenessInterval = DEFAULT_LIVENESS_INTERVAL_MILLIS;
            }

            @SuppressWarnings("unchecked")
            ConcurrentHashMap<String, Service> serviceMap = (ConcurrentHashMap<String, Service>) listener
                    .getNativeData(TABLE_TO_SERVICE_MAP_KEY);

            CompletableFuture<EngineResult> comFuture = new CompletableFuture<>();
            CdcCompletionCallback completionCallback = new CdcCompletionCallback();
            BalChangeConsumer changeConsumer = new BalChangeConsumer(serviceMap, environment.getRuntime());
            ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
            DebeziumEngine<ChangeEvent<String, String>> engine = create(Json.class)
                    .using(engineProperties)
                    .notifying(changeConsumer)
                    .using(new DebeziumEngine.ConnectorCallback() {
                        @Override
                        public void taskStarted() {
                            EngineResult result = new EngineResult();
                            result.success = true;
                            comFuture.complete(result);
                        }
                    })
                    .using(completionCallback)
                    .build();
            executor.submit(engine);

            EngineResult engineResult = comFuture.get();
            if (engineResult.success) {
                listener.addNativeData(DEBEZIUM_ENGINE_KEY, engine);
                listener.addNativeData(EXECUTOR_SERVICE_KEY, executor);
                listener.addNativeData(CHANGE_CONSUMER_KEY, changeConsumer);
                listener.addNativeData(COMP_CALLBACK_KEY, completionCallback);
                listener.addNativeData(LIVENESS_INTERVAL_KEY, livenessInterval);
                listener.addNativeData(LISTENER_START_TIME_KEY, Instant.now());
            } else {
                return createCdcError("Failed to start the Debezium engine due to unknown error");
            }
            listener.addNativeData(IS_STARTED_KEY, true);
            return null;
        } catch (Throwable t) {
            return createCdcError("Failed to start the Debezium engine: " + t.getMessage());
        } finally {
            lock.unlock();
        }
    }

    public static Object gracefulStop(BObject listener) {
        String id = getListenerId(listener);
        ReentrantLock lock = lockMap.computeIfAbsent(id, k -> new ReentrantLock());

        lock.lock();
        try {
            Object debEngine = listener.getNativeData(DEBEZIUM_ENGINE_KEY);
            if (debEngine != null) {
                ((DebeziumEngine<?>) debEngine).close();
                listener.addNativeData(DEBEZIUM_ENGINE_KEY, null);
            }

            Object executor = listener.getNativeData(EXECUTOR_SERVICE_KEY);
            if (executor != null) {
                ((ExecutorService) executor).shutdown();
                listener.addNativeData(EXECUTOR_SERVICE_KEY, null);
            }

            listener.addNativeData(IS_STARTED_KEY, false);
            return null;
        } catch (IOException e) {
            return createCdcError("Failed to stop the Debezium engine: " + e.getMessage());
        } finally {
            lock.unlock();
        }
    }

    public static Object immediateStop(BObject listener) {
        String id = getListenerId(listener);
        ReentrantLock lock = lockMap.computeIfAbsent(id, k -> new ReentrantLock());

        lock.lock();
        try {
            Object executor = listener.getNativeData(EXECUTOR_SERVICE_KEY);

            if (executor != null) {
                ((ExecutorService) executor).shutdownNow();
                listener.addNativeData(EXECUTOR_SERVICE_KEY, null);
            }

            listener.addNativeData(DEBEZIUM_ENGINE_KEY, null);
            listener.addNativeData(IS_STARTED_KEY, false);
            return null;
        } catch (Exception e) {
            return createCdcError("Failed to stop the Debezium engine: " + e.getMessage());
        } finally {
            lock.unlock();
        }
    }

    public static Object isLive(BObject listener) {
        String id = getListenerId(listener);
        ReentrantLock lock = lockMap.computeIfAbsent(id, k -> new ReentrantLock());

        lock.lock();
        try {
            Object completionCallback = listener.getNativeData(COMP_CALLBACK_KEY);
            if (completionCallback != null) {
                boolean invoked = ((CdcCompletionCallback) completionCallback).isInvoked();
                if (invoked) {
                    return false;
                }
            } else {
                return false;
            }

            Long livenessInterval = (Long) listener.getNativeData(LIVENESS_INTERVAL_KEY);

            Object listenerStartTime = listener.getNativeData(LISTENER_START_TIME_KEY);
            if (listenerStartTime != null) {
                Instant current = Instant.now();
                long diff = ChronoUnit.MILLIS.between((Instant) listenerStartTime, current);
                if (diff < livenessInterval) {
                    return true;
                }
            } else {
                return false;
            }

            Object changeConsumer = listener.getNativeData(CHANGE_CONSUMER_KEY);
            if (changeConsumer != null) {
                Optional<Instant> lastEventReceivedTime = ((BalChangeConsumer) changeConsumer)
                        .getLastEventReceivedTime();
                if (lastEventReceivedTime.isEmpty()) {
                    return false;
                }

                Instant current = Instant.now();
                Instant lastEventReceived = lastEventReceivedTime.get();
                long diff = ChronoUnit.MILLIS.between(lastEventReceived, current);
                if (diff > livenessInterval) {
                    return false;
                }
            }

            return true;
        } catch (Exception e) {
            return createCdcError("Failed to invoke the liveliness check for the Debezium engine: " + e.getMessage());
        } finally {
            lock.unlock();
        }
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

    private static Properties populateEngineProperties(BMap<BString, Object> config) {
        Properties engineProperties = new Properties();
        for (Map.Entry<BString, Object> configEntry : config.entrySet()) {
            if (configEntry.getKey().equals(LIVENESS_INTERVAL_CONFIG_KEY)) {
                continue;
            }
            engineProperties.setProperty(configEntry.getKey().getValue(), configEntry.getValue().toString());
        }
        return engineProperties;
    }

    private static String getListenerId(BObject listener) {
        Object idObj = listener.getNativeData(LISTENER_ID);
        String id;
        if (idObj == null) {
            id = UUID.randomUUID().toString();
            listener.addNativeData(LISTENER_ID, id);
        } else {
            id = (String) idObj;
        }
        return id;
    }

    // Helper class to store result
    static class EngineResult {
        volatile boolean success = true;
    }
}
