#!/usr/bin/env bash
set -e

cd $(dirname $0)/../..

function make_build_env {
    local ARGS=""
    for LINE in $(cat build.env | grep -v '^#'); do
        ARGS="$ARGS --build-arg $LINE"
    done
    echo "$ARGS"
}

function make_tag_version {
    local VERSION="$(date +%Y%m%d.%H%M%S)"
    [[ ! -z "$BUILD_ID" ]] && VERSION="$BUILD_ID"
    echo "$VERSION"
}

DOCKER_BUILD_ENV=$(make_build_env)
DOCKER_TAG_VERSION=$(make_tag_version)
DOCKER_REGISTRY_URL="nexus.devops.bankcontactcloud.com:5001"
DOCKER_IMAGE_NAME="surepay-wiremock"

echo "Building Dockerfile with version: $DOCKER_TAG_VERSION"

DOCKER_TAG="$DOCKER_REGISTRY_URL/$DOCKER_IMAGE_NAME:$DOCKER_TAG_VERSION"
docker build ${DOCKER_BUILD_ENV} -t ${DOCKER_TAG} .

echo "Image successfully built: $DOCKER_TAG"