# References
# https://blog.container-solutions.com/tagging-docker-images-the-right-way
# https://www.youtube.com/watch?v=p0KKBmfiVl0

include .env

LATEST_GIT_HASH := $$(git log -1 --pretty=%h)

GCP_IMG_NAME := gcr.io/${GCP_PROJECT_ID}/${DOCKER_PROJECT}
GCP_IMG_ID := ${GCP_IMG_NAME}:${LATEST_GIT_HASH}
GCP_IMG_LATEST := ${GCP_IMG_NAME}:latest
GCP_CLOUD_RUN_NAME := ${DOCKER_PROJECT}

MKFILE_PATH := $(abspath $(firstword $(MAKEFILE_LIST)))
PROJECT_DIR := $(shell dirname ${MKFILE_PATH})

# .PHONY indicates that these make commands do not have a target file,
# they merely execute commands
.PHONY: build-image run-container check-gcp-login conf-docker-for-gcp push-latest-image-to-gcp deploy add-roles-to-service-account

run-flask-dev:
	python api/run.py

# Couldnt figure out how to load environment
# variables into uwsgi.ini, but this works
run-flask-uwsgi:
	uwsgi\
		--socket ${FLASK_HOST}:${FLASK_PORT}\
		--protocol ${UWSGI_PROTOCOL}\
		--module api:app\
		--threads ${UWSGI_THREADS}\
		--processes ${UWSGI_PROCESSES}

build-image:
	@echo "Building docker image locally using GCP tag..."
	docker build\
		-t ${GCP_IMG_ID}\
		--build-arg FLASK_PORT=${FLASK_PORT}\
		--build-arg FLASK_HOST=${FLASK_HOST}\
		--build-arg DOCKER_PROJECT_DIR=${DOCKER_PROJECT_DIR}\
		--build-arg MODEL_PATH=${MODEL_PATH}\
		--build-arg UWSGI_PROTOCOL=${UWSGI_PROTOCOL}\
		--build-arg UWSGI_THREADS=${UWSGI_THREADS}\
		--build-arg UWSGI_PROCESSES=${UWSGI_PROCESSES}\
		.
	@echo "Docker build completed"
	docker tag ${GCP_IMG_ID} ${GCP_IMG_LATEST}
	@echo "Tagged ${GCP_IMG_ID} as ${GCP_IMG_LATEST}."

run-container:
	docker run\
		-p ${OS_PORT}:${FLASK_PORT}\
		-v ${PROJECT_DIR}:${DOCKER_PROJECT_DIR}\
		-e FLASK_ENV=${FLASK_ENV}\
		${GCP_IMG_LATEST}

check-gcp-login:
	gcloud config configurations list

create-service-account:
	gcloud iam service-accounts create\
		${GCP_SERVICE_ACCOUNT_NAME}\
		--project ${GCP_PROJECT_ID}\

delete-service-account:
	gcloud iam service-accounts delete\
		${GCP_SERVICE_ACCOUNT_EMAIL}\
		--project ${GCP_PROJECT_ID}\

add-roles:
	echo ${GCP_PROJECT_ID}
	${PROJECT_DIR}/scripts/add_roles_to_service_account.sh

create-key:
	gcloud iam service-accounts keys create\
		${GCP_KEY_PATH}\
		--iam-account=${GCP_SERVICE_ACCOUNT_EMAIL}

create-config:
	gcloud config configurations create ${GCP_PROJECT_ID}-service-account
	gcloud auth activate-service-account ${GCP_SERVICE_ACCOUNT_EMAIL} --key-file=${GCP_KEY_PATH}

conf-docker-for-gcp:
	gcloud auth configure-docker

image-to-gcp:
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
