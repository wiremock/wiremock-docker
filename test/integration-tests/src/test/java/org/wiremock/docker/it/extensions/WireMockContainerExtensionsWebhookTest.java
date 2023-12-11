/*
 * Copyright (C) 2023 WireMock Inc, Oleg Nenashev and all project contributors
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
 */
package org.wiremock.docker.it.extensions;

import org.junit.Before;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.wiremock.docker.it.TestConfig;
import org.wiremock.docker.it.util.HttpResponse;
import org.wiremock.docker.it.util.TestHttpClient;
import org.wiremock.docker.it.util.TestHttpServer;
import org.wiremock.integrations.testcontainers.WireMockContainer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.testcontainers.Testcontainers.exposeHostPorts;
import static org.testcontainers.shaded.org.awaitility.Awaitility.await;

import java.io.IOException;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.Collections;

import static org.testcontainers.shaded.org.awaitility.Awaitility.await;

/**
 * Tests the WireMock Webhook extension and TestContainers Networking
 * For this type of tests we should use following steps:
 * <p>
 * Use {@link GenericContainer#withAccessToHost(boolean)} to force the host access mechanism
 * <p>
 * Use {@link org.testcontainers.Testcontainers#exposeHostPorts(int...)} to expose host machine ports to containers
 * <p>
 * Use {@link GenericContainer#INTERNAL_HOST_HOSTNAME} to calculate hostname for callback
 *
 * @see <a href="https://www.testcontainers.org/features/networking/">Testcontainers Networking</a>
 */
@Testcontainers
class WireMockContainerExtensionsWebhookTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(WireMockContainerExtensionsWebhookTest.class);
    private static final String WIREMOCK_PATH = "/wiremock/callback-trigger";
    private static final String APPLICATION_PATH = "/application/callback-receiver";

    TestHttpServer applicationServer = TestHttpServer.newInstance();
    Slf4jLogConsumer logConsumer = new Slf4jLogConsumer(LOGGER);

    @Container
    WireMockContainer wiremockServer = new WireMockContainer(TestConfig.WIREMOCK_IMAGE)
            .withLogConsumer(new Slf4jLogConsumer(LOGGER))
            .withCliArg("--global-response-templating")
            .withMapping("webhook-callback-template", WireMockContainerExtensionsWebhookTest.class,
              "webhook-callback-template.json")
      // No longer needed and leads to crash on 3.3.1
      //   .withExtension("org.wiremock.webhooks.Webhooks")
            .withAccessToHost(true); // Force the host access mechanism

    @Before
    public void setupLogging() {
      wiremockServer.followOutput(logConsumer);
    }

    @Test
    void callbackUsingJsonStub() throws Exception {
        // given
        exposeHostPorts(applicationServer.getPort()); // Exposing host ports to the container

        String wiremockUrl = wiremockServer.getUrl(WIREMOCK_PATH);
        String applicationCallbackUrl = String.format("http://%s:%d%s", GenericContainer.INTERNAL_HOST_HOSTNAME, applicationServer.getPort(), APPLICATION_PATH);

        // when
        HttpResponse response = new TestHttpClient().post(
                wiremockUrl,
                "{\"callbackMethod\": \"PUT\", \"callbackUrl\": \"" + applicationCallbackUrl + "\"}"
        );

        // then
        assertThat(response).as("Wiremock Response").isNotNull().satisfies(it -> {
            assertThat(it.getStatusCode()).as("Wiremock Response Status").isEqualTo(200);
            assertThat(it.getBody()).as("Wiremock Response Body")
                    .contains("Please wait callback")
                    .contains("PUT")
                    .contains(applicationCallbackUrl);
        });

        await().atMost(Duration.ofMillis(5000)).untilAsserted(() -> {
            assertThat(applicationServer.getRecordedRequests()).as("Received Callback")
                    .hasSize(1)
                    .first().usingRecursiveComparison()
                    .isEqualTo(new TestHttpServer.RecordedRequest("PUT", APPLICATION_PATH, "Async processing Finished"));
        });
    }
}
