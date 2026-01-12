# =====================================================
# reset_repo_safe.ps1
# Ritual seguro para limpiar historial y entorno Python
#⚠️ SCRIPT DESTRUCTIVO — USAR CON CONSCIENCIA
# =====================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "==== Ritual de limpieza segura del repositorio ====" -ForegroundColor Cyan

# =======================
# Configuración
# =======================
$RepoPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $RepoPath

$venvFolder = "venv"
$requirementsFile = "requirements.txt"
$remoteBranch = "main"

# =======================
# Validaciones iniciales
# =======================
if (-not (Test-Path ".git")) {
    Write-Error "Este directorio no es un repositorio Git. Abortando."
    exit 1
}

$currentBranch = git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne $remoteBranch) {
    Write-Warning "Estás en la rama '$currentBranch'. Se esperaba '$remoteBranch'."
    $confirmBranch = Read-Host "¿Deseas continuar de todas formas? (SI/NO)"
    if ($confirmBranch -ne "SI") { exit 1 }
}

# =======================
# 1. Cancelar merges pendientes
# =======================
if (git status --porcelain | Select-String "^UU") {
    Write-Host "[INFO] Conflictos detectados. Abortando merge..." -ForegroundColor Yellow
    git merge --abort
} else {
    Write-Host "[INFO] No se encontraron merges pendientes."
}

# =======================
# 2. Asegurar .gitignore
# =======================
if (-not (Test-Path ".gitignore")) {
    New-Item ".gitignore" -ItemType File | Out-Null
}

if (-not (Select-String -Path ".gitignore" -Pattern "^$venvFolder/?$" -Quiet)) {
    Add-Content -Path ".gitignore" -Value "$venvFolder/"
    Write-Host "[OK] venv agregado a .gitignore."
} else {
    Write-Host "[INFO] venv ya estaba ignorado."
}

# =======================
# 3. Eliminar venv del index
# =======================
if (git ls-files --error-unmatch $venvFolder 2>$null) {
    git rm -r --cached $venvFolder
    Write-Host "[OK] venv eliminado del control de versiones."
} else {
    Write-Host "[INFO] venv no estaba trackeado."
}

# =======================
# 4. Confirmación destructiva
# =======================
Write-Host ""
Write-Host "⚠️  ADVERTENCIA MAYOR ⚠️" -ForegroundColor Red
Write-Host "Este paso REESCRIBE el historial Git."
Write-Host "Afectará a TODOS los colaboradores."
Write-Host ""

$confirm = Read-Host "Escribe EXACTAMENTE: LIMPIAR-HISTORIAL"
if ($confirm -ne "LIMPIAR-HISTORIAL") {
    Write-Host "Confirmación incorrecta. Ritual cancelado." -ForegroundColor Yellow
    exit 1
}

# =======================
# 5. Verificar git-filter-repo
# =======================
if (-not (Get-Command git-filter-repo -ErrorAction SilentlyContinue)) {
    Write-Error "git-filter-repo no está instalado. Ejecuta: pip install git-filter-repo"
    exit 1
}

Write-Host "[INFO] Limpiando historial de archivos grandes..." -ForegroundColor Cyan
git filter-repo `
    --invert-paths `
    --path $venvFolder `
    --path-glob '*.dll' `
    --force

Write-Host "[OK] Historial Git limpiado." -ForegroundColor Green

# =======================
# 6. Commit y push forzado
# =======================
git add .gitignore

if (-not (git diff --cached --quiet)) {
    git commit -m "chore: limpiar historial y excluir venv"
    Write-Host "[OK] Commit realizado."
} else {
    Write-Host "[INFO] No había cambios para commitear."
}

Write-Host "[INFO] Push forzado al remoto..." -ForegroundColor Yellow
git push origin $remoteBranch --force
Write-Host "[OK] Push completado." -ForegroundColor Green

# =======================
# 7. Recrear entorno virtual
# =======================
if (Test-Path $venvFolder) {
    Remove-Item -Recurse -Force $venvFolder
    Write-Host "[INFO] venv antiguo eliminado."
}

python -m venv $venvFolder
Write-Host "[OK] venv recreado."

# =======================
# 8. Instalar dependencias
# =======================
if (Test-Path $requirementsFile) {
    Write-Host "[INFO] Instalando dependencias..." -ForegroundColor Cyan
    & .\$venvFolder\Scripts\python.exe -m pip install --upgrade pip
    & .\$venvFolder\Scripts\python.exe -m pip install -r $requirementsFile
    Write-Host "[OK] Dependencias instaladas."
} else {
    Write-Warning "No se encontró requirements.txt."
}

# =======================
# Final
# =======================
Write-Host ""
Write-Host "==== Ritual completado con éxito ====" -ForegroundColor Cyan
Write-Host "Activa el entorno con:"
Write-Host ".\$venvFolder\Scripts\Activate.ps1"
