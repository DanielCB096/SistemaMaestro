# Changelog

## 2026-11-25 — H4.2: bitácora atómica

- La bitácora de venta, anulación, abono, gasto, movimiento de caja, corte, compra y pago se escribe en la misma transacción que la operación ([ADR-007](docs/07-decisiones/ADR-007-bitacora-transaccion.md)).
- Si la bitácora falla, la operación se revierte: no quedan movimientos de dinero sin auditoría.
- Pendiente: inventario, altas/ediciones, usuarios y respaldos.

## 2026-11-25 — H4.1: caja y reportes caracterizados

- 5 pruebas de caracterización de caja y reportes con un escenario completo (ventas efectivo/tarjeta/mixto/fiado, abono, ingreso, retiro y gastos).
- Bug corregido: un gasto de caja pagado con tarjeta reducía el efectivo esperado. Ahora caja exige efectivo y el corte filtra por método ([ADR-006](docs/07-decisiones/ADR-006-gasto-caja-efectivo.md)).
- La venta mixta no se duplica en el reporte: 240 + 260 + 200 = 700.
- 435 pruebas en total. CI en verde (run `45666381652`) y fusionada a `main` (`95fea70`).
- Pendiente de H4: bitácora dentro de la transacción.

## 2026-11-25 — H3: caracterización del inventario

- 6 pruebas de caracterización: tras alta, entrada, merma, ajuste, venta, anulación y compra, el stock coincide con el log de movimientos.
- `ProductosDescuadrados()` para diagnóstico y línea en el paquete de soporte.
- Esquema v17: reconciliación de `Productos.Stock` con los movimientos.
- Decisión en [ADR-005](docs/07-decisiones/ADR-005-stock-movimientos.md): el log es la verdad; la caché se actualiza en la misma transacción.
- 430 pruebas en total. CI en verde (run `45660429181`) y fusionada a `main` (`2d58b70`).

## 2026-11-25 — Cierre H2.3b y verificación Android

- El asistente inicial ofrece activar el cifrado con tarjeta de recuperación; el paquete de soporte se cifra con la misma clave.
- **Android verificado** en POCO X6 Pro 5G (Android 16): el asistente generó la clave, el respaldo automático y el manual se guardaron como `.db.stb`, la clave sobrevivió al reinicio (Keystore) y la restauración cifrada creó `antes-restaurar`.
- 2 pruebas nuevas (424 en total). CI en verde (run `45652514886`) y fusionada a `main` (`9f7fe92`).
- Pendiente: restaurar en otro equipo con la tarjeta, prueba de restauración guiada en el asistente y bloqueo en Android.

## 2026-11-24 — H2.3: respaldos cifrados

- Clave de respaldo de 120 bits en DPAPI/SecureStorage y tarjeta de recuperación; AES-256-GCM + PBKDF2-SHA256 (600k).
- Los respaldos nuevos (manuales y automáticos) se cifran como `.db.stb`; restaurar pide la clave y no toca la base si falla.
- Los respaldos viejos sin cifrar se pueden restaurar con aviso.
- Esquema v16 (`RespaldoCifradoActivado`); 14 pruebas nuevas (422 en total). CI en verde (run `45512214039`) y fusionada a `main` (`dc7b80c`).
- Pendiente H2.3b: activación guiada en el asistente, cifrar el paquete de soporte y verificar en Android.

## 2026-11-24 — H2.2: bloqueo de sesión y errores

- Esquema v15 en `tienda`: `ConfiguracionTienda.MinutosInactividad` (2–15, por defecto 5) y `EstadoAcceso` para el bloqueo del login.
- **5 intentos fallidos bloquean el acceso 3 minutos**, con estado persistido en SQLite y bitácora de cada fallo.
- **Bloqueo por inactividad:** modal que conserva el carrito, se desbloquea con PIN y permite cambiar de usuario.
- **Manejador global de errores** con registro en `logs/errores.log`.
- 5 pruebas nuevas (408 en total). CI en verde (run `45501565476`) y fusionada a `main` (`06a7c11`).

## 2026-11-24 — H2.1: permisos por acción

- Se implementa la matriz del [ADR-003](docs/07-decisiones/ADR-003-permisos-accion.md) en `tienda`, rama `feat/h2-permisos-accion`.
- `AgregarClienteFiado` y `AgregarProveedor` ahora exigen permiso; se cierra el hueco que permitía a un empleado crear registros llamando al servicio.
- `VerCostos` es por usuario: el dueño lo concede a un encargado desde **Ajustes → Usuarios y PIN**. Sin él, el encargado no ve costos, utilidad ni la pestaña Reportes.
- Exportar CSV/PDF exige `ExportarDatos`; los reportes con costo exigen además `VerCostos`.
- Las pestañas se arman por permiso: el empleado solo ve Inicio, Vender, Inventario, Ventas y Ajustes.
- 13 pruebas nuevas (matriz y manifiesto de métodos públicos); 403 en total. CI en verde (run `45496679264`) y fusionada a `main` (`881bfc8`).

## 2026-11-24 — QR del ticket legible (P7)

- Se corrige el QR en `tienda`, rama `fix/ticket-qr-escaneo` (`28f66e4`): ya no incluye productos, baja de 89×89 a 49×49 módulos y se muestra como imagen de 240 dp.
- Evidencia: el PNG y una captura de pantalla (258×258 px) se decodificaron con `pyzbar` y devolvieron tienda, folio, fecha, total y método.
- Pruebas: 390 en verde; dos pruebas nuevas impiden que el QR vuelva a crecer. CI en verde (run `45479446077`) y fusionada a `main` (`28f66e4`).
- **Validado** el 2026-11-24: un teléfono real escaneó el QR desde la pantalla maximizada y devolvió el resumen esperado. P7 cerrado.
- Pendiente: escaneo con la cámara de un teléfono físico.

## 2026-11-24 — Búsqueda dinámica en el POS (P8)

- Se cierra **P8** en `tienda`, rama `feat/pos-busqueda-dinamica` (`c57fef0`): el buscador de **Vender** sugiere productos desde dos caracteres, con espera de 250 ms y hasta ocho coincidencias.
- `InventoryService.SugerirProductos` ordena por código exacto, prefijo de código, prefijo de nombre, inicio de palabra y coincidencia interna; ignora acentos y mayúsculas.
- Al agregar desde la lista se limpia el buscador; si el producto no tiene stock, la lista y el texto se conservan. El escaneo por código y Enter siguen igual.
- Verificado en Windows: sugerencias al escribir, orden por prefijo, escaneo de código, rechazo de stock 0 y lista de Enter. 7 pruebas nuevas; 389 en total. Android compila sin advertencias. CI verde (run `45471273678`) y fusionada a `main` (`c57fef0`).

## 2026-11-24 — P3, ruta de respaldo accionable y datos de prueba
- Se completa **P3** (prueba con dueño no técnico) en la app de Windows aislada `com.sistematienda.p3`. Resultado positivo: flujo entendido y recomendado; hallazgos en `docs/09-pendientes/p3-resultados-2026-11-24.md`.
- Se cierra **P6** en `tienda`, rama `fix/p3-respaldo-ruta` (`53a35fe`, fusionada en `main` `290cde6`): copiar ruta de respaldos, abrir la carpeta, lista de respaldos recientes con restauración directa y aviso con **Abrir carpeta** al exportar. Verificado en Windows, incluida la restauración desde la lista con `antes-restaurar`. CI de `main` en verde (run `45463281513`).
- Se agrega `SistemaTienda.Semilla` en `tienda` (`d0e3c53`, merge `290cde6`): escenarios `limpio`, `configurado` y `demo`, con seguridad para no tocar la app real ni sobrescribir sin `--reset`. 4 pruebas nuevas; 382 en total. CI verde (run `45464387127`).
- `scripts/p3-preparar.ps1` acepta `-Semilla` y usa la base limpia por defecto, porque el asistente de primera vez solo se valida desde cero.
- Android local: el JDK 17 vigente está en `%LOCALAPPDATA%\jdk17`; `JAVA_HOME` y `ANDROID_HOME` deben exportarse en cada sesión.

## 2026-11-24 — Verificación Android y onboarding

- Se verifica H1 en un POCO X6 Pro 5G (Android 16 / HyperOS 3.0):
  - Exportar respaldo: **pasa** (share sheet + archivo en caché).
  - Restaurar respaldo: **pasa** (respaldo previo y datos conservados).
  - Paquete de soporte: **falla** porque el ZIP se copia sobre sí mismo en caché.
- Corrección en `tienda`, rama `fix/android-soporte-cache` (`67af2a5`): `CarpetaExportacion.EsMismaRuta` evita la autocopia. 378/378 pruebas. CI en verde en el run `45424725218`.
- Se documenta la compilación Android con SDK .NET 10.0.100 local, `maui-android`, APK con ensamblados embebidos y la restricción de instalación de Xiaomi.
- Se crea `AGENTS.md` y `docs/08-agentes/ONBOARDING.md` con el checklist obligatorio para cualquier agente que continúe desde otro dispositivo.
- Se añade `scripts/preparar-entorno.ps1` para copiar skills, instalar graphify y verificar .NET, Android SDK, Java y adb.
- Se añade `docs/06-referencias/h1-android.md` con resultados y pasos de retest.

## 2026-11-23 — Verificación manual de H1

- Se consulta a ChatGPT, Claude y Gemini el criterio de aceptación manual de H1; respuestas en `docs/05-colaboracion-ia/rondas/2026-11-23-verificacion-h1/`.
- Se ejecuta la verificación manual en Windows con una base aislada: exportar, restaurar, respaldo previo, archivo corrupto, dos instancias y paquete de soporte sin/con base.
- Hallazgo: `C:\Users\PC\Documents` no permite crear archivos en este equipo; la exportación fallaba con `FileNotFoundException`.
- Corrección en `tienda` (`546900f`): `CarpetaExportacion` elige la primera carpeta escribible (Documentos → Escritorio → Descargas) y se agregan 3 pruebas. Total: **376/376**.
- CI de `f748af8` en verde en el run `45320190550` (Windows y Android); la PR #40 queda lista para decisión de merge.
- **H1 mergeado a `main`:** PR #40, merge commit `41c5983`; documentación del merge en `84dc8e1`. Deuda post-merge: Android, otro equipo, corte de energía y dueño no técnico.
- La verificación manual de Windows pasa en su núcleo; quedan pendientes Android, otro equipo físico, corte de energía y prueba con un dueño no técnico.
- Se actualizan el estado de H1, la skill `backup-recovery` y la PR #40.

## 2026-11-23 — Skills de los agentes y graphify

- Se consulta a ChatGPT, Claude y Gemini sobre el catálogo de skills para los agentes que trabajan el código; se guardan las respuestas completas en `docs/05-colaboracion-ia/rondas/2026-11-23-skills/`.
- Se consolida el catálogo en `docs/08-agentes/catalogo-skills.md`: 6 skills P0, 4 P1 de ejecución, 2 documentos de contexto y 1 herramienta.
- Se crean las 6 skills P0 en `docs/08-agentes/skills/`: `protocolo-de-cambio`, `sqlite-local`, `dinero-y-reglas-caja`, `testing-dotnet`, `seguridad-permisos` y `backup-recovery`.
- Se agrega `ADR-002 — Catálogo de skills` en estado propuesto.
- Se instala `graphify` en OpenCode y se genera el grafo AST de `tienda` (2,531 nodos, 8,160 aristas, 124 comunidades).
- Se documenta que las sesiones web de ChatGPT, Claude y Gemini no cargan skills locales; usan el catálogo como contexto.
- Se corrige el estado de H1: el job de pruebas pasó, pero el job MAUI falló en “Compilar para Windows” (run `45293159856`); la rama sigue sin fusionar y sin PR.
- Se corrige el fallo de compilación MAUI de H1 en `10fb923`: `Application.Current` ambiguo con `SistemaTienda.Application`; verificado en local con Windows y 373/373 pruebas. CI confirmado en verde en los runs `45301168757`, `45301104936` y `45302432719` (Windows y Android).
- Se abre la PR #40 de H1: <https://github.com/DanielCB096/tienda/pull/40>. Queda pendiente la verificación manual y el merge.

## 2026-11-23 — Documentación inicial

- Se crea el repositorio de diseño `SistemaMaestro`.
- Se añade el informe técnico comparativo de `tienda` y `gym-dotnet`.
- Se añade el plan maestro v2 con decisiones, producto, roadmap de 90 días y riesgos.
- Se añaden el Decision Brief v1 y el ADR-001 propuesto.
- Se documentan el modelo de documentos/pagos/caja, hardware, actualizaciones y CFDI.
- Se documenta el protocolo de colaboración con IA y la ronda del 2026-11-23.
- Se añade la política de cuotas: si un plan gratuito se agota, se espera al restablecimiento.
- ChatGPT, Claude y Gemini aprueban la ruta incremental y autorizan H1; precios y piloto quedan condicionados a validación real.
- H1 implementado en `tienda` (`feat/h1-respaldo-restauracion`, implementación `4e89fe0`, estado `8a4fe0c`): respaldo exportable, restauración, paquete de soporte, WAL, `busy_timeout` e instancia única. 373 pruebas en verde; job de pruebas en CI aprobado; job MAUI en progreso al apagar el equipo. Ver `SistemaTienda/docs/estado-h1.md` en la rama.
- **Verificación Android completada (2026-11-24):** exportar respaldo, restaurar, paquete sin base y paquete con base pasan en POCO X6 Pro 5G / Android 16. Corrección `fix/android-soporte-cache` (`67af2a5`, 378/378 pruebas, CI verde) fusionada a `main` por fast-forward. Evidencia en `docs/06-referencias/h1-android.md`.
- **Entorno de agentes:** 6 skills P0 + graphify instaladas en OpenCode y `~/.agents/skills`; SDK .NET 10.0.100 local con `maui-android`, Android SDK 36, platform-tools y JDK 17.
- **Limpieza Android:** `chore/instancia-unica-warnings` (`82aa23e`) deja la compilación Android en 0 advertencias; 378/378 pruebas y CI verde (run `45442442966`). Fusionada a `main`.
- **Pendientes post-H1 anotados:** otro equipo/tablet, corte de energía real, dueño no técnico y acceso de colaborador en GitHub. Ver `docs/09-pendientes/h1-post-merge.md`.
- **P3 preparado:** app Windows aislada `com.sistematienda.p3`, acceso directo de prueba, guion del participante, hoja de observación y scripts de preparación/limpieza en `scripts/`.
- **P3 completado (2026-11-24):** el participante completó el flujo y recomendaría el sistema. Hallazgos: ruta de respaldo poco accionable (P6), QR del ticket no escaneable (P7) y falta de búsqueda dinámica en POS (P8). Ver `docs/09-pendientes/p3-resultados-2026-11-24.md`.
