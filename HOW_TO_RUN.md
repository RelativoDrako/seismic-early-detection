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
Puede ejecutarse mÃºltiples veces sin riesgo.
