# H1 — Respaldo, restauración y confiabilidad local

**Estado:** implementado; **CI en verde**; **PR #40 abierta**; verificación manual de Windows aprobada en su núcleo, pendiente Android, otro equipo y corte de energía.  
**Repositorio:** `DanielCB096/tienda`  
**Rama:** `feat/h1-respaldo-restauracion`  
**Commit:** `7c7c9a6` (documentación); verificación en `f748af8`; corrección de exportación en `546900f`; corrección de CI en `10fb923`; implementación en `4e89fe0`  
**Fecha:** 2026-11-23  
**Estado detallado:** `SistemaTienda/docs/estado-h1.md` en la rama  
**Ronda de verificación:** [2026-11-23-verificacion-h1](../05-colaboracion-ia/rondas/2026-11-23-verificacion-h1.md)  
**CI original:** <https://github.com/DanielCB096/tienda/actions/runs/45292691228>  
**CI fallido:** run `45293159856` (commit `8a4fe0c`), `CS0234` en `AjustesPage.xaml.cs`.  
**CI corregido:** <https://github.com/DanielCB096/tienda/actions/runs/45301168757> (commit `7e09cb7`), ambos jobs en verde.  
**CI final de código:** <https://github.com/DanielCB096/tienda/actions/runs/45320190550> (commit `f748af8`), ambos jobs en verde.

## Corrección de CI MAUI (`10fb923`)

- Se usa `Microsoft.Maui.Controls.Application` con alias local.
- El cierre de ventana queda dentro de `#if WINDOWS`.
- Verificación local:
  - `dotnet build SistemaTienda/SistemaTienda.Maui/SistemaTienda.Maui.csproj -f net10.0-windows10.0.19041.0 -c Release`: **0 errores**, 2 advertencias XAML preexistentes.
  - `dotnet test SistemaTienda/SistemaTienda.sln -c Release`: **376/376** en verde.
- El nuevo run de CI quedó **en verde**: “Compilar y probar” y “Compilar app MAUI (Windows y Android)” pasaron.
- El CI de `f748af8` quedó **en verde** en el run `45320190550`; `7c7c9a6` es solo documentación.

## Alcance implementado

- Respaldo exportable fuera del almacenamiento privado:
  - Windows: copia a `Documentos\SistemaTienda` y abre la carpeta.
  - Android: diálogo de compartir del sistema.
- Restauración desde Ajustes con confirmación, respaldo previo y cierre de la ventana en Windows.
- Paquete de soporte: `resumen.txt`, `LEEME.txt` y base de datos opcional.
- SQLite en modo WAL.
- `busy_timeout=30000` y `synchronous=NORMAL` en cada conexión.
- Instancia única en Windows para evitar dos procesos sobre la misma base.
- Conexiones de respaldo sin pooling para poder mover el archivo verificado.
- Permisos: exportar, restaurar y paquete de soporte visibles solo para el dueño; restauración valida `Configurar` en el servicio.

## Archivos principales

- `SistemaTienda.Infrastructure/Database.cs`
- `SistemaTienda.Infrastructure/RespaldoLocal.cs`
- `SistemaTienda.Application/Services/RespaldoService.cs`
- `SistemaTienda.Application/Services/PaqueteSoporteService.cs`
- `SistemaTienda.Maui/MauiProgram.cs`
- `SistemaTienda.Maui/App.xaml.cs`
- `SistemaTienda.Maui/Services/ExportacionRespaldoApp.cs`
- `SistemaTienda.Maui/Services/InstanciaUnica.cs`
- `SistemaTienda.Maui/Pages/AjustesPage.xaml(.cs)`
- `SistemaTienda.Maui/Pages/InstanciaDuplicadaPage.cs`
- `SistemaTienda.Tests/RespaldoWalTests.cs`

## Pruebas

- `dotnet build SistemaTienda.sln -c Release`: correcto, 0 errores, 0 advertencias.
- `dotnet test SistemaTienda.sln -c Release`: **376/376** en verde.
- 8 pruebas nuevas:
  - WAL y `busy_timeout` activos.
  - Respaldo con WAL conserva datos y restaura.
  - Respaldo manual sin sesión falla.
  - Paquete de soporte sin base no incluye datos.
  - Paquete de soporte con base incluye copia consistente.
  - Carpeta de exportación usa la primera carpeta escribible.
  - Carpeta de exportación salta una ruta que no es carpeta.
  - Carpeta de exportación falla si ninguna ruta sirve.

## Fallback de exportación (`546900f`)

En este equipo `C:\Users\PC\Documents` no permite crear archivos: `Directory.CreateDirectory` y `File.Copy` fallan con `FileNotFoundException` aunque el ACL muestre control total. Es un problema de la carpeta conocida, no de SQLite.

- `CarpetaExportacion` prueba en orden: `Documentos\SistemaTienda` → `Escritorio\SistemaTienda` → `Descargas\SistemaTienda`.
- Elige la primera donde puede crear y borrar un archivo de prueba.
- La app informa la ruta final en el diálogo.
- Se agregaron 3 pruebas.

## Verificación manual Windows (2026-11-23)

| Escenario | Resultado |
|---|---|
| W1 Exportar respaldo | **PASA** con fallback a Escritorio |
| W2 Restaurar | **PASA**; producto, usuario y configuración conservados |
| W3 Respaldo previo | **PASA**; `tienda-...-antes-restaurar.db` |
| W4 Archivo corrupto | **PASA**; rechazado sin tocar la base |
| W5 Dos instancias | **PASA**; la segunda muestra “SistemaTienda ya está abierto” |
| W8 Paquete sin base | **PASA**; sin `datos.db` |
| W8 Paquete con base | **PASA**; con consentimiento y `datos.db` |
| W6/W7 Corte de energía | **PENDIENTE** |
| W9 Venta + respaldo | **PENDIENTE** |
| W10 Dueño no técnico | **PENDIENTE** |
| Android A1–A3 | **PENDIENTE** (sin dispositivo/emulador) |
| Otro equipo físico | **PENDIENTE** |

## Pendiente

- Probar Android: exportar por compartir, restaurar y abrir.
- Restaurar en otro equipo físico.
- Simular corte de energía en venta y en respaldo.
- Probar el ciclo con un dueño no técnico, sin ayuda verbal.
- Confirmar el CI de `546900f`/`f748af8` y hacer el merge de la PR #40.

## PR

- **PR #40:** <https://github.com/DanielCB096/tienda/pull/40>
- Abierta desde la cuenta propietaria en el navegador interno de OpenCode.
- Base `main`, head `feat/h1-respaldo-restauracion`.
- El CI del PR se dispara al abrirla; los runs de push ya estaban en verde.
