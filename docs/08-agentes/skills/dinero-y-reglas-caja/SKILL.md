---
name: dinero-y-reglas-caja
description: "Úsala para cambios en ventas, pagos mixtos, fiado, gastos, inventario, corte de caja o reportes de dinero. Fija centavos enteros, un solo efecto de caja y una sola fuente de stock."
---

# Dinero y reglas de caja

**Versión:** 1.0  
**Prioridad:** P0  
**Dueño:** DeepSeek / Claude  
**Revisión:** 2026-11-23  
**Fuente:** [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md), auditoría, [modelo de documentos/pagos/caja](../../../02-arquitectura/modelo-documentos-pagos-caja.md).

## Propósito

Evitar descuadres, doble conteo y stock inconsistente. Esta skill se activa siempre que el cambio toque dinero, caja, inventario o reportes financieros.

## Hechos que debes asumir

- El dinero se maneja en **centavos enteros** (`long`/`INTEGER`); los porcentajes, en `decimal`.
- Hay ventas simples, mixtas y fiadas; abonos con método; gastos de caja; compras que cambian costo; anulaciones.
- La auditoría detectó: gasto con doble efecto potencial, anulación sin una sola regla de “ventas netas”, stock dependiente de `SUM(movimientos)`, corte sin bloqueo de doble cierre y compra que actualiza costo con permiso distinto al de editar precio.
- H4 es el hito que cierra estas reglas; hasta entonces, la skill sirve para no empeorarlas.

## Cuándo se activa

- Ventas, pagos, cambio, devoluciones o anulaciones.
- Fiado, abonos y saldos.
- Gastos y movimientos de caja.
- Compras, costo y stock.
- Corte de caja y arqueo.
- Reportes de utilidad, ventas netas o métodos de pago.

## Reglas inviolables

1. **Centavos enteros.** No uses `double` ni `float` para dinero; no redondees a pesos en el dominio.
2. **Una sola fuente de stock.** El log de movimientos es la verdad; si hay caché, se actualiza en la misma transacción y se concilia.
3. **Un solo efecto de caja por gasto.** No crear pago y retiro a la vez.
4. **Una sola regla de anulación.** “Venta neta” se calcula por estado o por referencia de anulación, no por ambas.
5. **Venta mixta se reporta por pago, no por documento duplicado.**
6. **Saldos transaccionales.** Si hay caché de saldo, se actualiza en la misma transacción y se concilia; no se deja “para el reporte”.
7. **Idempotencia.** Toda operación financiera que pueda reintentarse lleva `idempotency_key`.
8. **Auditoría en la misma transacción.** El movimiento y su bitácora se confirman o se revierten juntos.
9. **Arqueo ciego.** El cajero declara el efectivo antes de ver el esperado; solo el dueño ve el esperado.
10. **No cambiar una regla de negocio sin ADR.** Si la regla no está escrita, pregunta antes de inventarla.

## Flujo

1. Identifica la regla afectada: venta, pago, gasto, stock, saldo o corte.
2. Escribe el caso en una tabla de decisión: entrada, efecto en caja, efecto en stock, efecto en saldo.
3. Agrega una prueba de caracterización del comportamiento actual.
4. Implementa la regla en el servicio, no en el code-behind.
5. Prueba el caso simple y los bordes: mixta, fiada, anulada, con gasto, con cambio de costo.
6. Verifica que el corte cuadre y que el stock se pueda reconstruir desde movimientos.
7. Reporta la matriz de casos y el resultado del corte.

## Matriz mínima de pruebas

| Caso | Caja | Stock | Saldo | Debe cumplir |
|---|---|---|---|---|
| Venta simple efectivo | + total | − cantidad | — | Un solo movimiento por venta |
| Venta mixta efectivo + tarjeta | + efectivo, + tarjeta | − cantidad | — | Reporte por pago, no por documento duplicado |
| Venta fiada | 0 | − cantidad | + saldo | Saldo y stock en la misma transacción |
| Abono | + monto | — | − saldo | Método de pago registrado |
| Anulación | − total | + cantidad | − saldo si fiada | Documento nuevo, no edición del original |
| Gasto efectivo | − monto | — | — | Un solo efecto de caja |
| Compra con cambio de costo | − monto | + cantidad | — | Costo actualizado con permiso correcto |
| Corte ciego | Esperado oculto | — | — | El cajero declara antes de ver |

## Criterio de aceptación

- Cada regla de la matriz tiene al menos una prueba que la cita.
- El corte cuadra en todos los escenarios de la matriz.
- El stock se reconstruye desde movimientos y coincide con la caché.
- No hay doble efecto de caja ni doble conteo de venta mixta.
- La anulación no deja dos formas de calcular ventas netas.

## Anti-patrones

- Sumar `decimal` y convertir a centavos al final.
- Crear un pago y un retiro para el mismo gasto.
- “Ajustar” el stock con un `UPDATE` sin movimiento.
- Anular borrando la venta original.
- Reportar utilidad desde la venta en lugar del pago.
- Cerrar caja sin bloquear el doble cierre.

## Referencias

- [Auditoría — hallazgos P1](../../../00-auditoria/informe-tienda-gym-dotnet.md)
- [Modelo de documentos, pagos y caja](../../../02-arquitectura/modelo-documentos-pagos-caja.md)
- [Plan maestro v2 — H4](../../../01-plan/plan-maestro-v2.md)
- `tienda/SistemaTienda/SistemaTienda.Core/Dinero.cs`
- `tienda/SistemaTienda/SistemaTienda.Application/Services/`

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-23 | Creación a partir de la auditoría y del modelo financiero |
