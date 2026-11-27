# ADR-017 — Clara como producto independiente de finanzas personales

- **Fecha:** 2026-11-27
- **Estado:** Aceptado
- **Hito:** Catálogo de productos SistemaMaestro

## Contexto

Clara nació como un gestor de tareas PWA y evolucionó a una app de finanzas
personales offline: ingresos, egresos, presupuestos, pendientes y reglas
recurrentes. Su README seguía describiendo el producto anterior. No tiene Git,
servidor ni integración con POSale o Centro Fit.

SistemaMaestro agrupa productos para pequeños negocios en México. La tentación
era meter Clara dentro del panel del negocio; eso mezclaría finanzas personales
con caja, empleados y datos fiscales, y rompería su promesa de privacidad.

## Decisión

- Clara es un **producto independiente** del catálogo SistemaMaestro:
  “Clara — finanzas personales del dueño”.
- Se mantiene como **PWA vanilla**, offline y sin servidor. No se reescribe en
  .NET ni se acopla al núcleo.
- El código vive en su **repositorio propio** (`clara`), con Git, SemVer y
  migraciones de esquema. SistemaMaestro la documenta y enlaza, no la incluye
  como submódulo ni copia código dentro de las verticales.
- **Separación estricta:** Clara no lee la base de POSale/Centro Fit y esos
  productos no leen el `localStorage` de Clara. No hay sincronización de ventas,
  caja, inventario ni nómina.
- El retiro de utilidades del negocio se registra en Clara como un **ingreso
  personal explícito**, nunca de forma automática.
- Integración futura máxima: **nivel 1**, exportar/importar un archivo (JSON o
  CSV) de retiros. Nada de servicio local ni API compartida.
- Clara no se convierte en ERP, contabilidad ni CFDI.

## Consecuencias

- El dueño puede usar Clara en su teléfono sin exponer sus finanzas en la PC del
  mostrador.
- El soporte de POSale/Centro Fit no recibe datos personales.
- Hay que resolver la fragilidad de `localStorage`: exportación JSON visible,
  recordatorios de respaldo y `navigator.storage.persist()`.
- No hay multi-dispositivo; se documenta como límite y se cubre con
  exportar/importar.
- El producto se puede vender solo o como complemento; el precio es una
  hipótesis a validar, no una promesa.

## Verificación

- README de Clara corregido a finanzas personales.
- Repositorio Git inicializado; versiones `v1.0.0` y `v1.1.0`; 63 pruebas verdes.
- Ficha de catálogo y recordatorio de respaldo listos en 1.1.0.
- Pendiente: prueba en Android/iOS y validación con 5–10 dueños.
