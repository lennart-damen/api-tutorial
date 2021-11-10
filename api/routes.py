import joblib
from api import app


@app.route("/")
@app.route("/index")
def index():
    return "Hello, ML Engineer!"


@app.route("/predict")
def predict():
    # Parse request
    X = None  # TODO

    # Load model
    model = None  # TODO

    # Predict
    y_hat = model.predict(X=X)

    # Post-process
    response = None  # TODO
    return response
