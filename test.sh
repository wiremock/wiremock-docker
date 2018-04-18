#!/bin/bash

. smoke.sh

message() {
  echo
  echo "${bold}$1${normal}"
  echo
}

sleep 5

# default
message "Test default run"
CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" wiremock)
smoke_url_ok "http://$CONTAINER_IP:8080/__admin"
smoke_assert_body "mappings"

# wiremock args
message "Test Wiremock args"
CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" wiremock-args)
smoke_url_ok "https://$CONTAINER_IP:8443/__admin"
smoke_assert_body "mappings"

# helloworld sample
message "Test helloworld sample"
CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" wiremock-hello)
smoke_url_ok "http://$CONTAINER_IP:8080/hello"
smoke_assert_body "Hello World !"

# extension
message "Test Wiremock extension"
CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" wiremock-random)
smoke_url_ok "http://$CONTAINER_IP:8080/random"
smoke_assert_body "randomInteger"

# alpine
message "Test alpine image"
CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" wiremock-alpine)
smoke_url_ok "http://$CONTAINER_IP:8080/__admin"
smoke_assert_body "mappings"

# final report
echo
smoke_report
