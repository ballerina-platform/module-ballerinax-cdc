/*
 * Copyright (c) 2026, WSO2 LLC. (http://www.wso2.org).
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied. See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.lib.cdc;

import io.debezium.engine.DebeziumEngine;

import java.io.PrintStream;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * This class contains the logic to be executed when the CDC engine shuts-down gracefully.
 */
public class CdcCompletionCallback implements DebeziumEngine.CompletionCallback {
    private static final PrintStream ERR_OUT = System.err;

    private final AtomicBoolean invoked = new AtomicBoolean(false);
    private final CompletableFuture<?> startupFuture;

    public CdcCompletionCallback() {
        this(null);
    }

    /**
     * @param startupFuture the future awaited by the engine starter. If the engine terminates with a
     *                      failure before it ever started (so {@code taskStarted()} never completes the
     *                      future), this callback completes it exceptionally so the starter surfaces a
     *                      clean error instead of blocking forever. Once the engine has started the
     *                      future is already completed, so a later failure here is a no-op for it.
     */
    public CdcCompletionCallback(CompletableFuture<?> startupFuture) {
        this.startupFuture = startupFuture;
    }

    @Override
    public void handle(boolean success, String message, Throwable error) {
        invoked.set(true);
        if (success) {
            return;
        }

        String errorMsg = "Debezium engine terminated unexpectedly: " + message;
        if (Objects.nonNull(error)) {
            errorMsg = errorMsg + ": " + error.getMessage();
        }
        ERR_OUT.println(errorMsg);

        if (startupFuture != null && !startupFuture.isDone()) {
            startupFuture.completeExceptionally(new IllegalStateException(errorMsg, error));
        }
    }

    public boolean isInvoked() {
        return invoked.get();
    }
}
