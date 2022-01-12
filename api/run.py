"""Main module."""
import os
from api import app, DEBUG


if __name__ == "__main__":
    app.run(host=os.getenv("FLASK_HOST"), port=os.getenv("FLASK_PORT"), debug=DEBUG)
