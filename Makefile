#!/usr/bin/make -f

#-------------------------------------------------------------------------------
# Python variables
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


#-------------------------------------------------------------------------------
# Docker variables
#-------------------------------------------------------------------------------

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


#-------------------------------------------------------------------------------
# Python application
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
.PHONY: deps
deps: init ${TARGET_DIR}/deps.touch

#-------------------------------------------------------------------------------
.PHONY: cleandeps
cleandeps: init
	rm ${TARGET_DIR}/deps.touch


#-------------------------------------------------------------------------------
${TARGET_DIR}/deps.touch:
	@#-- make artifact dir
	pip3 install -r requirements.txt -t ${TARGET_DIR}/${ARTIFACT}
	touch ${TARGET_DIR}/deps.touch

#-------------------------------------------------------------------------------
.PHONY: build
build: deps
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
.PHONY: docker-build-arm
docker-build-arm: build bin/qemu-arm-static

	#-- register cpu emulation
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	#-- build image
	docker build \
		-t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm \
		-f docker-arm.Dockerfile \
		.


#-------------------------------------------------------------------------------
.PHONY: docker-build-x64
docker-build-x64: build

	#-- build image
	docker build \
		-t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64 \
		-f docker-x64.Dockerfile \
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
docker-push: docker-build-arm docker-build-x64 docker-login
	#
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm
	docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64 ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64
	#
	docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-arm
	docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION}-x64
