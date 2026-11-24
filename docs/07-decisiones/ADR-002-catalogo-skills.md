# ADR-002 — Catálogo de skills para los agentes

**Estado:** propuesto (pendiente de aprobación de Daniel).  
**Fecha:** 2026-11-23.  
**Decisores:** Daniel Cuevas Bernal; consultas a ChatGPT, Claude y Gemini; verificación de DeepSeek.  
**Reemplaza:** ninguno.  
**Relacionado:** [ADR-001](ADR-001-tienda-v2-incremental.md), [ronda de skills](../05-colaboracion-ia/rondas/2026-11-23-skills.md).

## Contexto

Los agentes que trabajan el código no comparten un conjunto explícito de instrucciones. Cada sesión depende de la memoria del chat, de `AGENTS.md` o de lo que el modelo recuerde. Eso produce cuatro riesgos recurrentes:

- Cambios fuera de alcance y sin línea base de pruebas.
- Reglas de dinero, stock y permisos aplicadas de forma distinta en cada tarea.
- Decisiones que no quedan registradas ni son auditables.
- Sesiones web que creen poder cargar archivos locales cuando no pueden.

La auditoría de `tienda` confirma que los riesgos no son teóricos: `DatabaseTools` concentra ~1,996 líneas y ~72 métodos públicos; hay 30 handlers `async void`; `date(Fecha)` inutiliza índices; faltan permisos en altas; el bloqueo de login es efímero; el CSV no escapa fórmulas; la base y los respaldos no están cifrados. H1 ya corrigió WAL, `busy_timeout`, instancia única y respaldo/restauración, pero el conocimiento sigue disperso.

## Decisión

Adoptar un catálogo versionado de **13 artefactos**:

- **6 skills P0 de ejecución:** `protocolo-de-cambio`, `sqlite-local`, `dinero-y-reglas-caja`, `testing-dotnet`, `seguridad-permisos`, `backup-recovery`.
- **4 skills P1 de ejecución:** `estandares-repo`, `pos-ux`, `release-y-soporte`, `hardware-pos`.
- **2 documentos de contexto:** `producto-piloto`, `adr-decisiones`.
- **1 herramienta:** `graphify`.

Reglas de adopción:

1. La fuente de verdad vive en `docs/08-agentes/skills/`; el espejo ejecutable se instala en `~/.config/opencode/skills/`.
2. Solo se instalan las 6 P0 al inicio. Las P1 se crean cuando la tarea que las activa está en curso.
3. Las sesiones web de ChatGPT, Claude y Gemini usan el catálogo como documento de contexto; no cargan skills locales.
4. Toda skill P0 debe citar una prueba o un comando verificable.
5. Cambiar una skill P0 requiere un ADR nuevo y revisión de otro rol.
6. Revisión mensual: si una skill no se usó en 90 días, se revisa o se retira.

## Alternativas

| Alternativa | Pros | Contras | Riesgo |
|---|---|---|---|
| A. No crear skills | Cero mantenimiento | Cada sesión repite los mismos errores; no hay auditoría | Alto |
| B. Una sola skill gigante | Un solo archivo | Mezcla roles, reglas y tecnologías; nadie la mantiene | Alto |
| C. Catálogo P0 primero (elegida) | Foco en riesgo; instalación gradual; auditable | Requiere disciplina de mantenimiento | Medio |
| D. Instalar las 13 de golpe | Cobertura inmediata | Ruido, skills vacías o desfasadas, más carga para el agente | Medio-alto |

## Consecuencias

**Positivas**

- Un cambio de código cita la skill y su versión; el reporte se vuelve verificable.
- Las reglas de dinero, permisos y respaldo dejan de depender de la memoria del chat.
- Los roles tienen un límite claro: ejecución, arquitectura, negocio y UX.
- Las sesiones web reciben un documento de contexto pequeño en lugar de todo el repositorio.

**Negativas**

- Hay que mantener 6 skills P0 y actualizarlas cuando cambie el código.
- Una skill desfasada puede dar falsa confianza.

**Mitigaciones**

- Cada regla P0 tiene una prueba que la cita.
- Revisión mensual y retiro de skills sin uso.
- El código sigue siendo la evidencia final; la skill no sustituye la prueba.

## Evidencia

- [Ronda de skills 2026-11-23](../05-colaboracion-ia/rondas/2026-11-23-skills.md)
- [Respuesta de ChatGPT](../05-colaboracion-ia/rondas/2026-11-23-skills/chatgpt.md)
- [Respuesta de Claude](../05-colaboracion-ia/rondas/2026-11-23-skills/claude.md)
- [Respuesta de Gemini](../05-colaboracion-ia/rondas/2026-11-23-skills/gemini.md)
- [Auditoría técnica](../00-auditoria/informe-tienda-gym-dotnet.md)
- [Métricas y evidencia](../00-auditoria/metricas-y-evidencia.md)
- [H1 implementado](../06-referencias/h1-respaldo-restauracion.md)

## Criterio de salida

El ADR pasa a **aprobado** cuando Daniel confirma el catálogo y las 6 skills P0 se instalan y superan su tarea de prueba. Si una skill P0 no se puede verificar, no se instala: se corrige o se retira.
