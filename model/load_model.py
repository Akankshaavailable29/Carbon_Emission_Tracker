import joblib

MODEL_PATH = "carbon_emission_model.pkl"

def load_model():
    return joblib.load(MODEL_PATH)
