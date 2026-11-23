# Changelog

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
