FROM python:3.9.7-slim-bullseye

ARG FLASK_HOST
ARG FLASK_PORT

ENV FLASK_HOST ${FLASK_HOST}
ENV FLASK_PORT ${FLASK_PORT}
ENV FLASK_ENV production

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

ENV FLASK_APP="$DOCKER_PROJECT_DIR/api/run.py"
ENV MODEL_PATH="$DOCKER_PROJECT_DIR/$MODEL_PATH"
WORKDIR $DOCKER_PROJECT_DIR

COPY . .

RUN pip install --upgrade pip &&\
    pip install --no-cache-dir .

CMD flask run --host=${FLASK_HOST} --port=${FLASK_PORT}
