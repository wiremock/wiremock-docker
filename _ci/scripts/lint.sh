#!/usr/bin/env bash
set -e

cd $(dirname $0)/../..

echo "Running linter"

docker run --rm -i hadolint/hadolint < Dockerfile