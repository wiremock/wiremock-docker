/*
 * Copyright (C) 2024 WireMock Inc, Rafe Arnold and all project contributors
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
package org.wiremock.docker.it;

import org.junit.jupiter.api.Test;
import org.testcontainers.containers.wait.strategy.Wait;
import org.wiremock.integrations.testcontainers.WireMockContainer;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;

class HealthTest {

  @Test
  public void containerCanWaitForDockerHealthcheck() throws Exception {
    try (WireMockContainer wiremockServer =
           new WireMockContainer(TestConfig.WIREMOCK_IMAGE).waitingFor(Wait.forHealthcheck())) {
      wiremockServer.start();
      final HttpClient client = HttpClient.newHttpClient();
      final HttpRequest request = HttpRequest.newBuilder()
        .uri(new URI(wiremockServer.getUrl("/__admin/health")))
        .timeout(Duration.ofSeconds(1))
        .GET()
        .build();

      HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

      assertThat(response.statusCode()).isEqualTo(200);
    }
  }
}
