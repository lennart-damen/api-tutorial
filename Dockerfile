FROM python:3.9.7-slim-bullseye

ARG FLASK_HOST
ARG FLASK_PORT
ARG DOCKER_PROJECT_DIR
ARG MODEL_PATH
ARG UWSGI_PROTOCOL
ARG UWSGI_THREADS
ARG UWSGI_PROCESSES

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Installing C compiler
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install gcc mono-mcs && \
    rm -rf /var/lib/apt/lists/*

ENV MODEL_PATH="$DOCKER_PROJECT_DIR/$MODEL_PATH"
WORKDIR $DOCKER_PROJECT_DIR

COPY setup.py .
COPY setup.cfg .
COPY README.md .

RUN pip install --upgrade pip &&\
    pip install --no-cache-dir .

ENV FLASK_HOST ${FLASK_HOST}
ENV FLASK_PORT ${FLASK_PORT}
ENV FLASK_ENV production
ENV UWSGI_PROTOCOL ${UWSGI_PROTOCOL}
ENV UWSGI_THREADS ${UWSGI_THREADS}
ENV UWSGI_PROCESSES ${UWSGI_PROCESSES}

COPY Makefile .
COPY ./api ./api
COPY ./models ./models

# TODO: Docker container will not execute 'make' command, not sure why
# Just use the uwsgi command instead
CMD uwsgi\
        --socket ${FLASK_HOST}:${FLASK_PORT}\
        --protocol ${UWSGI_PROTOCOL}\
        --module api:app\
        --threads ${UWSGI_THREADS}\
        --processes ${UWSGI_PROCESSES}
