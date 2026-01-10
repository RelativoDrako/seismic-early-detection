# =============================================
# setup_seismic.ps1
# Preparacion completa del entorno y estructura
# =============================================

chcp 65001

Write-Host "==== Setup del proyecto Seismic Early Detection ===="

function New-File {
    param (
        [string]$Path,
        [string]$Content
    )
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

# ----- Estructura de carpetas -----
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
    "decisions",
    "src"
)

foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d | Out-Null
    }
}

# ----- Archivos base -----
$readme = @'
# Seismic Early Detection & Impact Prediction System

Applied AI project focused on early seismic signal detection
under real-world operational constraints.

Edge-first. Low latency. Failure-aware.
'@

$license = @'
Apache License Version 2.0
https://www.apache.org/licenses/LICENSE-2.0
'@

$disclaimer = @'
Research and educational project only.
Not intended for real-world seismic alerting.
'@

$requirements = @'
numpy
pandas
scikit-learn
scipy
matplotlib
seaborn
joblib
tqdm
tensorflow
'@

New-File "README.md" $readme
New-File "LICENSE" $license
New-File "DISCLAIMER.md" $disclaimer
New-File "requirements.txt" $requirements

# ----- Entorno virtual -----
if (-not (Test-Path "venv")) {
    python -m venv venv
}

. .\venv\Scripts\Activate.ps1

pip install --upgrade pip
pip install -r requirements.txt

Write-Host "==== Setup completado ===="
Write-Host "Ejecuta: .\deploy_seismic.ps1"
