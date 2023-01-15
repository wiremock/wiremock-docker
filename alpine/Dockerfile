FROM adoptopenjdk/openjdk11:alpine-jre

LABEL maintainer="Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>"

ENV WIREMOCK_VERSION 2.35.0

WORKDIR /home/wiremock

RUN apk add --update openssl

# grab su-exec for easy step-down from root
# and bash
RUN apk add --no-cache 'su-exec>=0.2' bash

# grab wiremock standalone jar
RUN mkdir -p /var/wiremock/lib/ \
  && wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/$WIREMOCK_VERSION/wiremock-jre8-standalone-$WIREMOCK_VERSION.jar \
    -O /var/wiremock/lib/wiremock-jre8-standalone.jar

COPY docker-entrypoint.sh /

EXPOSE 8080 8443

ENTRYPOINT ["/docker-entrypoint.sh"]
