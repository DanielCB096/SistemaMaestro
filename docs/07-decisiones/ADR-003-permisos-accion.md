# ADR-003 — Matriz de permisos por acción

- **Fecha:** 2026-11-24
- **Estado:** Aceptado
- **Hito:** H2.1
- **Consulta:** [ronda H2](../05-colaboracion-ia/rondas/2026-11-24-h2-permisos.md)

## Contexto

Tienda V2 tiene tres roles (dueño, encargado, empleado) y una sola sesión por dispositivo. La auditoría encontró tres huecos:

1. `AgregarClienteFiado` y `AgregarProveedor` no validan permiso: un empleado puede crear registros llamando al servicio.
2. `Consultar` abre los reportes de utilidad, así que el empleado ve costos y márgenes.
3. Exportar CSV/PDF no tiene permiso propio.

Además, la UI oculta botones, pero la autorización real debe vivir en la capa de aplicación.

## Decisión

### Roles y permisos

Se conservan los tres roles y se agregan permisos por tipo de dato y por acción:

| Permiso | Dueño | Encargado | Empleado |
|---|---|---|---|
| `Vender` | Sí | Sí | Sí |
| `Consultar` (catálogo, ventas, caja operativa) | Sí | Sí | Sí |
| `CrearCliente` | Sí | Sí | No |
| `CrearProveedor` | Sí | Sí | No |
| `RegistrarAbono`, `RegistrarGasto` | Sí | Sí | No |
| `EditarCliente`, `EditarProveedor` | Sí | Sí | No |
| `PagarProveedor`, `RegistrarCompra` | Sí | Sí | No |
| `RegistrarEntrada`, `RegistrarMerma` | Sí | Sí | No |
| `AnularVenta` | Sí | Sí | No |
| `CorteCaja`, `IngresoCaja` | Sí | Sí | No |
| `RetiroCaja`, `AjustarInventario`, `DesactivarProducto`, `CambiarPrecios` | Sí | No | No |
| `ExportarDatos` | Sí | Sí | No |
| `VerCostos` | Sí | Solo si se concede | No |
| `Configurar`, `GestionarUsuarios`, `ConsultarBitacora` | Sí | No | No |

`VerCostos` es un permiso **por usuario**, no por rol. Se guarda en `UsuariosSistema.PermisosEspeciales` y el dueño lo concede a un encargado concreto desde **Ajustes → Usuarios y PIN**. Por defecto, ningún encargado lo tiene.

### Qué cubre cada permiso

- **`VerCostos`**: reportes de utilidad, comparación de periodos, costo y margen en inventario y en el detalle de venta, y exportación de reportes financieros.
- **`ExportarDatos`**: CSV/PDF de ventas, caja y estados de cuenta de clientes y proveedores. Los reportes con costo o utilidad exigen además `VerCostos`.
- **`Consultar`**: catálogo, ventas del día y caja operativa, sin costos ni utilidad.

### Autorización en el servicio

1. Todo método público de aplicación que escribe o expone datos sensibles exige su permiso al inicio.
2. Los rechazos devuelven un error explícito y se registran en la bitácora.
3. En operaciones sensibles (anular, precios, restauración, usuarios, exportaciones, cambio de PIN) se revalida el rol leyendo la base, no solo la sesión en memoria.
4. Una prueba de manifiesto enumera los métodos públicos de los servicios y falla si aparece uno nuevo sin revisar, para que no vuelva a colarse un hueco por omisión.
5. La UI oculta o deshabilita lo que el rol no puede hacer, pero nunca es la única defensa.

### Matriz de pestañas

| Pestaña | Dueño | Encargado | Empleado |
|---|---|---|---|
| Inicio | Sí | Sí | Sí |
| Vender | Sí | Sí | Sí |
| Inventario | Sí | Sí | Sí (consulta) |
| Ventas | Sí | Sí | Sí |
| Clientes | Sí | Sí | No |
| Proveedores | Sí | Sí | No |
| Gastos | Sí | Sí | No |
| Caja | Sí | Sí | No |
| Reportes | Sí | Solo con `VerCostos` | No |
| Ajustes | Sí | Sí (solo cerrar sesión) | Sí (solo cerrar sesión) |

## Consecuencias

- El dueño puede prometer: «Tus empleados venden sin ver cuánto te cuesta la mercancía ni cuánto ganas».
- El encargado conserva la operación del turno; pierde costos y utilidad salvo concesión expresa.
- Un empleado no puede crear clientes, proveedores, gastos, abonos ni exportar, aunque llame al servicio directamente.
- El costo de implementación es bajo: permisos nuevos, dos validaciones faltantes, filtros de pestañas y pruebas.

## Lo que queda fuera de H2.1

- Filtrar la pestaña **Ventas** para que el empleado vea solo sus ventas. Se anota como pendiente; hoy ve los importes del día, sin costos.
- Bloqueo persistente, timeout y manejador global: H2.2.
- Respaldos cifrados: H2.3.

## Verificación

- Pruebas de matriz rol × permiso, incluidas llamadas directas al servicio con sesión de empleado.
- Prueba de que un encargado sin `VerCostos` recibe error en el reporte y uno con la concesión lo obtiene.
- Prueba de manifiesto de métodos públicos.
- Revisión manual en Windows con los tres roles.
