# Referencia — `tienda`

**Repositorio:** <https://github.com/DanielCB096/tienda>  
**Producto:** POS local-first para tiendas pequeñas.  
**Stack:** .NET 8 (Core, Infrastructure, Application, Presentation, Tests) + .NET MAUI 10 (Windows/Android) + SQLite.

## Arquitectura real

- `Application` referencia `Infrastructure`; no hay interfaces ni puertos.
- `DatabaseTools` (~1,996 líneas, ~72 métodos, 164 SQL) mezcla persistencia y negocio.
- 18 tablas SQLite, migraciones v1–v14 con `PRAGMA user_version`.
- 293 `[Fact]` + 25 `[Theory]`.
- Todo el acceso a datos es síncrono; 30 handlers `async void` en MAUI.

## Fortalezas

- Reglas de inventario por movimientos, venta atómica, corte de caja, fiado, IVA congelado.
- `Dinero`, `Result`, `Texto`, PDF/CSV, QR, migraciones y respaldos reutilizables.
- Red de pruebas amplia.
- Producto ya vendido y en uso.

## Problemas principales

- Pérdida de datos en Android: respaldos privados sin exportación/restauración in-app.
- Permisos insuficientes: Empleado ve utilidad/costos y puede crear clientes/proveedores.
- Doble fuente de stock; gasto con origen/método independiente; venta mixta duplicada.
- Bitácora fuera de transacción; triggers de inmutabilidad solo en 6 tablas.
- Sin WAL, `busy_timeout`, instancia única ni cifrado.
- Lógica duplicada entre servicios, infraestructura y code-behind.

## Papel en la migración

Base del producto V2 y del futuro kernel. No se reescribe: se corrige, se prueba y se extrae por interfaces.
