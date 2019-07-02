#!/usr/bin/env bash
set -e

cd $(dirname $0)/../..

source _mob_ci/scripts/build.sh

DOCKER_LATEST="$DOCKER_REGISTRY_URL/$DOCKER_IMAGE_NAME:latest"
docker push ${DOCKER_TAG}
docker tag ${DOCKER_TAG} ${DOCKER_LATEST}
docker push ${DOCKER_LATEST}