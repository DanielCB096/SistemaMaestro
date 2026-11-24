# Roles y skills

**Versión:** 1.0 (propuesta).  
**Fecha:** 2026-11-23.  
**Base:** [Protocolo de colaboración con IA](../05-colaboracion-ia/protocolo.md) y [catálogo de skills](catalogo-skills.md).

## Principio

Un rol no “posee” todas las skills: **responde por ellas**. Las skills transversales obligan a todos; las específicas las usa quien ejecuta esa tarea. La sesión web de cada experto no carga skills locales, así que el catálogo se comparte como documento de contexto.

## Matriz

| Rol | Responsabilidad | Skills principales | Skills transversales |
|---|---|---|---|
| **Daniel (dueño)** | Aprueba, prioriza y valida con clientes | `adr-decisiones`, `producto-piloto` | Todas las P0 |
| **DeepSeek (OpenCode)** | Audita, implementa, mide y escribe ADRs | `protocolo-de-cambio`, `sqlite-local`, `dinero-y-reglas-caja`, `testing-dotnet`, `seguridad-permisos`, `backup-recovery` | `producto-piloto`, `adr-decisiones` |
| **Claude (arquitectura/riesgo)** | Dominio, concurrencia, seguridad, pruebas y revisión adversarial | `sqlite-local`, `seguridad-permisos`, `dinero-y-reglas-caja`, `testing-dotnet`, `adr-decisiones` | `protocolo-de-cambio`, `producto-piloto` |
| **ChatGPT (producto/negocio)** | Cliente, oferta, precios, soporte y validación comercial | `producto-piloto`, `adr-decisiones` | `seguridad-permisos`, `backup-recovery` |
| **Gemini (UX/operaciones)** | Flujos, onboarding, hardware, soporte y capacitación | `pos-ux`, `release-y-soporte`, `hardware-pos`, `producto-piloto` | `seguridad-permisos`, `backup-recovery` |

## Reglas por rol

### Daniel — dueño

- Aprueba el catálogo y los cambios de prioridad.
- No necesita ejecutar skills técnicas; sí debe poder leer sus criterios de aceptación.
- Decide cuándo una skill P1 se convierte en P0.

### DeepSeek — ejecución

- Es el único que modifica código en `tienda`.
- Debe cargar `protocolo-de-cambio` antes de cualquier cambio.
- No inventa reglas de negocio: si una regla no está en el catálogo, en el ADR o en una prueba, pregunta.
- Deja evidencia verificable: comandos, resultados, diff y prueba.

### Claude — arquitectura y riesgo

- Revisa las skills P0 de dinero, permisos y persistencia antes de aprobar un cambio estructural.
- No fija precios ni plazos sin evidencia.
- Su salida se usa como revisión adversarial, no como sustituto de la prueba.

### ChatGPT — producto y negocio

- Mantiene `producto-piloto` y la promesa comercial.
- No diseña el esquema de datos ni cambia reglas de dinero.
- Las decisiones de precio y piloto se validan con clientes reales.

### Gemini — UX y operaciones

- Mantiene `pos-ux`, `hardware-pos` y `release-y-soporte` en su parte operativa.
- No afirma compatibilidad de hardware sin prueba física.
- Traduce las reglas de mostrador a criterios verificables.

## Flujo de una tarea

1. **Clasificar:** ¿qué skills activa la tarea?
2. **Cargar:** leer la skill P0 correspondiente y su criterio de aceptación.
3. **Verificar línea base:** pruebas actuales en verde.
4. **Ejecutar:** seguir el flujo de la skill.
5. **Probar:** la prueba debe fallar antes y pasar después.
6. **Registrar:** actualizar ADR o documento si cambió una regla.
7. **Reportar:** qué skill se usó, qué se verificó y qué quedó pendiente.

## Cuotas y continuidad

- Si un experto no está disponible, se marca “revisión pendiente” y no se bloquea la ejecución.
- La ruta crítica H1–H4 se ejecuta con evidencia del código y pruebas; las revisiones son apoyo.
- No se reintenta en bucle cuando una cuota se agota.
