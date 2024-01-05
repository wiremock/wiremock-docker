FROM wiremock/wiremock:3.3.1-1

COPY stubs /home/wiremock

ADD https://repo1.maven.org/maven2/org/wiremock/extensions/wiremock-faker-extension-standalone/0.1.1/wiremock-faker-extension-standalone-0.1.1.jar /var/wiremock/extensions/
# TODO: Checksum Validation

CMD ["--global-response-templating", "--extensions", "org.wiremock.RandomExtension"]
