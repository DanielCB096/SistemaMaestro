# ADR-007 — Bitácora dentro de la transacción

- **Fecha:** 2026-11-25
- **Estado:** Aceptado; cobertura completa salvo respaldos
- **Hito:** H4.2 y H4.2b

## Contexto

Los servicios registraban la bitácora **después** de que la operación se confirmaba. Si la escritura de la bitácora fallaba, la venta, el abono o el corte quedaban sin auditoría, y nadie se enteraba.

## Decisión

- La bitácora de las operaciones de dinero se inserta **dentro de la misma transacción** que la operación.
- `DatabaseTools.AgregarBitacora(conn, tx, registro)` es el punto de escritura; si falla, la excepción revierte la operación completa.
- El servicio arma el registro (acción, entidad, usuario, antes, motivo) y lo pasa; la capa de datos completa el identificador y los importes calculados dentro de la transacción.

### Cobertura actual

| Operación | Estado |
|---|---|
| Venta | Atómica |
| Anulación de venta | Atómica |
| Abono de cliente | Atómica |
| Gasto | Atómica |
| Movimiento de caja | Atómica |
| Corte de caja | Atómica |
| Compra a proveedor | Atómica |
| Pago a proveedor | Atómica |
| Entrada de inventario | Atómica |
| Merma | Atómica |
| Ajuste de inventario | Atómica |
| Alta y edición de productos | Atómica |
| Alta y edición de clientes | Atómica |
| Alta y edición de proveedores | Atómica |
| Usuarios, PIN y permisos | Atómica |
| Configuración de la tienda | Atómica |

### Fuera de la transacción

- **Respaldos**: el archivo vive fuera de SQLite y se registra después de crearlo y verificarlo. No hay forma de abarcar archivo y base en una sola transacción.
- **Exportaciones**: son lecturas; no cambian datos y no requieren bitácora.

## Consecuencias

- Una operación de dinero no puede quedar sin rastro: o se guardan ambos, o no se guarda ninguno.
- Si la tabla de bitácora tiene un problema, la operación falla y se muestra el error; es preferible a un registro silencioso.
- El detalle de la bitácora para cortes y compras se calcula dentro de la transacción, así que refleja los importes realmente guardados.

## Verificación

- Las pruebas de bitácora existentes siguen en verde: la entrada se crea una sola vez y con el mismo detalle.
- `BitacoraTransaccionTests` cubre las nuevas operaciones y la reversión de entrada, gasto y venta cuando la bitácora falla.
- La caracterización de caja, reportes e inventario sigue en verde.
- Suite completa: 442 pruebas.
