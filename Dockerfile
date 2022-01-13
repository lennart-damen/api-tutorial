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

ENV FLASK_APP="DOCKER_PROJECT_DIR/api/run.py"
ENV MODEL_PATH="$DOCKER_PROJECT_DIR/$MODEL_PATH"

WORKDIR $DOCKER_PROJECT_DIR
COPY . .

RUN pip install --upgrade pip &&\
    pip install --no-cache-dir .

ENV FLASK_HOST ${FLASK_HOST}
ENV FLASK_PORT ${FLASK_PORT}
ENV FLASK_ENV production
ENV UWSGI_PROTOCOL ${UWSGI_PROTOCOL}
ENV UWSGI_THREADS ${UWSGI_THREADS}
ENV UWSGI_PROCESSES ${UWSGI_PROCESSES}

CMD uwsgi\
        --socket ${FLASK_HOST}:${FLASK_PORT}\
        --protocol ${UWSGI_PROTOCOL}\
        --module api:app\
        --threads ${UWSGI_THREADS}\
        --processes ${UWSGI_PROCESSES}
