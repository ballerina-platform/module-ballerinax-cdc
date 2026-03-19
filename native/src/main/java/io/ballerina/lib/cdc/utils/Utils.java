/*
 * Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

package io.ballerina.lib.cdc.utils;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.RecordType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.util.ArrayList;
import java.util.List;

/**
 * This class contains utility methods for the CDC module.
 *
 * @since 1.3.0
 */
public class Utils {

    /**
     * This method returns the additional configuration keys provided in the options map which are not defined in the
     * typedesc.
     *
     * @param options the options map provided by the user.
     * @param bTypedesc type description of the DB-specific options record.
     * @return A Ballerina array containing the additional configuration keys.
     */
    public static BArray getAdditionalConfigKeys(BMap<BString, Object> options, BTypedesc bTypedesc) {
        List<BString> additionalConfigs = new ArrayList<>();
        Type describedType = TypeUtils.getReferredType(bTypedesc.getDescribingType());
        if (!(describedType instanceof RecordType recordType)) {
            return ValueCreator.createArrayValue(new BString[0]);
        }
        for (BString key : options.getKeys()) {
            if (!recordType.getFields().containsKey(key.getValue())) {
                additionalConfigs.add(key);
            }
        }
        return ValueCreator.createArrayValue(additionalConfigs.toArray(new BString[0]));
    }
}
