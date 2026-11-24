---
name: sqlite-local
description: "Úsala para cualquier cambio en persistencia SQLite de tienda: esquema, consultas, migraciones, WAL, concurrencia, respaldo o rendimiento de índices."
---

# SQLite local

**Versión:** 1.0  
**Prioridad:** P0  
**Dueño:** DeepSeek / Claude  
**Revisión:** 2026-11-23  
**Fuente:** [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md), [H1](../../../06-referencias/h1-respaldo-restauracion.md), auditoría.

## Propósito

Mantener la base local íntegra, recuperable y rápida en un negocio sin internet. Esta skill se activa cuando el cambio puede afectar datos, concurrencia, migraciones o rendimiento.

## Hechos que debes asumir

- `tienda` usa SQLite con ADO.NET directo; `DatabaseTools` concentra ~1,996 líneas, ~72 métodos públicos y 164 sentencias SQL.
- H1 ya dejó WAL, `busy_timeout=30000`, `synchronous=NORMAL` e instancia única en Windows.
- Las conexiones de respaldo usan `Pooling = false` para poder mover el archivo verificado.
- Hay 18 tablas y migraciones v1–v14.
- `date(Fecha)` en `WHERE` impide usar los índices de ventas y reportes.
- La suite actual tiene 373 pruebas en verde al cierre de H1.

## Cuándo se activa

- Cambios de esquema o migraciones.
- Consultas nuevas o modificadas.
- Transacciones, concurrencia, bloqueos o tiempos de espera.
- Respaldo, restauración o exportación de la base.
- Reportes que filtran por fecha.
- Cualquier síntoma de “base bloqueada”, “database is locked” o lentitud.

## Cuándo no se activa

- Cambios puramente visuales que no leen ni escriben datos.
- Documentación sin impacto en persistencia.

## Reglas inviolables

1. **Una conexión por operación.** No compartas una conexión entre hilos ni la dejes abierta más de lo necesario.
2. **SQL parametrizado.** Nunca concatenes valores; usa parámetros aunque el valor “venga de la UI”.
3. **Transacción para escrituras múltiples.** Si una operación toca más de una tabla, abre transacción y confirma o revierte.
4. **WAL y pragmas vigentes.** No los desactives para “probar”; si un cambio los afecta, demuéstralo con prueba.
5. **Migración con respaldo previo.** Antes de alterar esquema, crear respaldo y verificar que se puede restaurar.
6. **No copiar el archivo con `-wal` abierto.** Usa la API de respaldo de SQLite o el procedimiento de H1.
7. **Fechas con rango, no `date(Fecha)`.** Usa `Fecha >= @desde AND Fecha < @hasta` para conservar índices.
8. **No dos instancias sobre la misma base.** La instancia única de Windows es parte de la integridad, no un adorno.
9. **Prueba de restauración en instalación independiente.** Un respaldo que no se restaura no es un respaldo.

## Flujo

1. Lee `Database.cs`, `RespaldoLocal.cs` y la migración más reciente.
2. Identifica si el cambio toca esquema, consulta, transacción o respaldo.
3. Escribe una prueba que reproduzca el comportamiento actual (caracterización) o el fallo.
4. Aplica el cambio mínimo.
5. Ejecuta la suite completa y las pruebas de WAL/respaldo.
6. Verifica el plan de consulta si cambiaste un filtro de fecha: `EXPLAIN QUERY PLAN`.
7. Si tocaste esquema, crea respaldo, migra y prueba restauración.
8. Reporta el número de pruebas y el resultado de la restauración.

## Casos borde obligatorios

- Corte de energía o cierre forzado durante una escritura.
- Dos instancias o dos ventanas sobre la misma base.
- Respaldo tomado mientras hay WAL activo.
- Migración interrumpida a la mitad.
- Filtro de fecha con índice disponible.
- Restauración en otro equipo con otra ruta.

## Criterio de aceptación

- La suite completa queda verde.
- La prueba de restauración en instalación independiente pasa.
- Dos instancias no corrompen la base.
- La consulta de fecha usa índice (o se documenta por qué no puede).
- No hay SQL concatenado nuevo.

## Anti-patrones

- `using var conn = ...` compartido en un servicio singleton.
- `DateTime.Now` convertido a texto sin formato estable.
- `DELETE` o `UPDATE` masivo sin transacción.
- “Lo pruebo en producción, es un cliente pequeño”.
- Cambiar el esquema y dejar la migración para después.

## Referencias

- `tienda/SistemaTienda/SistemaTienda.Infrastructure/Database.cs`
- `tienda/SistemaTienda/SistemaTienda.Infrastructure/RespaldoLocal.cs`
- `tienda/SistemaTienda/SistemaTienda.Tests/RespaldoWalTests.cs`
- [H1 — respaldo y restauración](../../../06-referencias/h1-respaldo-restauracion.md)
- [Modelo de documentos, pagos y caja](../../../02-arquitectura/modelo-documentos-pagos-caja.md)

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-23 | Creación con el estado posterior a H1 |
