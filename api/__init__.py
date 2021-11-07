"""Top-level package for deployment_workshop."""
from flask import Flask

__author__ = """Lennart Damen"""
__email__ = 'lennart.damen@coolblue.nl'
__version__ = '0.0.0'

app = Flask(__name__)

from api import routes
