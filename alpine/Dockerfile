FROM adoptopenjdk/openjdk11:alpine-jre

LABEL maintainer="Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>"

ENV WIREMOCK_VERSION 2.32.0

RUN apk add --update openssl

# grab su-exec for easy step-down from root
# and bash
RUN apk add --no-cache 'su-exec>=0.2' bash

# grab wiremock standalone jar
RUN mkdir -p /var/wiremock/lib/ \
  && wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/$WIREMOCK_VERSION/wiremock-jre8-standalone-$WIREMOCK_VERSION.jar \
    -O /var/wiremock/lib/wiremock-jre8-standalone.jar

WORKDIR /home/wiremock

COPY docker-entrypoint.sh /

VOLUME /home/wiremock
EXPOSE 8080 8443

ENTRYPOINT ["/docker-entrypoint.sh"]
