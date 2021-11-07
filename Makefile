# References
# https://blog.container-solutions.com/tagging-docker-images-the-right-way
# https://www.youtube.com/watch?v=p0KKBmfiVl0

FLASK_PORT := 8080
FLASK_HOST := 0.0.0.0
DOCKER_USER := coolblue
DOCKER_PROJECT := ds-api

LATEST_GIT_HASH := $$(git log -1 --pretty=%h)

NAME := ${DOCKER_USER}/${DOCKER_PROJECT}
IMG_ID := ${NAME}:${LATEST_GIT_HASH}
IMG_LATEST := ${NAME}:latest

OS_PORT := 5000

# .PHONY indicates that these make commands do not have a target file,
# they merely execute commands
.PHONY: build-image run-container

build-image:
	@echo "Building docker image using the latest git hash as identifier..."
	docker build -t ${IMG_ID} --build-arg FLASK_PORT=${FLASK_PORT} --build-arg FLASK_HOST=${FLASK_HOST} .
	@echo "Docker build completed"
	docker tag ${IMG_ID} ${IMG_LATEST}
	@echo "Tagged ${IMG_ID} as ${IMG_LATEST}."

run-container:
	docker run -p ${OS_PORT}:${FLASK_PORT} ${IMG_LATEST}
