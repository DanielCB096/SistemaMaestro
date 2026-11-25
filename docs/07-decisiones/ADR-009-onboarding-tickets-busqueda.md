# ADR-009 — Onboarding, tickets en espera y búsqueda

- **Fecha:** 2026-11-25
- **Estado:** Aceptado; H6.1 implementado, H6.2 y H6.3 pendientes
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

### Tickets en espera (H6.2, pendiente)

- Persistir en SQLite (`TicketsEspera` y líneas), no en memoria.
- **No reservar stock**: se valida al cobrar, igual que una venta normal.
- Recalcular precios con el catálogo vigente al retomar, avisar los cambios y exigir confirmación.
- Máximo 10 tickets por equipo, nota opcional, visibles para quien tenga permiso de vender.
- Sin caducidad automática; descarte manual.
- Auditar dejar, retomar y descartar; descartar no borra la evidencia.

### Búsqueda (H6.3, pendiente)

- Mantener SQLite y la normalización actual (sin acentos ni mayúsculas); sin FTS5 ni caché global.
- Medir 3000 productos en Windows y Android antes de optimizar.
- Escaneo por código de barras: coincidencia exacta primero, sin perder dígitos.

## Consecuencias

- Un archivo con errores ya no deja el catálogo a medias sin que el dueño lo sepa.
- Revertir un lote no borra productos ni movimientos; el stock neto vuelve a cero y el producto queda inactivo.
- El costo es una tabla y dos columnas nuevas (esquema v18) y más pasos en la interfaz de importación.
- La reversión no corrige precios ni nombres ya editados: el dueño debe corregirlos a mano.

## Verificación

- `ImportacionLotesTests`: vista previa sin escritura, lote y vínculos, 3000 filas en un lote, reversión limpia, bloqueo por venta, fallo de inserción sin residuos, permiso de empleado y migración v17 → v18.
- `PlantillaProductos` se previsualiza con dos filas válidas.
- Suite completa: 468 pruebas.
- Pendiente: verificar la vista previa y el botón **Lotes** en Windows y Android con un archivo real.
