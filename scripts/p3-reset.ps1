$ErrorActionPreference = "Stop"

$data = Join-Path $env:LOCALAPPDATA "SistemaTienda\com.sistematienda.p3"

Get-Process -Name "SistemaTienda.Maui" -ErrorAction SilentlyContinue | Stop-Process -Force

if (Test-Path $data) {
    Remove-Item $data -Recurse -Force
    Write-Host "Datos de prueba P3 borrados: $data"
} else {
    Write-Host "No había datos de prueba P3 en: $data"
}

Write-Host "La app real no se toca; solo se borra la carpeta com.sistematienda.p3."
