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
DOCKER_IMAGE_NAME=fbarmes/speedtest-exporter
DOCKER_IMAGE_VERSION=$(shell cat VERSION)


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
.PHONY: docker-build
docker-build: build
	docker build -t ${DOCKER_IMAGE_NAME} .
