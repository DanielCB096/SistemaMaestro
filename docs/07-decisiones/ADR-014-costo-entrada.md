# ADR-014 — Costo del catálogo al registrar entradas

- **Fecha:** 2026-11-27
- **Estado:** Aceptado; verificado en Windows el 2026-11-27
- **Hito:** Inventario y utilidad

## Contexto

La entrada de inventario guardaba el costo unitario del movimiento, pero no
actualizaba `Productos.Costo`. Después de comprar al mismo proveedor a otro
precio, el valorizado y el costo congelado de las siguientes ventas seguían
usando el costo viejo hasta que el dueño lo editara a mano. Ese paso se olvida
con facilidad y la utilidad queda distorsionada.

Las compras a proveedor desde T39 ya actualizan el costo del catálogo al último
costo. La entrada manual era la excepción.

## Decisión

- Al registrar una entrada, el costo unitario capturado **actualiza
  `Productos.Costo`** en la misma transacción que el movimiento de inventario.
- La pantalla muestra una casilla **“Actualizar el costo del catálogo”**,
  marcada por defecto. Si se desmarca, el movimiento conserva su costo, pero el
  catálogo mantiene el costo anterior.
- Un costo capturado en **cero** no borra el costo del catálogo: se registra
  como costo del movimiento (por ejemplo, una donación) y el catálogo conserva
  su valor. Un costo igual al actual tampoco genera actualización.
- La acción la puede hacer quien tenga `RegistrarEntrada`: **dueño y
  encargado**, igual que las compras. La edición de costo/precio desde el
  formulario del producto sigue reservada al dueño.
- La bitácora `EntradaInventario` guarda stock y costo antes/después, el costo
  unitario capturado y si el catálogo se actualizó. Movimiento y bitácora se
  confirman o se revierten juntos.
- Las ventas siguientes congelan el costo nuevo. Las ventas anteriores
  conservan el costo con el que se registraron.

### Precio de venta

- Cuando el costo cambia, la pantalla calcula un **precio sugerido** que conserva
  el margen **en pesos**: `precio nuevo = costo nuevo + (precio actual − costo
  actual)`. Es la regla del ejemplo $12→$13, $18→$19.
- El precio **no cambia solo**. El dueño ve la casilla **“Actualizar el precio a
  $X (conservar margen)”**, desmarcada por defecto, y decide si la aplica.
- Si el usuario no tiene `CambiarPrecios` (el encargado), la casilla no aparece:
  puede actualizar el costo, pero el precio lo cambia el dueño.
- El precio se guarda en la misma transacción que la entrada y su bitácora.
- La sugerencia nunca baja de un centavo; si el margen actual es negativo, el
  precio sugerido queda por debajo del costo nuevo y la interfaz lo muestra con
  el margen resultante.

## Consecuencias

- El valorizado y la utilidad reflejan la última compra sin pasos extra.
- El encargado puede corregir el costo al recibir mercancía; queda auditado.
- No se guarda un “costo de reposición” separado: el catálogo usa el último
  costo capturado. Si más adelante se necesita un valor de reposición distinto,
  se agrega como campo propio sin cambiar esta regla.
- Las entradas con costo cero o sin actualizar siguen siendo posibles para
  donaciones, ajustes o correcciones.

## Verificación

- `CostoEntradaTests`: actualización atómica, casilla desmarcada, costo cero,
  costo igual, costo congelado de la siguiente venta, precio sugerido con margen
  en pesos, precio aplicado, precio cero y encargado sin permiso de precio.
- Verificado en Windows el 2026-11-27: costo $12→$13 con precio sugerido $19, casilla desmarcada que conserva el precio y encargado sin control de precio. Android pendiente.
