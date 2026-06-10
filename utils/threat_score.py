def calculate_threat_score(is_anomaly, emission_value):
    if is_anomaly:
        return min(100, int(60 + emission_value * 10))
    return min(30, int(emission_value * 5))
