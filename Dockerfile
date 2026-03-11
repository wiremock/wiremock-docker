ARG JAVA_VERSION=17
FROM eclipse-temurin:${JAVA_VERSION}-jre

LABEL maintainer="Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>"

ARG WIREMOCK_VERSION=3.13.2
ENV WIREMOCK_VERSION=$WIREMOCK_VERSION

WORKDIR /home/wiremock

# grab wiremock standalone jar
RUN mkdir -p /var/wiremock/lib/ \
  && curl https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/$WIREMOCK_VERSION/wiremock-standalone-$WIREMOCK_VERSION.jar \
    -o /var/wiremock/lib/wiremock-standalone.jar

# Init WireMock files structure
RUN mkdir -p /home/wiremock/mappings && \
	mkdir -p /home/wiremock/__files && \
	mkdir -p /var/wiremock/extensions

COPY docker-entrypoint.sh /

EXPOSE 8080 8443

HEALTHCHECK --start-period=5s --start-interval=100ms CMD curl -f http://localhost:8080/__admin/health || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
