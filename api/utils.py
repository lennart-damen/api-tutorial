from typing import Optional
import joblib


def load_model_from_filesystem(path: Optional[str]):
    if not isinstance(path, str):
        raise ValueError(f"Environment variable MODEL_PATH is not defined well: {path}")
    return joblib.load(path)
