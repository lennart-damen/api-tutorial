# References
# https://blog.container-solutions.com/tagging-docker-images-the-right-way
# https://www.youtube.com/watch?v=p0KKBmfiVl0

include .env

# Note: FLASK_PORT must be 8080 for Cloud Run to work!
FLASK_PORT := 8080
FLASK_HOST := 0.0.0.0
OS_PORT := 5000

LATEST_GIT_HASH := $$(git log -1 --pretty=%h)

# Note: make sure GCP_PROJECT_ID and DOCKER_PROJECT
# are defined in the .env file. Exclude the .env from
# source control!
GCP_IMG_NAME := gcr.io/${GCP_PROJECT_ID}/${DOCKER_PROJECT}
GCP_IMG_ID := ${GCP_IMG_NAME}:${LATEST_GIT_HASH}
GCP_IMG_LATEST := ${GCP_IMG_NAME}:latest

MKFILE_PATH := $(abspath $(firstword $(MAKEFILE_LIST)))
PROJECT_DIR := $(shell dirname ${MKFILE_PATH})

# .PHONY indicates that these make commands do not have a target file,
# they merely execute commands
.PHONY: build-image run-container check-gcp-login conf-docker-for-gcp push-latest-image-to-gcp deploy

build-image:
	@echo "Building docker image locally using GCP tag..."
	docker build\
		-t ${GCP_IMG_ID}\
		--build-arg FLASK_PORT=${FLASK_PORT}\
		--build-arg FLASK_HOST=${FLASK_HOST}\
		.
	@echo "Docker build completed"
	docker tag ${GCP_IMG_ID} ${GCP_IMG_LATEST}
	@echo "Tagged ${GCP_IMG_ID} as ${GCP_IMG_LATEST}."

run-container:
	docker run\
		-p ${OS_PORT}:${FLASK_PORT}\
		-v ${PROJECT_DIR}/api:/usr/src/app/api\
		-e FLASK_ENV=development\
		${GCP_IMG_LATEST}

check-gcp-login:
	gcloud config configurations list

conf-docker-for-gcp:
	gcloud auth configure-docker

# Not working because permissions
push-latest-image-to-gcp:
	docker push ${GCP_IMG_ID}

# Not working because billing not enabled
deploy:
	gcloud run deploy --image=${GCP_IMG_ID}