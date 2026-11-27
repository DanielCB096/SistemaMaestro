# Clara — finanzas personales del dueño

**Estado:** producto independiente; versión 1.2.0, pendiente validación con usuarios.  
**Repo:** `C:\proyectos\clara` (Git local; sin remoto todavía).  
**Decisión:** [ADR-017](../07-decisiones/ADR-017-clara-independiente.md).

## Qué es

PWA offline para las finanzas **personales** del dueño de un pequeño negocio:

- ingresos y egresos personales;
- presupuestos por categoría con alertas;
- pendientes con fecha límite;
- reglas recurrentes de ingresos;
- resumen mensual y exportación/importación JSON.

No es un ERP, no es contabilidad y no se conecta a la caja del negocio.

## Cliente ideal

Dueño de tienda, gimnasio, purificadora o comercio pequeño que:

- mezcla gastos personales con el dinero del negocio;
- usa efectivo, transferencias y tarjeta;
- no quiere aprender contabilidad ni dar claves bancarias;
- valora privacidad y funcionamiento sin internet.

## Propuesta de valor

> “Tus finanzas claras. Tu negocio por separado.”

Simple, privada, offline y en el teléfono del dueño, no en la PC del mostrador.

## Paquete y precio (hipótesis)

| Modalidad | Precio experimental |
|---|---:|
| Clara independiente | $399–$599 MXN, pago único |
| Complemento de POSale o Centro Fit | $299–$399 MXN |
| Actualizaciones menores | Incluidas |

No cerrar precio sin validar con 5–10 dueños. No regalarla indiscriminadamente
si se quiere medir valor real.

## Frontera técnica

- PWA vanilla, sin backend, sin dependencias externas.
- Datos en `localStorage`; una sola copia local.
- Exportar/importar JSON es la recuperación; no hay sincronización.
- Git, SemVer y migraciones de esquema.
- Integración futura máxima: archivo de retiros (nivel 1). Nada de API compartida.
- El núcleo de SistemaMaestro no depende de Clara.

## Riesgos

| Riesgo | Mitigación |
|---|---|
| Pérdida de datos al limpiar el navegador o cambiar de teléfono | **1.1.0:** recordatorio de respaldo, exportación y `storage.persist()`. **1.2.0:** escritura verificada, copia previa a migraciones y pantalla de recuperación |
| Sin multi-dispositivo | Documentarlo; exportar/importar manual |
| Cuota de 5 MB | Medir con historial de varios años; archivado anual |
| Deriva de alcance hacia el negocio | ADR y frontera explícita |
| README desactualizado | Corregido a finanzas personales |
| Sin Git/versión | Repo inicializado, tag `v1.0.0` |

## Roadmap acordado (1.2)

El debate entre tres IAs (producto, arquitectura y UX) dejó este orden:
red de seguridad de datos → captura en 3 toques → respaldo verificable con
Web Share → bienvenida con demo efímero → cierre semanal → benchmark de
almacenamiento. Detalle en el repo de Clara:
`docs/roadmap-1.2.md`. Fuera del ciclo: IndexedDB (solo medir), cifrado de
respaldos, flujo a 30 días y paywall.

## Avance 1.2.0

- Captura rápida con botón flotante, monto primero, categorías frecuentes y repetir el último movimiento.
- Red de seguridad de datos: escritura en doble clave, copia interna antes de migrar, rechazo de versiones futuras y recuperación guiada.
- 79 pruebas verdes y CI. Pendiente: respaldo verificable con Web Share, bienvenida con demo, cierre semanal y benchmark.

## Plan de 30 días

1. **Días 1–5:** README real, Git, tag, revisar pruebas y modelo de datos.
2. **Días 6–12:** recordatorio de respaldo, `storage.persist()`, exportación/importación probada y migraciones.
3. **Días 13–20:** 5–10 entrevistas con dueños; entender cómo separan (o no) su dinero.
4. **Días 21–30:** piloto con 3–5 dueños; medir uso semanal y disposición a pagar.

## Métricas

- Dueños entrevistados: 5–10.
- Usuarios piloto activos: 3–5.
- Registran gastos semanalmente: ≥70 %.
- Entienden la separación personal/negocio: 100 %.
- Dispuestos a pagar: ≥3.

## No hacer

- No integrarla a la base de POSale/Centro Fit.
- No convertirla en app de tareas del personal (el README viejo estaba mal).
- No añadir nube, sincronización, cuentas bancarias, CFDI ni analítica.
- No reescribirla en .NET mientras la PWA cumpla.

## Enlaces

- Código: `C:\proyectos\clara`
- Especificación: `SPEC.md` y `DECISIONES.md` del repo.
- Roadmap de plataforma: [plan maestro v2](../01-plan/plan-maestro-v2.md).
