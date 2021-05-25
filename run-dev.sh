#!/usr/bin/env bash

DOCKER_IMAGE_VERSION="$(cat VERSION)-x64"
DOCKER_IMAGE_NAME="speedtest-exporter"

DOCKER_IMAGE="${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}"

DOCKER_IMAGE="fbarmes/speedtest-exporter:1.1-SNAPSHOT-x64"

set -x
docker run  \
  -it --rm  \
  --entrypoint bash \
  ${DOCKER_IMAGE}
set +x


# set -x
# docker run  \
#   -it --rm  \
#   -v ${PWD}/target/speedtest-exporter:/opt/speedtest-exporter \
#   ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} $@
# set +x
