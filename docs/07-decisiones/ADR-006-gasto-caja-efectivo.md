# ADR-006 — Gasto de caja solo en efectivo

- **Fecha:** 2026-11-25
- **Estado:** Aceptado
- **Hito:** H4

## Contexto

Un gasto tenía dos campos independientes: `Origen` (Caja / Externo) y `MetodoPago` (Efectivo, Tarjeta, Transferencia, Otro). La caja restaba **todos** los gastos con `Origen = Caja`, sin mirar el método. Un gasto de caja pagado con tarjeta reducía el efectivo esperado aunque no saliera un peso de la caja: descuadre garantizado.

## Decisión

1. **`Origen = Caja` implica `MetodoPago = Efectivo`.** `AgregarGasto` rechaza cualquier otra combinación con un mensaje que ofrece registrarlo como externo.
2. Si el método llega vacío, se asume **Efectivo** (compatibilidad con altas antiguas y pruebas).
3. El cálculo del corte suma solo `Origen = Caja AND MetodoPago = Efectivo`; los registros históricos inconsistentes ya no restan efectivo.
4. En la app, al activar «Salió del efectivo de la caja» el selector de método se fija en Efectivo y se deshabilita; al desactivarlo se elige libremente.

## Consecuencias

- Un gasto pagado con tarjeta o transferencia se registra como **externo**: afecta la utilidad, no el efectivo.
- El corte deja de descontar gastos que no salieron de la caja.
- Los gastos históricos con la combinación inválida se conservan, pero ya no afectan el efectivo esperado.

## Verificación

- `CaracterizacionCajaReportesTests`:
  - Corte con ventas, abonos, ingresos, retiros y gastos: esperado 485.00.
  - Reporte con venta mixta: efectivo 240 + tarjeta 260 + fiado 200 = 700, sin duplicar.
  - `GastoDeCajaConTarjeta_SeRechaza`.
  - `GastoDeCajaConTarjetaHistorico_NoReduceElEfectivoEsperado`.
  - Corte cerrado con diferencia cero.
- Suite completa: 435 pruebas.

## Pendiente de H4

- Bitácora dentro de la misma transacción que la operación. Hoy se registra después de confirmar; si falla la bitácora, la operación queda sin auditoría.
