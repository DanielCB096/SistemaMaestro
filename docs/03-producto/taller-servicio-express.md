# Taller & Servicio Express — producto propuesto

**Estado:** propuesto por tres IAs; pendiente validación con talleres reales.
**Decisión:** [ADR-018](../07-decisiones/ADR-018-taller-servicio-express.md).
**Base:** POSale (SQLite, caja, tickets, roles, MSI, respaldos).

## Cliente inicial

Taller de **reparación de celulares, cómputo o electrónica** con 1–5 personas,
que hoy trabaja con libreta, notas de papel y WhatsApp. No se apunta todavía a
talleres mecánicos ni línea blanca: piden campos distintos y disparan el soporte.

## Dolor

- Se pierden órdenes y accesorios.
- No saben qué equipo está listo ni quién dejó anticipo.
- El cliente pregunta “¿ya quedó?” todo el día.
- Al entregar, se olvida cobrar el saldo.
- No hay historial por cliente/equipo ni garantía trazable.

## Propuesta de valor

> “Cada equipo con folio, cada anticipo cobrado y cada cliente avisado. Sin libreta.”

## MVP — 5 funciones, 4–8 semanas

1. **Recepción con ticket:** cliente (nombre + WhatsApp), equipo, falla reportada,
   accesorios, precio estimado y fecha promesa; imprime folio y etiqueta.
2. **Tablero de estados:** recibido → en diagnóstico → esperando refacción →
   listo → entregado; filtro por técnico.
3. **Anticipos y liquidación:** abono al recibir, saldo visible y cobro al
   entregar; corte de caja diario.
4. **Aviso por WhatsApp en un clic:** `wa.me` con mensaje prellenado; sin API de
   Meta ni bots.
5. **Historial por cliente/equipo + respaldo automático:** reparaciones previas,
   garantías y copia de seguridad al cerrar turno.

## Reutilización

| Pieza | De dónde sale |
|---|---|
| Base de datos y migraciones | POSale / SQLite |
| Caja, abonos y corte | POSale |
| Tickets e impresión | POSale |
| Roles y permisos | Núcleo |
| Licencia offline y MSI | Núcleo |
| Respaldos y paquete de soporte | Núcleo |

## Precio hipotético

- Licencia: **$4,900–$5,500 MXN**.
- Soporte: **$300–$350 MXN/mes**.
- Pilotos fundadores: **$2,750–$2,900** con 3 meses de soporte a cambio de
  feedback semanal y testimonio.

## Validación de 30 días

| Días | Acción | Meta |
|---|---|---|
| 1–10 | 8–15 entrevistas en talleres de celulares/electrónica | 8 reconocen el problema como importante |
| 11–14 | Demo con ticket impreso y tablero | 3 aceptan pilotear |
| 15–30 | Operación real en 3 talleres | ≥2 capturan ≥80 % de sus órdenes |

**Continuar si:** 3 pilotos con pago parcial y ≥2 usan el sistema para la mayoría
de sus órdenes al día 30.

**Cancelar si:** no hay 3 pilotos con pago al día 10, o menos de 2 usan el sistema
al día 30. No se agregan funciones para rescatar el producto.

## Pieza interna mínima (no producto)

Dentro del instalador, con ~3 días de trabajo:

- Reporte local de versión, licencia y último respaldo exitoso.
- Respaldo automático al cierre.
- Texto “corte del día” listo para pegar en WhatsApp.

No se construye PWA de solo lectura, consola de flota ni panel remoto hasta que
haya al menos 3 productos con clientes de pago.

## Qué NO construir

- Inventario avanzado de refacciones o catálogo de proveedores.
- CFDI, contabilidad, nómina o garantías con contrato legal.
- App móvil para técnicos, GPS o seguimiento en tiempo real.
- WhatsApp Business API, bots o portal de rastreo para clientes.
- SaaS multiempresa o personalizaciones por cliente.
- Campos para mecánica automotriz o línea blanca en la primera versión.

## Riesgos

| Riesgo | Mitigación |
|---|---|
| Cada taller pide campos distintos | Un solo subtipo (celulares/electrónica) y conceptos libres, no catálogo |
| Soporte por respaldos rotos | Respaldo automático y reporte mínimo desde el día 1 |
| “Quiero más clientes, no control” | Preguntar por pérdidas concretas, no por deseos |
| Inventario se vuelve un ERP | Solo refacciones usadas vs. stock, sin compras ni proveedores |
| Precio percibido alto | Piloto fundador con pago parcial y testimonio |

## Preguntas abiertas para las entrevistas

1. ¿Cuántas órdenes recibe al día y dónde las anota?
2. ¿Cuánto cobra de anticipo y cómo lo registra?
3. ¿Cómo avisa que está listo?
4. ¿Qué pasa cuando se pierde un accesorio o una orden?
5. ¿Cómo maneja garantías?
6. ¿Qué hace hoy cuando no encuentra una nota?
7. ¿Pagaría por esto? ¿Cuánto y con qué frecuencia?

## Siguiente paso

No programar todavía. Ejecutar las entrevistas y conseguir 3 pilotos con pago
parcial. Si se cumple, crear el repositorio `taller` con el mismo patrón de
POSale y el MVP de cinco funciones.
