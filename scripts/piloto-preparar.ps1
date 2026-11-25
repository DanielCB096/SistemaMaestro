param(
    [string]$Paquete,

    [switch]$Empaquetar,

    [string]$Version = "1.0.0",

    [string]$Salida,

    [string]$RepoTienda = "C:\opentelemety\tienda",

    [string]$RepoSistema = "C:\opentelemety\SistemaMaestro",

    [switch]$Comprimir,

    [switch]$Forzar
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

if ([string]::IsNullOrWhiteSpace($Salida)) {
    $Salida = Join-Path (Get-Location) "Kit-Piloto"
}
$Salida = [System.IO.Path]::GetFullPath($Salida)

if ((Test-Path $Salida) -and !$Forzar) {
    throw "La carpeta del kit ya existe: $Salida. Usa -Forzar para reemplazarla."
}
if ($Forzar -and (Test-Path $Salida)) {
    Remove-Item $Salida -Recurse -Force
}
New-Item -ItemType Directory -Path $Salida -Force | Out-Null

if ($Empaquetar) {
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-piloto-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    try {
        & powershell -ExecutionPolicy Bypass -File (Join-Path $RepoSistema "scripts\h5-empaquetar.ps1") `
            -Version $Version -Salida $temp -RepoTienda $RepoTienda
        if ($LASTEXITCODE -ne 0) {
            throw "El empaquetado fallo con codigo $LASTEXITCODE"
        }

        $Paquete = Get-ChildItem $temp -File |
            Where-Object { $_.Name -like "POSale-*-win-x64.zip" -or $_.Name -like "SistemaTienda-*-win-x64.zip" } |
            Select-Object -First 1 -ExpandProperty FullName
        if ([string]::IsNullOrWhiteSpace($Paquete)) {
            throw "No se genero el ZIP de la app en $temp"
        }
    }
    finally {
        if (Test-Path $temp) {
            Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Paquete) -or !(Test-Path $Paquete)) {
    throw "Indica -Paquete <zip> o usa -Empaquetar -Version <version>"
}
$Paquete = [System.IO.Path]::GetFullPath($Paquete)

# El manifiesto viaja dentro del ZIP: sin el, el kit no sirve.
$zip = [System.IO.Compression.ZipFile]::OpenRead($Paquete)
try {
    $entrada = $zip.Entries | Where-Object { $_.FullName -eq "manifiesto.json" } |
        Select-Object -First 1
    if ($null -eq $entrada) {
        throw "El paquete no contiene manifiesto.json: $Paquete"
    }

    $lector = New-Object System.IO.StreamReader($entrada.Open())
    try {
        $manifiesto = $lector.ReadToEnd() | ConvertFrom-Json
    }
    finally {
        $lector.Dispose()
    }

    if ([string]::IsNullOrWhiteSpace($manifiesto.versionApp)) {
        throw "El manifiesto no declara versionApp"
    }
}
finally {
    $zip.Dispose()
}

$carpetaApp = Join-Path $Salida "app"
New-Item -ItemType Directory -Path $carpetaApp -Force | Out-Null
Copy-Item -LiteralPath $Paquete -Destination $carpetaApp

Copy-Item -LiteralPath (Join-Path $RepoSistema "scripts\h5-instalar.ps1") -Destination $Salida

$docsOrigen = Join-Path $RepoTienda "SistemaTienda\docs\08-piloto"
$docsDestino = Join-Path $Salida "documentacion"
New-Item -ItemType Directory -Path $docsDestino -Force | Out-Null
Get-ChildItem -LiteralPath $docsOrigen -Filter "*.md" |
    Copy-Item -Destination $docsDestino

$hash = (Get-FileHash -LiteralPath $Paquete -Algorithm SHA256).Hash
$leeme = @"
POSale - Kit de piloto
=============================

Version de la app: $($manifiesto.versionApp)
Esquema de base:   $($manifiesto.versionEsquema)
Paquete:           $(Split-Path $Paquete -Leaf)
SHA-256:           $hash

Contenido
---------
app\                 Paquete autocontenido de la app (no requiere .NET)
h5-instalar.ps1      Instalador y reversion
documentacion\       Plan, instalacion, capacitacion, tarjeta y plantillas

Paso 1. Instalar (en el equipo de la tienda)
--------------------------------------------
powershell -ExecutionPolicy Bypass -File h5-instalar.ps1 -Paquete "app\$(Split-Path $Paquete -Leaf)"

Paso 2. Abrir la app
--------------------
Carpeta: %LOCALAPPDATA%\SistemaTienda\app\versiones\$($manifiesto.versionApp)

Paso 3. Configurar y probar
---------------------------
Sigue documentacion\instalacion-y-dia-0.md y documentacion\checklist-dia-0.md.
No arranques el piloto si falla una venta, un corte o una restauracion.

Paso 4. Capacitar
-----------------
documentacion\capacitacion.md y documentacion\tarjeta-cajero.md (imprimir).

Paso 5. Operar 30 dias
----------------------
documentacion\guion-30-dias.md y documentacion\registro-incidencias.md.

Reversion si la app nueva no abre
---------------------------------
powershell -ExecutionPolicy Bypass -File h5-instalar.ps1 -Revertir
Los datos no se tocan.

Soporte
-------
Canal:      [WHATSAPP / TELEFONO]
Horario:    [LUNES A SABADO, 9:00-19:00]
Emergencia: [TELEFONO]
"@

Set-Content -LiteralPath (Join-Path $Salida "LEEME-PRIMERO.txt") -Value $leeme -Encoding UTF8

$manifiestoKit = @(
    "Kit generado: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    "Version: $($manifiesto.versionApp)",
    "Esquema: $($manifiesto.versionEsquema)",
    "Paquete SHA-256: $hash"
)
Set-Content -LiteralPath (Join-Path $Salida "manifiesto-kit.txt") -Value $manifiestoKit -Encoding UTF8

if ($Comprimir) {
    $zipKit = Join-Path (Split-Path $Salida -Parent) ("Kit-Piloto-" + $manifiesto.versionApp + ".zip")
    if (Test-Path $zipKit) {
        Remove-Item $zipKit -Force
    }
    Compress-Archive -Path (Join-Path $Salida "*") -DestinationPath $zipKit
    Write-Host "Kit comprimido: $zipKit"
}

Write-Host ""
Write-Host "Kit listo: $Salida"
Write-Host "Version: $($manifiesto.versionApp) / esquema $($manifiesto.versionEsquema)"
Write-Host "Paquete: $Paquete"
Write-Host "Documentos: $((Get-ChildItem $docsDestino -Filter '*.md').Count)"
