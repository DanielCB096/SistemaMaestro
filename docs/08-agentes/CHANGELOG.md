# Changelog de agentes y skills

## 2026-11-23 — v1.2 `backup-recovery`

- H1 mergeado a `main` (PR #40, `41c5983`).
- Se documenta la deuda post-merge: Android, otro equipo físico, corte de energía y prueba con dueño no técnico.

## 2026-11-23 — v1.1 `backup-recovery`

- Se documenta el fallback de exportación a Escritorio/Descargas cuando Documentos no es escribible.
- Se actualiza el estado: 376 pruebas; verificación manual Windows W1–W5 y W8 pasan.
- Quedan pendientes Android, otro equipo físico, corte de energía y prueba con dueño no técnico.

## 2026-11-23 — v1.0

- Se consulta a ChatGPT, Claude y Gemini sobre el catálogo de skills.
- Se crea el catálogo con 6 P0, 4 P1 de ejecución, 2 documentos de contexto y 1 herramienta.
- Se crean las 6 skills P0:
  - `protocolo-de-cambio`
  - `sqlite-local`
  - `dinero-y-reglas-caja`
  - `testing-dotnet`
  - `seguridad-permisos`
  - `backup-recovery`
- Se instalan en OpenCode (`~/.config/opencode/skills/`) y en el espejo genérico (`~/.agents/skills/`).
- Se instala `graphify` como herramienta P2 y se genera el grafo AST de `tienda`.
- Se crea el ADR-002 en estado propuesto.
- Se documenta que las sesiones web no cargan skills locales.

## Plantilla para cambios

```text
## YYYY-MM-DD — vX.Y

- Skill:
- Cambio:
- Razón:
- Evidencia (prueba o comando):
- Aprobó:
```
