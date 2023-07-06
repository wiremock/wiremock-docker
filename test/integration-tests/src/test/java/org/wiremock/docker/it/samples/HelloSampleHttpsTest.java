package org.wiremock.docker.it.samples;

import org.junit.jupiter.api.Test;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.wiremock.docker.it.TestConfig;
import org.wiremock.integrations.testcontainers.WireMockContainer;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Path;
import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Verifies samples in the repository root and mimics the old smoke tests.
 * In the future it can be extended for bigger acceptance tests
 */
@Testcontainers
public class HelloSampleHttpsTest extends AbtsractSampleTest {

  @Override
  public Path getHomeDir() {
    return TestConfig.getSamplesPath().resolve("hello");
  }

  @Override
  public WireMockContainer createWireMockContainer() {
    return super.createWireMockContainer()
      .withCliArg("--https-port")
      .withCliArg("8443")
      .withExposedPorts(8443);
  }

  @Test
  public void helloWorldHttps() throws Exception {
    final HttpClient client = HttpClient.newBuilder().build();
    final String url = String.format("https://%s:%d/hello",
      wiremockServer.getHost(),
      wiremockServer.getMappedPort(8443));

    final HttpRequest request = HttpRequest.newBuilder()
      .uri(new URI(url))
      .timeout(Duration.ofSeconds(10))
      .header("Content-Type", "application/json")
      .GET().build();

    HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

    assertThat(response.body())
      .as("Wrong response body")
      .contains("Hello World !");
  }
}
