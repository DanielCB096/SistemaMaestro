---
name: protocolo-de-cambio
description: "Úsala antes de cualquier cambio de código en tienda para fijar rama, línea base de pruebas, alcance cerrado, evidencia y lista de qué no tocar."
---

# Protocolo de cambio

**Versión:** 1.0  
**Prioridad:** P0  
**Dueño:** DeepSeek  
**Revisión:** 2026-11-23  
**Fuente:** [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md), [ronda de skills](../../../05-colaboracion-ia/rondas/2026-11-23-skills.md).

## Propósito

Evitar que un agente cambie más de lo pedido, mezcle tareas o entregue un cambio sin línea base y sin evidencia. Es la skill que se carga **antes** de tocar cualquier archivo de `tienda`.

## Cuándo se activa

- Cualquier cambio de código, prueba, migración o configuración.
- Cualquier corrección de un bug.
- Cualquier refactorización.
- Cualquier cambio en documentación que acompañe código.

## Cuándo no se activa

- Consultas de solo lectura que no modifican archivos.
- Cambios exclusivos en `SistemaMaestro` que no tocan código de producto.
- Generación de un grafo o de un reporte sin modificar el repositorio.

## Reglas inviolables

1. **Una rama por tarea.** No se trabaja sobre `main` ni se mezclan dos objetivos.
2. **Línea base antes de cambiar.** Ejecutar la suite y registrar el resultado; si ya falla, documentarlo antes de atribuirlo al cambio.
3. **Alcance escrito.** Antes de editar, declarar en una frase qué se va a cambiar y qué no.
4. **Una prueba primero.** Todo bug o comportamiento nuevo empieza con una prueba que falla por la razón correcta.
5. **No tocar lo ajeno.** No se reformatea, renombra o “limpia” código fuera del alcance.
6. **No secretos.** Nunca credenciales, certificados, bases de datos, respaldos ni datos reales de clientes.
7. **Evidencia al final.** Comandos ejecutados, resultados y diff; sin evidencia, el cambio no está terminado.
8. **Documentar la decisión.** Si el cambio altera arquitectura, reglas de negocio o permisos, se actualiza el ADR o se crea uno nuevo.

## Flujo

1. **Leer el contexto:** `AGENTS.md`, `CLAUDE-tienda.md` y el estado del hito en `SistemaTienda/docs/`.
2. **Consultar el grafo** si `graphify-out/graph.json` existe: `graphify query "..."` para ubicar impacto.
3. **Crear rama:** `feat/...`, `fix/...`, `test/...` o `docs/...`, según el caso.
4. **Línea base:** `dotnet build SistemaTienda.sln -c Release` y `dotnet test SistemaTienda.sln -c Release`; anotar el número de pruebas en verde.
5. **Escribir la prueba** que reproduce el problema o fija el comportamiento.
6. **Implementar** el cambio mínimo que hace pasar la prueba.
7. **Ejecutar la suite completa** y revisar el diff contra el alcance declarado.
8. **Actualizar documentación** si cambió una regla, un permiso o una decisión.
9. **Reportar:** rama, archivos, comandos, resultados, riesgos y pendientes.

## Evidencia mínima

| Evidencia | Formato |
|---|---|
| Alcance | Una frase antes del cambio |
| Línea base | Comando y resultado (pruebas en verde) |
| Prueba nueva | Nombre y por qué fallaba antes |
| Resultado final | Build y test completos |
| Diff | Lista de archivos tocados |
| Decisión | Enlace al ADR o documento actualizado |

## Criterio de aceptación

- El diff contiene solo lo declarado.
- La prueba nueva falla sin el cambio y pasa con él.
- La suite completa queda verde.
- El reporte permite a otra persona repetir la verificación.

## Anti-patrones

- “Aproveché para ordenar” archivos fuera del alcance.
- Cambiar código y pruebas en el mismo commit sin línea base.
- Reportar “compila” como si fuera “funciona”.
- Ocultar una prueba que ya fallaba.
- Arreglar un síntoma sin prueba de caracterización.

## Referencias

- `tienda/AGENTS.md`
- `tienda/CLAUDE-tienda.md`
- `tienda/SistemaTienda/docs/estado-h1.md`
- [ADR-001](../../../07-decisiones/ADR-001-tienda-v2-incremental.md)
- [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md)

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-23 | Creación a partir de la ronda de skills y la disciplina observada en H1 |
