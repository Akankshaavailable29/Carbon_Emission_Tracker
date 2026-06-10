from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np
import joblib
import os
import requests

app = FastAPI(
    title="AI Carbon Emission Prediction API",
    description="REST API for Digital Carbon Emission Risk Prediction",
    version="1.0"
)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, "model", "carbon_emission_model.pkl")

model = joblib.load(MODEL_PATH)


SPRING_BOOT_URL = "http://localhost:8081"


class PredictRequest(BaseModel):
    cpu_usage: float
    network_usage: float
    data_transfer_gb: float
    active_hours: float
    emission_estimate: float


class PredictResponse(BaseModel):
    prediction: str
    threat_score: int


class FeedbackRequest(BaseModel):
    predictionId: int
    isCorrect: bool
    comments: str | None = None


@app.get("/")
def health_check():
    return {
        "status": "AI Carbon Emission API Running",
        "model_loaded": True
    }


@app.post("/predict", response_model=PredictResponse)
def predict(data: PredictRequest):

    features = np.array([[
        data.cpu_usage,
        data.network_usage,
        data.data_transfer_gb,
        data.active_hours,
        data.emission_estimate
    ]])

    result = model.predict(features)[0]

    if result == 1:
        prediction = "HIGH_RISK"
        threat_score = 85
    else:
        prediction = "NORMAL"
        threat_score = 25

    
    try:
        payload = {
            "cpuUsage": data.cpu_usage,
            "networkUsage": data.network_usage,
            "dataTransferGb": data.data_transfer_gb,
            "activeHours": data.active_hours,
            "emissionEstimate": data.emission_estimate,
            "prediction": prediction,
            "threatScore": threat_score
        }

        requests.post(
            f"{SPRING_BOOT_URL}/api/predictions",
            json=payload,
            timeout=5
        )

    except Exception as e:
        print("Warning: Could not send prediction to backend:", e)

    return {
        "prediction": prediction,
        "threat_score": threat_score
    }



@app.post("/feedback")
def feedback(data: FeedbackRequest):

    try:
        payload = {
            "predictionId": data.predictionId,
            "isCorrect": data.isCorrect,
            "comments": data.comments
        }

        requests.post(
            f"{SPRING_BOOT_URL}/api/feedback",
            json=payload,
            timeout=5
        )

        return {"status": "Feedback recorded successfully"}

    except Exception as e:
        return {
            "status": "Failed to send feedback",
            "error": str(e)
        }
