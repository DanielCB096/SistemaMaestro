# Cola de preguntas a expertos

**Regla:** una decisión por pregunta. Si un experto agota su cuota, se marca `bloqueada por cuota` y se espera al restablecimiento; no se reintenta en bucle.

**Estados:** `pendiente` · `enviada` · `respondida` · `bloqueada por cuota` · `descartada`.

## Semana actual

| Prioridad | Experto | Pregunta | Decisión que cierra | Estado |
|---|---|---|---|---|
| 0 | ChatGPT + Claude + Gemini | Criterio de aceptación manual de H1 | Qué evidencia exige el merge | respondida |
| 0 | ChatGPT + Claude + Gemini | Catálogo de skills para los agentes que trabajan el código | Qué skills crear, priorizar y documentar | respondida |
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

## Aprobación 2026-11-23

Las 7 preguntas de aprobación fueron respondidas por ChatGPT, Claude y Gemini. Resultado: H1 autorizado; precios y piloto quedan condicionados a validación real. Ver [`rondas/2026-11-23-aprobacion.md`](rondas/2026-11-23-aprobacion.md).

## Skills 2026-11-23

La ronda de skills fue respondida por ChatGPT, Claude y Gemini. Resultado: catálogo de 6 P0, 4 P1 de ejecución, 2 documentos de contexto y 1 herramienta. Ver [`rondas/2026-11-23-skills.md`](rondas/2026-11-23-skills.md) y [`08-agentes/catalogo-skills.md`](../08-agentes/catalogo-skills.md).

## Verificación H1 2026-11-23

La ronda de verificación fue respondida por ChatGPT, Claude y Gemini. Resultado: H1 en Windows pasa en su núcleo (W1–W5, W8); quedan Android, otro equipo, corte de energía y prueba con dueño no técnico. Ver [`rondas/2026-11-23-verificacion-h1.md`](rondas/2026-11-23-verificacion-h1.md).

Próximas preguntas derivadas:

| Experto | Pregunta | Decisión que cierra | Estado |
|---|---|---|---|
| Claude | Revisar las 6 skills P0 contra el código real | Si las reglas son verificables | pendiente |
| Gemini | Validar los flujos de mostrador de `pos-ux` | Si la UX mínima es vendible | pendiente |
| ChatGPT | Convertir `producto-piloto` en guion y checklist comercial | Oferta y piloto | pendiente |

| Pregunta | Estado |
|---|---|
| Windows-first | aprobado |
| Cliente ideal y alcance | aprobado |
| Precios | tentativo; validar |
| Piloto | aprobado el orden; fecha por puertas |
| CFDI | aprobado como extensión |
| Validaciones externas | ampliadas |
| Iniciar H1 | **en ejecución** |

## Reglas de uso

1. No enviar el informe completo si un resumen de 1 página basta.
2. Pedir salida etiquetada `[HECHO]`, `[HIPÓTESIS]`, `[RECOMENDACIÓN]`.
3. Pedir máximo 700–900 palabras.
4. Guardar la respuesta como resumen en `rondas/`.
5. Actualizar esta tabla después de cada ronda.
6. Si la cuota se agota, continuar con el plan y retomar después.
