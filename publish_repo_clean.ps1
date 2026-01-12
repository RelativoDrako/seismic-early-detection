# =========================================
# publish_repo_clean.ps1
# Publicación limpia del repositorio a GitHub
# =========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "==== Publicación limpia del repositorio ====" -ForegroundColor Cyan

# -------------------------------
# Configuración
# -------------------------------
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repoRoot

$venvFolder = "venv"
$requirementsFile = "requirements.txt"
$targetBranch = "main"

# -------------------------------
# Validaciones iniciales
# -------------------------------
if (-not (Test-Path ".git")) {
    Write-Error "Este directorio no es un repositorio Git."
    exit 1
}

$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne $targetBranch) {
    Write-Warning "Estás en la rama '$currentBranch'. Se recomienda '$targetBranch'."
}

# -------------------------------
# 1. Asegurar .gitignore
# -------------------------------
if (-not (Test-Path ".gitignore")) {
    New-Item ".gitignore" -ItemType File | Out-Null
}

$gitignoreRules = @(
    "venv/",
    "__pycache__/",
    "*.pyc",
    "*.pyo",
    "*.pyd",
    "*.log",
    "*.tmp"
)

foreach ($rule in $gitignoreRules) {
    if (-not (Select-String -Path ".gitignore" -Pattern "^$rule$" -Quiet)) {
        Add-Content -Path ".gitignore" -Value $rule
        Write-Host "[OK] Regla agregada a .gitignore: $rule" -ForegroundColor Green
    }
}

# -------------------------------
# 2. Eliminar venv del index (si está trackeado)
# -------------------------------
$trackedVenv = git ls-files $venvFolder 2>$null

if ($trackedVenv) {
    git rm -r --cached $venvFolder
    Write-Host "[OK] venv eliminado del control de versiones." -ForegroundColor Green
} else {
    Write-Host "[INFO] venv no estaba versionado." -ForegroundColor DarkGray
}


# -------------------------------
# 3. Commit seguro
# -------------------------------
git add .gitignore

if (-not (git diff --cached --quiet)) {
    git commit -m "chore: ignore venv and clean repository"
    Write-Host "[OK] Commit realizado." -ForegroundColor Green
} else {
    Write-Host "[INFO] No había cambios para commitear."
}

# -------------------------------
# 4. Push al remoto
# -------------------------------
Write-Host "[INFO] Publicando en origin/$targetBranch..." -ForegroundColor Yellow
git push origin $targetBranch
Write-Host "[OK] Push completado." -ForegroundColor Green

# -------------------------------
# 5. Recrear entorno virtual local
# -------------------------------
if (Test-Path $venvFolder) {
    Remove-Item -Recurse -Force $venvFolder
    Write-Host "[INFO] venv local eliminado."
}

python -m venv $venvFolder
Write-Host "[OK] venv recreado."

# -------------------------------
# 6. Instalar dependencias (sin activar venv)
# -------------------------------
if (Test-Path $requirementsFile) {
    Write-Host "[INFO] Instalando dependencias..." -ForegroundColor Cyan
    & .\$venvFolder\Scripts\python.exe -m pip install --upgrade pip
    & .\$venvFolder\Scripts\python.exe -m pip install -r $requirementsFile
    Write-Host "[OK] Dependencias instaladas."
} else {
    Write-Warning "No se encontró requirements.txt."
}

# -------------------------------
# Final
# -------------------------------
Write-Host ""
Write-Host "==== Repositorio publicado correctamente ====" -ForegroundColor Cyan
Write-Host "Para trabajar:"
Write-Host ".\venv\Scripts\Activate.ps1"
