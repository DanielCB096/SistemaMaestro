# ADR-015 — Reembolso de ventas anuladas

- **Fecha:** 2026-11-27
- **Estado:** Aceptado; verificación visual pendiente
- **Hito:** Ventas y caja

## Contexto

La anulación devolvía stock y revertía el fiado, pero el dinero se entregaba a
mano sin registro. La venta anulada se excluye del corte pendiente, así que un
reembolso pagado en el mismo periodo no descuadraba. Si el cliente recogía el
efectivo después de cerrar el corte, el retiro no quedaba registrado y el
efectivo esperado del siguiente periodo quedaba alto.

No se podía registrar el reembolso al anular porque el cliente puede recogerlo
después y porque una venta mixta tiene partes en efectivo y con tarjeta.

## Decisión

- En el detalle de una **venta anulada** aparece la sección **Reembolso** con lo
  pagado, lo reembolsado y lo pendiente, más el historial.
- **Registrar reembolso** es una acción separada: elige método (Efectivo,
  Tarjeta, Transferencia u Otro) y monto. Se pueden registrar varias partes
  hasta cubrir lo pagado.
- Lo reembolsable es **efectivo + tarjeta**. El **fiado no se reembolsa**: la
  anulación ya revirtió el saldo del cliente.
- **Solo el efectivo mueve la caja**: genera un retiro con motivo
  `Reembolso venta #X` en el periodo abierto, en la misma transacción que el
  reembolso. Tarjeta, transferencia y otro solo reducen el pendiente.
- El monto debe ser mayor a cero y no superar el pendiente; el servicio y la
  base lo vuelven a validar para que dos capturas no se excedan.
- Permiso: `AnularVenta` (dueño y encargado). El empleado puede ver el estado
  si tiene `Consultar`, pero no registrar el reembolso.
- La bitácora `ReembolsoVenta` guarda pagado, reembolsado, pendiente, método,
  monto y si generó retiro. Reembolso, retiro, reembolso y bitácora son
  atómicos.
- Esquema **v22**: tabla `ReembolsosVenta` inmutable (sin `UPDATE` ni `DELETE`),
  con índices por venta y fecha y `MovimientoCajaId` opcional.
- Las ventas anuladas antes de la v22 aparecen con su pendiente y se pueden
  reembolsar desde la app.

## Consecuencias

- El corte refleja el efectivo que realmente salió, aunque el cliente recoja el
  reembolso días después.
- Un reembolso parcial deja el pendiente visible hasta completarlo.
- No se registran reembolsos de ventas no anuladas ni de fiado.
- El reembolso no cambia el reporte de utilidad: la venta anulada ya está
  excluida.

## Verificación

- `ReembolsosTests`: efectivo con retiro, tarjeta sin caja, venta mixta,
  parciales, exceso, venta no anulada, fiado, empleado sin permiso y migración.
- Pendiente: prueba visual en Windows y Android.
