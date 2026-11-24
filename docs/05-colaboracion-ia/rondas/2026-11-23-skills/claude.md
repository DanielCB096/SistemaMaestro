# Ronda de skills — Claude (arquitectura y riesgo)

**Fecha:** 2026-11-23  
**Sesión:** Claude web, cuenta Dani (plan Free), modelo Sonnet 5.5  
**Conversación:** “Compartir conversación de ChatGPT”  
**Pregunta:** catálogo de skills para los agentes que trabajan el código, priorizado para reducir riesgo técnico en 90 días.  
**Advertencia de la propia sesión:** los hechos del código provienen del informe de DeepSeek y no fueron verificados por Claude.

> Texto tal como lo devolvió la sesión. Las tablas venían separadas por tabuladores.

```text
Claude respondió: Catálogo de skills para agentes de código (90 días)
Catálogo de skills para agentes de código (90 días)

Aclaración: los hechos del código vienen del informe de DeepSeek, no los he verificado. “Skill” aquí significa un documento de instrucciones versionado que el agente carga al activarse.

1) Crítica de la lista
graphify: bajar a P2. [HIPÓTESIS] Con ~16,000 líneas, el grafo ahorra poco; el costo es mantenerlo actualizado y que los agentes confíen en un grafo obsoleto. [RECOMENDACIÓN] Úsalo solo para la fase de desmontar DatabaseTools (~2,000 líneas, 72 métodos públicos, según el informe).
dotnet-maui: reducir y fusionar. [HECHO, según el informe] hay 30 async void sin catch y la lógica está duplicada en code-behind. [RECOMENDACIÓN] Fusiónalo con una skill de “estándares del repo” (async, excepciones, DI, ubicación de reglas de negocio) en lugar de una skill genérica de MAUI.
sqlite-local: mantener y ampliar. Es el centro del riesgo: WAL, busy_timeout, instancia única, migraciones, respaldo consistente con -wal/-shm, date(Fecha) que anula índices.
testing-dotnet: mantener, orientar a caracterización. [RECOMENDACIÓN] Debe cubrir cómo escribir pruebas de caracterización, no teoría de TDD.
seguridad-permisos: mantener, fusionar con datos sensibles. [HECHO, según el informe] permisos de altas, lectura excesiva de Empleado, bloqueo de login efímero, CSV sin escape de fórmulas, sin cifrado. Incluye privacidad del paquete de soporte.
adr-decisiones: mantener, pero ligera. Su valor es auditabilidad, no volumen.
producto-piloto: quitar como skill de código. [RECOMENDACIÓN] Es contexto de negocio de ChatGPT/Gemini; no cambia cómo se escribe código. Va como documento de referencia, no como skill.

Agregar:

release-engineering (instalador, versionado, rollback, migración en campo, paquete de soporte): es H5 y hoy no hay nadie que lo cubra.
dinero-y-reglas-caja (centavos enteros, redondeo, venta mixta, gasto origen/método, fuente única de stock): [HECHO, según el informe] son los bugs de integridad P1.
protocolo-de-cambio (flujo del agente: rama, línea base de pruebas, alcance, qué no tocar): evita que DeepSeek “arregle de más”.
2) Tabla
Skill	Propósito	Cuándo se activa	Contenido mínimo	Criterio de aceptación	Prioridad
protocolo-de-cambio	Disciplina de ejecución	Toda tarea que toque código	Rama dedicada, pruebas base en verde, alcance cerrado, formato de reporte, lista de “no tocar”	Un cambio de prueba reproduce el flujo completo sin intervención	P0
sqlite-local	Persistencia segura	Tocar base, migraciones, respaldo	WAL y copia consistente, busy_timeout, instancia única, migración con respaldo previo, reglas de índices y fechas	Prueba de corte de energía y dos instancias pasa	P0
dinero-y-reglas-caja	Integridad financiera	Ventas, gastos, corte, stock	Reglas de dinero, tabla de casos (mixta, fiado, anulación, gasto), invariantes	Cada regla tiene al menos una prueba que la cite	P0
testing-dotnet	Pruebas de caracterización	Antes de refactorizar	Cómo caracterizar, nombres, datos de prueba, aislamiento de SQLite, qué cuenta como “verde”	La suite detecta una regresión inyectada a propósito	P0
seguridad-permisos	Autorización y datos	Permisos, login, exportaciones	Matriz rol×acción, bloqueo persistente, escape CSV, manejo de datos personales	La matriz se verifica con pruebas automáticas	P0
estandares-repo (ex dotnet-maui)	Convenciones de código	Cualquier cambio en MAUI/Application	Async, excepciones globales, dónde vive cada regla, inyección de dependencias	Revisión con lista de verificación sin hallazgos	P1
release-engineering	Entrega en campo	H5, versiones, soporte	Manifiesto, migración, rollback, paquete de soporte sin datos sensibles	Actualizar y revertir en una máquina limpia	P1
adr-decisiones	Trazabilidad	Decisión que cambia arquitectura	Plantilla, estados, enlace a código/pruebas	Toda decisión P0 tiene un ADR	P1
graphify	Mapa del código	Al desmontar DatabaseTools	Cómo regenerar, límites, cuándo ignorarlo	El grafo coincide con el código a la fecha	P2
3) Estructura y formato

[RECOMENDACIÓN]

SistemaMaestro/
  skills/
    README.md          (índice, reglas de uso)
    CATALOGO.md        (tabla maestra, versión, dueño)
    <nombre>/
      SKILL.md
      ejemplos/
      CHANGELOG.md
  decisiones/          (ADR)

Cada SKILL.md lleva: encabezado con versión, estado, fecha de revisión, rol dueño; después propósito, cuándo se activa, cuándo no, reglas, ejemplos, anti-patrones, criterio de aceptación y enlaces a pruebas y ADR. [HECHO] El código vive en tienda, así que el repo de tienda debe tener un puntero a la versión del catálogo que usó cada cambio.

Auditabilidad: [RECOMENDACIÓN] toda skill se versiona en git; cada tarea de agente cita qué skill y versión usó; el cambio de una skill P0 requiere ADR y revisión de otro rol.

4) Por rol y transversales
Transversales: protocolo-de-cambio, adr-decisiones, seguridad-permisos, dinero-y-reglas-caja (todos deben conocer estas reglas).
DeepSeek (ejecución): sqlite-local, testing-dotnet, estandares-repo, graphify.
Claude (arquitectura/riesgo): adr-decisiones como autor, revisión de seguridad-permisos y dinero-y-reglas-caja.
Gemini (UX/operaciones): release-engineering en su parte de instalación y soporte.
ChatGPT (negocio): producto-piloto como documento, no como skill.
Riesgos
[HIPÓTESIS] Un catálogo grande que nadie mantiene es peor que uno pequeño: empieza con las 5 P0 y añade el resto cuando una tarea real lo pida.
[HIPÓTESIS] Las skills que describen reglas (dinero, permisos) pueden quedar desfasadas respecto al código; por eso cada una exige una prueba que la cite.
[RECOMENDACIÓN] Verifica que OpenCode realmente cargue la skill: haz una tarea de prueba cuya respuesta correcta dependa de ella.
```
