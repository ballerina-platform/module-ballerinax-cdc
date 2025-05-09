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
package io.ballerina.lib.cdc.compiler;

import io.ballerina.projects.ProjectEnvironmentBuilder;
import io.ballerina.projects.environment.Environment;
import io.ballerina.projects.environment.EnvironmentBuilder;
import io.ballerina.tools.text.LinePosition;
import io.ballerina.tools.text.LineRange;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Utility class for common operations used in CDC compiler plugin tests.
 */
public class TestUtils {

    private static final Path DISTRIBUTION_PATH = Paths.get("../", "target", "ballerina-runtime").toAbsolutePath();

    public static ProjectEnvironmentBuilder getEnvironmentBuilder() {
        Environment environment = EnvironmentBuilder.getBuilder()
                .setBallerinaHome(DISTRIBUTION_PATH)
                .build();
        return ProjectEnvironmentBuilder.getBuilder(environment);
    }

    public static boolean isWithinRange(LineRange lineRange, LinePosition position) {
        int startLine = lineRange.startLine().line();
        int startOffset = lineRange.startLine().offset();
        int endLine = lineRange.endLine().line();
        int endOffset = lineRange.endLine().offset();
        int posLine = position.line();
        int posOffset = position.offset();

        // Check if the position is within the same line range
        if (startLine == endLine && posLine == startLine) {
            return posOffset >= startOffset && posOffset <= endOffset;
        }

        // Check if the position spans multiple lines
        return (posLine > startLine && posLine < endLine) ||
                (posLine == startLine && posOffset >= startOffset) ||
                (posLine == endLine && posOffset <= endOffset);
    }
}
