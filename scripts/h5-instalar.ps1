param(
    [string]$Paquete,

    [string]$Destino = (Join-Path $env:LOCALAPPDATA "SistemaTienda\app"),

    [switch]$Revertir
)

$ErrorActionPreference = "Stop"

function Leer-Estado([string]$destino) {
    $ruta = Join-Path $destino "actual.json"
    if (!(Test-Path $ruta)) {
        return $null
    }
    return Get-Content -LiteralPath $ruta -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Escribir-Estado([string]$destino, $estado) {
    $ruta = Join-Path $destino "actual.json"
    $estado | ConvertTo-Json | Set-Content -LiteralPath $ruta -Encoding UTF8
}

function Leer-Manifiesto([string]$carpeta) {
    $ruta = Join-Path $carpeta "manifiesto.json"
    if (!(Test-Path $ruta)) {
        throw "El paquete no tiene manifiesto.json: $carpeta"
    }

    $manifiesto = Get-Content -LiteralPath $ruta -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([string]::IsNullOrWhiteSpace($manifiesto.versionApp)) {
        throw "El manifiesto no declara versionApp: $ruta"
    }
    if ([int]$manifiesto.versionEsquema -le 0) {
        throw "El manifiesto no declara versionEsquema: $ruta"
    }

    return $manifiesto
}

New-Item -ItemType Directory -Path $Destino -Force | Out-Null
$versiones = Join-Path $Destino "versiones"
New-Item -ItemType Directory -Path $versiones -Force | Out-Null

$estado = Leer-Estado $Destino

if ($Revertir) {
    if ($null -eq $estado -or [string]::IsNullOrWhiteSpace($estado.anterior)) {
        throw "No hay una version anterior registrada en $Destino"
    }
    if (!(Test-Path $estado.anterior)) {
        throw "La version anterior ya no existe: $($estado.anterior)"
    }

    $revertido = [ordered]@{
        version         = $estado.versionAnterior
        pagina          = (Join-Path $estado.anterior "SistemaTienda.Maui.exe")
        ruta            = $estado.anterior
        versionAnterior = ""
        anterior        = ""
        esquema         = $estado.esquema
        fecha           = (Get-Date).ToString("s")
    }
    Escribir-Estado $Destino $revertido

    Write-Host "Version restaurada: $($revertido.version)"
    Write-Host "Carpeta: $($revertido.ruta)"
    Write-Host "La version fallida sigue en: $($estado.ruta)"
    Write-Host "Los datos de la tienda no se tocaron."
    return
}

if ([string]::IsNullOrWhiteSpace($Paquete)) {
    throw "Indica -Paquete <zip o carpeta> o usa -Revertir"
}
if (!(Test-Path $Paquete)) {
    throw "No existe el paquete: $Paquete"
}

$temporal = Join-Path ([System.IO.Path]::GetTempPath()) ("h5-instalar-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $temporal -Force | Out-Null

try {
    $origen = $Paquete
    if ((Get-Item $Paquete).PSIsContainer -eq $false -and
        [System.IO.Path]::GetExtension($Paquete) -ieq ".zip") {
        Expand-Archive -LiteralPath $Paquete -DestinationPath $temporal -Force
        $origen = $temporal
    }

    # Si el zip trae una sola carpeta raiz, se usa esa.
    $hijos = Get-ChildItem -LiteralPath $origen -Force
    if ($hijos.Count -eq 1 -and $hijos[0].PSIsContainer -and
        !(Test-Path (Join-Path $origen "manifiesto.json"))) {
        $origen = $hijos[0].FullName
    }

    $manifiesto = Leer-Manifiesto $origen
    $version = [string]$manifiesto.versionApp

    if ($null -ne $estado -and $estado.version -eq $version) {
        Write-Host "La version $version ya esta instalada. No se hizo nada."
        return
    }

    $destinoVersion = Join-Path $versiones $version
    $trabajo = Join-Path $versiones ("$version.tmp")
    if (Test-Path $trabajo) {
        Remove-Item $trabajo -Recurse -Force
    }

    Write-Host "Copiando $version..."
    Copy-Item -LiteralPath $origen -Destination $trabajo -Recurse -Force

    if (Test-Path $destinoVersion) {
        Remove-Item $destinoVersion -Recurse -Force
    }
    Move-Item -LiteralPath $trabajo -Destination $destinoVersion

    $nuevo = [ordered]@{
        version         = $version
        pagina          = (Join-Path $destinoVersion "SistemaTienda.Maui.exe")
        ruta            = $destinoVersion
        versionAnterior = if ($null -ne $estado) { $estado.version } else { "" }
        anterior        = if ($null -ne $estado) { $estado.ruta } else { "" }
        esquema         = [int]$manifiesto.versionEsquema
        fecha           = (Get-Date).ToString("s")
    }

    # El puntero cambia al final: si la copia falla, la version anterior sigue activa.
    Escribir-Estado $Destino $nuevo

    if ($null -ne $estado) {
        Write-Host "Actualizado de $($estado.version) a $version."
        Write-Host "Para volver: powershell -ExecutionPolicy Bypass -File h5-instalar.ps1 -Revertir"
    }
    else {
        Write-Host "Instalada la version $version."
    }
    Write-Host "Carpeta: $destinoVersion"
    Write-Host "Los datos de la tienda no se tocaron."
}
finally {
    if (Test-Path $temporal) {
        Remove-Item $temporal -Recurse -Force -ErrorAction SilentlyContinue
    }
}
