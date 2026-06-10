import os
import sys
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# ✅ Add project root to PYTHONPATH
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(BASE_DIR)

from utils.preprocessing import preprocess_data

RAW_DATA = os.path.join(BASE_DIR, "data", "raw", "digital_activity_data.csv")
CLEAN_DATA = os.path.join(BASE_DIR, "data", "processed", "cleaned_data.csv")

# Preprocess data
df = preprocess_data(RAW_DATA, CLEAN_DATA)

X = df.drop("label", axis=1)
y = df["label"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model = RandomForestClassifier(
    n_estimators=100,
    random_state=42
)

model.fit(X_train, y_train)

MODEL_PATH = os.path.join(BASE_DIR, "model", "carbon_emission_model.pkl")
joblib.dump(model, MODEL_PATH)

print("✅ Model trained and saved at:", MODEL_PATH)
