# SistemaMaestro

Repositorio de diseño, decisiones y evolución de la plataforma modular para pequeños negocios en México.

**Estado:** H1–H6 implementados y verificados en Windows y Android; piloto de 30 días preparado, todavía no iniciado en una tienda real.  
**Producto inicial:** POSale (Tienda V2), con foco en abarrotes, purificadoras y minisúper.  
**Objetivo de largo plazo:** núcleo modular con verticales (retail, gimnasio y otros giros), licencias de pago único y funcionamiento local sin internet.

> Este repositorio es la fuente de verdad de la documentación. Los repositorios `tienda` y `gym-dotnet` siguen siendo los sistemas en producción y no se modifican desde aquí.

## Estado actual

- **H1:** respaldo, restauración, WAL e instancia única; verificado en Windows y Android.
- **H2:** permisos por acción, bloqueo persistente, timeout, manejador global y respaldos cifrados AES-256-GCM.
- **H3–H4:** caracterización, stock por movimientos, gasto de caja único y bitácora atómica.
- **H5:** instalador, actualización con respaldo/rollback y CSV seguro.
- **H6:** importación con vista previa, tickets en espera y búsqueda medida con 3,000 productos.
- **Marca:** POSale; identificadores internos siguen como `SistemaTienda`.
- **Piloto:** kit, plan, capacitación y registro listos; falta ejecutarlo en una tienda real.
- **Pendientes de campo:** otro equipo/tablet, corte de energía real, restauración con tarjeta, bloqueo en Android, instalación limpia y escáner físico. Ver [`docs/09-pendientes`](docs/09-pendientes).
- **Open PRs heredadas:** #38 (`feat/restaurar-respaldos`) y #39 (`feat/ventas-historial`) siguen abiertas y atrasadas respecto a `main`; requieren decisión de cierre o rebase.

## Documentos clave

| Documento | Qué contiene |
|---|---|
| [Informe de auditoría](docs/00-auditoria/informe-tienda-gym-dotnet.md) | Análisis técnico comparativo de `tienda` y `gym-dotnet`: arquitectura, modelos, funcionalidades, deuda y migración |
| [Plan maestro v2](docs/01-plan/plan-maestro-v2.md) | Decisiones, producto v2, roadmap de 90 días, riesgos y modelo de colaboración con IA |
| [Decision Brief v1](docs/01-plan/decision-brief-v1.md) | Primera decisión formal: tienda v2 incremental vs. núcleo nuevo |
| [Modelo de documentos, pagos y caja](docs/02-arquitectura/modelo-documentos-pagos-caja.md) | Diseño conceptual del núcleo financiero y correcciones al modelo propuesto |
| [Protocolo de colaboración con IA](docs/05-colaboracion-ia/protocolo.md) | Roles de ChatGPT, Claude, Gemini y DeepSeek; rondas, reglas y ADRs |
| [Resumen de la ronda del 2026-11-23](docs/05-colaboracion-ia/rondas/2026-11-23.md) | Qué aportó cada experto y qué cambió en el plan |
| [Catálogo de skills](docs/08-agentes/catalogo-skills.md) | Skills P0/P1/P2, dueños, disparadores y criterios de aceptación |
| [Onboarding del agente](docs/08-agentes/ONBOARDING.md) | Instalación de skills, .NET, Android SDK, adb y graphify |
| [Ronda de skills 2026-11-23](docs/05-colaboracion-ia/rondas/2026-11-23-skills.md) | Propuestas de ChatGPT, Claude y Gemini y catálogo consolidado |
| [Verificación manual de H1](docs/05-colaboracion-ia/rondas/2026-11-23-verificacion-h1.md) | Criterios de las IA y resultados reales en Windows |
| [H1 implementado](docs/06-referencias/h1-respaldo-restauracion.md) | Respaldo, restauración, WAL e instancia única; rama y commit |
| [H1 en Android](docs/06-referencias/h1-android.md) | Resultados de exportar, restaurar y paquete de soporte en el POCO X6 Pro |
| [Plantilla de ADR](docs/07-decisiones/ADR-000-plantilla.md) | Formato para registrar decisiones arquitectónicas |

## Estructura

```text
SistemaMaestro/
├─ AGENTS.md                   instrucciones obligatorias para agentes
├─ README.md
├─ CHANGELOG.md
├─ scripts/
│  └─ preparar-entorno.ps1     skills + verificación de herramientas
├─ docs/
│  ├─ 00-auditoria/            análisis de los sistemas existentes
│  ├─ 01-plan/                 plan maestro, roadmap y decision briefs
│  ├─ 02-arquitectura/         modelos, principios y decisiones técnicas
│  ├─ 03-producto/             definición de producto, precios y piloto
│  ├─ 04-operacion/            hardware, actualizaciones, CFDI y soporte
│  ├─ 05-colaboracion-ia/      protocolo y resúmenes de rondas
│  ├─ 06-referencias/          perfiles de tienda, gym-dotnet y H1
│  ├─ 07-decisiones/           ADRs
│  └─ 08-agentes/              skills, roles, catálogo y onboarding
└─ (código futuro)
```

## Reglas del repositorio

1. **Documentación primero:** toda decisión relevante se registra en un ADR antes de implementarse.
2. **Hechos, hipótesis y recomendaciones** se etiquetan como `[HECHO]`, `[HIPÓTESIS]` o `[RECOMENDACIÓN]`.
3. **No secretos:** nunca subir credenciales, certificados, bases de datos, respaldos ni datos reales de clientes.
4. **No código en fase 0:** primero se cierra el alcance de Tienda V2; el código nuevo vivirá en los proyectos que se definan después.
5. **Los sistemas actuales no se tocan desde este repositorio:** `tienda` y `gym-dotnet` se mantienen en sus repos y se corrigen allí cuando se apruebe.
6. **Una decisión por ronda:** las IA se usan para contrastar, no para generar documentos infinitos.
7. **Cuotas de IA:** los planes gratuitos tienen límites. Cuando uno se agota, se espera al restablecimiento; no se reintenta en bucle. La ruta crítica no depende de la cuota de un modelo.

## Decisiones pendientes

- [x] Windows-first para Tienda V2 y Android como soporte secundario.
- [x] Cliente ideal y exclusión de forrajeras/básculas en V2.
- [~] Precios y política de soporte: aprobados como tentativos; validar con clientes y costos reales.
- [x] Piloto después de H4; fecha condicionada a puertas de calidad, no a calendario.
- [x] CFDI como extensión futura y V2 sin timbrado.
- [x] Autorizado el inicio de H1 (respaldo/restauración/exportación) en `tienda`.
- [x] H1 mergeado a `main` (PR #40, `41c5983`); deuda post-merge: Android, otro equipo, corte de energía y prueba con dueño no técnico.
- [ ] Aprobar el catálogo de skills de los agentes (ADR-002) y verificar la instalación de las P0.

## Referencias externas

- Repositorio de tienda: <https://github.com/DanielCB096/tienda>
- Repositorio de gimnasio: <https://github.com/DanielCB096/gym-dotnet>
