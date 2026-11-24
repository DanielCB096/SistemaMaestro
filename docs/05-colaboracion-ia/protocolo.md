# Protocolo de colaboración con IA

**Objetivo:** usar varios modelos como revisores especializados, no como oráculos que diseñan todo.

## Roles

| Rol | Experto | Responsabilidad | Límite |
|---|---|---|---|
| Hechos, código y ejecución | DeepSeek | Auditar, verificar, implementar, medir, escribir ADRs | No inventar reglas de negocio |
| Producto, negocio y pricing | ChatGPT | Cliente, oferta, licencias, soporte, orden comercial, validación | No diseñar el esquema de datos |
| Arquitectura y riesgo | Claude | Dominio, concurrencia, seguridad, pruebas, gates, revisión adversarial | No fijar precios ni plazos sin evidencia |
| Producto/UX/operaciones | Gemini | Flujos, onboarding, hardware, soporte, huecos de producto | No afirmar datos fiscales o de hardware sin validar |
| Dueño del proyecto | Daniel | Aprueba, prioriza y valida con clientes | — |

Las skills que cada rol debe cargar viven en [`08-agentes/`](../08-agentes/README.md). Son instrucciones versionadas, no documentos de negocio: las sesiones web no las cargan, solo OpenCode/CLI. El catálogo y las reglas de instalación están en [`08-agentes/catalogo-skills.md`](../08-agentes/catalogo-skills.md).

## Rondas

1. **Decision Brief:** una página con contexto, hechos, decisión, opciones y criterio de aceptación.
2. **Ronda independiente:** cada experto responde su ángulo, sin ver a los otros.
3. **Contraste:** se comparten respuestas anonimizadas; cada uno busca errores y omisiones.
4. **Síntesis:** DeepSeek verifica contra el código y escribe un ADR.
5. **Puerta:** no se implementa hasta que el ADR esté aprobado.

## Reglas

- Etiquetar `[HECHO]`, `[HIPÓTESIS]` o `[RECOMENDACIÓN]`.
- Citar archivos, tablas o métodos cuando se hable de código.
- No aceptar datos fiscales, de hardware o plazos sin verificación.
- Una decisión por ronda; máximo dos rondas.
- No pedir “diseña toda la plataforma” en un solo prompt.
- No tocar repositorios hasta cerrar la decisión.
- No compartir secretos, credenciales ni datos personales en los prompts.

## Plantilla de prompt

```text
Actúa como [rol].
Contexto verificado: [hechos].
Decisión a tomar: [una sola].
Opciones: [A/B/C].
Criterio de aceptación: [medible].
Entrega: [formato, extensión].
Etiqueta cada afirmación como [HECHO], [HIPÓTESIS] o [RECOMENDACIÓN].
No inventes datos; si falta evidencia, dilo.
```

## Cadencia

- Semanal: una pregunta de negocio a ChatGPT y una técnica a Claude.
- Quincenal: revisión de producto/UX con Gemini.
- Mensual: revisión cruzada de decisiones y riesgos.
- Cada decisión cerrada se registra en `docs/07-decisiones/`.

## Cuotas, disponibilidad y continuidad

Los planes gratuitos de ChatGPT, Claude y Gemini tienen límites. Cuando uno se agota, **no se reintenta en bucle**: se anota y se espera al restablecimiento.

Reglas:

1. **El repositorio es la fuente de verdad.** No depender de historiales de chat ni de memoria de sesión.
2. **Presupuesto semanal:** 1–2 preguntas por experto, 3–5 en total. Priorizar decisiones irreversibles.
3. **Un experto principal + un revisor.** El tercero solo para decisiones de alto riesgo; no preguntar lo mismo a los tres.
4. **Si un experto no está disponible:** continuar con los otros, marcar la decisión como “revisión pendiente” y no bloquear la implementación.
5. **La ruta crítica no depende de las IA.** H1–H4 se ejecutan con la evidencia del código y las pruebas; las revisiones son apoyo, no bloqueo.
6. **Guardar cada respuesta** como resumen en `rondas/` y actualizar la cola de preguntas.
7. **Evitar repetir contexto:** usar el Decision Brief y resúmenes; no pegar el informe completo salvo que sea imprescindible.
8. **No gastar cuota en preguntas genéricas.** Cada prompt debe tener una decisión, un criterio de aceptación y un formato de salida.
9. **Si se agota una cuota:** registrar `bloqueada por cuota`, seguir con el plan y retomar cuando se restablezca.

La cola priorizada vive en [`cola-de-preguntas.md`](cola-de-preguntas.md).
