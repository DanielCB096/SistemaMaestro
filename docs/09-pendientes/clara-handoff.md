# Clara — handoff para continuar

**Fecha:** 2026-11-27
**Estado:** producto independiente, versión **1.5.1**, en preparación del piloto.
**Repo:** <https://github.com/DanielCB096/clara> (tag `v1.5.1`, commit `2eb33fb`).
**Ficha de producto:** [clara-finanzas.md](../03-producto/clara-finanzas.md).
**Decisión:** [ADR-017](../07-decisiones/ADR-017-clara-independiente.md).

## Dónde está todo

- Código y documentación técnica: repositorio `clara` (raíz: `HANDOFF.md`).
- Plan del piloto: `docs/piloto-clara.md` dentro del repo.
- Guías operativas: `docs/piloto/` (instalación, llamadas, privacidad, checklist, CSV).
- Despliegue: `docs/despliegue.md`.
- Service worker: `docs/service-worker.md`.
- Benchmark: `docs/benchmark-almacenamiento.md`.

## Qué está listo

- Funciones: ingresos, egresos, presupuestos, pendientes, recurrentes.
- Captura rápida en 3 toques y cierre semanal.
- Red de seguridad de datos y recuperación guiada.
- Respaldo con huella, prueba de integridad y Web Share.
- Modo ejemplo efímero.
- Offline con service worker y aviso de actualización.
- Paquete de despliegue listo: iconos, manifest, `_headers`, `netlify.toml` y guía paso a paso.
- 91 pruebas y CI verde.

## Qué falta (en orden)

1. **Publicar en HTTPS** con Cloudflare Pages o Netlify.
2. **Probar en Android e iPhone reales**: instalar, modo avión, respaldo, actualización.
3. **Reclutar 3–5 dueños** y ejecutar el piloto de 14 días.
4. **Decidir** con las métricas y criterios de cancelación.

## Regla vigente

Las tres IAs consultadas concluyeron **pausar el desarrollo y validar**.
No se agregan funciones de producto durante el piloto: solo se corrigen
pérdidas de datos, números incorrectos o bloqueos de captura.

## Pendientes técnicos conocidos

- Sin sincronización entre dispositivos.
- iOS puede purgar el almacenamiento de una PWA sin uso.
- El respaldo externo es la única recuperación si se pierde el teléfono.
- El service worker en `localhost` solo se registra con `?sw=1`.
- El hosting aún no está elegido ni configurado.

## Cómo retomar en otra PC

```bash
git clone https://github.com/DanielCB096/clara.git
cd clara
npm test
npm run check
npm start
```

Abrir <http://localhost:4173>. Todo el detalle para una IA nueva está en
`HANDOFF.md` del repositorio.
