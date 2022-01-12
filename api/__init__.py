"""Top-level package for deployment_workshop."""
import os
from flask import Flask
from dotenv import load_dotenv
from api import utils

__author__ = """Lennart Damen"""
__email__ = "lennart.damen@coolblue.nl"
__version__ = "0.0.0"

load_dotenv()
DEBUG = True if os.getenv("FLASK_ENV") == "development" else False

app = Flask(__name__)

from api import routes  # noqa: E402
