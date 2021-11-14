"""Top-level package for deployment_workshop."""
from flask import Flask
import joblib
import os

__author__ = """Lennart Damen"""
__email__ = 'lennart.damen@coolblue.nl'
__version__ = '0.0.0'

model_path = os.getenv("MODEL_PATH")
if model_path is None:
    raise ValueError("Environment variable MODEL_PATH is not defined")
model = joblib.load(model_path)

app = Flask(__name__)

from api import routes
