# Agentes y skills

**Estado:** catálogo propuesto el 2026-11-23; P0 en proceso de instalación.  
**Decisión:** [ADR-002](../07-decisiones/ADR-002-catalogo-skills.md).  
**Ronda:** [2026-11-23-skills](../05-colaboracion-ia/rondas/2026-11-23-skills.md).

## Qué es una skill aquí

Una skill es un documento de instrucciones versionado que un agente carga cuando la tarea coincide con sus disparadores. No es un prompt suelto ni un documento de negocio: debe cambiar cómo se ejecuta una tarea y tener una forma verificable de saber si se cumplió.

- **Fuente de verdad:** `docs/08-agentes/skills/`.
- **Espejo ejecutable:** `~/.config/opencode/skills/` (OpenCode) o el directorio de skills del CLI que se use.
- **Sesiones web:** ChatGPT, Claude y Gemini **no cargan skills locales**. Usan el catálogo y los documentos de contexto como referencia; no se les debe pedir que “lean” una ruta local.

## Estructura

```text
docs/08-agentes/
├─ README.md                 este documento
├─ catalogo-skills.md        tabla maestra, prioridad, dueño y estado
├─ roles.md                  qué skills usa cada rol y cuáles son transversales
├─ CHANGELOG.md              historial de versiones del catálogo
└─ skills/
   ├─ protocolo-de-cambio/
   │  └─ SKILL.md
   ├─ sqlite-local/
   │  └─ SKILL.md
   ├─ dinero-y-reglas-caja/
   │  └─ SKILL.md
   ├─ testing-dotnet/
   │  └─ SKILL.md
   ├─ seguridad-permisos/
   │  └─ SKILL.md
   └─ backup-recovery/
      └─ SKILL.md
```

Las skills P1 y P2 se crean cuando la tarea que las activa esté en curso; hasta entonces viven solo en el catálogo. `graphify` ya está instalada como herramienta.

## Instalación de las P0 en OpenCode

Desde la raíz de `SistemaMaestro`:

```powershell
$destino = Join-Path $env:USERPROFILE ".config\opencode\skills"
New-Item -ItemType Directory -Force $destino | Out-Null
Get-ChildItem "docs\08-agentes\skills" -Directory | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $destino $_.Name) -Recurse -Force
}
Get-ChildItem $destino -Directory | Select-Object Name
```

Después abre una sesión nueva de OpenCode y verifica que aparezcan las skills. No basta con que el archivo exista: hay que probar que el agente la usa.

### Espejo genérico para otros agentes

Los mismos archivos se copian a `~/.agents/skills/`, que es el directorio que leen las herramientas compatibles con la especificación de Agent Skills. Esto no hace que ChatGPT, Claude o Gemini web carguen las skills: esas sesiones siguen usando el catálogo como contexto.

```powershell
$origen = "docs\08-agentes\skills"
$destino = Join-Path $env:USERPROFILE ".agents\skills"
New-Item -ItemType Directory -Force $destino | Out-Null
Get-ChildItem $origen -Directory | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $destino $_.Name) -Recurse -Force
}
```

`graphify` se instala aparte con `graphify install --platform agents`.

## Verificación

Una skill está bien instalada cuando:

1. OpenCode la lista al iniciar la sesión.
2. Una tarea de prueba cuya respuesta correcta dependa de la skill se resuelve siguiendo sus reglas.
3. El agente cita la skill y deja evidencia (comando, prueba o archivo) en su reporte.

Prueba mínima por skill P0:

| Skill | Tarea de prueba |
|---|---|
| `protocolo-de-cambio` | Pedir un cambio pequeño y comprobar que crea rama, corre línea base y reporta evidencia |
| `sqlite-local` | Pedir una consulta nueva y comprobar que usa parámetros, transacción y prueba |
| `dinero-y-reglas-caja` | Pedir un cálculo de venta mixta y comprobar centavos enteros y una sola fuente de stock |
| `testing-dotnet` | Pedir una corrección y comprobar que primero agrega una prueba que falla |
| `seguridad-permisos` | Pedir una pantalla de costos y comprobar que exige permiso en el servicio, no solo en la UI |
| `backup-recovery` | Pedir un cambio en respaldo y comprobar restauración en instalación independiente |

## Reglas

1. **Una capacidad por skill.** Si una skill necesita dos dueños y dos criterios, probablemente son dos skills.
2. **Toda skill P0 cita una prueba o un comando verificable.**
3. **Toda skill tiene versión, dueño y fecha de revisión.**
4. **Cambiar una skill P0 requiere ADR** y revisión de otro rol.
5. **El código no se copia aquí.** Las skills dicen cómo trabajar; el código sigue en `tienda`.
6. **No se instalan todas de golpe.** Primero las P0; las P1 cuando la tarea las pida.

## Relación con la auditoría

Las skills P0 se apoyan en hechos verificados del informe:

- `DatabaseTools` ~1,996 líneas, ~72 métodos públicos y 164 sentencias SQL.
- 30 handlers `async void` en MAUI, varios sin `catch`.
- `date(Fecha)` inutiliza índices de ventas y reportes.
- Permisos faltantes en altas, lectura excesiva para Empleado y bloqueo de login efímero.
- CSV sin escape de fórmulas y base/respaldos sin cifrar.
- H1 ya implementó WAL, `busy_timeout`, instancia única y respaldo/restauración; las skills deben reflejar ese estado, no el anterior.

Ver [`docs/00-auditoria/metricas-y-evidencia.md`](../00-auditoria/metricas-y-evidencia.md) y [`docs/06-referencias/h1-respaldo-restauracion.md`](../06-referencias/h1-respaldo-restauracion.md).
