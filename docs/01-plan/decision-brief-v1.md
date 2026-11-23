# Decision Brief v1 — Alcance de los próximos 90 días

**Fecha:** 23 de noviembre de 2026  
**Estado:** propuesto, pendiente de aprobación.  
**Dueño de la decisión:** Daniel Cuevas Bernal.  
**Expertos consultados:** ChatGPT (negocio), Claude (arquitectura/riesgo), Gemini (producto/UX/operaciones), DeepSeek (verificación/ejecución).

## 1. Contexto

Existen dos sistemas en producción:

- **`tienda`**: .NET MAUI + SQLite, Windows/Android. POS, inventario, fiado, proveedores, caja, reportes. 318 pruebas. Tiene problemas P0 de respaldo/restauración, permisos, bloqueo de login, timeout y cifrado.
- **`gym-dotnet`**: .NET 10 Windows Service + React + SQL Server. Más maduro en autenticación, MFA, backups y operación, pero no compila sin librerías GymCore externas, usa estado global, API sin DTOs y tiene carreras de concurrencia.

La auditoría concluye que ninguno sirve tal cual como base universal, pero `tienda` es la mejor base para un producto vendible a corto plazo.

## 2. Decisión

¿Qué hacemos en los próximos 90 días?

| Opción | Descripción | Riesgo |
|---|---|---|
| A | Construir una tercera aplicación (núcleo universal nuevo) | 8–24 meses sin producto nuevo; mantener dos legacy; sobreingeniería |
| B | Tienda V2 incremental: corregir P0, añadir integridad, instalar y pilotar | Deuda acumulada si no se ponen límites |
| C | Híbrido: V2 + extraer kernel en paralelo desde la semana 6 | Dos frentes para un solo desarrollador |

## 3. Recomendación

**Opción B con puerta de salida.**

- Semanas 1–2: respaldo/restauración/exportación, WAL, instancia única.
- Semanas 2–4: permisos, bloqueo persistente, timeout, manejador global.
- Semanas 3–6: suite de caracterización.
- Semanas 6–8: stock único, gasto/caja unificado, ventas mixtas, bitácora transaccional, arqueo ciego.
- Semanas 8–9: instalador, migración automática y rollback.
- Semanas 9–10: importación CSV, búsqueda instantánea, tickets en espera.
- Semanas 10–13: piloto de 30 días y lanzamiento de Tienda V2.

**Puerta de salida:** si al terminar la semana 13 no hay un piloto estable, no se empieza el núcleo universal; se corrige lo que falle y se reevalúa.

## 4. Criterios de aceptación

- Restaurar un respaldo en otro dispositivo.
- Empleado sin acceso a utilidad/costos ni altas sensibles.
- Suite de caracterización verde en CI.
- Corte de caja cuadrado en los escenarios de prueba.
- Actualización fallida vuelve a la versión anterior.
- 14 días de operación real sin pérdida de datos ni descuadres inexplicados.

## 5. Evidencia

- Auditoría: `docs/00-auditoria/informe-tienda-gym-dotnet.md`.
- Plan: `docs/01-plan/plan-maestro-v2.md`.
- Ronda de expertos: `docs/05-colaboracion-ia/rondas/2026-11-23.md`.

## 6. Qué nos haría cambiar de opinión

- Que `tienda` no pueda estabilizarse en 8 semanas por complejidad de `DatabaseTools`.
- Que un cliente exija multi-sucursal o sincronización antes del piloto.
- Que el hardware o CFDI bloqueen la venta del producto.
- Que el costo de soporte del piloto supere el precio de la licencia.

## 7. Preguntas para la siguiente ronda

**ChatGPT:** ¿qué se vende antes del piloto y cómo se evita prometer de más?

**Claude:** ¿qué parte de H1–H4 es irreversible y qué prueba la cierra?

**Gemini:** ¿qué flujo de onboarding hace que un abarrotes real adopte el sistema en una semana?
