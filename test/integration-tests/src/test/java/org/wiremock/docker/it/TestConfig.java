package org.wiremock.docker.it;

/**
 * WireMock Test configuration.
 * To be set by the test runner to configure proper execution.
 */
public class TestConfig {

  /**
   * Docker image tag to be used for testing.
   */
  public static String WIREMOCK_IMAGE_TAG =
    System.getProperty("it.wiremock-version", "2.35.0");
}
