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
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.lib.cdc;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import io.ballerina.lib.cdc.models.Method;
import io.ballerina.lib.cdc.models.Payload;
import io.ballerina.lib.cdc.models.Service;
import io.ballerina.lib.cdc.utils.Constants.DebeziumOperation;
import io.ballerina.lib.cdc.utils.Constants.EventMembers;
import io.ballerina.lib.cdc.utils.Constants.ServiceMethodNames;
import io.ballerina.lib.data.jsondata.json.Native;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.concurrent.StrandMetadata;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.debezium.engine.ChangeEvent;
import io.debezium.engine.DebeziumEngine;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static io.ballerina.lib.cdc.utils.Constants.ALLOW_DATA_PROJECTION;
import static io.ballerina.lib.cdc.utils.Constants.BallerinaErrors.EVENT_PROCESSING_ERROR;
import static io.ballerina.lib.cdc.utils.Constants.BallerinaErrors.EVENT_PROCESSING_ERROR_DETAIL;
import static io.ballerina.lib.cdc.utils.Constants.BallerinaErrors.EVENT_PROCESSING_ERROR_DETAIL_PAYLOAD_FIELD;
import static io.ballerina.lib.cdc.utils.Constants.BallerinaErrors.PAYLOAD_BINDING_ERROR;
import static io.ballerina.lib.cdc.utils.Constants.ENABLE_CONSTRAINT_VALIDATION;
import static io.ballerina.lib.cdc.utils.Constants.PARSER_AS_TYPE_OPTIONS;
import static io.ballerina.lib.cdc.utils.Constants.SERVICE_MAP_ALL_KEY;
import static io.ballerina.lib.cdc.utils.ErrorUtils.createError;
import static io.ballerina.lib.cdc.utils.ErrorUtils.getEventProcessingErrorDetail;
import static io.ballerina.lib.cdc.utils.ModuleUtils.getModule;
import static java.lang.Boolean.FALSE;

/**
 * Handles change events from the Debezium engine and invokes the appropriate Ballerina service methods.
 */
public class BalChangeConsumer implements DebeziumEngine.ChangeConsumer<ChangeEvent<String, String>> {

    private final Map<String, Service> serviceMap;
    private final boolean isSingleServiceAttached;
    private final Service singleService;
    private final Runtime runtime;

    public BalChangeConsumer(Map<String, Service> serviceMap, Runtime runtime) {
        this.serviceMap = new HashMap<>(serviceMap);
        if (serviceMap.size() == 1 && serviceMap.containsKey(SERVICE_MAP_ALL_KEY)) {
            this.isSingleServiceAttached = true;
            this.singleService = serviceMap.get(SERVICE_MAP_ALL_KEY);
        } else {
            this.isSingleServiceAttached = false;
            this.singleService = null;
        }
        this.runtime = runtime;
    }

    @Override
    public void handleBatch(List<ChangeEvent<String, String>> records,
                            DebeziumEngine.RecordCommitter<ChangeEvent<String, String>> committer)
            throws InterruptedException {
        for (ChangeEvent<String, String> record : records) {
            Service selectedService = null;
            try {
                JsonObject jsonEvent = new Gson().fromJson(record.value(), JsonObject.class);
                Payload payload = new Payload(jsonEvent.getAsJsonObject(EventMembers.PAYLOAD));
                selectedService = getSelectedService(payload);

                String methodName = getMethodName(payload.getOp());
                Method method = selectedService.getMethod(methodName);
                if (method == null) {
                    throw createMethodNotFoundError(payload, methodName);
                }

                boolean isIsolated = selectedService.isIsolated() && method.isIsolated();
                StrandMetadata metaData = new StrandMetadata(isIsolated, null);
                Object returnValue = this.runtime.callMethod(selectedService.getService(), methodName, metaData,
                        processParameters(selectedService, methodName, payload));
                handleReturnValue(returnValue);
                committer.markProcessed(record);
            } catch (BError bError) {
                handleError(selectedService, bError);
                committer.markProcessed(record);
            } catch (Throwable e) {
                // Catch unexpected exceptions to prevent the engine from stopping
                // This ensures the library can log details of the issue without disrupting ongoing operations
                BMap<BString, Object> detail = ValueCreator.createMapValue();
                detail.put(StringUtils.fromString(EVENT_PROCESSING_ERROR_DETAIL_PAYLOAD_FIELD),
                        JsonUtils.parse(record.value()));
                BError error = createError(EVENT_PROCESSING_ERROR, "Event Processing failed. " + e.getMessage(),
                        ErrorCreator.createError(e), detail);
                handleError(selectedService, error);
                committer.markProcessed(record);
            }
        }
        committer.markBatchFinished();
    }

    private Service getSelectedService(Payload payload) {
        if (this.isSingleServiceAttached) {
            return this.singleService;
        }
        StringBuilder serviceMapKeyBuilder = new StringBuilder(payload.getDatabase()).append(".");
        if (payload.getSchema() != null && !payload.getSchema().isEmpty()) {
            serviceMapKeyBuilder.append(payload.getSchema()).append(".");
        }
        serviceMapKeyBuilder.append(payload.getTable());
        String serviceMapKey = serviceMapKeyBuilder.toString();

        if (this.serviceMap.containsKey(serviceMapKey)) {
            return this.serviceMap.get(serviceMapKey);
        }
        BMap<BString, Object> detail = getEventProcessingErrorDetail(payload.toString());
        throw createError(EVENT_PROCESSING_ERROR,
                "Service for table '" + serviceMapKey + "' is not available.", null,
                ValueCreator.createRecordValue(getModule(), EVENT_PROCESSING_ERROR_DETAIL, detail));
    }

    private String getMethodName(String op) {
        return switch (op) {
            case DebeziumOperation.READ -> ServiceMethodNames.ON_READ;
            case DebeziumOperation.UPDATE -> ServiceMethodNames.ON_UPDATE;
            case DebeziumOperation.CREATE -> ServiceMethodNames.ON_CREATE;
            case DebeziumOperation.DELETE -> ServiceMethodNames.ON_DELETE;
            case DebeziumOperation.TRUNCATE -> ServiceMethodNames.ON_TRUNCATE;
            default -> ServiceMethodNames.ON_ERROR;
        };
    }

    private Object[] processParameters(Service service, String functionName, Payload payload) {
        Method method = service.getMethod(functionName);
        if (method == null) {
            throw createMethodNotFoundError(payload, functionName);
        }

        List<Object> parameters = new ArrayList<>();
        if (method.hasBeforeParam()) {
            parameters.add(processParameterToIntendedType(payload, EventMembers.BEFORE, method.beforeParamType()));
        }
        if (method.hasAfterParam()) {
            parameters.add(processParameterToIntendedType(payload, EventMembers.AFTER, method.afterParamType()));
        }
        if (method.hasTableName()) {
            parameters.add(StringUtils.fromString(payload.getTable()));
        }
        return parameters.toArray();
    }

    private Object processParameterToIntendedType(Payload payload, String memberKey, Type type) {
        Map<String, Object> jsonDataOptions = new HashMap<>();
        jsonDataOptions.put(ENABLE_CONSTRAINT_VALIDATION, FALSE);
        jsonDataOptions.put(ALLOW_DATA_PROJECTION, FALSE);
        BMap<BString, Object> mapValue = ValueCreator.createRecordValue(
                io.ballerina.lib.data.ModuleUtils.getModule(),
                PARSER_AS_TYPE_OPTIONS, jsonDataOptions);
        BTypedesc typeDescValue = ValueCreator.createTypedescValue(TypeUtils.getReferredType(type));
        JsonObject payloadMember = payload.getPayloadMember(memberKey);
        String memberString = payloadMember == null ? "{}" : payloadMember.toString();
        Object parsedRecord = Native.parseString(StringUtils.fromString(memberString), mapValue, typeDescValue);
        if (parsedRecord instanceof BError e) {
            BMap<BString, Object> detail = ValueCreator.createMapValue();
            detail.put(StringUtils.fromString(EVENT_PROCESSING_ERROR_DETAIL_PAYLOAD_FIELD),
                    JsonUtils.parse(payload.toString()));
            throw createError(PAYLOAD_BINDING_ERROR, "Payload binding failed. " + e.getMessage(), e, detail);
        }
        return parsedRecord;
    }

    @SuppressWarnings("CallToPrintStackTrace")
    private void handleError(Service selectedService, BError bError) {
        try {
            if (selectedService != null && selectedService.isOnErrorPresent()) {
                boolean isIsolated = selectedService.isIsolated() && selectedService.isOnErrorMethodIsolated();
                StrandMetadata metaData = new StrandMetadata(isIsolated, null);
                Object returnValue = this.runtime.callMethod(selectedService.getService(),
                        ServiceMethodNames.ON_ERROR, metaData, bError);
                handleReturnValue(returnValue);
            } else {
                bError.printStackTrace();
            }
        } catch (BError balError) {
            balError.printStackTrace();
        }
    }

    @SuppressWarnings("CallToPrintStackTrace")
    private void handleReturnValue(Object returnValue) {
        if (returnValue instanceof BError) {
            ((BError) returnValue).printStackTrace();
        }
    }

    private BError createMethodNotFoundError(Payload payload, String methodName) {
        BMap<BString, Object> detail = getEventProcessingErrorDetail(payload.toString());
        return createError(EVENT_PROCESSING_ERROR, "Function '" + methodName + "' is not available.",
                null, ValueCreator.createRecordValue(getModule(), EVENT_PROCESSING_ERROR_DETAIL, detail));
    }
}
