import pandas as pd
import random

data = []

for _ in range(1500):
    cpu = random.randint(5, 95)
    network = random.randint(20, 200)
    data_gb = random.randint(1, 50)
    hours = random.randint(1, 24)

    emission = round(
        (cpu * 0.03) + (network * 0.02) + (data_gb * 0.05),
        2
    )

    label = 1 if emission > 3.5 else 0

    data.append([
        cpu, network, data_gb, hours, emission, label
    ])

df = pd.DataFrame(
    data,
    columns=[
        "cpu_usage",
        "network_usage",
        "data_transfer_gb",
        "active_hours",
        "emission_estimate",
        "label"
    ]
)

df.to_csv("raw/digital_activity_data.csv", index=False)

print("✅ Dataset generated (1500 rows)")
