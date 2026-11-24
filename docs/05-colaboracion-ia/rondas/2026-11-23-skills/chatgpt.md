# Ronda de skills — ChatGPT (producto y negocio)

**Fecha:** 2026-11-23  
**Sesión:** ChatGPT web, cuenta Daniel Cuevas Bernal (plan Free)  
**Conversación:** “Sistemas para pueblos”  
**Pregunta:** catálogo de skills para los agentes que trabajan el código, priorizado para reducir riesgo comercial y operativo en 90 días.  
**Estado de la sesión:** la ventana de contexto se llenó al terminar la respuesta; ChatGPT ofreció iniciar un chat nuevo con resumen.

> Texto tal como lo devolvió la sesión. Las tablas venían separadas por tabuladores.

```text
1. Crítica de la lista

[RECOMENDACIÓN] La lista tiene una buena base técnica, pero está demasiado enfocada en tecnologías y no cubre suficientemente los riesgos de operar un producto en negocios reales.

Skill candidata	Decisión	Justificación
graphify	MODIFICAR	Útil para comprender dependencias, pero no debe ser prioridad antes de estabilizar H1.
dotnet-maui	CONSERVAR	Fundamental para Windows-first y la operación de escritorio.
sqlite-local	CONSERVAR	Crítica para integridad, concurrencia y funcionamiento offline.
testing-dotnet	CONSERVAR	Debe incluir pruebas de regresión y aceptación, no solo pruebas unitarias.
seguridad-permisos	CONSERVAR	Protege información financiera, usuarios y operaciones.
adr-decisiones	CONSERVAR	Evita decisiones contradictorias entre agentes.
producto-piloto	CONSERVAR	Conecta el desarrollo con la operación real y los criterios comerciales.

[RECOMENDACIÓN] Agregaría cuatro skills:

backup-recovery: respaldos, exportación, restauración y recuperación.
release-deployment: instalación, actualización y migraciones en equipos de clientes.
soporte-diagnostico: recopilación de logs, diagnóstico y resolución de incidencias.
hardware-pos: impresoras térmicas, lectores, cajones y periféricos compatibles.

[RECOMENDACIÓN] No crearía una skill independiente para cada pequeña tecnología. Las skills deben representar capacidades reutilizables y procedimientos verificables.

2. Catálogo priorizado
Skill	Propósito y activación	Contenido mínimo	Criterio de aceptación	Prioridad
dotnet-maui	Desarrollo o modificación de interfaz, navegación y plataforma Windows.	Estructura del proyecto, patrones existentes, ciclo de vida, manejo de errores y convenciones.	Cambios compatibles con la arquitectura y compilación Windows.	P0
sqlite-local	Cualquier cambio en persistencia, consultas, transacciones o migraciones.	Esquema, migraciones, WAL, busy_timeout, transacciones, concurrencia e índices.	Sin pérdida de datos ni inconsistencias en pruebas.	P0
testing-dotnet	Todo cambio funcional o corrección de defectos.	xUnit, regresión, integración, pruebas de concurrencia y aceptación.	Pruebas reproducibles y cobertura de escenarios afectados.	P0
backup-recovery	Modificaciones a respaldos, exportaciones y restauraciones.	Procedimientos, integridad, recuperación, validación y escenarios de fallo.	Restauración comprobada en una instalación independiente.	P0
seguridad-permisos	Cambios en autenticación, roles, operaciones financieras o datos sensibles.	Matriz de permisos, autorización, sesiones, auditoría y amenazas conocidas.	Ningún usuario ejecuta operaciones fuera de sus permisos.	P0
release-deployment	Preparación de versiones e instalación en clientes.	Instalación, actualización, migraciones, reversión y compatibilidad.	Instalación y actualización verificadas sin perder información.	P0
adr-decisiones	Cuando se modifica arquitectura, dependencias o reglas de negocio importantes.	Formato ADR, contexto, alternativas, decisión y consecuencias.	Toda decisión relevante queda registrada y aprobada.	P1
producto-piloto	Preparación de pilotos y evaluación de funcionalidades.	Flujos comerciales, criterios de aceptación, incidencias y métricas.	Un negocio puede completar sus operaciones sin asistencia constante.	P1
soporte-diagnostico	Errores reportados por clientes o fallos de producción.	Logs, diagnóstico, reproducción, clasificación y evidencia.	Incidencia reproducible o diagnóstico documentado.	P1
hardware-pos	Integración o modificación de periféricos.	Compatibilidad, protocolos, instalación y pruebas físicas.	Hardware probado en el equipo objetivo.	P1
graphify	Exploración del repositorio y análisis de dependencias.	Generación, consulta, actualización y limitaciones del grafo.	Grafo actualizado y útil para identificar impactos.	P2

[RECOMENDACIÓN] P0 significa obligatorio para trabajar en áreas críticas; P1 significa necesario antes de ampliar el piloto; P2 significa útil, pero no bloqueante.

3. Estructura documental

[RECOMENDACIÓN] Mantendría el catálogo en el repositorio SistemaMaestro y las instrucciones ejecutables en OpenCode/CLI.

Texto sin formato
SistemaMaestro/
├── agents/
│   ├── skills/
│   │   ├── dotnet-maui/
│   │   │   └── SKILL.md
│   │   ├── sqlite-local/
│   │   │   └── SKILL.md
│   │   ├── testing-dotnet/
│   │   │   └── SKILL.md
│   │   ├── backup-recovery/
│   │   │   └── SKILL.md
│   │   └── ...
│   ├── roles/
│   │   ├── executor.md
│   │   ├── architect.md
│   │   ├── product.md
│   │   └── ux-operations.md
│   └── SKILLS-CATALOG.md
├── decisions/
│   └── ADR/
├── quality/
│   ├── acceptance-criteria.md
│   └── regression-checklist.md
└── roadmap/
    └── H1-H6.md

Cada SKILL.md debe contener:

Nombre, versión y responsable.
Propósito y alcance.
Cuándo debe activarse.
Cuándo no debe utilizarse.
Procedimiento y restricciones.
Archivos de referencia.
Criterios de aceptación.
Checklist de revisión.
Historial de cambios.

[RECOMENDACIÓN] Las skills deben estar versionadas en Git. Las sesiones web de ChatGPT, Claude y Gemini utilizarán los documentos exportados o compartidos como contexto; no deben asumir que pueden cargar las skills locales.

4. Skills por rol y transversales
Rol	Skills principales
DeepSeek — ejecución	dotnet-maui, sqlite-local, testing-dotnet, backup-recovery, release-deployment, seguridad-permisos.
Claude — arquitectura/riesgo	sqlite-local, seguridad-permisos, testing-dotnet, adr-decisiones, graphify.
Gemini — UX/operaciones	producto-piloto, hardware-pos, soporte-diagnostico, dotnet-maui.
ChatGPT — producto/negocio	producto-piloto, adr-decisiones, soporte-diagnostico.
Daniel — dueño	adr-decisiones, producto-piloto, criterios de aceptación y aprobación de cambios.

[RECOMENDACIÓN] Transversales: testing-dotnet, seguridad-permisos, adr-decisiones y producto-piloto. Todos los agentes deben respetar sus reglas, aunque no ejecuten directamente esas tareas.

Decisión estratégica

[RECOMENDACIÓN] No instalar las once skills de golpe. Implementaría primero las seis P0 y después las P1 conforme avance el proyecto.

Orden inmediato: backup-recovery → sqlite-local → testing-dotnet → seguridad-permisos → dotnet-maui → release-deployment.

[RECOMENDACIÓN] La regla central de SistemaMaestro debe ser: ningún agente modifica código crítico sin consultar la skill correspondiente, respetar los criterios de aceptación y dejar evidencia verificable de sus cambios.
```
