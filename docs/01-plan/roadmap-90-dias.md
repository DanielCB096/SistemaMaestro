# Roadmap de 90 días

| Semanas | Negocio | Técnico | Puerta |
|---|---|---|---|
| 1–2 | Cliente, promesa, alcance y precio | H1: respaldo/restauración/exportación, paquete de soporte, WAL, `busy_timeout`, instancia única | Restaurar en otro dispositivo |
| 2–4 | Entrevistas y acuerdo de piloto | H2: permisos por acción, bloqueo persistente, timeout, manejador global, respaldos cifrados | Empleado sin acceso a utilidad/costos |
| 3–6 | Candidatos a piloto y hardware | H3: suite de caracterización | Verde en CI |
| 6–8 | Ajuste de oferta y soporte | H4: stock único, gasto/caja unificado, ventas mixtas, bitácora transaccional, arqueo ciego | Corte cuadrado |
| 8–9 | Instalación y capacitación | H5: instalador, migración automática, rollback, `date(Fecha)`, escape CSV | Actualización fallida vuelve atrás |
| 9–10 | Inicio de piloto | H6: importación CSV, búsqueda instantánea, tickets en espera | Cliente operando |
| 10–13 | Piloto de 30 días y lanzamiento | Estabilización y soporte | 14 días sin pérdida ni descuadres |

**Regla:** si H3 se alarga, se mueve el piloto; no se recortan H1–H4.

**Detalle completo:** [Plan maestro v2](plan-maestro-v2.md).

## Estado al 2026-11-25

| Hito | Estado | Evidencia |
|---|---|---|
| H1 | Implementado y fusionado; Windows y Android pasan | `h1-respaldo-restauracion.md`, `h1-android.md` |
| H2 | Implementado y fusionado; Keystore Android verificado | ADR-003, ADR-004; `09-pendientes/h2-pendientes.md` |
| H3 | Implementado y fusionado | ADR-005 |
| H4 | Implementado y fusionado | ADR-006, ADR-007 |
| H5 | Implementado y fusionado; falta instalación limpia y corte real | ADR-008 |
| H6 | Implementado y verificado en Android; falta medición instrumentada y escáner físico | ADR-009 |
| Piloto | Kit y documentación listos; **no iniciado** en tienda real | `tienda/SistemaTienda/docs/08-piloto` |

**Puertas pendientes antes de vender fuera del piloto:** otro equipo/tablet, corte de energía real, restauración con tarjeta en otro equipo, bloqueo/inactividad en Android, instalación limpia y escáner físico. Ver [`docs/09-pendientes`](../09-pendientes).
