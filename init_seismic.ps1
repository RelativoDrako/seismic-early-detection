# ===============================================
# Initialize Seismic Early Detection Repo
# ===============================================

# Crear carpetas
$dirs = @(
    "architecture",
    "data",
    "data\raw",
    "data\processed",
    "data\simulated",
    "models",
    "models\baseline",
    "models\experimental",
    "edge",
    "evaluation",
    "decisions"
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}

# Función para crear archivos .md con contenido
function New-File($path, $content) {
    $content | Set-Content -Path $path -Encoding UTF8
}

# README
New-File "README.md" @"
# Seismic Early Detection & Impact Prediction System

An **applied AI system** designed to explore **early seismic signal detection and impact estimation** under **real-world operational constraints**.

This project prioritizes:
- low latency
- reliability
- failure awareness
- edge-first deployment
"@

# Architecture
New-File "architecture\system_overview.md" @"
# System Overview

Edge-first, failure-aware seismic detection system.
"@
New-File "architecture\data_flow.md" @"
# Data Flow

Sensor -> Preprocessing -> Feature Extraction -> Model Inference -> Decision Logic -> Alert
"@
New-File "architecture\deployment_edge.md" @"
# Edge Deployment Constraints

CPU-only, limited memory, intermittent connectivity.
"@

# Models
New-File "models\baseline\README.md" @"
# Baseline Models

Thresholding and Logistic Regression.
"@
New-File "models\experimental\README.md" @"
# Experimental Models

Lightweight CNNs and Autoencoders.
"@

# Edge
New-File "edge\constraints.md" @"
# Edge Constraints

CPU-only, <512MB RAM, no GPU
"@

# Evaluation
New-File "evaluation\metrics.md" @"
# Evaluation Metrics

- Detection latency
- False positive cost
- False negative risk
- Noise robustness
"@
New-File "evaluation\scenarios.md" @"
# Evaluation Scenarios

1. Clean signal
2. Noisy signal
3. Sensor failure
4. Network loss
"@

# Decisions
New-File "decisions\adr-001-edge-first.md" @"
# ADR-001: Edge-First Architecture

Inference runs on edge to minimize latency.
"@
New-File "decisions\adr-002-model-choice.md" @"
# ADR-002: Baseline Models First

Implement interpretable models before complex ones.
"@
New-File "decisions\adr-003-thresholding.md" @"
# ADR-003: Confidence-Based Thresholding

Alerts depend on confidence, not binary output.
"@

# Roadmap
New-File "roadmap.md" @"
# Roadmap

Phase 1: Architecture
Phase 2: Simulation
Phase 3: Edge Prototype
Phase 4: Iteration
"@

# Disclaimer
New-File "DISCLAIMER.md" @"
This project is for research and educational purposes only.
Not intended for real-world seismic alerting.
"@

# License
New-File "LICENSE" @"
Apache License Version 2.0
https://www.apache.org/licenses/LICENSE-2.0
"@

Write-Host "Repository initialized successfully!"
