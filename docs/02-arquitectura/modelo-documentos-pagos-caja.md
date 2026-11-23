# Modelo conceptual — Documentos, pagos, caja y cuentas

**Estado:** propuesto, no aprobado.  
**Objetivo:** resolver los cuatro defectos detectados en la auditoría sin sobre-generalizar:

1. Doble fuente de stock (`Productos.Stock` vs `SUM(MovimientoInventario)`).
2. Gasto con `Origen` y `MetodoPago` independientes que descuadra caja.
3. Venta mixta contada dos veces en el reporte por método.
4. Historial inmutable solo en algunas tablas.

## 1. Entidades del núcleo

### Documento

- `id` (UUIDv7)
- `tipo`: VENTA | COMPRA | GASTO | MEMBRESIA | ANULACION | DEVOLUCION
- `estado`: BORRADOR | CONFIRMADO | ANULADO
- `fecha_emision`
- `tercero_id` (cliente, socio, proveedor o nulo)
- `referencia_doc_id` (anulación o devolución)
- `subtotal_centavos`, `impuesto_centavos`, `total_centavos`
- `nota`
- `metadatos` (JSON extensible por vertical)

### LineaDocumento

- `documento_id`
- `item_id`
- `descripcion` (congelada)
- `cantidad` (decimal, soporta peso)
- `precio_unitario_centavos`, `costo_unitario_centavos`
- `impuesto_porcentaje`, `impuesto_centavos`
- `importe_centavos`

### PagoDocumento

- `documento_id`
- `medio_pago_id`
- `sesion_caja_id` (nullable)
- `monto_centavos`
- `referencia_externa`

### MedioPago

- `nombre`: EFECTIVO | TARJETA | TRANSFERENCIA | FIADO | CREDITO_VIRTUAL
- `afecta_caja_fisica` (booleano)
- `requiere_referencia` (booleano)

### SesionCaja / MovimientoCaja / DesgloseSesionCaja

- Apertura, cierre, fondo inicial, fondo contado.
- Movimientos de ingreso, retiro y fondo.
- Desglose por denominación.

### ItemCatalogo / MovimientoInventario

- El stock **no** es una columna editable: es la suma del log de movimientos.
- Para rendimiento se permiten snapshots o saldos por cierre, pero la fuente de verdad sigue siendo el log.

### Tercero / CuentaCorriente / MovimientoCuenta

- Tercero: cliente, proveedor, socio o personal.
- Cuenta corriente: fiado, crédito virtual o deuda de proveedor.
- Saldo derivado de movimientos o caché actualizada en la misma transacción, con conciliación.

### EventoAuditoria

- `entidad`, `entidad_id`, `accion`, `antes_json`, `despues_json`
- `usuario_id`, `correlation_id`, `ocurrido_en`
- Se inserta **en la misma transacción** que la operación.

## 2. Validación con tres casos

### Caso 1 — Venta de abarrotes con pago mixto, fiado y anulación

- Documento VENTA con líneas y dos `PagoDocumento`: efectivo y tarjeta.
- El corte suma solo los pagos con `afecta_caja_fisica = true`.
- El reporte por método suma `PagoDocumento`, no `COUNT(*)` por documento.
- Fiado: `PagoDocumento` con medio FIADO + `MovimientoCuenta` de cargo.
- Anulación: documento ANULACION con `referencia_doc_id`; no se modifica la venta original.
- Regla única para “ventas netas”: excluir documentos con estado ANULADO **o** con anulación referenciada; no ambas.

### Caso 2 — Cobro de membresía con vencimiento y crédito

- Documento MEMBRESIA con línea del plan.
- Pago mixto: crédito virtual + efectivo.
- `MovimientoCuenta` carga el crédito utilizado.
- La extensión Gym maneja vencimiento, congelamiento, acceso y renovación.

### Caso 3 — Gasto de caja pagado con tarjeta

- Documento GASTO con `PagoDocumento` TARJETA y `sesion_caja_id = null`.
- No afecta el efectivo del cajón.
- Si se paga en efectivo, un solo registro debe afectar caja; **no** crear pago y retiro a la vez.

## 3. Correcciones obligatorias

1. **Gasto en efectivo:** un único efecto sobre caja. La propuesta original de la revisión independiente lo restaba dos veces.
2. **Anulación:** una sola regla de “ventas netas”.
3. **Saldos:** no mantener caché sin actualización transaccional y conciliación.
4. **Inventario:** no depender solo de `SUM(movimientos)` a largo plazo; usar snapshots por cierre.
5. **IDs:** UUIDv7 nativo en .NET 10; no introducir ULID si no aporta.
6. **Offline:** no prometer sincronización; añadir `nodo_origen_id` e `idempotency_key` cuando exista un cliente que la necesite.

## 4. Decisiones abiertas

- ¿El núcleo se implementa como biblioteca compartida o como proyecto dentro de un monorepo?
- ¿La primera vertical nueva es gimnasio o se valida antes con otro retail?
- ¿CFDI se integra con PAC propio o se deja al cliente autofacturar?
- ¿Se cifra la base completa o solo los respaldos?
