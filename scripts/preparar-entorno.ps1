# Prepara el entorno mínimo para trabajar en SistemaMaestro.
# Uso: powershell -ExecutionPolicy Bypass -File scripts\preparar-entorno.ps1

$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $PSScriptRoot
$origenSkills = Join-Path $repo "docs\08-agentes\skills"

Write-Host "== Skills ==" -ForegroundColor Cyan
if (-not (Test-Path $origenSkills)) {
    throw "No se encontró $origenSkills"
}

foreach ($base in @(
    (Join-Path $env:USERPROFILE ".config\opencode\skills"),
    (Join-Path $env:USERPROFILE ".agents\skills")
)) {
    New-Item -ItemType Directory -Force $base | Out-Null
    Get-ChildItem $origenSkills -Directory | ForEach-Object {
        Copy-Item $_.FullName (Join-Path $base $_.Name) -Recurse -Force
    }
    Write-Host "  Copiadas a $base"
}

$graphify = Get-Command graphify -ErrorAction SilentlyContinue
if ($graphify) {
    Write-Host "== Graphify ==" -ForegroundColor Cyan
    graphify install --platform opencode
    graphify install --platform agents
} else {
    Write-Warning "graphify no está instalado. Instálalo con: pip install graphifyy"
}

Write-Host "== .NET ==" -ForegroundColor Cyan
$dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnet) {
    Write-Host "  dotnet: $((& dotnet --version) 2>$null)"
    & dotnet workload list
} else {
    Write-Warning "dotnet no está en PATH"
}

$localSdk = Join-Path $env:LOCALAPPDATA "dotnet10\dotnet.exe"
if (Test-Path $localSdk) {
    Write-Host "  SDK local para Android: $localSdk"
} else {
    Write-Warning @"
No hay SDK local para Android. El SDK global puede fallar al instalar maui-android.
Crea uno con:
  Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile `"$env:TEMP\dotnet-install.ps1`"
  powershell -ExecutionPolicy Bypass -File `"$env:TEMP\dotnet-install.ps1`" -Channel 10.0 -Version 10.0.100 -InstallDir `"$env:LOCALAPPDATA\dotnet10`"
"@
}

Write-Host "== Android ==" -ForegroundColor Cyan
$androidHome = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$adb = Join-Path $androidHome "platform-tools\adb.exe"
if (Test-Path $adb) {
    Write-Host "  Android SDK: $androidHome"
    & $adb version | Select-Object -First 2
    & $adb devices -l
    if (-not (& $adb devices | Select-String "device$")) {
        Write-Warning "No hay dispositivo autorizado. Activa Depuración USB y acepta la huella."
    }
} else {
    Write-Warning "adb no encontrado en $adb. Instala Android SDK Platform-Tools."
}

$java = Get-Command java -ErrorAction SilentlyContinue
if ($java) {
    Write-Host "  Java: $($java.Source)"
} else {
    Write-Warning "java no está en PATH. Configura JAVA_HOME con un JDK 17."
}

Write-Host ""
Write-Host "Siguiente: lee docs/08-agentes/ONBOARDING.md y revisa el estado en docs/06-referencias/h1-android.md" -ForegroundColor Green
