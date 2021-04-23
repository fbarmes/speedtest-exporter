#!/usr/bin/env bash

DOCKER_IMAGE_VERSION="$(cat VERSION)-arm"
DOCKER_IMAGE_NAME="speedtest-exporter"

set -x
docker run  \
  -it --rm  \
  -v ${PWD}/target/speedtest-exporter:/opt/speedtest-exporter \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} $@
