# Hardware y pruebas de campo

**Estado:** propuesto.  
**Objetivo:** no prometer compatibilidad universal; validar modelos concretos antes del piloto.

## Matriz mínima

| Prueba | Criterio de paso | Estado |
|---|---|---|
| Impresora térmica USB 58/80 mm | Ticket legible, acentos correctos, corte de papel | Pendiente |
| Impresora térmica de red | Impresión sin driver propietario en el equipo objetivo | Pendiente |
| Lector de código de barras USB-HID | Captura sin perder dígitos con escaneos rápidos | Pendiente |
| Cajón de dinero RJ11 | Se abre solo en venta en efectivo, mediante impresora compatible | Pendiente |
| Báscula serial/USB | Documentar compatibilidad; **no prometer** en V2 | Pendiente |
| Corte de energía durante venta | Venta completa o inexistente, nunca parcial | Pendiente |
| Corte durante respaldo | Respaldo anterior intacto | Pendiente |
| Corte durante migración | Arranca en versión previa o completa; sin base corrupta | Pendiente |
| Corte durante corte de caja | Estado consistente al reiniciar | Pendiente |
| Disco lleno | Error claro, sin corrupción | Pendiente |

## Reglas

- Probar con hardware económico disponible en México; documentar marca y modelo.
- El cajón depende de la impresora: no basta con que el conector sea RJ11.
- La báscula queda fuera de la promesa comercial de V2.
- Todo modelo validado se registra aquí con fecha, versión y resultado.
