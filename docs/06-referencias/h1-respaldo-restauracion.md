# H1 — Respaldo, restauración y confiabilidad local

**Estado:** implementado en rama; **CI en verde**; **PR #40 abierta**; pendiente verificación manual y merge.  
**Repositorio:** `DanielCB096/tienda`  
**Rama:** `feat/h1-respaldo-restauracion`  
**Commit:** `0ca16ef` (estado final); corrección de CI en `10fb923`; implementación en `4e89fe0`  
**Fecha:** 2026-11-23  
**Estado detallado:** `SistemaTienda/docs/estado-h1.md` en la rama  
**CI original:** <https://github.com/DanielCB096/tienda/actions/runs/45292691228>  
**CI fallido:** run `45293159856` (commit `8a4fe0c`), `CS0234` en `AjustesPage.xaml.cs`.  
**CI corregido:** <https://github.com/DanielCB096/tienda/actions/runs/45301168757> (commit `7e09cb7`), ambos jobs en verde.  
**CI final de la rama:** <https://github.com/DanielCB096/tienda/actions/runs/45302432719> (commit `0ca16ef`), ambos jobs en verde.

## Corrección de CI MAUI (`10fb923`)

- Se usa `Microsoft.Maui.Controls.Application` con alias local.
- El cierre de ventana queda dentro de `#if WINDOWS`.
- Verificación local:
  - `dotnet build SistemaTienda/SistemaTienda.Maui/SistemaTienda.Maui.csproj -f net10.0-windows10.0.19041.0 -c Release`: **0 errores**, 2 advertencias XAML preexistentes.
  - `dotnet test SistemaTienda/SistemaTienda.sln -c Release`: **373/373** en verde.
- El nuevo run de CI quedó **en verde**: “Compilar y probar” y “Compilar app MAUI (Windows y Android)” pasaron.

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
- `dotnet test SistemaTienda.sln -c Release`: **373/373** en verde.
- 5 pruebas nuevas:
  - WAL y `busy_timeout` activos.
  - Respaldo con WAL conserva datos y restaura.
  - Respaldo manual sin sesión falla.
  - Paquete de soporte sin base no incluye datos.
  - Paquete de soporte con base incluye copia consistente.

## Pendiente

- Verificación manual en Windows y Android de los botones de Ajustes.
- Restaurar en otro dispositivo.
- Probar dos instancias en Windows.
- Confirmar que el paquete de soporte no se comparte sin consentimiento.
- Confirmar los checks de la PR #40 y hacer el merge cuando la verificación manual pase.

## PR

- **PR #40:** <https://github.com/DanielCB096/tienda/pull/40>
- Abierta desde la cuenta propietaria en el navegador interno de OpenCode.
- Base `main`, head `feat/h1-respaldo-restauracion`.
- 5 commits, 17 archivos, +745/−6.
- El CI del PR se dispara al abrirla; los runs de push ya estaban en verde.
