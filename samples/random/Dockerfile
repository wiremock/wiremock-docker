FROM wiremock/wiremock

COPY stubs /home/wiremock

ADD https://repo1.maven.org/maven2/com/opentable/wiremock-body-transformer/1.1.3/wiremock-body-transformer-1.1.3.jar /var/wiremock/extensions/

CMD ["--extensions", "com.opentable.extension.BodyTransformer"]
