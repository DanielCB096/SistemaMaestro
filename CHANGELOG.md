# Changelog

## 2026-11-23 — Verificación manual de H1

- Se consulta a ChatGPT, Claude y Gemini el criterio de aceptación manual de H1; respuestas en `docs/05-colaboracion-ia/rondas/2026-11-23-verificacion-h1/`.
- Se ejecuta la verificación manual en Windows con una base aislada: exportar, restaurar, respaldo previo, archivo corrupto, dos instancias y paquete de soporte sin/con base.
- Hallazgo: `C:\Users\PC\Documents` no permite crear archivos en este equipo; la exportación fallaba con `FileNotFoundException`.
- Corrección en `tienda` (`546900f`): `CarpetaExportacion` elige la primera carpeta escribible (Documentos → Escritorio → Descargas) y se agregan 3 pruebas. Total: **376/376**.
- CI de `f748af8` en verde en el run `45320190550` (Windows y Android); la PR #40 queda lista para decisión de merge.
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
