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
GCP_CLOUD_RUN_NAME := ${DOCKER_PROJECT}

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

# Not working because permissions: use personal account
push-latest-image-to-gcp:
	docker push ${GCP_IMG_LATEST}

# Not working because billing not enabled: use personal account
# see https://cloud.google.com/sdk/gcloud/reference/run/deploy
deploy:
	gcloud run deploy\
		${GCP_CLOUD_RUN_NAME}\
		--image ${GCP_IMG_LATEST}\
		--project ${GCP_PROJECT_ID}\
		--region ${GCP_REGION}\
		--allow-unauthenticated\
		--port ${FLASK_PORT}\
		--memory 128Mi\
		--cpu 1\
		--max-instances 1

list-cloud-run:
	gcloud beta run services list --project ${GCP_PROJECT_ID}

describe-service:
	gcloud run services describe\
		${DOCKER_PROJECT}\
		--project ${GCP_PROJECT_ID}\
		--region ${GCP_REGION}

delete-deployment:
	gcloud run services delete\
		${DOCKER_PROJECT}\
		--project ${GCP_PROJECT_ID}\
		--region ${GCP_REGION}

list-gcp-images:
	gcloud container images list --project ${GCP_PROJECT_ID}

delete-latest-gcp-image:
	gcloud container images delete ${GCP_IMG_LATEST}
