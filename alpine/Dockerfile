FROM eclipse-temurin:11-jre-alpine

LABEL maintainer="Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>"

ARG WIREMOCK_VERSION=4.0.0-beta.29
ENV WIREMOCK_VERSION=$WIREMOCK_VERSION

WORKDIR /home/wiremock

RUN apk add --update openssl

# grab su-exec for easy step-down from root
# and bash
RUN apk add --no-cache 'su-exec>=0.2' bash

# grab wiremock standalone jar
RUN mkdir -p /var/wiremock/lib/ \
  && wget https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/$WIREMOCK_VERSION/wiremock-standalone-$WIREMOCK_VERSION.jar \
    -O /var/wiremock/lib/wiremock-standalone.jar

# Init WireMock files structure
RUN mkdir -p /home/wiremock/mappings && \
	mkdir -p /home/wiremock/__files && \
	mkdir -p /var/wiremock/extensions

COPY docker-entrypoint.sh /

EXPOSE 8080 8443

HEALTHCHECK --start-period=5s --start-interval=100ms CMD wget --no-verbose --tries=1 --spider http://localhost:8080/__admin/health || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
