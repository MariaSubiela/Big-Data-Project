import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

df = pd.read_csv("degree_center_data_2.csv")

# Drop missing values
df = df.dropna(subset=[
    "success_rate",
    "avg_admission_score",
    "pct_women",
    "avg_credits_enrolled",
    "mobility_ratio",
    "pct_low_background"
])

# Select features
features = df[[
    "success_rate",
    "avg_admission_score",
    "pct_women",
    "avg_credits_enrolled",
    "mobility_ratio",
    "pct_low_background"
]]

# Normalize
scaler = StandardScaler()
X = scaler.fit_transform(features)

# Clustering
kmeans = KMeans(n_clusters=3, random_state=42)
df["cluster"] = kmeans.fit_predict(X)

# Plot
plt.scatter(df["avg_admission_score"], df["success_rate"], c=df["cluster"])
plt.xlabel("Admission Score")
plt.ylabel("Success Rate")
plt.title("Clusters of Degree Profiles")
plt.savefig('clusters_2.png')
plt.close()

# Cluster interpretation
print(df.groupby("cluster")[features.columns].mean())

for i in df["cluster"].unique():
    df[df["cluster"] == i][[
        "avg_admission_score",
        "success_rate"
    ]].to_csv(f"cluster_{i}.csv", index=False)



df[[
    "avg_admission_score",
    "success_rate",
    "cluster"
]].to_csv("canva_scatter_data.csv", index=False)