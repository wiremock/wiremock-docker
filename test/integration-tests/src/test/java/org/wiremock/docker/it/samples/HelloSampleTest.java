package org.wiremock.docker.it.samples;

import org.junit.jupiter.api.Test;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.wiremock.docker.it.TestConfig;

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
public class HelloSampleTest extends AbtsractSampleTest {

  @Override
  public Path getHomeDir() {
    return TestConfig.getSamplesPath().resolve("hello");
  }

  @Test
  public void helloWorld() throws Exception {
    final HttpClient client = HttpClient.newBuilder().build();
    final HttpRequest request = HttpRequest.newBuilder()
      .uri(new URI(wiremockServer.getUrl("hello")))
      .timeout(Duration.ofSeconds(10))
      .header("Content-Type", "application/json")
      .GET().build();

    HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

    assertThat(response.body())
      .as("Wrong response body")
      .contains("Hello World !");
  }
}
