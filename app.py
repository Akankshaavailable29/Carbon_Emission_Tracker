from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json

    usage = data.get("usage")
    energy = data.get("energy")

    emission = usage * energy * 0.82
    threat_score = min(emission / 50, 1.0)

    return jsonify({
        "emissionValue": round(emission, 2),
        "threatScore": round(threat_score, 2)
    })

if __name__ == "__main__":
    app.run(port=5000, debug=True)
