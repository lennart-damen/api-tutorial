# Insanely useful article on Medium, search for:
# We’ll Do It Live: Updating Machine Learning
# Models on Flask/uWSGI with No Downtime

# Or just use GCP Vertex AI/AI Platform :)

import os
from api import app, utils, model
from flask import request, jsonify
import pandas as pd


@app.route("/")
@app.route("/index")
def index():
    return "Hello, ML Engineer!"


@app.route("/predict", methods=["POST"])
def predict():
    # Parse request
    X_json = request.get_json()
    X = pd.DataFrame(X_json)

    # Predict
    y_hat = model.predict(X=X)
    y_hat = y_hat.tolist()

    # Post-process
    response = {"predictions": y_hat}
    response = jsonify(response)
    return response


# TODO: This will not work when spawning multiple processes
@app.route("/load_model", methods=["GET"])
def load_model():
    global model
    model = utils.load_model_from_filesystem(path=os.getenv("MODEL_PATH"))
    return jsonify(success=True)
