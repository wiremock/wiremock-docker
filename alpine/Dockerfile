FROM openjdk:8-jre-alpine

MAINTAINER Rodolphe CHAIGNEAU <rodolphe.chaigneau@gmail.com>

ENV WIREMOCK_VERSION 2.6.0

RUN apk add --update openssl

# grab su-exec for easy step-down from root
# and bash for "bin/elasticsearch" among others
RUN apk add --no-cache 'su-exec>=0.2' bash

# grab wiremock standalone jar
RUN mkdir -p /var/wiremock/lib/ \
  && wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/${WIREMOCK_VERSION}/wiremock-standalone-$WIREMOCK_VERSION.jar \
    -O /var/wiremock/lib/wiremock-standalone.jar

WORKDIR /home/wiremock

COPY docker-entrypoint.sh /

VOLUME /home/wiremock
EXPOSE 8080 8081

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java", "-cp", "/var/wiremock/lib/*:/var/wiremock/extensions/*", "com.github.tomakehurst.wiremock.standalone.WireMockServerRunner"]
