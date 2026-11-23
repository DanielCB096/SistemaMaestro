# Cola de preguntas a expertos

**Regla:** una decisión por pregunta. Si un experto agota su cuota, se marca `bloqueada por cuota` y se espera al restablecimiento; no se reintenta en bucle.

**Estados:** `pendiente` · `enviada` · `respondida` · `bloqueada por cuota` · `descartada`.

## Semana actual

| Prioridad | Experto | Pregunta | Decisión que cierra | Estado |
|---|---|---|---|---|
| 1 | ChatGPT | Guion de venta, objeciones y contrato de piloto | Cómo vender V2 antes y durante el piloto | pendiente |
| 1 | Claude | Especificación de H1–H4 con pruebas y criterios de aceptación | Qué se implementa primero | pendiente |
| 2 | Gemini | Flujos de onboarding, venta rápida, corte ciego y soporte | UX mínima vendible | pendiente |
| 2 | Claude | Instalador, actualización, rollback y paquete de soporte | Cómo actualizar en campo | pendiente |
| 3 | ChatGPT | Validación de precios con 5 entrevistas | Precio y alcance de licencia | pendiente |
| 3 | Gemini | Checklist de instalación en un negocio real | Criterio de “listo para vender” | pendiente |
| 4 | Claude | Correcciones al modelo de documentos/pagos/caja | Modelo financiero del núcleo | respondida parcialmente |
| 5 | ChatGPT | CFDI: autofactura vs. PAC | Alcance fiscal futuro | bloqueada por validación con contador |

## Preguntas que no son para IA

- **CFDI:** validar con contador.
- **Hardware:** probar impresora, lector y cajón reales.
- **Licencia GymCore:** revisar propiedad/licencia con el autor.
- **Precios:** validar con clientes reales, no con modelos.

## Reglas de uso

1. No enviar el informe completo si un resumen de 1 página basta.
2. Pedir salida etiquetada `[HECHO]`, `[HIPÓTESIS]`, `[RECOMENDACIÓN]`.
3. Pedir máximo 700–900 palabras.
4. Guardar la respuesta como resumen en `rondas/`.
5. Actualizar esta tabla después de cada ronda.
6. Si la cuota se agota, continuar con el plan y retomar después.
