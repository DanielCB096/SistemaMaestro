param(
    [switch]$Reset
)

$ErrorActionPreference = "Stop"

$exe = "C:\opentelemety\tienda\SistemaTienda\SistemaTienda.Maui\bin\Debug\net10.0-windows10.0.19041.0\win-x64\SistemaTienda.Maui.exe"
$data = Join-Path $env:LOCALAPPDATA "SistemaTienda\com.sistematienda.p3"

if (!(Test-Path $exe)) {
    throw "No existe la app de prueba P3. Compílala primero con: dotnet build SistemaTienda\SistemaTienda.Maui\SistemaTienda.Maui.csproj -f net10.0-windows10.0.19041.0 -c Debug -p:ApplicationId=com.sistematienda.p3 -p:ApplicationTitle=`"SistemaTienda P3`""
}

Get-Process -Name "SistemaTienda.Maui" -ErrorAction SilentlyContinue | Stop-Process -Force

if ($Reset -and (Test-Path $data)) {
    Remove-Item $data -Recurse -Force
    Write-Host "Datos de prueba P3 borrados: $data"
}

$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Prueba P3 - SistemaTienda.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exe
$shortcut.WorkingDirectory = Split-Path $exe
$shortcut.IconLocation = $exe
$shortcut.Description = "Prueba de uso P3 - SistemaTienda"
$shortcut.Save()

Write-Host ""
Write-Host "Acceso directo creado: $shortcutPath"
Write-Host "App: $exe"
Write-Host "Datos aislados: $data"
Write-Host ""
Write-Host "Datos de prueba:"
Write-Host "  Tienda: Abarrotes La Esquina"
Write-Host "  Giro: Abarrotes"
Write-Host "  PIN: 2468"
Write-Host "  Producto: Refresco 600 ml / P3-001 / costo 10 / precio 15 / stock 10"
Write-Host "  Venta: 2 refrescos en efectivo, pago con 50"
Write-Host "  Fondo de caja: 200"
Write-Host ""
Write-Host "Entrega la hoja docs\09-pendientes\p3-guion-participante.md y no des ayuda verbal."
