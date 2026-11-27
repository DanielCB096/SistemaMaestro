# Pendientes de POSale (tienda)

**Estado:** POSale está funcionalmente completo en Windows; quedan pendientes de campo, comerciales y mejoras opcionales.  
**Fecha:** 2026-11-27.  
**Fuente:** consolidado de [`deuda-tecnica.md`](../../tienda/SistemaTienda/docs/deuda-tecnica.md), [`roadmap.md`](../../tienda/SistemaTienda/docs/roadmap.md), [`h1-post-merge.md`](h1-post-merge.md), [`h2-pendientes.md`](h2-pendientes.md) y `tienda/SistemaTienda/docs/08-piloto/`.

> Nada de esta lista bloquea el uso diario en Windows. Lo que sigue se ordena por lo que más acerca a una venta real y a un piloto estable.

## 1. Campo y validación (no requiere código)

| # | Pendiente | Prioridad | Cómo cerrarlo |
|---|---|---|---|
| C1 | Instalador en máquina limpia | Alta | Instalar el paquete de Windows en un equipo sin SDK, crear tienda, vender, respaldar y restaurar |
| C2 | Actualización desde una versión anterior | Alta | Instalar una versión previa, actualizar con el paquete nuevo y comprobar que conserva datos y revierte si falla |
| C3 | Restaurar en otro equipo con la tarjeta | Alta | Llevar un `.db.stb` y la clave a otro PC, restaurar y comparar conteos |
| C4 | Restauración guiada en Android | Alta | Repetir el flujo del asistente y de la pantalla de arranque fallido en el teléfono |
| C5 | Bloqueo por inactividad en Android | Media | Dejar la caja sola los minutos configurados y volver |
| C6 | Intentos fallidos en Android | Media | Fallar 5 veces el PIN y comprobar el bloqueo de 3 minutos |
| C7 | Segundo dispositivo/tableta | Alta | Instalar el APK en otro Android 10+ arm64 y repetir el checklist |
| C8 | Corte de energía real | Alta | Apagar durante venta, respaldo, migración, restauración y corte; validar WAL y recuperación |
| C9 | Escáner físico | Media | Probar un lector USB/Bluetooth con códigos reales |
| C10 | Medición instrumentada de búsqueda | Baja | Medir con 3,000 productos en el dispositivo final y registrar resultados |
| C11 | Piloto de 30 días | Alta | Ejecutar el kit de `08-piloto/` en una tienda real y registrar incidencias |

## 2. Comercial y entrega

| # | Pendiente | Prioridad | Cómo cerrarlo |
|---|---|---|---|
| V1 | Contrato de licencia y soporte | Alta | Borrador con alcance, una caja/sucursal, soporte, actualizaciones, datos y terminación |
| V2 | One-pager / página de venta | Alta | Precio, qué incluye, qué no incluye, requisitos y proceso de instalación |
| V3 | Validar precio con 5 dueños | Alta | Entrevistas del cliente ideal; ajustar $5,900/$7,900 y soporte |
| V4 | Proceso de entrega | Alta | Checklist: instalación, catálogo, usuarios/PIN, capacitación, respaldo y licencia |
| V5 | Soporte y SLA | Media | Horario, canal, tiempo de respuesta y qué no cubre |
| V6 | Respaldo de la llave privada | Alta | Guardar `%USERPROFILE%\.posale\private.pem` fuera del equipo; probar reemisión de una licencia |
| V7 | Reemisión de licencia | Media | Procedimiento para cliente que pierde el archivo o cambia de equipo |
| V8 | CFDI | Baja | Solo si un cliente lo paga; hoy es extensión futura, no se promete |
| V9 | Precio de instalación/capacitación | Media | Confirmar $1,000–$1,500 y qué incluye |

## 3. Producto (mejoras opcionales)

| # | Pendiente | Prioridad | Nota |
|---|---|---|---|
| P1 | Devolución parcial por producto | Alta | Hoy solo se anula la venta completa; falta devolver uno o varios renglones |
| P2 | Arqueo ciego | Alta | El cajero declara el efectivo antes de ver el esperado |
| P3 | Impresión térmica de tickets | Media | Bluetooth/USB; hoy se comparte texto, PNG o PDF |
| P4 | Etiquetas con código de barras | Media | Para productos nuevos o sin código |
| P5 | Respaldo a USB o carpeta de red | Media | Además de la copia local; no incluye nube |
| P6 | Reporte de mermas | Media | Por motivo, producto y periodo, con costo perdido |
| P7 | Filtro por categoría en inventario | Baja | El catálogo ya guarda categoría |
| P8 | Comparación por producto entre periodos | Media | Reportes ya compara totales; falta por producto |
| P9 | Baja/reactivación de usuarios | Media | El cambio de PIN ya existe; falta baja lógica sin borrar historial |
| P10 | Recordatorio de fiado | Baja | Compartir saldo por WhatsApp/texto desde el estado de cuenta |
| P11 | Comprobante de reembolso | Baja | Imprimir o compartir el reembolso registrado |
| P12 | Precios de mayoreo | Baja | Requiere reglas por cantidad o cliente |
| P13 | Multitienda, nube, sincronización, básculas | Baja | Solo con demanda de un cliente que lo pague |

## 4. Deuda técnica

| # | Pendiente | Impacto |
|---|---|---|
| T1 | La app MAUI no tiene pruebas automatizadas de interfaz | Un error de pantalla se detecta en verificación manual |
| T2 | Funciones nuevas (licencia, reembolsos, descuentos, costo, ventas por día) solo verificadas en Windows | Falta Android y segundo fabricante |
| T3 | La bitácora de respaldos se escribe después del archivo | Si falla, el respaldo existe sin registro; no afecta ventas ni stock |
| T4 | El respaldo automático solo se evalúa al iniciar o cerrar | Sesiones de varios días pueden quedar con copia vieja; el dueño decidió no priorizarlo |
| T5 | El QR del ticket es informativo y limitado a 10 productos | No es comprobante fiscal ni valida la venta |
| T6 | Reportes sin comparación por producto ni ventas por hora | Mejora futura |
| T7 | `Busqueda_3000Productos_RespondeRapido` es sensible a la carga del equipo | Puede fallar de forma intermitente en suites paralelas; no es un fallo funcional |
| T8 | Migraciones probadas desde versiones anteriores sin `DROP COLUMN` | Ya corregido con inicialización parcial; mantener esa convención |
| T9 | Registros antiguos de clientes/proveedores conservan `FechaRegistro` en UTC | No se reescriben; solo afecta la fecha mostrada de registros previos al 2026-11-19 |

## 5. Decisiones abiertas

1. ¿La licencia se queda solo como aviso o se bloqueará en una versión futura? Hoy es solo aviso por decisión del dueño.
2. ¿CFDI se cotiza como extensión o se descarta?
3. ¿El siguiente vertical es gimnasio, o se extrae primero el núcleo compartido?
4. ¿Se cobra la instalación/capacitación o va incluida en el precio?

## Lo que ya quedó cerrado

- Ventas por rango, reportes por producto/categoría y ventas por día.
- Descuento por producto y atajo para toda la venta.
- Costo del catálogo en entradas y precio sugerido con margen en pesos.
- Reembolsos de ventas anuladas por método y en partes.
- Licencia offline perpetua con prueba de 30 días y avisos sin bloqueo.
- Prueba de día completo y escenario `demo` con todos los casos.
- 545 pruebas en verde; migrador y pruebas de SQLite sin conexiones con esquema viejo.
