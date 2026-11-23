# Principios de arquitectura

**Estado:** propuesto para el núcleo futuro. No se implementa en Tienda V2.

1. **Monolito modular**, no microservicios.
2. **Núcleo de documentos, pagos, caja y terceros**; verticales retail y gym.
3. **SQLite-first**; proveedor abstracto solo cuando exista un cliente que lo pague.
4. **Sin multi-tenant**; cada instalación es un negocio.
5. **UUIDv7** (`Guid.CreateVersion7()`) para IDs nuevos.
6. **Idempotencia** en operaciones financieras.
7. **Append-only** para documentos; anulación como documento nuevo.
8. **Stock:** log de movimientos + snapshots/cierres para rendimiento.
9. **Saldos:** derivados o actualizados en la misma transacción, con conciliación.
10. **Auditoría** en la misma transacción, con `correlation_id`.
11. **CFDI** como extensión desacoplada, no en el núcleo.
12. **Actualizaciones** con manifiesto, respaldo, migración, verificación y rollback.
13. **Contratos tipados** (DTOs/OpenAPI) cuando se construya API.
14. **Asincronía** en la ruta crítica del núcleo nuevo.
15. **No sobre-generalizar:** una tabla universal con decenas de columnas opcionales es peor que un núcleo de documentos con extensiones.

## Correcciones conocidas

- Gasto en efectivo: un solo efecto sobre caja.
- Anulación: una sola regla de ventas netas.
- Saldos: no cachear sin transacción y conciliación.
- Inventario: no depender solo de `SUM(movimientos)` a largo plazo.
- IDs: no introducir ULID si UUIDv7 nativo alcanza.
- Offline: no prometer sincronización sin cliente que la necesite.
