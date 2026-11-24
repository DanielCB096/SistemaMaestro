---
name: seguridad-permisos
description: "Úsala para cambios en autenticación, roles, permisos, sesiones, exportaciones o datos sensibles. Autoriza en el servicio, deniega por defecto y prueba la matriz rol×acción."
---

# Seguridad y permisos

**Versión:** 1.0  
**Prioridad:** P0  
**Dueño:** DeepSeek / Claude  
**Revisión:** 2026-11-23  
**Fuente:** [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md), auditoría, plan H2.

## Propósito

Impedir que un empleado vea utilidades, costos o datos que no le corresponden, y evitar que una exportación o un paquete de soporte filtre información. La seguridad no es ocultar botones: es autorizar en el servicio y probarlo.

## Hechos que debes asumir

- Roles del sistema: Dueño, Encargado y Empleado.
- La matriz de permisos es estática y vive en servicios; la UI también oculta opciones.
- La auditoría detectó: permisos faltantes en altas, lectura excesiva para Empleado, bloqueo de login efímero (vive en una página transitoria), CSV sin escape de fórmulas y base/respaldos sin cifrar.
- H2 debe dejar permisos por acción, bloqueo persistente, timeout de sesión, manejador global y respaldos cifrados.
- H1 ya restringió exportar, restaurar y paquete de soporte al dueño, y valida `Configurar` en el servicio.

## Cuándo se activa

- Altas, bajas o ediciones de usuarios.
- Login, PIN, bloqueo, sesión o timeout.
- Cualquier pantalla o acción que muestre costos, utilidad, caja o reportes.
- Exportaciones CSV/PDF y paquetes de soporte.
- Cambios en la matriz de permisos.
- Manejo de datos personales o logs.

## Reglas inviolables

1. **Autoriza el servicio, no solo la UI.** Ocultar un botón no es un permiso.
2. **Deniega por defecto.** Si la acción no tiene permiso explícito, se rechaza.
3. **Permiso por acción.** No basta “Consultar”: separa altas, lectura, edición, borrado, costos, utilidad, caja, reportes y configuración.
4. **El dueño no es un atajo.** No agregues `if (esDueno)` para saltarte la matriz; el dueño también tiene permisos explícitos.
5. **Bloqueo persistente.** El contador de intentos no puede vivir en una página `Transient`; debe sobrevivir al reinicio.
6. **Timeout de sesión.** La sesión inactiva se cierra; no se queda abierta toda la jornada.
7. **Manejador global.** Una excepción no puede dejar la app en un estado inseguro ni mostrar detalles internos al usuario.
8. **CSV seguro.** Escapa o prefija `=`, `+`, `-` y `@` para evitar inyección de fórmulas.
9. **Datos sensibles con consentimiento.** El paquete de soporte no incluye la base sin autorización explícita.
10. **No secretos en logs.** Ni PIN, ni hashes, ni rutas con datos personales.

## Flujo

1. Identifica la acción y el rol que debe poder ejecutarla.
2. Escribe la fila de la matriz: rol × acción × resultado esperado.
3. Implementa la verificación en el servicio, antes de tocar datos.
4. Agrega una prueba que intente la acción con un rol sin permiso y espere rechazo.
5. Prueba también el rol con permiso para evitar un “deniega todo”.
6. Revisa la UI: puede ocultar, pero no sustituye la verificación.
7. Si hay exportación, prueba el escape de fórmulas.
8. Reporta la matriz y las pruebas.

## Matriz mínima

| Acción | Dueño | Encargado | Empleado |
|---|---|---|---|
| Ver utilidad y costos | sí | según política | no |
| Crear proveedor | sí | sí | no |
| Editar precio/costo | sí | según política | no |
| Anular venta | sí | según política | no |
| Abrir/cerrar caja | sí | sí | sí, con reglas |
| Ver reportes | sí | según política | solo los permitidos |
| Exportar respaldo/soporte | sí | no | no |
| Configurar usuarios | sí | no | no |

La política exacta de Encargado se define con el dueño; lo que no se permite es improvisarla en el código.

## Criterio de aceptación

- Un Empleado no ve utilidad, costos ni crea proveedores.
- El bloqueo de login sobrevive al reinicio.
- La sesión inactiva se cierra.
- La matriz rol×acción está cubierta por pruebas automáticas.
- Un CSV con `=cmd` no se ejecuta al abrirlo.
- El paquete de soporte sin consentimiento no contiene la base.

## Anti-patrones

- `if (usuario.Rol == "Dueño")` desperdigado por la UI.
- Permiso “Consultar” usado para todo.
- Bloqueo en memoria de la página.
- Exportar sin escapar fórmulas.
- Incluir la base “porque es más fácil de diagnosticar”.
- Loguear el PIN o el hash.

## Referencias

- [Auditoría — hallazgos de permisos](../../../00-auditoria/informe-tienda-gym-dotnet.md)
- [Plan maestro v2 — H2](../../../01-plan/plan-maestro-v2.md)
- [H1 — permisos de respaldo](../../../06-referencias/h1-respaldo-restauracion.md)
- `tienda/SistemaTienda/SistemaTienda.Application/Services/AutorizacionService.cs`
- `tienda/SistemaTienda/SistemaTienda.Maui/Services/SesionApp.cs`

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-23 | Creación con hallazgos de auditoría y estado de H1 |
