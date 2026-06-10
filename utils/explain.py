def generate_explanation(prediction):
    if prediction == 1:
        return (
            "High resource consumption and abnormal usage patterns "
            "detected, leading to increased digital carbon emissions."
        )
    return "Digital activity is within normal emission thresholds."
