package org.wiremock.docker.it.samples;

import org.junit.jupiter.api.Test;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.wiremock.docker.it.TestConfig;
import org.wiremock.integrations.testcontainers.WireMockContainer;

import java.io.File;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
public class RandomSampleTest extends AbtsractSampleTest {

  @Override
  public Path getHomeDir() {
    return TestConfig.getSamplesPath().resolve("random");
  }

  @Override
  public WireMockContainer createWireMockContainer() {
    return super.createWireMockContainer().
      withExtensions(Collections.singleton("com.opentable.extension.BodyTransformer"),
        new File("target/test-wiremock-extension/wiremock-body-transformer-1.1.3.jar"));
  }

  @Test
  public void testRandom() throws Exception {
    final HttpClient client = HttpClient.newBuilder().build();
    final HttpRequest request = HttpRequest.newBuilder()
      .uri(new URI(wiremockServer.getUrl("random")))
      .timeout(Duration.ofSeconds(10))
      .header("Content-Type", "application/json")
      .GET().build();

    HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

    assertThat(response.body())
      .as("Wrong response body")
      .contains("randomInteger");
  }
}
