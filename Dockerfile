                            # references:
# - https://stackoverflow.com/questions/40454470/how-can-i-use-a-variable-inside-a-dockerfile-cmd
# - https://vsupalov.com/docker-arg-env-variable-guide/

FROM python:3.9.7-slim-bullseye

ENV PROJECT_DIR=/usr/src/app
WORKDIR $PROJECT_DIR

COPY . .

RUN pip install --upgrade pip &&\
    pip install --no-cache-dir .

CMD [ "python", "./api/run.py" ]