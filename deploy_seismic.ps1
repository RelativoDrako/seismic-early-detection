# =============================================
# deploy_seismic.ps1
# Ejecucion completa del pipeline
# =============================================

chcp 65001

Write-Host "==== Deploy del pipeline sismico ===="

if (-not (Test-Path "venv")) {
    Write-Host "Entorno virtual no encontrado. Ejecuta setup_seismic.ps1"
    exit
}

. .\venv\Scripts\Activate.ps1

# ----- Validar scripts -----
$requiredScripts = @(
    "src\generate_signals.py",
    "src\preprocessing.py",
    "src\train_baseline.py",
    "src\evaluate_baseline.py"
)

foreach ($s in $requiredScripts) {
    if (-not (Test-Path $s)) {
        Write-Host "Script faltante: $s"
        exit
    }
}

# ----- Pipeline -----
Write-Host "Generando senales..."
python src\generate_signals.py

Write-Host "Preprocesando datos..."
python src\preprocessing.py

Write-Host "Entrenando modelo baseline..."
python src\train_baseline.py

Write-Host "Evaluando modelo..."
python src\evaluate_baseline.py

Write-Host "==== Deploy finalizado correctamente ===="
