FROM python:3.9.7-slim-bullseye

ENV PROJECT_DIR="/usr/src/app"
ENV FLASK_APP="$PROJECT_DIR/api/run.py"
WORKDIR $PROJECT_DIR

COPY . .

RUN pip install --upgrade pip &&\
    pip install --no-cache-dir .

CMD [ "flask", "run", "--host=0.0.0.0", "--port=8080" ]