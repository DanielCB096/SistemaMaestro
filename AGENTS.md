# Instrucciones para agentes

Este repositorio es la **fuente de verdad documental** de SistemaMaestro. El código de producto vive en [`DanielCB096/tienda`](https://github.com/DanielCB096/tienda). No se toca `gym-dotnet` desde aquí.

## Antes de escribir código (obligatorio)

1. Lee [`docs/08-agentes/ONBOARDING.md`](docs/08-agentes/ONBOARDING.md).
2. Ejecuta:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\preparar-entorno.ps1
   ```

   Esto copia las 6 skills P0 a OpenCode y a `~/.agents/skills`, instala `graphify` y verifica .NET, Android SDK y `adb`.

3. Verifica que OpenCode cargó las skills:
   - `graphify`
   - `protocolo-de-cambio`
   - `sqlite-local`
   - `dinero-y-reglas-caja`
   - `testing-dotnet`
   - `seguridad-permisos`
   - `backup-recovery`

4. Verifica las herramientas:
   - `dotnet --version`
   - `dotnet workload list`
   - `adb devices -l`
   - `java -version`

5. Lee el estado actual:
   - [`docs/06-referencias/h1-respaldo-restauracion.md`](docs/06-referencias/h1-respaldo-restauracion.md)
   - [`docs/06-referencias/h1-android.md`](docs/06-referencias/h1-android.md)
   - [`docs/08-agentes/catalogo-skills.md`](docs/08-agentes/catalogo-skills.md)

## Reglas de trabajo

- Carga `protocolo-de-cambio` antes de tocar código.
- Rama dedicada, línea base de pruebas y evidencia al final.
- No trabajar directamente en `main` de `tienda` sin rama.
- Una decisión por ADR; documenta antes de implementar.
- No secretos, credenciales, bases de datos ni respaldos reales en el repositorio.

## Estado actual (2026-11-24)

- **H1 mergeado** en `tienda` `main` (merge `41c5983`, PR #40).
- **CI de `main` en verde** (Windows y Android compilan).
- **Verificación manual Windows:** W1–W5 y W8 pasan.
- **Verificación manual Android:** **PASA**. Exportar, restaurar, paquete sin base y paquete con base verificados en POCO X6 Pro 5G / Android 16. Evidencia en [`docs/06-referencias/h1-android.md`](docs/06-referencias/h1-android.md).
- **Corrección Android:** `fix/android-soporte-cache`, commit `67af2a5`, 378/378 pruebas. CI en verde (run `45424725218`). Fusionada a `main` por fast-forward (`84dc8e1..67af2a5`) porque la cuenta de Edge no puede abrir PR (`must be a collaborator`).
- **Limpieza de advertencias:** `chore/instancia-unica-warnings`, commit `82aa23e`, CI verde (run `45442442966`); Android queda en 0 advertencias. Fusionada a `main` por fast-forward (`67af2a5..82aa23e`).
- **H2.3 hecho y fusionado** (`dc7b80c`, CI `45512214039`): respaldos cifrados con AES-256-GCM + PBKDF2 (600k), clave en DPAPI/SecureStorage, tarjeta de recuperación y restauración con clave; ver [ADR-004](docs/07-decisiones/ADR-004-respaldos-cifrados.md). Pendiente H2.3b: activación guiada en el asistente, paquete de soporte cifrado y verificación en Android.
- **H3 hecho:** caracterización del inventario y reconciliación del stock ([ADR-005](docs/07-decisiones/ADR-005-stock-movimientos.md)); 430 pruebas.
- **H4 hecho:** gasto de caja solo en efectivo ([ADR-006](docs/07-decisiones/ADR-006-gasto-caja-efectivo.md)) y bitácora atómica en dinero, inventario, catálogo, clientes, proveedores, usuarios y configuración ([ADR-007](docs/07-decisiones/ADR-007-bitacora-transaccion.md)); 442 pruebas.
- **H4.2b y H5 fusionados en `main` de `tienda`** (`f2f4110` y `0b15fe6`, CI `45684057019` en verde).
- **Licencia:** perpetua, firmada RSA-PSS, prueba de 30 días y avisos sin bloqueo ([ADR-016](docs/07-decisiones/ADR-016-licencia-offline.md)); 545 pruebas; verificado en Windows el 2026-11-27.
- **Día completo:** `DiaCompletoTests` y el escenario `demo` cubren ventas, descuentos, reembolsos, abono, gasto, merma y compra; 535 pruebas; verificado en Windows el 2026-11-27.
- **Reembolsos:** ventas anuladas con reembolso por método, partes y retiro de caja para efectivo ([ADR-015](docs/07-decisiones/ADR-015-reembolso-anulacion.md)); 534 pruebas; verificado en Windows el 2026-11-27.
- **Costo en entradas:** la entrada actualiza el costo del catálogo con casilla para conservarlo ([ADR-014](docs/07-decisiones/ADR-014-costo-entrada.md)); precio sugerido con margen en pesos; 525 pruebas; verificado en Windows el 2026-11-27.
- **Ventas por día:** Reportes agrupa por día con total, costo+comisión y utilidad bruta en pantalla, CSV y PDF; 514 pruebas.
- **Descuento por producto:** % o monto con permiso de dueño/encargado, reparto por línea e IVA neto ([ADR-013](docs/07-decisiones/ADR-013-descuento-por-producto.md)); 510 pruebas; verificado en Windows.
- **Reportes y gastos:** productos/categorías en Reportes y edición de gastos con bloqueo tras corte cerrado ([ADR-012](docs/07-decisiones/ADR-012-edicion-gastos.md)); 499 pruebas.
- **Ventas por rango:** historial en la pestaña Ventas con Desde/Hasta, Hoy y Este mes; 492 pruebas.
- **Marca:** nombre visible **POSale** y logo de canasta/etiqueta/peso ([ADR-010](docs/07-decisiones/ADR-010-marca-posale.md)); identificadores internos y ruta de datos siguen como `SistemaTienda`.
- **Piloto preparado:** plan, instalación/día 0, checklist, capacitación, tarjeta, guion de 30 días, incidencias, privacidad y criterios en `tienda/SistemaTienda/docs/08-piloto`; kit con `scripts/piloto-preparar.ps1` probado con paquete simulado. No se instaló en una tienda real.
- **H6.3 hecho:** búsqueda medida con 3000 productos (33.52 ms sugerencias, 28.08 ms nombre, 0.07 ms código en Windows Release), optimización ASCII y pruebas de escáner; 483 pruebas. Verificado en Android el 2026-11-25 (POCO X6 Pro 5G): búsqueda sin acentos, código completo, tickets persistentes, cobro, descarte y bitácora. H6 cerrado; también se verificaron vista previa, importación y reversión de un lote en el teléfono. Pendiente medición instrumentada y escáner físico.
- **H6.2 hecho:** tickets en espera persistidos, sin reservar stock, precios recalculados con aviso, máximo 10 y venta atómica que cierra el ticket ([ADR-009](docs/07-decisiones/ADR-009-onboarding-tickets-busqueda.md)); 478 pruebas. Pendiente H6.3 (búsqueda medida).
- **H6.1 hecho:** importación con vista previa, lote auditable, plantilla y reversión compensatoria ([ADR-009](docs/07-decisiones/ADR-009-onboarding-tickets-busqueda.md)); 468 pruebas. Pendiente H6.2 (tickets en espera) y H6.3 (búsqueda medida en Android).
- **H5 hecho:** manifiesto de versión/esquema, actualizador con respaldo, verificación y restauración automática, paquete de Windows por versiones con `-Revertir` y CSV sin fórmulas ([ADR-008](docs/07-decisiones/ADR-008-instalacion-actualizacion.md)); 459 pruebas. Pendiente: instalar en una máquina limpia y probar un corte de energía real.
- **H2.3b hecho y fusionado** (`9f7fe92`): el asistente ofrece el cifrado y el paquete de soporte se cifra; Keystore verificado en Android.
- **H2.2 hecho y fusionado** (`06a7c11`, CI `45501565476`): bloqueo persistente (5 intentos, 3 minutos, estado en `EstadoAcceso`), timeout de inactividad configurable (2–15 min) y manejador global de errores en `logs/errores.log`; 408 pruebas.
- **H2.1 hecho y fusionado** (`881bfc8`, CI `45496679264`): permisos por acción según [ADR-003](docs/07-decisiones/ADR-003-permisos-accion.md). `VerCostos` por usuario; el encargado no ve costos salvo concesión; 403 pruebas.
- **Skills:** 6 P0 instaladas; P1/P2 definidas en el catálogo.
- **Graphify:** instalado (`0.9.114`) y skill visible en OpenCode y `~/.agents/skills`; el grafo de `tienda` no se versiona.
- **Pendientes de H2:** restaurar en otro equipo con la tarjeta, restauración guiada en el asistente y bloqueo/inactividad en Android. Keystore ya se verificó en un Android físico. Ver [`docs/09-pendientes/h2-pendientes.md`](docs/09-pendientes/h2-pendientes.md).
- **Pendientes post-H1:** otro equipo/tablet, corte de energía real y acceso de colaborador en GitHub. P3 (dueño no técnico) **completado** el 2026-11-24; **P6 (ruta de respaldo)** cerrado en `53a35fe` (`main` `290cde6`); **P8 (búsqueda dinámica)** en `c57fef0`; **P7 (QR)** en `28f66e4` y **escaneado con un teléfono real**. Ver [`docs/09-pendientes/h1-post-merge.md`](docs/09-pendientes/h1-post-merge.md). Ver [`docs/09-pendientes/h1-post-merge.md`](docs/09-pendientes/h1-post-merge.md).
- **Datos de prueba:** `tienda` incluye `SistemaTienda.Semilla` con escenarios `limpio`, `configurado` y `demo`; `scripts/p3-preparar.ps1 -Semilla` los aplica a la app aislada. `limpio` sigue siendo el valor por defecto para P3.

## Siguiente paso

1. Ejecutar el piloto con una tienda real: kit, instalación, capacitación y revisiones semanales.
2. Cerrar los pendientes de campo de H2/H5: restaurar en otro equipo con la tarjeta, restauración guiada, bloqueo en Android, instalación limpia y corte de energía real. Ver [`docs/09-pendientes`](docs/09-pendientes).
3. Medir la búsqueda con instrumentación en el Android del piloto y probar un escáner físico de 13 dígitos.

