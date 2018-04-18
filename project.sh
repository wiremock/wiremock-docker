#!/bin/bash

. util.sh

EXECUTION_OUTPUT=/dev/null

usage() {
cat << EOF
Usage: $0 COMMAND [-v]

Wiremock Docker image project

Commands:
  build             Build classic & alpine images
  test              Test classic & alpine images
  release clean     Clean workspace (revert readme & Dockerfiles)
  release prepare   Prepare release (update version in readme.md, Dockerfile & alpine/Dockerfile files)
  release perform   Perform release (docker push & git tag/push)

Args:
  -v      verbose mode
  -y      force yes
EOF
exit
}

build() {
  #################
  # classic image #
  #################

  CURRENT_VERSION=$(cat Dockerfile | grep "ENV WIREMOCK_VERSION" | cut -d ' ' -f 3)
  title "Build Wiremock Docker image $CURRENT_VERSION"

  message "Build classic image"
  docker build -t ${IMAGE_NAME} . > ${EXECUTION_OUTPUT}
  assert_bash_ok $?

  ################
  # alpine image #
  ################

  CURRENT_VERSION=$(cat alpine/Dockerfile | grep "ENV WIREMOCK_VERSION" | cut -d ' ' -f 3)
  title "Build Wiremock Docker alpine image $CURRENT_VERSION"

  message "Build alpine image"
  docker build -t ${IMAGE_NAME}-alpine alpine > ${EXECUTION_OUTPUT}
  assert_bash_ok $?
}

test() {
  # remove running container
  docker rm -f wiremock-container > ${EXECUTION_OUTPUT} 2>&1

  #################
  # classic image #
  #################

  # version message
  eval $(docker run --rm ${IMAGE_NAME}-alpine env | grep WIREMOCK_VERSION)
  title "Test Wiremock Docker image $WIREMOCK_VERSION"

  # default
  message "Test default run"
  CONTAINER_ID=$(docker run -d ${IMAGE_NAME})
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 1
  smoke_url_ok "http://$CONTAINER_IP:8080/__admin"
  smoke_assert_body "mappings"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # wiremock args
  message "Test Wiremock args"
  CONTAINER_ID=$(docker run -d ${IMAGE_NAME} --https-port 8443)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 1
  smoke_url_ok "https://$CONTAINER_IP:8443/__admin"
  smoke_assert_body "mappings"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # helloworld sample
  message "Test helloworld sample"
  docker build -t wiremock-hello samples/hello > ${EXECUTION_OUTPUT}
  CONTAINER_ID=$(docker run -d wiremock-hello)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 1
  smoke_url_ok "http://$CONTAINER_IP:8080/hello"
  smoke_assert_body "Hello World !"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # extension
  message "Test Wiremock extension"
  docker build -t wiremock-random samples/random > ${EXECUTION_OUTPUT}
  CONTAINER_ID=$(docker run -d wiremock-random)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 1
  smoke_url_ok "http://$CONTAINER_IP:8080/random"
  smoke_assert_body "randomInteger"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # file permission
  # TODO

  ################
  # alpine image #
  ################

  # version message
  eval $(docker run --rm ${IMAGE_NAME}-alpine env | grep WIREMOCK_VERSION)
  title "Test Wiremock Docker alpine image $WIREMOCK_VERSION"

  # default
  message "Test default run"
  CONTAINER_ID=$(docker run -d ${IMAGE_NAME}-alpine)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 1
  smoke_url_ok "http://$CONTAINER_IP:8080/__admin"
  smoke_assert_body "mappings"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # wiremock args
  message "Test Wiremock args"
  CONTAINER_ID=$(docker run -d ${IMAGE_NAME}-alpine --https-port 8443)
  CONTAINER_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_ID})
  sleep 1
  smoke_url_ok "https://$CONTAINER_IP:8443/__admin"
  smoke_assert_body "mappings"
  docker rm -f ${CONTAINER_ID} > ${EXECUTION_OUTPUT}

  # file permission
  # TODO
}

release_clean() {
  title "Clean workspace"

  message "Revert readme.md, Dockerfile & alpine/Dockerfile files"
  git checkout readme.md Dockerfile alpine/Dockerfile
  assert_bash_ok $?
}

release_prepare() {
  title "Prepare release"

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

release_perform() {
  title "Perform release"

  if [ "$FORCE_YES" != "true" ]
  then
    message "${red}The Docker image will be pushed to the HUB"
    message "The project code will be commit, tagged & pushed to GitHub${normal}"
    echo
    read -p " Are you sure? [Y/n] "œœ -n 1 -r
    echo
    if [[ $REPLY =~ ^[^Yy]$ ]]
    then
      exit 0
    fi
  fi

  # docker build

  build

  # functionnal tests

  test

  # docker tag

  title "Tag Wiremock Docker image $CURRENT_VERSION"
  message "Tag classic image"
  docker tag ${IMAGE_NAME} ${IMAGE_NAME}:${CURRENT_VERSION}
  assert_bash_ok $?

  title "Tag Wiremock Docker alpine image $CURRENT_VERSION"
  message "Tag alpine image"
  docker tag ${IMAGE_NAME}-alpine ${IMAGE_NAME}-alpine:${CURRENT_VERSION}
  assert_bash_ok $?

#  # docker push
#
#  title "Push Wiremock Docker image $CURRENT_VERSION"
#  message "Push classic image"
#  docker push ${IMAGE_NAME}:${CURRENT_VERSION}
#  assert_bash_ok $?
#
#  title "Push Wiremock Docker alpine image $CURRENT_VERSION"
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

release() {
  case $1 in
    clean|prepare|perform)
      release_$1 $2
      ;;
    *)
      usage
      ;;
  esac
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
  build|test|release)
    $@
    smoke_report
    ;;
  *)
    usage
    ;;
esac
