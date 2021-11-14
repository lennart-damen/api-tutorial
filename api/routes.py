from api import app, model
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
