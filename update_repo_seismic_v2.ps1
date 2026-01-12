# =====================================================
# update_repo_seismic_v2.ps1
# Idempotent MVP Setup — Seismic Early Detection System
# =====================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------- Encoding ----------
chcp 65001 | Out-Null

Write-Host "==== Updating Seismic Early Detection Repo (MVP v3) ====" -ForegroundColor Cyan

# ---------- Utils ----------
function Ensure-Directory {
    param ([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Host "Created directory: $Path" -ForegroundColor Green
    }
}

function Ensure-File {
    param (
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Content
    )

    if (-not (Test-Path $Path)) {
        Set-Content -Path $Path -Value $Content -Encoding UTF8
        Write-Host "Created file: $Path" -ForegroundColor Green
    }
}

function Ensure-Venv {
    param ([string]$Path = "venv")

    if (-not (Test-Path $Path)) {
        Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
        python -m venv $Path
    }
}

# ---------- Folder Structure ----------
$directories = @(
    "architecture",
    "data/raw",
    "data/processed",
    "data/simulated",
    "models/baseline",
    "models/experimental",
    "edge",
    "evaluation",
    "decisions",
    "src"
)

foreach ($dir in $directories) {
    Ensure-Directory $dir
}

# ---------- README ----------
Ensure-File "README.md" @'
# Seismic Early Detection & Impact Prediction System

Applied AI system for early detection of abnormal vibration patterns
under real-world operational constraints.

## Executive Summary — Architectural Decisions
1. Edge-first processing for low latency and resilience.
2. Decision-support system (no autonomous control).
3. Generic models with asset-specific tuning for critical systems.
4. Rule-based alerts with ML-assisted anomaly detection.
5. Distributed deployment with centralized analytics.

Priorities: safety, explainability, scalability, failure awareness.
'@

# ---------- ADRs ----------
$adrs = @{
    "adr-001-edge-first.md" = "# ADR-001 Edge-First Architecture`nCritical processing runs on edge devices."
    "adr-002-decision-support.md" = "# ADR-002 Decision-Support Only`nSystem provides alerts, not autonomous control."
    "adr-003-generic-vs-specific.md" = "# ADR-003 Generic vs Asset-Specific Models`nScalable default, tuned when needed."
    "adr-004-rule-vs-ml.md" = "# ADR-004 Rule-Based + ML`nExplainable rules, ML for advanced insight."
    "adr-005-distributed.md" = "# ADR-005 Distributed Deployment`nLocal processing, central aggregation."
}

foreach ($adr in $adrs.GetEnumerator()) {
    Ensure-File ("decisions\" + $adr.Key) $adr.Value
}

# ---------- Architecture Docs ----------
Ensure-File "architecture/system_overview.md" @'
# System Overview

```mermaid
flowchart LR
    Sensor --> Edge
    Edge --> Alert
    Edge --> Cloud
    Cloud --> Analytics
'@

Ensure-File "architecture/data_flow.md" @'

Data Flow
mermaid
sequenceDiagram
    Sensor->>Edge: Raw vibration
    Edge->>Edge: Feature extraction
    Edge->>Edge: Rule evaluation
    Edge->>Cloud: Aggregated data
'@

Ensure-File "architecture/deployment_diagram.md" @'

Deployment Diagram
mermaid
flowchart TB
    subgraph Site
        Sensor --> EdgeNode
    end
    EdgeNode --> CentralPlatform
'@

#---------- Python Pipeline Templates ----------
Ensure-File "src/generate_signals.py" @'
import numpy as np
import pandas as pd

np.random.seed(42)
t = np.linspace(0, 10, 1000)
signal = np.sin(t) + 0.2 * np.random.randn(len(t))

df = pd.DataFrame({"time": t, "signal": signal})
df.to_csv("data/raw/signals.csv", index=False)
print("Signals generated")
'@

Ensure-File "src/preprocessing.py" @'
import pandas as pd

df = pd.read_csv("data/raw/signals.csv")
df["filtered"] = df["signal"].rolling(5).mean()
df.to_csv("data/processed/processed.csv", index=False)
print("Preprocessing complete")
'@

Ensure-File "src/train_baseline.py" @'
import pandas as pd
from sklearn.linear_model import LogisticRegression
import joblib

df = pd.read_csv("data/processed/processed.csv").dropna()
X = df[["filtered"]]
y = (df["filtered"].abs() > 0.8).astype(int)

model = LogisticRegression()
model.fit(X, y)
joblib.dump(model, "models/baseline/model.joblib")
print("Baseline model trained")
'@

Ensure-File "src/evaluate_baseline.py" @'
import pandas as pd
import joblib

model = joblib.load("models/baseline/model.joblib")
df = pd.read_csv("data/processed/processed.csv").dropna()

preds = model.predict(df[["filtered"]])
print("Evaluation complete. Alerts:", preds.sum())
'@

#---------- Evaluation ----------
Ensure-File "evaluation/metrics.md" @'

Metrics
Detection latency

False positives

False negatives

Signal noise tolerance
'@

#---------- License / Disclaimer ----------
Ensure-File "LICENSE" "Apache License Version 2.0"
Ensure-File "DISCLAIMER.md" "Educational and research use only."

#---------- Environment ----------
Ensure-File "requirements.txt" @'
numpy
pandas
scikit-learn
joblib
matplotlib
'@

#---------- Python Environment ----------
Ensure-Venv "venv"
. .\venv\Scripts\Activate.ps1

pip install --upgrade pip | Out-Null
pip install -r requirements.txt | Out-Null

Write-Host "==== Repo MVP v3 ready ====" -ForegroundColor Cyan
Write-Host "Activate env: .\venv\Scripts\Activate.ps1"