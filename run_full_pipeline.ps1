
# =============================================
# run_full_pipeline.ps1
# Orquestador final de deploy (simple y seguro)
# =============================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "==== Deploy completo: Seismic Early Detection ====" -ForegroundColor Cyan

# -------------------------------
# Configuración básica
# -------------------------------
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repoRoot

$setupScript  = "update_repo_seismic_v2.ps1"
$deployScript = "deploy_seismic.ps1"
$venvActivate = ".\venv\Scripts\Activate.ps1"
$howToFile    = "HOW_TO_RUN.md"

# -------------------------------
# Validaciones mínimas
# -------------------------------
if (-not (Test-Path ".git")) {
    Write-Error "Este directorio no es un repositorio Git."
    exit 1
}

foreach ($required in @($setupScript, $deployScript)) {
    if (-not (Test-Path $required)) {
        Write-Error "Script requerido no encontrado: $required"
        exit 1
    }
}

# -------------------------------
# 1. Preparar / actualizar repo
# -------------------------------
Write-Host "[1/4] Preparando repositorio..." -ForegroundColor Yellow
& .\$setupScript

# -------------------------------
# 2. Activar entorno virtual
# -------------------------------
if (-not (Test-Path $venvActivate)) {
    Write-Error "Entorno virtual no encontrado. Ejecuta primero el setup."
    exit 1
}

Write-Host "[2/4] Activando entorno virtual..." -ForegroundColor Yellow
. $venvActivate

# -------------------------------
# 3. Ejecutar pipeline
# -------------------------------
Write-Host "[3/4] Ejecutando pipeline..." -ForegroundColor Yellow
& .\$deployScript

# -------------------------------
# 4. Crear HOW_TO_RUN.md (si falta)
# -------------------------------
if (-not (Test-Path $howToFile)) {
    Write-Host "[4/4] Generando HOW_TO_RUN.md..." -ForegroundColor Yellow

@'
# How to Run the Seismic Early Detection Pipeline

## 1. Activar el entorno virtual
```powershell
.\venv\Scripts\Activate.ps1
```
## 2. Ejecutar el pipeline completo
```powershell
.\run_full_pipeline.ps1
```
## 3. Archivos generados

data/raw/*.csv

data/processed/*.csv

models/baseline/*.joblib

evaluation/*.md


## 4. Notas
Este pipeline es reproducible e idempotente.
Puede ejecutarse múltiples veces sin riesgo.
'@ | Set-Content -Path $howToFile -Encoding UTF8

git add $howToFile
if (-not (git diff --cached --quiet)) {
    git commit -m "docs: add HOW_TO_RUN instructions"
    Write-Host "[INFO] HOW_TO_RUN.md creado y versionado." -ForegroundColor Green
}
} else {
Write-Host "[INFO] HOW_TO_RUN.md ya existe. No se modifica."
}

#-------------------------------
## Final
#-------------------------------
Write-Host ""
Write-Host "==== Deploy completo finalizado ====" -ForegroundColor Cyan
Write-Host "Uso futuro:"
Write-Host "1. Activar entorno: .\venv\Scripts\Activate.ps1"
Write-Host "2. Ejecutar pipeline: .\run_full_pipeline.ps1"