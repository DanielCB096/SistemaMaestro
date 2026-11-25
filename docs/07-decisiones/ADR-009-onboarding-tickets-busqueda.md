# ADR-009 — Onboarding, tickets en espera y búsqueda

- **Fecha:** 2026-11-25
- **Estado:** Aceptado; H6.1, H6.2 y H6.3 implementados
- **Hito:** H6

## Contexto

La importación de productos ya existía, pero guardaba filas válidas sin vista previa, sin lote y sin forma de deshacer. El POS perdía el carrito al cerrar la app y la búsqueda por nombre cargaba todo el catálogo en cada tecla, aunque con debounce.

Se consultó a Claude, Gemini y ChatGPT. Las tres respuestas coincidieron en: no borrar historial al revertir, persistir los tickets sin reservar stock y evitar FTS5/caché global sin una necesidad medida.

## Decisiones

### Importación (H6.1)

- **Vista previa obligatoria**: se valida el archivo completo y se muestran filas leídas, válidas, omitidas y los primeros errores. Nada se escribe hasta que el dueño confirma.
- **Parcial explícito**: al confirmar se importan solo las filas válidas, en **una sola transacción**. Si la escritura falla, no queda ningún producto del lote.
- **Plantilla fija** con encabezados `CodigoBarras,Nombre,Costo,Precio,Stock,StockMinimo,Categoria,Impuesto`, tolerante al orden de columnas. La app puede compartir la plantilla con dos ejemplos.
- **Lote auditable**: tabla `Importaciones` (fecha, usuario, archivo, hash, conteos, estado) y `Productos.ImportacionId`; los movimientos de stock inicial también guardan `ImportacionId`.
- **Reversión compensatoria**, nunca borrado: por cada producto se registra un `AJUSTE` con el stock restante, se desactiva el producto y el lote pasa a `Revertida`, todo en una transacción con bitácora `ReversionImportacion`.
- **Bloqueo**: si algún producto del lote tiene ventas, compras u otro movimiento ajeno al lote, la reversión se rechaza y se sugiere desactivar los productos. La regla del historial no tiene excepciones.
- **Duplicados**: se rechazan códigos repetidos dentro del archivo y contra el catálogo antes de escribir. El hash del archivo queda guardado para soporte; no se bloquea reimportar un archivo corregido.

### Tickets en espera (H6.2)

- Persistir en SQLite (`TicketsEspera` y líneas), no en memoria.
- **No reservar stock**: se valida al cobrar, igual que una venta normal.
- Recalcular precios con el catálogo vigente al retomar, avisar los cambios y exigir confirmación.
- Máximo 10 tickets por equipo, nota opcional, visibles para quien tenga permiso de vender.
- Sin caducidad automática; descarte manual.
- Auditar dejar, retomar y descartar; descartar no borra la evidencia.
- Persistencia: `TicketsEspera` y `TicketEsperaLineas` (esquema v19). El ticket guarda el precio congelado por línea para avisar cambios.
- La venta cierra el ticket (`Estado = Cobrado`, `VentaId`) dentro de la misma transacción que el stock; si el ticket no está retomado por quien cobra, la venta se revierte.
- Un ticket retomado que queda huérfano por un cierre inesperado se libera a los 30 minutos.

### Búsqueda (H6.3)

- Mantener SQLite y la normalización actual (sin acentos ni mayúsculas); sin FTS5 ni caché global.
- Medir con 3000 productos antes de optimizar. En Windows Release: 33.52 ms por
  sugerencias, 28.08 ms por nombre y 0.07 ms por código exacto; el POS espera
  250 ms desde la última tecla.
- Optimización aplicada: camino rápido para texto ASCII y una sola normalización
  por producto y consulta. `BuscarPorNombre` limita a 200 resultados.
- Escaneo por código de barras: coincidencia exacta primero, prefijo después, sin
  perder dígitos. La medición en Android queda para el equipo del piloto.
- Si el equipo real supera 300 ms o se siente lento, medir antes de evaluar FTS5 o
  caché; no se adelanta complejidad.

## Consecuencias

- Un archivo con errores ya no deja el catálogo a medias sin que el dueño lo sepa.
- Revertir un lote no borra productos ni movimientos; el stock neto vuelve a cero y el producto queda inactivo.
- El costo es una tabla y dos columnas nuevas (esquema v18) y más pasos en la interfaz de importación.
- La reversión no corrige precios ni nombres ya editados: el dueño debe corregirlos a mano.

## Verificación

- `ImportacionLotesTests`: vista previa sin escritura, lote y vínculos, 3000 filas en un lote, reversión limpia, bloqueo por venta, fallo de inserción sin residuos, permiso de empleado y migración v17 → v18.
- `PlantillaProductos` se previsualiza con dos filas válidas.
- `TicketsEsperaTests`: guardar sin mover stock ni caja, máximo 10, precio actual y cambio, retomar, bloqueo de otro cajero, descarte auditado, venta que cierra el ticket, doble cobro rechazado, liberación por vencimiento y migración v18 → v19.
- `BusquedaRendimientoTests`: 3000 productos, umbrales anti-regresión, tope de 200
  resultados, prefijos del escáner, código antes que nombre y acentos.
- Suite completa: 483 pruebas.
- Pendiente: verificar la vista previa, **Lotes**, **Guardar en espera** y **En espera** en Windows y Android con datos reales.
