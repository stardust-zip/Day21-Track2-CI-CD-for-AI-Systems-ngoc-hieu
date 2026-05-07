import os

import joblib
from fastapi import FastAPI, HTTPException
from google.cloud import storage
from pydantic import BaseModel

app = FastAPI()

GCS_BUCKET = os.environ["GCS_BUCKET"]
GCS_MODEL_KEY = "models/latest/model.pkl"
MODEL_PATH = os.path.expanduser("~/models/model.pkl")


def download_model():
    """Tai file model.pkl tu GCS ve may khi server khoi dong."""
    client = storage.Client()
    bucket = client.bucket(GCS_BUCKET)
    blob = bucket.blob(GCS_MODEL_KEY)
    blob.download_to_filename(MODEL_PATH)
    print("Model da duoc tai xuong tu GCS.")


download_model()
model = joblib.load(MODEL_PATH)


class PredictRequest(BaseModel):
    features: list[float]


@app.get("/health")
def health():
    """Endpoint kiem tra suc khoe server."""
    return {"status": "ok"}


@app.post("/predict")
def predict(req: PredictRequest):
    """Endpoint suy luan chinh."""
    if len(req.features) != 12:
        raise HTTPException(status_code=400, detail="Expected 12 features")

    # Model scikit-learn tra ve mot numpy array, nen ta lay phan tu dau tien [0]
    pred = model.predict([req.features])[0]

    # Chuyen doi tu so nguyen sang nhan string
    label_map = {0: "thap", 1: "trung_binh", 2: "cao"}
    label = label_map.get(int(pred), "unknown")

    return {"prediction": int(pred), "label": label}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
