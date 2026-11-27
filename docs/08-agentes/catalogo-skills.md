# Catálogo de skills

**Versión:** 1.0 (propuesta).  
**Fecha:** 2026-11-23.  
**Decisión:** [ADR-002](../07-decisiones/ADR-002-catalogo-skills.md).  
**Ronda:** [2026-11-23-skills](../05-colaboracion-ia/rondas/2026-11-23-skills.md).

## Tabla maestra

| # | Skill | Tipo | Prioridad | Propósito | Se activa cuando | Dueño | Estado |
|---:|---|---|---|---|---|---|---|
| 1 | [`protocolo-de-cambio`](skills/protocolo-de-cambio/SKILL.md) | ejecución | P0 | Rama, línea base, alcance cerrado y evidencia | Cualquier cambio de código | DeepSeek | instalada |
| 2 | [`sqlite-local`](skills/sqlite-local/SKILL.md) | ejecución | P0 | Integridad, concurrencia, migraciones y WAL | Esquema, consultas, respaldo | DeepSeek/Claude | instalada |
| 3 | [`dinero-y-reglas-caja`](skills/dinero-y-reglas-caja/SKILL.md) | ejecución | P0 | Centavos, ventas mixtas, gastos, stock y corte | Ventas, caja, inventario, reportes | DeepSeek/Claude | instalada |
| 4 | [`testing-dotnet`](skills/testing-dotnet/SKILL.md) | ejecución | P0 | Pruebas de caracterización y regresión | Antes de refactorizar o corregir | DeepSeek | instalada |
| 5 | [`seguridad-permisos`](skills/seguridad-permisos/SKILL.md) | ejecución | P0 | RBAC, bloqueo, sesión y datos sensibles | Auth, permisos, exportaciones | DeepSeek/Claude | instalada |
| 6 | [`backup-recovery`](skills/backup-recovery/SKILL.md) | ejecución | P0 | Respaldo, restauración y paquete de soporte | H1, migraciones y soporte | DeepSeek | instalada |
| 7 | `estandares-repo` | ejecución | P1 | Async, excepciones, DI y ubicación de reglas | Cualquier cambio en MAUI/Application | DeepSeek | definida |
| 8 | `pos-ux` | ejecución | P1 | Teclado, lector, contraste y corte ciego | H2, H4, H6 y vistas XAML | Gemini/DeepSeek | definida |
| 9 | `release-y-soporte` | ejecución | P1 | Instalador, migración, rollback, soporte y CSV | H5, H6 y versiones | DeepSeek/Gemini | definida |
| 10 | `hardware-pos` | ejecución | P1 | ESC/POS, cajón, lector USB y emulación | H6 y hardware físico | Gemini/DeepSeek | definida |
| 11 | `producto-piloto` | contexto | P1 | Alcance, cliente ideal, exclusiones y aceptación | Inicio de tarea o cambio de alcance | ChatGPT/Gemini | definida |
| 12 | `adr-decisiones` | contexto | P1 | Contexto, decisión, consecuencias y evidencia | Decisión estructural o cierre de hito | Claude/DeepSeek | definida |
| 13 | `graphify` | herramienta | P2 | Grafo consultable de código y documentos | Exploración, impacto y desmontaje | DeepSeek | instalada |
| 14 | [`preguntar-a-las-ias`](skills/preguntar-a-las-ias/SKILL.md) | herramienta | P2 | Debate multi-modelo en el navegador: roles, dos rondas y síntesis | Decisiones de producto, arquitectura, precios o UX | DeepSeek/Claude | instalada |

## Criterios de prioridad

- **P0:** obligatoria antes de tocar código crítico. Su ausencia puede causar pérdida de datos, permisos indebidos, regresiones o un cambio imposible de auditar.
- **P1:** necesaria antes de ampliar el piloto o antes de H5/H6. Se crea cuando la tarea que la activa está en curso.
- **P2:** apoyo. No bloquea la venta ni la integridad; se usa cuando ahorra tiempo real.

## Detalle por skill

### P0

#### `protocolo-de-cambio`

- **Problema:** el agente toca más de lo pedido, no deja línea base o mezcla cambios.
- **Regla central:** toda tarea tiene rama, alcance escrito, línea base de pruebas y reporte con evidencia.
- **Criterio:** un cambio de prueba reproduce el flujo completo sin intervención y el diff solo contiene lo declarado.

#### `sqlite-local`

- **Problema:** corrupción, bloqueos, migraciones sin respaldo y consultas que ignoran índices.
- **Regla central:** una conexión por operación, SQL parametrizado, transacción para escrituras múltiples, WAL y `busy_timeout` vigentes, migración con respaldo previo.
- **Criterio:** cierre forzado sin corrupción, dos instancias bloqueadas y restauración íntegra en instalación independiente.

#### `dinero-y-reglas-caja`

- **Problema:** doble efecto de caja, stock duplicado, ventas mixtas contadas dos veces y cortes que no cuadran.
- **Regla central:** dinero en centavos enteros, una sola fuente de stock, un solo efecto por gasto, anulación como documento nuevo y arqueo ciego.
- **Criterio:** cada regla tiene una prueba que la cita; el corte cuadra en venta simple, mixta, fiada, anulada y con gasto.

#### `testing-dotnet`

- **Problema:** refactorizar sin red de seguridad y “arreglar” comportamiento existente sin saberlo.
- **Regla central:** primero una prueba de caracterización que falle; después el cambio; la suite completa debe seguir verde.
- **Criterio:** una regresión inyectada a propósito es detectada por la suite.

#### `seguridad-permisos`

- **Problema:** permisos solo en la UI, lectura excesiva para Empleado, bloqueo efímero y exportaciones inseguras.
- **Regla central:** autorizar en el servicio, denegar por defecto, permiso por acción, bloqueo persistente, timeout y escape de fórmulas en CSV.
- **Criterio:** un Empleado no ve utilidad, costos ni crea proveedores; el bloqueo sobrevive al reinicio; la matriz rol×acción está probada.

#### `backup-recovery`

- **Problema:** respaldos que no restauran, copias inconsistentes con WAL y paquetes de soporte con datos sin consentimiento.
- **Regla central:** usar la API de respaldo de SQLite, verificar antes de mover, restaurar con confirmación y respaldo previo, y no compartir datos sin autorización.
- **Criterio:** restauración en otro dispositivo, dos instancias bloqueadas y paquete sin base que no contiene datos.

### P1

#### `estandares-repo`

Reemplaza la idea genérica de “dotnet-maui”. Cubre `async`/`await`, excepciones, inyección de dependencias, ubicación de reglas de negocio y convenciones del repositorio. Se activa en cualquier cambio de MAUI o Application.

#### `pos-ux`

Cubre navegación por teclado, foco automático del lector, alto contraste, cero bloqueos modales durante el cobro y arqueo ciego. Se activa en H2, H4, H6 y cualquier vista XAML.

#### `release-y-soporte`

Fusiona instalador, actualización, migración, rollback, paquete de soporte, importación CSV y diagnóstico. Se activa en H5/H6 y en cada versión que llegue a un cliente.

#### `hardware-pos`

Cubre impresión térmica ESC/POS, apertura de cajón, lectores USB HID, desconexión y modo de emulación sin hardware. Se activa en H6 y en validaciones físicas.

#### `producto-piloto`

Documento de contexto, no skill de ejecución. Mantiene el alcance: cliente ideal, exclusiones (sin nube, báscula ni CFDI), criterios de aceptación y qué no prometer. Lo usan ChatGPT y Gemini; los agentes de código lo consultan para no salirse del alcance.

#### `adr-decisiones`

Plantilla ligera de contexto, decisión, consecuencias y evidencia. Se activa al cerrar un hito o cambiar arquitectura. Claude lo usa como autor; DeepSeek lo verifica contra el código.

### P2

#### `graphify`

Herramienta instalada. Genera un grafo AST del código de `tienda` y un grafo semántico de documentos cuando hay backend. Se usa para explorar impacto y desmontar `DatabaseTools`; no se mantiene como dependencia obligatoria.

#### `preguntar-a-las-ias`

Herramienta instalada en la configuración del agente. Cuando el usuario dice
«pregúntales a las IAs», abre ChatGPT, Claude y Gemini en el navegador, asigna un
rol a cada uno, ejecuta dos rondas (propuestas y crítica cruzada) y guarda una
síntesis con acuerdos, desacuerdos, recomendación y métrica. No simula opiniones:
si un modelo no responde, se documenta.

## Mantenimiento

- Revisión mensual del catálogo.
- Toda skill P0 debe tener una prueba o comando de verificación.
- Si una skill no se usó en 90 días, se revisa o se retira.
- Los cambios de prioridad se registran en un ADR nuevo; no se edita el histórico.
