#!/bin/bash

. util.sh

IMAGE_NAME=rodolpheche/wiremock
CURRENT_VERSION=$(cat Dockerfile | grep "ENV WIREMOCK_VERSION" | cut -d ' ' -f 3)
CURRENT_ALPINE_VERSION=$(cat alpine/Dockerfile | grep "ENV WIREMOCK_VERSION" | cut -d ' ' -f 3)
IMAGE_TAG=${IMAGE_NAME}:${CURRENT_VERSION}
ALPINE_IMAGE_TAG=${IMAGE_NAME}:${CURRENT_ALPINE_VERSION}-alpine

EXECUTION_OUTPUT=/dev/null

usage() {
cat << EOF
Usage: $0 COMMAND [-v]
       $0 [ -h | --help ]

Wiremock Docker image project

Commands:
  build             Build classic & alpine images
  test              Test classic & alpine images
  clean             Clean workspace (revert readme.md, Dockerfile & alpine/Dockerfile)
  update            Update version (readme.md, Dockerfile & alpine/Dockerfile)
  release           Perform release (docker push & git tag/push) # NOT IMPLEMENTED

Args:
  -v|--version      verbose mode
  -y                force yes
EOF
exit
}

build() {
  title "Build Wiremock Docker image ${IMAGE_TAG}"
  docker build -t ${IMAGE_TAG} . > ${EXECUTION_OUTPUT}
  assert_bash_ok $?

  title "Tag Wiremock Docker image ${IMAGE_NAME}:latest"
  docker tag ${IMAGE_TAG} ${IMAGE_NAME}
  assert_bash_ok $?

  title "Build Wiremock Docker image ${ALPINE_IMAGE_TAG}"
  docker build -t ${ALPINE_IMAGE_TAG} alpine > ${EXECUTION_OUTPUT}
  assert_bash_ok $?
}

_test() {
  TAG=$1

  title "Test Wiremock Docker image ${TAG}"

  # version message
  message "Test version"
  eval $(docker run --rm ${TAG} env | grep WIREMOCK_VERSION)
  assert_equal ${CURRENT_VERSION} ${WIREMOCK_VERSION}

  # default
  message "Test default run"
  CONTAINER_ID=$(docker run -d ${TAG})
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 5
  smoke_url_ok "http://${CONTAINER_IP}:8080/__admin"
  smoke_assert_body "mappings"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # wiremock args
  message "Test Wiremock args"
  CONTAINER_ID=$(docker run -d ${TAG} --https-port 8443)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 5
  smoke_url_ok "https://${CONTAINER_IP}:8443/__admin"
  smoke_assert_body "mappings"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}
}

test() {
  # classic image common tests
  _test ${IMAGE_TAG}

  # helloworld sample
  message "Test helloworld sample"
  docker build -t wiremock-hello samples/hello > ${EXECUTION_OUTPUT}
  CONTAINER_ID=$(docker run -d wiremock-hello)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 5
  smoke_url_ok "http://${CONTAINER_IP}:8080/hello"
  smoke_assert_body "Hello World !"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}
  docker image rm wiremock-hello > ${EXECUTION_OUTPUT}

  # extension
  message "Test Wiremock extension"
  docker build -t wiremock-random samples/random > ${EXECUTION_OUTPUT}
  CONTAINER_ID=$(docker run -d wiremock-random)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 5
  smoke_url_ok "http://${CONTAINER_IP}:8080/random"
  smoke_assert_body "randomInteger"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}
  docker image rm wiremock-random > ${EXECUTION_OUTPUT}

  # alpine image common tests
  _test ${ALPINE_IMAGE_TAG}
}

clean() {
  title "Clean workspace"

  message "Revert readme.md, Dockerfile & alpine/Dockerfile files"
  git checkout readme.md Dockerfile alpine/Dockerfile
  assert_bash_ok $?
}

update() {
  title "Update version"

  if [ "$1" = "" ]
  then
    echo "You must specify a version"
    exit 1
  fi

  message "Revert readme.md, Dockerfile & alpine/Dockerfile files"
  git checkout readme.md Dockerfile alpine/Dockerfile
  assert_bash_ok $?

  message "Fetch tags from Github"
  git fetch -q origin -t
  assert_bash_ok $?

  message "Fetch last git tag"
  LAST_VERSION=$(git describe --tag --abbrev=0)
  LAST_MINOR_VERSION=${LAST_VERSION%.*}
  NEW_VERSION=$1
  NEW_MINOR_VERSION=${1%.*}
  assert_bash_ok $?

  message "Sed version in readme.md, Dockerfile & alpine/Dockerfile files"
  sed -i s/${LAST_VERSION}/${NEW_VERSION}/g readme.md Dockerfile alpine/Dockerfile
  assert_bash_ok $?

  message "Sed minor version in readme.md file"
  sed -i s/${LAST_MINOR_VERSION}/${NEW_MINOR_VERSION}/g readme.md
  assert_bash_ok $?
}

release() {
  echo "NOT IMPLEMENTED"
  # title "Perform release"

  # if [ "${FORCE_YES}" != "true" ]
  # then
  #   message "${red}The Docker image should be pushed to the HUB from CI only !!"
  #   message "${normal}The project code will be commit, tagged & pushed to GitHub"
  #   echo
  #   read -p " Are you sure? [Y/n] " -n 1 -r
  #   echo
  #   if [[ ${REPLY} =~ ^[^Yy]$ ]]
  #   then
  #     exit 0
  #   fi
  # fi
  #  # docker push
  #
  #  title "Push Wiremock Docker image ${CURRENT_VERSION}"
  #  message "Push classic image"
  #  docker push ${IMAGE_NAME}:${CURRENT_VERSION}
  #  assert_bash_ok $?
  #
  #  title "Push Wiremock Docker alpine image ${CURRENT_VERSION}"
  #  message "Push alpine image"
  #  docker push ${IMAGE_NAME}-alpine:${CURRENT_VERSION}
  #  assert_bash_ok $?
  #
  #  # git commit
  #
  #  # git tag
  #
  #  # git push (with tags)

}

# args extract

SHORT_OPTS="vyh"
LONG_OPTS="verbose,,help"
ARGS=$(getopt -o ${SHORT_OPTS} -l ${LONG_OPTS} -n "$0" -- "$@")
eval set -- "${ARGS}"
while true
do
  case $1 in
    -y)
      FORCE_YES="true"
      ;;
    -v|--verbose)
      EXECUTION_OUTPUT=/dev/stdout
      ;;
    -h|--help)
      usage
      exit
      ;;
    --)
      break
      ;;
  esac
  shift
done
shift

# process

case $1 in
  build|test|clean|update|release)
    $@
    smoke_report
    ;;
  *)
    usage
    ;;
esac
