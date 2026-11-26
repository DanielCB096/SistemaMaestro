# ADR-013 — Descuento por producto

- **Fecha:** 2026-11-26
- **Estado:** Aceptado; verificado en Windows el 2026-11-26
- **Hito:** Ventas Fase 2

## Contexto

El POS cobraba siempre precio de catálogo × cantidad. Para una promoción, un
cliente frecuente o un ajuste acordado, el cajero no tenía forma de bajar el
total sin inventar una venta o modificar el precio del producto. Ambas salidas
rompen el historial: el precio congelado deja de reflejar lo cobrado o se
distorsiona el catálogo para todas las ventas futuras.

El descuento toca dinero, IVA, comisión de tarjeta, reportes por producto y
utilidad. Por eso necesita una regla escrita y una autorización explícita.
También debe permitir rebajar un solo producto o dar descuentos distintos por
renglón.

## Decisión

- El descuento vive en **cada renglón**. Cada producto puede llevar su propio
  descuento, como **porcentaje** o como **monto fijo**; nunca ambos en el mismo
  renglón.
- La venta ofrece un atajo **“Descuento a toda la venta”**: con porcentaje aplica
  el mismo porcentaje a cada renglón; con monto reparte el importe total entre
  los renglones en proporción a su importe bruto (mayor residuo) y guarda la
  parte que corresponde a cada uno.
- Solo **dueño y encargado** aplican descuentos, con el permiso nuevo
  `AplicarDescuento`. El empleado no ve la acción y el servicio rechaza
  cualquier renglón con descuento.
- Límites por renglón: el porcentaje debe ser mayor a 0 y menor a 100; el monto,
  mayor a cero y menor al importe del renglón. Siempre queda un total mayor a
  cero.
- Cada línea guarda su descuento en `VentaLineas.Descuento`, su porcentaje en
  `VentaLineas.DescuentoPorcentaje` y su `Importe` queda **neto**. La venta
  guarda la suma en `Ventas.Descuento` y un porcentaje común solo cuando todos
  los renglones rebajados comparten el mismo porcentaje.
- El **IVA incluido** se recalcula sobre el importe neto de cada línea. La
  **comisión de tarjeta** se calcula sobre lo realmente cobrado con tarjeta.
- El **costo congelado** no cambia: el descuento reduce la utilidad.
- Los reportes por producto y categoría usan `VentaLineas.Importe`, así que
  quedan netos sin una segunda regla de cálculo.
- El ticket y el detalle muestran el descuento por renglón, el subtotal, el
  descuento total y el total. La reimpresión usa los valores guardados.
- La anulación sigue siendo de la venta completa y reembolsa el total neto de
  forma manual, como antes.
- El esquema **v20** agrega `Ventas.Descuento`,
  `Ventas.DescuentoPorcentaje` y `VentaLineas.Descuento`; la **v21** agrega
  `VentaLineas.DescuentoPorcentaje`. Las ventas anteriores quedan en cero.

## Consecuencias

- El dueño puede hacer promociones por producto sin tocar el catálogo.
- El reporte por producto, la utilidad y el corte cuadran con lo cobrado.
- Un empleado que necesite dar un descuento debe pedir a un encargado que
  inicie sesión; la autorización por PIN sin cambiar de sesión queda como
  mejora futura.
- Los descuentos no se guardan en tickets en espera: al retomar un ticket se
  capturan de nuevo.
- No hay descuento retroactivo ni edición de una venta ya registrada.
- Si cambia la cantidad de un renglón con descuento fijo y este ya no cabe, se
  quita y se avisa; los descuentos porcentuales se recalculan solos.

## Verificación

- `DescuentosTests`: descuento por producto y mixto (% en un renglón y monto en
  otro), una sola línea rebajada, límites, permiso de empleado, IVA, comisión de
  tarjeta, reporte por producto, fiado y ticket.
- Migración v20 → v21 cubierta en la misma suite.
- Verificado en Windows el 2026-11-26: descuento por producto con % y monto, distintos por renglón, total y ticket correctos. Android pendiente.
