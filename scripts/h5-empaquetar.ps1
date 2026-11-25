param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [string]$Salida = "dist",

    [string]$Runtime = "win-x64",

    [string]$RepoTienda = "C:\opentelemety\tienda"
)

$ErrorActionPreference = "Stop"

$proyecto = Join-Path $RepoTienda "SistemaTienda\SistemaTienda.Maui\SistemaTienda.Maui.csproj"
$proyectoSemilla = Join-Path $RepoTienda "SistemaTienda\SistemaTienda.Semilla\SistemaTienda.Semilla.csproj"

if (!(Test-Path $proyecto)) {
    throw "No existe el proyecto MAUI: $proyecto"
}

$dotnet = Join-Path $env:LOCALAPPDATA "dotnet10\dotnet.exe"
if (!(Test-Path $dotnet)) {
    $dotnet = "dotnet"
}
else {
    $env:DOTNET_ROOT = Split-Path $dotnet
    $env:DOTNET_MULTILEVEL_LOOKUP = "0"
}

$salidaAbs = [System.IO.Path]::GetFullPath($Salida)
$app = Join-Path $salidaAbs "app"
if (Test-Path $app) {
    Remove-Item $app -Recurse -Force
}
New-Item -ItemType Directory -Path $app -Force | Out-Null

Write-Host "Publicando $Version ($Runtime)..."
& $dotnet publish $proyecto `
    -f net10.0-windows10.0.19041.0 `
    -c Release `
    -p:WindowsPackageType=None `
    -p:RuntimeIdentifier=$Runtime `
    -p:Version=$Version `
    -p:ApplicationDisplayVersion=$Version `
    -o $app

if ($LASTEXITCODE -ne 0) {
    throw "La publicacion fallo con codigo $LASTEXITCODE"
}

# El manifiesto toma la version de esquema de la propia app para no duplicarla.
$json = & $dotnet run --project $proyectoSemilla -c Release -- --manifiesto
if ($LASTEXITCODE -ne 0) {
    throw "No se pudo leer el manifiesto de la app"
}

$base = $json | ConvertFrom-Json
$manifiesto = [ordered]@{
    producto       = "SistemaTienda"
    versionApp     = $Version
    versionEsquema = [int]$base.versionEsquema
    generado       = (Get-Date).ToString("s")
}

$rutaManifiesto = Join-Path $app "manifiesto.json"
$manifiesto | ConvertTo-Json | Set-Content -LiteralPath $rutaManifiesto -Encoding UTF8

$leeme = @"
SistemaTienda $Version
Esquema de base de datos: $($base.versionEsquema)

Instalacion:
  powershell -ExecutionPolicy Bypass -File h5-instalar.ps1 -Paquete <este zip>

La actualizacion conserva la version anterior. Si algo falla, vuelve a ella con:
  powershell -ExecutionPolicy Bypass -File h5-instalar.ps1 -Revertir

Los datos viven aparte y no se tocan:
  %LOCALAPPDATA%\SistemaTienda\com.sistematienda.tienda\Data
"@
Set-Content -LiteralPath (Join-Path $app "LEEME.txt") -Value $leeme -Encoding UTF8

$zip = Join-Path $salidaAbs "SistemaTienda-$Version-$Runtime.zip"
if (Test-Path $zip) {
    Remove-Item $zip -Force
}
Compress-Archive -Path (Join-Path $app "*") -DestinationPath $zip

Write-Host ""
Write-Host "Paquete:  $zip"
Write-Host "Manifiesto: $rutaManifiesto"
Write-Host "Esquema:  $($base.versionEsquema)"
