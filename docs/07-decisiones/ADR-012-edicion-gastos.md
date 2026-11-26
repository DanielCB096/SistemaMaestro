# ADR-012 — Edición de gastos

- **Fecha:** 2026-11-26
- **Estado:** Aceptado; prueba visual pendiente
- **Hito:** Reportes y operación

## Contexto

Los gastos solo se podían crear. Un concepto mal escrito, un monto equivocado o un
origen incorrecto obligaban a dejar el error o a registrar un gasto compensatorio.
Editar un gasto de caja después de cerrar el corte cambiaría un arqueo histórico y
haría que el efectivo esperado ya no coincidiera con lo entregado.

## Decisión

- Se pueden editar **concepto, monto, método, origen y observaciones**.
- **La fecha no se edita**: no hay gastos retroactivos desde esta pantalla.
- **Se bloquea** la edición si el gasto ya quedó dentro de un corte cerrado
  (`CortesCaja.Hasta >= Gastos.Fecha`). En ese caso se pide registrar un gasto nuevo
  si hace falta corregir, y el historial conserva el original.
- Un gasto con origen **Caja** debe seguir siendo **Efectivo** (ADR-006).
- El permiso es `RegistrarGasto` (dueño y encargado).
- La actualización y la bitácora `EditarGasto` van en la misma transacción; si la
  bitácora falla, el gasto no cambia.
- La interfaz abre el editor al tocar un gasto; el formulario de alta y el de
  edición comparten campos y validaciones.

## Consecuencias

- El dueño corrige errores del día sin romper cortes ya cerrados.
- Un gasto mal capturado en un periodo cerrado sigue requiriendo un movimiento
  nuevo; es la misma regla que el resto del historial.
- El reporte de utilidad y el efectivo esperado reflejan la edición solo mientras
  el periodo siga abierto.

## Verificación

- `GastosTests`: edición con bitácora y fecha intacta, bloqueo por corte cerrado,
  rechazo de caja con tarjeta y rechazo para empleado.
- `ReportesTests` y `ExportadorCsvTests`: productos y categorías, exclusión de
  anuladas y exportación.
- Pendiente: prueba visual del editor en Windows y Android.
