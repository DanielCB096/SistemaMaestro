# ADR-005 — El stock se deriva de los movimientos

- **Fecha:** 2026-11-25
- **Estado:** Aceptado
- **Hito:** H3

## Contexto

El inventario tenía dos fuentes: la columna `Productos.Stock` (caché) y la suma de `MovimientoInventario`. La auditoría señaló el riesgo de que una ruta escribiera el stock sin registrar el movimiento, o al revés.

## Decisión

1. **El log de movimientos es la verdad.** Toda entrada, salida, merma, ajuste, venta, anulación y compra queda como movimiento.
2. **La caché se actualiza en la misma transacción que el movimiento.** `InsertarMovimiento` es el único lugar que cambia `Productos.Stock`; ninguna otra consulta lo escribe.
3. **Migración v17 reconcilia** todas las filas: `Stock = SUM(Cantidad)` por producto. Corrige desfases históricos al actualizar.
4. **Pruebas de caracterización:** después de alta, entrada, merma, ajuste, venta, anulación y compra, el stock de cada producto debe coincidir con sus movimientos. Seis pruebas en `CaracterizacionInventarioTests`.
5. **Diagnóstico:** `DatabaseTools.ProductosDescuadrados()` lista los productos descuadrados y el paquete de soporte informa cuántos hay.

## Por qué no derivar el stock en cada consulta

[RECOMENDACIÓN] Con años de movimientos, sumar en cada lectura de catálogo, POS y reportes cuesta y complica los índices. La caché mantenida en la misma transacción y reconciliada por migración y pruebas da la misma garantía con mejor rendimiento. El costo es que la disciplina vive en un solo método y se verifica con pruebas; el diagnóstico cubre lo que se escape.

## Consecuencias

- Cualquier consulta que necesite la verdad usa `ObtenerStock(productoId)` o la suma de movimientos.
- Un producto con descuadre se detecta en soporte (`Productos con stock descuadrado: N`) y se corrige al aplicar la migración.
- Las pruebas de caracterización bloquean regresiones en las reglas de inventario.

## Verificación

- `CaracterizacionInventarioTests` (6 casos) en verde.
- Suite completa: 430 pruebas.
- Migración v17 probada con las pruebas de migración existentes.
