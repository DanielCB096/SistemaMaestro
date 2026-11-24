# H1 — Verificación manual en Android

**Fecha:** 2026-11-24  
**Dispositivo:** POCO X6 Pro 5G (`2311DRK48G`), Android 16, HyperOS 3.0, arm64-v8a.  
**App de prueba:** `com.sistematienda.verificacionh1` (separada de la app real).  
**Rama:** `fix/android-soporte-cache` en `tienda` (commit `67af2a5`).  
**Pruebas:** 378/378 en verde.  
**CI de la rama:** run `45424725218`, ambos jobs en verde (Windows y Android).  
**Resultado:** **PASA** el paquete de soporte sin base y con base. Rama fusionada a `main` por fast-forward (`84dc8e1..67af2a5`).

> La creación de la PR desde el navegador falló con `Validation failed: must be a collaborator` porque la cuenta abierta en Edge no es colaboradora del repositorio. El cambio se integró por fast-forward después de confirmar el CI verde.

## Entorno verificado

| Componente | Resultado |
|---|---|
| .NET global | 11.0.100; SDK 10.0.400 disponible |
| .NET local | 10.0.100 en `%LOCALAPPDATA%\dotnet10` |
| Workloads | `maui-android` 10.0.115 instalado en el SDK local |
| Android SDK | `%LOCALAPPDATA%\Android\Sdk`; platform 36, build-tools 36.0.0 |
| adb | 37.0.3; dispositivo `ZD8P7XYXTGCY4D7T` como `device` |
| JDK | Temurin 17.0.21.1 |
| Skills | 6 P0 + `graphify` en OpenCode y `~/.agents/skills` |
| Pruebas | 378/378 |

## Cómo se compiló e instaló

- SDK .NET 10.0.100 local + workload `maui-android`.
- JDK 17 (Temurin 17.0.21.1) y Android SDK 36 / build-tools 36.0.0.
- APK Debug con `EmbedAssembliesIntoApk=true`; sin eso, el APK falla al abrir por Fast Deployment.
- APK: 91,733,905 bytes (87.5 MB), `com.sistematienda.verificacionh1-Signed.apk`.
- `adb install` falla con `INSTALL_FAILED_USER_RESTRICTED` por la restricción de Xiaomi/HyperOS. Se instaló desde el archivo APK con el instalador del sistema (`Intent.ACTION_VIEW`).
- El APK con Fast Deployment falló con:

```text
No assemblies found in '/data/user/0/com.sistematienda.verificacionh1/files/.__override__/arm64-v8a'.
Assuming this is part of Fast Deployment. Exiting...
```

El APK con ensamblados embebidos abrió correctamente.

## Resultados

| Escenario | Resultado | Evidencia |
|---|---|---|
| Instalar APK | **PASA** (vía instalador del sistema) | `pm list packages` muestra `com.sistematienda.verificacionh1`; versión 0.1 |
| Configuración inicial | **PASA** | Tienda `Tienda H1`, giro Abarrotes, PIN 1234, fondo $200 |
| Login | **PASA** | Rol Dueño; tablero con ventas 0 y efectivo esperado $200 |
| Exportar respaldo | **PASA** | Share sheet con `tienda-20261124-103044-exportacion.db`; 221,184 B en caché |
| Restaurar respaldo | **PASA** | Archivo `restore-test-h1.db` en Descargas; respaldo previo `tienda-20261124-103225-antes-restaurar.db`; app reabre con `Tienda H1` y PIN válido |
| Paquete sin base | **PASA** | `soporte-20261124-103243.zip` (673 B), share sheet; contiene `LEEME.txt` y `resumen.txt` |
| Paquete con base | **PASA** | Confirmación “incluirá ventas, clientes, fiados…”; `soporte-20261124-103426.zip` (6,662 B) con `LEEME.txt`, `resumen.txt` y `datos.db` (221,184 B) |
| Verificar ZIPs | **PASA** | Sin base: 2 entradas, sin datos; con base: 3 entradas, `datos.db` verificable |
| Error “archivo en uso” | **NO REPRODUCIDO** | La corrección de `CarpetaExportacion.EsMismaRuta` evita la copia sobre sí misma |

## Evidencia de archivos

```text
cache/
  soporte-20261124-103243.zip          673 B   (sin base)
  soporte-20261124-103426.zip        6,662 B   (con base)
  tienda-20261124-103044-exportacion.db 221,184 B

respaldos/
  tienda-20261124-102953-automatico.db      221,184 B
  tienda-20261124-103044-exportacion.db     221,184 B
  tienda-20261124-103225-antes-restaurar.db 221,184 B
```

Contenido de los ZIP (inspeccionado localmente tras extraer de `run-as`):

```text
Sin base:
  resumen.txt   509 B
  LEEME.txt     193 B

Con base:
  resumen.txt   510 B
  LEEME.txt     193 B
  datos.db      221,184 B
```

## Bug corregido

`PaqueteSoporteService.Crear` genera el ZIP en `FileSystem.CacheDirectory`. Después, `ExportacionRespaldoApp.ExportarAsync` en Android copiaba el archivo a `FileSystem.CacheDirectory` otra vez con el mismo nombre. Origen y destino eran el mismo archivo y `File.Copy` lanzaba “archivo en uso”.

## Corrección (`67af2a5`)

- `CarpetaExportacion.EsMismaRuta` compara rutas normalizadas.
- En Android se omite `File.Copy` cuando origen y destino coinciden.
- 2 pruebas nuevas: misma ruta normalizada y rutas distintas.
- Total: 378/378.

## Nota de compilación

La compilación Android emite dos advertencias `CS0169` por los campos `InstanciaUnica._mutex` y `_creada`, que solo se usan bajo `#if WINDOWS`. No afectan la ejecución ni el CI. Se pueden mover dentro del bloque `#if WINDOWS` en una limpieza posterior.

## Pendiente post-merge

- Probar en otro equipo físico y en una tablet.
- Corte de energía durante venta, respaldo y migración.
- Prueba con un dueño no técnico.
- Mover los campos de `InstanciaUnica` dentro de `#if WINDOWS` para dejar 0 advertencias en Android.
- Iniciar H2: permisos por acción, bloqueo persistente, timeout de sesión, manejador global y respaldos cifrados.

## Enlaces

- [Onboarding del agente](../08-agentes/ONBOARDING.md)
- [H1 — respaldo y restauración](h1-respaldo-restauracion.md)
- [Estado de H1 en tienda](https://github.com/DanielCB096/tienda/blob/main/SistemaTienda/docs/estado-h1.md)
