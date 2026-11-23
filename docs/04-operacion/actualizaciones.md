# Instalación, actualización y rollback

**Estado:** propuesto.  
**Objetivo:** que una actualización fallida no deje al cliente sin sistema.

## Principios

- Un paquete por versión con manifiesto: versión, versión de esquema y firma.
- Antes de actualizar: respaldo automático y verificación de integridad.
- Actualización: aplicar migración, verificar y arrancar en modo de prueba.
- Si falla: restaurar el respaldo y volver a la versión anterior.
- La versión anterior queda disponible junto a la nueva.
- Registrar versión y resultado de cada migración.

## Windows

- Instalador con manifiesto y actualización asistida.
- El instalador no debe borrar datos ni configuración.
- Rollback probado con una base real.

## Android

- La distribución por APK exige asistencia presencial al principio.
- Android no es el canal comercial principal de V2 hasta resolver actualización, respaldo y soporte.
- No prometer actualizaciones automáticas en Android.

## Paquete de soporte

- Archivo comprimido con logs, versión, esquema y copia de la base.
- Permitir excluir datos personales o financieros.
- Protegido con contraseña.
- No enviarlo automáticamente por WhatsApp; requiere consentimiento del cliente.

## Criterios de aceptación

- Actualización interrumpida deja la versión anterior operativa.
- Migración fallida restaura el respaldo.
- El cliente conserva ventas, inventario y configuración.
- El soporte puede diagnosticar sin visita presencial en la mayoría de casos.
