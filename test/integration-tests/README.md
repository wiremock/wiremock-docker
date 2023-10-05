# WireMock Docker - Integration tests

Runs tests for the WireMock Docker image and validates its behavior for key cases.
It also tests the demos in this repository.
The integration tests are executed as a part of the CI run on GitHub Actions.

Powered by the [WireMock Module](https://github.com/wiremock/wiremock-testcontainers-java) for Testcontainers Java.

## Configuration

The test can be configured via system properties:

- `it.wiremock-image` - Image to be used instead of the default one
- `it.samples-path` - Relative or absolute path to the sample/example files
