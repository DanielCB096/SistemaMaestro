param(
    [ValidateSet("limpio", "configurado", "demo")]
    [string]$Semilla = "limpio",
    [switch]$Reset
)

$ErrorActionPreference = "Stop"

$exe = "C:\opentelemety\tienda\SistemaTienda\SistemaTienda.Maui\bin\Debug\net10.0-windows10.0.19041.0\win-x64\SistemaTienda.Maui.exe"
$proyectoSemilla = "C:\opentelemety\tienda\SistemaTienda\SistemaTienda.Semilla\SistemaTienda.Semilla.csproj"
$data = Join-Path $env:LOCALAPPDATA "SistemaTienda\com.sistematienda.p3"

if (!(Test-Path $exe)) {
    throw "No existe la app de prueba P3. Compílala primero con: dotnet build SistemaTienda\SistemaTienda.Maui\SistemaTienda.Maui.csproj -f net10.0-windows10.0.19041.0 -c Debug -p:ApplicationId=com.sistematienda.p3 -p:ApplicationTitle=`"SistemaTienda P3`""
}

Get-Process -Name "SistemaTienda.Maui" -ErrorAction SilentlyContinue | Stop-Process -Force

if ($Reset) {
    $Semilla = "limpio"
}

# Prepara la base aislada de P3. El escenario limpio deja todo borrado para
# que el participante pase por el asistente de primera vez.
$dotnet = Join-Path $env:LOCALAPPDATA "dotnet10\dotnet.exe"
if (!(Test-Path $dotnet)) {
    $dotnet = "dotnet"
} else {
    $env:DOTNET_ROOT = Split-Path $dotnet
    $env:DOTNET_MULTILEVEL_LOOKUP = "0"
}

& $dotnet run --project $proyectoSemilla -c Debug -- --p3 --escenario $Semilla --reset
if ($LASTEXITCODE -ne 0) {
    throw "El generador de datos falló con código $LASTEXITCODE"
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
Write-Host "Acceso directo: $shortcutPath"
Write-Host "App: $exe"
Write-Host "Datos aislados: $data"
Write-Host "Escenario: $Semilla"
Write-Host ""

if ($Semilla -eq "limpio") {
    Write-Host "La app arranca vacía: el participante verá el asistente de primera vez."
    Write-Host "Datos de prueba:"
    Write-Host "  Tienda: Abarrotes La Esquina"
    Write-Host "  Giro: Abarrotes"
    Write-Host "  PIN: 2468 (lo elige el participante)"
    Write-Host "  Producto: Refresco 600 ml / P3-001 / costo 10 / precio 15 / stock 10"
    Write-Host "  Venta: 2 refrescos en efectivo, pago con 50"
    Write-Host "  Fondo de caja: 200"
    Write-Host ""
    Write-Host "Entrega docs\09-pendientes\p3-guion-participante.md y no des ayuda verbal."
} elseif ($Semilla -eq "configurado") {
    Write-Host "La app ya tiene tienda, usuarios y catálogo (PIN 1234)."
    Write-Host "Úsalo para practicar una venta sin pasar por el asistente."
} else {
    Write-Host "La app ya tiene datos de demostración: ventas, clientes, proveedores,"
    Write-Host "compras, gastos, caja y un corte cerrado."
    Write-Host "PIN: dueño 1234 · encargada 5678 · empleado 4321"
    Write-Host "Úsalo para demos y para revisar reportes, no para la prueba P3 de primera vez."
}
