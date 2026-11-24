# Onboarding del agente

**Objetivo:** que cualquier agente que empiece en otro dispositivo tenga las mismas skills, herramientas y contexto antes de tocar código.

## 1. Repositorios y ramas

```powershell
git clone https://github.com/DanielCB096/SistemaMaestro.git
git clone https://github.com/DanielCB096/tienda.git

cd tienda
git fetch origin
git switch main
git pull
```

Para la corrección pendiente de Android:

```powershell
git switch fix/android-soporte-cache
git pull
```

## 2. Skills (obligatorio)

Desde `SistemaMaestro`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\preparar-entorno.ps1
```

El script copia las 6 skills P0 a:

- `%USERPROFILE%\.config\opencode\skills\`
- `%USERPROFILE%\.agents\skills\`

Skills que deben aparecer:

1. `protocolo-de-cambio`
2. `sqlite-local`
3. `dinero-y-reglas-caja`
4. `testing-dotnet`
5. `seguridad-permisos`
6. `backup-recovery`

Instalación manual, si el script falla:

```powershell
$destino = Join-Path $env:USERPROFILE ".config\opencode\skills"
New-Item -ItemType Directory -Force $destino | Out-Null
Get-ChildItem "docs\08-agentes\skills" -Directory | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $destino $_.Name) -Recurse -Force
}
```

Repite con `%USERPROFILE%\.agents\skills`.

## 3. Graphify

```powershell
graphify install --platform opencode
graphify install --platform agents
```

Genera el grafo del código de `tienda`:

```powershell
cd tienda
graphify extract . --code-only
```

- El grafo vive en `tienda/graphify-out/` y **no se versiona**.
- Si no existe `graphify`, instálalo con `pip install graphifyy`.
- No ejecutes el grafo semántico de documentos con Ollama salvo que se pida; consume tiempo.

## 4. Herramientas de .NET

Verifica:

```powershell
dotnet --version
dotnet workload list
```

Requisitos:

- .NET SDK 10.
- Workload `maui-windows` para compilar la app de Windows.
- Workload `maui-android` para compilar Android.

### Problema conocido: `maui-android` en el SDK global

En este equipo, `dotnet workload install maui-android` falla con:

```text
No se pudo instalar la carga de trabajo: Object reference not set to an instance of an object.
```

Solución usada: instalar un SDK .NET 10.0.100 **local** y ahí instalar el workload.

```powershell
$dir = Join-Path $env:LOCALAPPDATA "dotnet10"
$script = Join-Path $env:TEMP "dotnet-install.ps1"
Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -OutFile $script -UseBasicParsing
powershell -NoProfile -ExecutionPolicy Bypass -File $script -Channel 10.0 -Version 10.0.100 -InstallDir $dir
```

Crea un `global.json` temporal en la raíz de `tienda` (no lo commitees):

```json
{
  "sdk": {
    "version": "10.0.100",
    "rollForward": "disable"
  }
}
```

Instala el workload en el SDK local:

```powershell
$dir = Join-Path $env:LOCALAPPDATA "dotnet10"
$env:DOTNET_ROOT = $dir
$env:DOTNET_MULTILEVEL_LOOKUP = "0"
& "$dir\dotnet.exe" workload install maui-android
```

## 5. Android SDK y Java

Rutas usadas en este equipo (ajusta en el otro):

```text
Android SDK: C:\Users\PC\AppData\Local\Android\Sdk
adb:         C:\Users\PC\AppData\Local\Android\Sdk\platform-tools\adb.exe
JDK 17:      C:\Program Files\Microsoft\jdk-17.0.21.102-hotspot
```

Verifica:

```powershell
$env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.21.102-hotspot"

& "$env:ANDROID_HOME\platform-tools\adb.exe" devices -l
java -version
```

Requisitos del dispositivo:

- Depuración USB activada.
- “Instalar vía USB” activado (Xiaomi/HyperOS).
- Aceptar la huella de la PC.
- Si `adb install` falla con `INSTALL_FAILED_USER_RESTRICTED`, instala el APK desde el archivo con el instalador del sistema.

## 6. Compilar y probar

### Pruebas

```powershell
cd tienda
$dir = Join-Path $env:LOCALAPPDATA "dotnet10"
$env:DOTNET_ROOT = $dir
$env:DOTNET_MULTILEVEL_LOOKUP = "0"
& "$dir\dotnet.exe" test SistemaTienda\SistemaTienda.sln -c Release
```

Esperado: **378/378**.

### Windows

```powershell
dotnet build SistemaTienda\SistemaTienda.Maui\SistemaTienda.Maui.csproj `
  -f net10.0-windows10.0.19041.0 -c Release
```

### Android (APK de prueba)

```powershell
$dir = Join-Path $env:LOCALAPPDATA "dotnet10"
$env:DOTNET_ROOT = $dir
$env:DOTNET_MULTILEVEL_LOOKUP = "0"
$env:ANDROID_HOME = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.21.102-hotspot"

& "$dir\dotnet.exe" build SistemaTienda\SistemaTienda.Maui\SistemaTienda.Maui.csproj `
  -f net10.0-android -c Debug -t:Rebuild `
  -p:ApplicationId=com.sistematienda.verificacionh1 `
  -p:EmbedAssembliesIntoApk=true `
  -p:AndroidSdkDirectory="$env:ANDROID_HOME" `
  -p:JavaSdkDirectory="$env:JAVA_HOME"
```

APK:

```text
SistemaTienda\SistemaTienda.Maui\bin\Debug\net10.0-android\com.sistematienda.verificacionh1-Signed.apk
```

**Importante:** sin `EmbedAssembliesIntoApk=true`, el APK Debug falla al abrir con:

```text
No assemblies found in '.../.__override__/arm64-v8a'. Assuming this is part of Fast Deployment.
```

### Instalar en el teléfono

```powershell
$adb = Join-Path $env:ANDROID_HOME "platform-tools\adb.exe"
$apk = "SistemaTienda\SistemaTienda.Maui\bin\Debug\net10.0-android\com.sistematienda.verificacionh1-Signed.apk"

& $adb push $apk /sdcard/Download/verificacionh1.apk
& $adb shell am start -a android.intent.action.VIEW `
  -d "file:///sdcard/Download/verificacionh1.apk" `
  -t "application/vnd.android.package-archive"
```

En el teléfono: elige **Instalar** y confirma. Si pide Play Protect, rechaza la activación.

## 7. Verificación Android pendiente

La rama `fix/android-soporte-cache` corrige el paquete de soporte que se copiaba sobre sí mismo en caché.

1. Compila el APK con el comando anterior.
2. Instala la actualización.
3. Abre la app, configura tienda y PIN si es instalación nueva.
4. Ajustes → Exportar respaldo → comprobar share sheet.
5. Restaurar desde un archivo en Descargas.
6. Paquete de soporte **sin base** → debe crear el ZIP y abrir share sheet sin error.
7. Paquete de soporte **con base** → debe pedir confirmación e incluir `datos.db`.
8. Revisa el ZIP con:

   ```powershell
   & $adb exec-out run-as com.sistematienda.verificacionh1 ls -la cache
   ```

## 8. Checklist de inicio

- [ ] Repos clonados y `main` actualizado.
- [ ] `scripts\preparar-entorno.ps1` ejecutado.
- [ ] 6 skills P0 + graphify visibles en OpenCode.
- [ ] `dotnet test` en 378/378.
- [ ] `adb devices -l` muestra el teléfono como `device`.
- [ ] `AGENTS.md` leído.
- [ ] Estado de H1 y Android leído.
- [ ] Rama de trabajo creada antes de tocar código.

## 9. Enlaces

- [Catálogo de skills](catalogo-skills.md)
- [Roles](roles.md)
- [H1 — respaldo y restauración](../06-referencias/h1-respaldo-restauracion.md)
- [H1 — verificación Android](../06-referencias/h1-android.md)
- [Protocolo de colaboración](../05-colaboracion-ia/protocolo.md)
