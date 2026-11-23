# ADR-001 — Tienda V2 incremental y posposición del núcleo universal

**Estado:** aprobado con condiciones (2026-11-23).  
**Fecha:** 2026-11-23.  
**Decisores:** Daniel Cuevas Bernal; consultas a ChatGPT, Claude, Gemini y DeepSeek.

## Aprobación

ChatGPT, Claude y Gemini aprobaron la ruta incremental y autorizaron el inicio de H1. Quedaron condiciones:

- Precios tentativos hasta medir costos reales.
- Piloto condicionado a puertas de calidad, no a calendario.
- Validaciones adicionales de privacidad, legal, seguridad y operación real.
- H1 solo termina cuando la recuperación esté probada.

Ver `docs/05-colaboracion-ia/rondas/2026-11-23-aprobacion.md`.

## Contexto

Existen dos sistemas en producción:

- `tienda`: .NET MAUI + SQLite, con POS, inventario, fiado, caja y reportes; 318 pruebas; problemas P0 de respaldo, permisos y seguridad.
- `gym-dotnet`: .NET 10 + React + SQL Server; más maduro en auth y operación, pero no compila sin GymCore externo y tiene deuda estructural.

La auditoría y las tres IA coinciden en que construir una plataforma universal ahora retrasaría la venta y multiplicaría el mantenimiento.

## Decisión

Durante los próximos 90 días:

1. Convertir `tienda` en Tienda V2 vendible.
2. Corregir P0 y la integridad de caja/stock antes del piloto.
3. Añadir instalador, actualización, rollback, importación y soporte.
4. Pilotar en un negocio real en semana 9–10.
5. Posponer el núcleo universal y el módulo de gimnasio.

## Alternativas

| Alternativa | Pros | Contras | Riesgo |
|---|---|---|---|
| A. Tercera app universal | Diseño limpio desde cero | 8–24 meses sin producto nuevo; tres bases de código | Proyecto inacabado |
| B. Tienda V2 incremental | Ingresos y clientes mientras se corrige; 318 pruebas | Deuda si no se ponen límites | Estancarse en parches |
| C. Híbrido en paralelo | Avance del núcleo | Dos frentes para un solo desarrollador | Ninguno termina bien |

## Consecuencias

- **Positivas:** producto vendible, retroalimentación real, base para el kernel.
- **Negativas:** el núcleo universal se retrasa; Android no es canal principal.
- **Deuda aceptada:** multi-tenant, sincronización, CFDI nativo y licenciamiento criptográfico quedan fuera.
- **Revisión:** al terminar la semana 13, con resultados del piloto.

## Evidencia

- `docs/00-auditoria/informe-tienda-gym-dotnet.md`
- `docs/01-plan/plan-maestro-v2.md`
- `docs/01-plan/decision-brief-v1.md`
- `docs/05-colaboracion-ia/rondas/2026-11-23.md`

## Criterio de salida

Si al terminar la semana 13 no hay piloto estable, no se inicia el núcleo universal; se corrige lo que falle y se reevalúa.
