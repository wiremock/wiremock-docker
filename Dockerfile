FROM java:8-jdk

ENV WIREMOCK_VERSION 2.1.7

RUN wget -q https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/${WIREMOCK_VERSION}/wiremock-standalone-$WIREMOCK_VERSION.jar

RUN useradd wiremock -m
USER wiremock
WORKDIR /home/wiremock

VOLUME /home/wiremock
EXPOSE 8080 8081

CMD java -jar /wiremock-standalone-$WIREMOCK_VERSION.jar $WIREMOCK_ARGS
