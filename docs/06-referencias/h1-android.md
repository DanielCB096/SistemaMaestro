# H1 — Verificación manual en Android

**Fecha:** 2026-11-24  
**Dispositivo:** POCO X6 Pro 5G (`2311DRK48G`), Android 16, HyperOS 3.0, arm64-v8a.  
**App de prueba:** `com.sistematienda.verificacionh1` (separada de la app real).  
**Rama:** `fix/android-soporte-cache` en `tienda` (commit `67af2a5`).  
**Pruebas:** 378/378 en verde.  
**CI de la rama:** run `45424725218`, ambos jobs en verde (Windows y Android).

## Cómo se compiló e instaló

- SDK .NET 10.0.100 local + workload `maui-android`.
- APK Debug con `EmbedAssembliesIntoApk=true`; sin eso, el APK falla al abrir por Fast Deployment.
- `adb install` falla con `INSTALL_FAILED_USER_RESTRICTED` por la restricción de Xiaomi/HyperOS. Se instaló desde el archivo APK con el instalador del sistema.
- El APK con Fast Deployment falló con:

```text
No assemblies found in '/data/user/0/com.sistematienda.verificacionh1/files/.__override__/arm64-v8a'.
Assuming this is part of Fast Deployment. Exiting...
```

El APK con ensamblados embebidos abrió correctamente.

## Resultados

| Escenario | Resultado | Evidencia |
|---|---|---|
| Instalar APK | **PASA** (vía instalador del sistema) | `pm list packages` muestra `com.sistematienda.verificacionh1` |
| Configuración inicial | **PASA** | Tienda `Abarrotes Android H1`, PIN 1234 |
| Login | **PASA** | Rol Dueño, fondo $200 |
| Exportar respaldo | **PASA** | Share sheet con `tienda-20261124-090919-exportacion.db`; 221,184 B en caché |
| Restaurar respaldo | **PASA** | Respaldo previo `tienda-20261124-091237-antes-restaurar.db`; app reabre con configuración y usuario |
| Paquete sin base | **FALLA** | `The process cannot access the file ... because it is being used by another process` |
| Paquete con base | **PENDIENTE** | Depende de la corrección |

## Bug encontrado

`PaqueteSoporteService.Crear` genera el ZIP en `FileSystem.CacheDirectory`. Después, `ExportacionRespaldoApp.ExportarAsync` en Android copia el archivo a `FileSystem.CacheDirectory` otra vez con el mismo nombre. Origen y destino son el mismo archivo, y `File.Copy` lanza “archivo en uso”.

## Corrección (`67af2a5`)

- `CarpetaExportacion.EsMismaRuta` compara rutas normalizadas.
- En Android se omite `File.Copy` cuando origen y destino coinciden.
- 2 pruebas nuevas: misma ruta normalizada y rutas distintas.
- Total: 378/378.

## Cómo retestar

1. Compila el APK de `fix/android-soporte-cache` con `EmbedAssembliesIntoApk=true`.
2. Instala la actualización en el teléfono.
3. Abre Ajustes → Exportar paquete de soporte sin base.
4. Repite con “Incluir la base de datos” activado y confirma.
5. Verifica los ZIP:

```powershell
$adb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
& $adb shell run-as com.sistematienda.verificacionh1 ls -la cache
```

- Sin base: `LEEME.txt` y `resumen.txt`.
- Con base: además `datos.db`.

## Pendiente

- Retestar ambos paquetes con el dispositivo conectado.
- Probar el paquete con base y confirmar que `datos.db` contiene los datos.
- Abrir PR de `fix/android-soporte-cache` y mergear con CI verde.
- Después: otro equipo físico, corte de energía y prueba con dueño no técnico.

## Enlaces

- [Onboarding del agente](../08-agentes/ONBOARDING.md)
- [H1 — respaldo y restauración](h1-respaldo-restauracion.md)
- [Estado de H1 en tienda](https://github.com/DanielCB096/tienda/blob/main/SistemaTienda/docs/estado-h1.md)
