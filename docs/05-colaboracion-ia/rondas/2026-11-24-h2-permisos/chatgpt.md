# Ronda H2 — ChatGPT (producto y negocio)

**Fecha:** 2026-11-24
**Sesión:** ChatGPT web, cuenta Daniel Cuevas Bernal (plan Free).
**Pregunta:** qué puede hacer un empleado sin frenar el mostrador y qué se le puede prometer al dueño.
**Nota:** la tabla venía separada por tabuladores; aquí se recompone como tabla Markdown sin cambiar el contenido.

> Texto tal como lo devolvió la sesión.

SistemaMaestro — Matriz de permisos H2

[RECOMENDACIÓN] Principio rector: el empleado debe poder vender sin acceder a información financiera sensible; el encargado debe administrar la operación diaria sin controlar decisiones reservadas al dueño.

## 1. Matriz rol × acción

| Acción | Dueño | Encargado | Empleado |
|---|---|---|---|
| Consultar productos y precios de venta | Sí | Sí | Sí |
| Registrar ventas | Sí | Sí | Sí |
| Crear clientes de contado | Sí | Sí | Sí |
| Crear clientes para fiado | Sí | Sí | No; solicitar al encargado |
| Consultar saldo de un cliente al cobrar | Sí | Sí | Sí, solo ese cliente |
| Consultar directorio completo y saldos | Sí | Sí | No |
| Crear proveedores | Sí | Sí | No |
| Consultar costo de productos | Sí | Sí | No |
| Consultar margen y utilidad | Sí | Sí | No |
| Consultar reportes operativos | Sí | Sí | Solo ventas propias o del turno |
| Consultar reportes financieros | Sí | Sí | No |
| Exportar CSV/PDF de ventas | Sí | Sí, alcance operativo | No |
| Exportar estados de cuenta | Sí | Sí | No |
| Exportar reportes financieros | Sí | Sí | No |
| Modificar precios, inventario o configuración | Sí | No | No |
| Anular ventas, retiros y ajustes | Sí | Según autorización expresa del dueño | No |
| Administrar usuarios y permisos | Sí | No | No |

## 2. Decisiones importantes

1. **Clientes y proveedores.** [RECOMENDACIÓN] El empleado puede crear clientes de contado, pero no clientes con crédito. El encargado autoriza el alta de clientes fiados y proveedores. Así se evita que cualquier empleado genere obligaciones de cobro o registros de abastecimiento.
2. **Costos, márgenes y utilidad.** [HECHO] Actualmente el empleado puede consultar costos y utilidad mediante reportes. [RECOMENDACIÓN] Ocultar esos datos al empleado y conservarlos para dueño y encargado. El dueño puede recibir esta promesa: «Tus empleados pueden vender y atender clientes sin conocer cuánto te cuesta la mercancía ni cuánto ganas».
3. **Saldo del cliente.** [RECOMENDACIÓN] El empleado necesita conocer el saldo del cliente al cobrar o registrar un abono para evitar errores. No necesita conocer las deudas de todos los clientes.
4. **Exportaciones.** [RECOMENDACIÓN] Reservarlas al dueño y encargado. El empleado no debe poder extraer información comercial, financiera o de clientes mediante CSV/PDF.

## 3. Restricción que probablemente quitará el dueño

[HIPÓTESIS] La creación de clientes fiados por parte del empleado. En negocios pequeños, el dueño puede considerar molesto tener que llamar al encargado cada vez que un cliente conocido solicita crédito.

[RECOMENDACIÓN] Mantener la restricción inicialmente y evaluar una excepción: permitir altas de fiado con límite de crédito y autorización del encargado. No eliminar el control completamente.

## 4. Frase para el empleado

[RECOMENDACIÓN] «Tu trabajo es vender, cobrar y atender clientes. Puedes consultar el saldo del cliente al momento de cobrar, pero no puedes crear créditos, consultar deudas de otros clientes, ver costos o ganancias, exportar reportes, modificar inventario ni manejar la caja. Si necesitas realizar alguna de esas operaciones, debes solicitarla al encargado».

Decisión de producto: H2 debe proteger la información del dueño sin convertir la operación diaria en una cadena de autorizaciones innecesarias.
