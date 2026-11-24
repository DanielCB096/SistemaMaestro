# Ronda de skills — Gemini (UX y operaciones)

**Fecha:** 2026-11-23  
**Sesión:** Gemini web, cuenta Daniel Cuevas Bernal (plan Plus)  
**Conversación:** “Inicio de Asistencia General”  
**Pregunta:** catálogo de skills para los agentes que trabajan el código, priorizado para reducir riesgo operativo y de experiencia en 90 días.

> Texto tal como lo devolvió la sesión. Las tablas venían separadas por tabuladores.

```text
Gemini dijo
1. Crítica de la lista de skills candidatas

La lista propuesta cubre bien la base técnica, pero tiene un sesgo de ingeniería que deja desprotegidos el mostrador y la operación en campo [HECHO].

Quitar/Posponer (graphify): En un proyecto de un solo desarrollador con horizonte de 90 días y un codebase acotado, mantener un grafo de dependencias añade fricción sin reducir el riesgo de pérdida de datos ni de abandono en mostrador [HIPÓTESIS].

Fusionar (dotnet-maui + UX de mostrador -> maui-pos-ux): Saber .NET MAUI genérico no basta; el agente necesita reglas estrictas de interfaz de punto de venta (navegación 100% por teclado, alto contraste, cero bloqueos modales en cobro y flujo de corte ciego) [RECOMENDACIÓN].

Agregar (hardware-pos-windows): Omitida en la lista original, pero crítica para ESC/POS, apertura de cajón RJ11 y lectores USB HID en Windows sin internet [HECHO].

Agregar (operacion-campo-soporte): Indispensable para cubrir el empaquetado del instalador (H5), migración silenciosa en sitio, importación inicial CSV y exportación de diagnóstico en un clic por WhatsApp [RECOMENDACIÓN].

2. Catálogo priorizado de skills para agentes de código
Nombre	Propósito	Cuándo se activa	Contenido mínimo	Criterio de aceptación	Prioridad
sqlite-local	Garantizar integridad transaccional, cero corrupción por cortes de luz y respaldos exportables [HECHO].	H1, H4, H5 y cualquier cambio en esquema o consultas [HECHO].	Pragmas (WAL, busy_timeout, foreign_keys), reglas de migración versionada y rutina de backup/restore [RECOMENDACIÓN].	Base de datos soporta cierre forzado de proceso sin corrupción y exporta/restaura respaldo íntegro [RECOMENDACIÓN].	P0
seguridad-permisos	Bloquear acceso de cajeros a costos, utilidades, edición de precios y borrado de ventas [HECHO].	H2 y creación de cualquier pantalla o acción operativa [HECHO].	Matriz RBAC (Dueño vs. Cajero), bloqueo persistente tras intentos fallidos y timeout de inactividad [RECOMENDACIÓN].	Un usuario rol Cajero no puede visualizar márgenes ni alterar historial bajo ningún flujo [RECOMENDACIÓN].	P0
maui-pos-ux	Asegurar cobro ultrarrápido, accesibilidad en mostrador y flujo de corte de caja ciego [RECOMENDACIÓN].	H2, H4, H6 y diseño de vistas XAML/C# [RECOMENDACIÓN].	Mapa de atajos (F1–F12, Enter, Esc), foco automático en código de barras, contraste alto y reglas de arqueo ciego [RECOMENDACIÓN].	Venta de 5 artículos se completa en menos de 10 segundos usando solo teclado/escáner; corte ciego oculta el esperado [RECOMENDACIÓN].	P0
testing-dotnet	Proteger reglas críticas de negocio (caja, stock, ventas mixtas) contra regresiones [HECHO].	H3, H4 y cada pull request o refactorización [HECHO].	Patrones de pruebas de caracterización sobre SQLite en memoria/temporal y casos límite de redondeo y pagos mixtos [RECOMENDACIÓN].	100% de los flujos de caja, fiado y descuento de inventario cubiertos por pruebas automatizadas en verde [RECOMENDACIÓN].	P0
hardware-pos-windows	Estandarizar impresión térmica, apertura de cajón y lectura de códigos en Windows [RECOMENDACIÓN].	H6 y validación de periféricos físicos [HECHO].	Comandos raw ESC/POS (58/80mm), pulso estándar de cajón RJ11, manejo de desconexión USB y modo emulación sin hardware [RECOMENDACIÓN].	Imprime ticket legible y abre cajón en menos de 1.5 segundos en impresoras genéricas USB Windows [RECOMENDACIÓN].	P1
operacion-campo-soporte	Resolver instalación, carga masiva inicial (onboarding) y diagnóstico sin internet [RECOMENDACIÓN].	H5 y H6 [HECHO].	Plantilla de importación CSV de catálogo, empaquetador Windows con auto-migración y generador de ZIP de logs + BD [RECOMENDACIÓN].	Carga de 1,000 productos en menos de 2 minutos y generación de paquete de soporte en un solo clic [RECOMENDACIÓN].	P1
producto-piloto	Alinear el código con el alcance comercial de 90 días y evitar sobreingeniería [RECOMENDACIÓN].	Al iniciar cualquier tarea nueva o evaluar cambios de alcance [RECOMENDACIÓN].	Definición del cliente ideal, lista de exclusiones (sin nube, sin báscula, sin CFDI) y checklist de aceptación de campo [HECHO].	Ningún commit introduce dependencias de red o funcionalidades fuera del alcance V2 [RECOMENDACIÓN].	P1
adr-decisiones	Registrar el porqué de las decisiones técnicas y operativas en SistemaMaestro [HECHO].	Al cerrar cada hito (H1–H6) o resolver un compromiso arquitectónico [RECOMENDACIÓN].	Plantilla breve: Contexto, Decisión, Consecuencias y Riesgos aceptados [RECOMENDACIÓN].	Todo cambio estructural tiene su ADR vinculado en la documentación antes de pasar de hito [RECOMENDACIÓN].	P2

3. Estructura de carpetas y formato de documentación

Dado que SistemaMaestro es la fuente de verdad y las sesiones web no leen archivos locales automáticamente, el catálogo debe vivir centralizado y versionado para copiarse o inyectarse con facilidad [HECHO]:

Plaintext
SistemaMaestro/
├── docs/
│   ├── adr/                  # Registros de decisiones (001-wal-sqlite.md, etc.)
│   └── catalogo-skills.md    # Índice maestro auditable con versiones y estados
└── skills/                   # Carpeta espejo instalable directamente en OpenCode/CLI
    ├── sqlite-local/
    │   └── SKILL.md
    ├── seguridad-permisos/
    │   └── SKILL.md
    └── maui-pos-ux/
        └── SKILL.md

Formato estándar de cada SKILL.md: Encabezado YAML (name, version, owner, priority, triggers) seguido de exactamente cuatro secciones: 1. Reglas inviolables (lo que el agente tiene prohibido hacer), 2. Flujo paso a paso, 3. Casos borde de operación/UX (ej. pérdida de foco, corte de luz, cajero novato) y 4. Checklist de verificación antes de cerrar tarea [RECOMENDACIÓN].

4. Asignación por rol vs. transversales

Transversales (obligatorias para todos los agentes en cualquier sesión):

producto-piloto (mantiene a todos dentro de los límites de 90 días y del perfil del tendero) [RECOMENDACIÓN].

adr-decisiones (asegura trazabilidad entre lo que se decide en web y lo que se ejecuta en CLI) [RECOMENDACIÓN].

Por rol específico:

DeepSeek (OpenCode / Ejecución de código): sqlite-local, seguridad-permisos, maui-pos-ux, testing-dotnet, hardware-pos-windows, operacion-campo-soporte [HECHO].

Claude (Arquitectura y riesgo): sqlite-local, seguridad-permisos, testing-dotnet (para auditar integridad y concurrencia) [HECHO].

Gemini (UX, capacitación y operaciones): maui-pos-ux, operacion-campo-soporte, hardware-pos-windows (para validar flujos de mostrador, onboarding y manuales de 1 página para el dueño) [HECHO].

ChatGPT (Negocio y validación comercial): producto-piloto (para mantener coherencia entre promesa de venta y capacidades reales de V2) [HECHO].
```
