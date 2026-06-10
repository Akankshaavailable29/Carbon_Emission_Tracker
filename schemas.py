from pydantic import BaseModel

class PredictionRequest(BaseModel):
    cpu_usage: float
    network_usage: float
    data_transfer_gb: float
    active_hours: float
    emission_estimate: float

class PredictionResponse(BaseModel):
    prediction: str
    threat_score: int
    explanation: str
