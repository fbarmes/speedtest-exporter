#!/usr/bin/make -f

#-------------------------------------------------------------------------------
# Main variables
#-------------------------------------------------------------------------------

#--
# where to generate the artifacts
TARGET_DIR=target

#--
# source dir
SRC_DIR=src

#--
# artifact coordinates
PROJECT_VERSION=$(shell cat VERSION)

#--
# artifact name
ARTIFACT=speedtest-exporter

#--
# package name
PACKAGE=${ARTIFACT}-${PROJECT_VERSION}.zip

#-------------------------------------------------------------------------------
# Docker variables
#-------------------------------------------------------------------------------
DOCKER_IMAGE_NAME=speedtest-exporter
DOCKER_IMAGE_VERSION=$(shell cat VERSION)

#------------------------------------------------------------------------------
# script internals
#-------------------------------------------------------------------------------

#-- Url to Quemu
QEMU_VERSION=v5.2.0-2
QEMU_URL=https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-arm-static.tar.gz

#-- base image name per architecture
BASE_IMAGE_ARM=fbarmes/rpi-debian:1.0-buster-slim

BASE_IMAGE_X64=debian:buster-slim


#-------------------------------------------------------------------------------
.PHONY: echo
echo:
	@echo ""
	@echo "--------------------------------------------"
	@echo " Makefile parameters"
	@echo "--------------------------------------------"
	@echo ""
	@echo "PROJECT_VERSION=${PROJECT_VERSION}"
	@echo "ARTIFACT=${ARTIFACT}"
	@echo "PACKAGE=${PACKAGE}"



#-------------------------------------------------------------------------------
# Targets run inside builder image
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
.PHONY: init
init:
	@echo "init - START"
	mkdir -p ${TARGET_DIR}
	mkdir -p ${TARGET_DIR}/${ARTIFACT}
	@echo "init - DONE"

#-------------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -rf ${TARGET_DIR}
	rm -rf src/__pycache__
	rm -rf bin


#-------------------------------------------------------------------------------
# Targets run inside builder image
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
.PHONY: dev-deps
dev-deps: init ${TARGET_DIR}/dev-deps.touch

#-------------------------------------------------------------------------------
.PHONY: dev-cleandeps
dev-cleandeps: init
	rm ${TARGET_DIR}/deps.touch


#-------------------------------------------------------------------------------
${TARGET_DIR}/dev-deps.touch:
	@#-- make artifact dir
	pip3 install -r requirements.txt -t ${TARGET_DIR}/${ARTIFACT}
	touch ${TARGET_DIR}/dev-deps.touch

#-------------------------------------------------------------------------------
.PHONY: dev-build
dev-build: dev-deps
	cp -rp ${SRC_DIR}/* ${TARGET_DIR}/${ARTIFACT}/


#-------------------------------------------------------------------------------
# Docker build
#-------------------------------------------------------------------------------

#--
bin/qemu-arm-static:
	#-- build qemu binary
	mkdir -p bin
	wget ${QEMU_URL} --output-document bin/qemu-arm-static.tar.gz
	tar -zxvf bin/qemu-arm-static.tar.gz -C ./bin
	rm bin/qemu-arm-static.tar.gz



#-------------------------------------------------------------------------------
.PHONY: docker-build-base
docker-build-base: init

	#-- register cpu emulation
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	docker build \
		--build-arg BASE_IMAGE=${BASE_IMAGE_ARM} \
		-t speedtest-exporter-base \
		--target base \
		-f Dockerfile \
		.


#-------------------------------------------------------------------------------
.PHONY: docker-build-dev
docker-build-dev: init

	#-- register cpu emulation
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	docker build \
		--build-arg BASE_IMAGE=${BASE_IMAGE_ARM} \
		-t speedtest-exporter-builder \
		--target dev \
		-f Dockerfile \
		.

#-------------------------------------------------------------------------------
.PHONY: docker-run-dev
docker-run-dev: init

	#-- register cpu emulation
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	docker run \
		-it --rm \
		-v ${PWD}/${SRC_DIR}:/workdir/src \
		speedtest-exporter-builder


#-------------------------------------------------------------------------------
.PHONY: docker-build-arm
docker-build-arm:

	#-- register cpu emulation
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	docker build \
		--build-arg BASE_IMAGE=${BASE_IMAGE_ARM} \
		-t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm \
		-f Dockerfile \
		.

#-------------------------------------------------------------------------------
.PHONY: docker-build-x64
docker-build-x64:
	docker build \
		--build-arg BASE_IMAGE=${BASE_IMAGE_ARM} \
		-t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64 \
		-f Dockerfile \
		.


#-------------------------------------------------------------------------------
# Docker publish
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
.PHONY: docker-login
docker-login:
	docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)

#-------------------------------------------------------------------------------
.PHONY: docker-push
docker-push: docker-login
	#
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64 ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64
	#
	docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm
	docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64


#-------------------------------------------------------------------------------
.PHONY: docker-push-latest
docker-push-latest: docker-login
	#
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest-arm
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64 ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest-x64
	#
	docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest-arm
	docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:latest-x64
