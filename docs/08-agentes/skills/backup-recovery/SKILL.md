---
name: backup-recovery
description: "Úsala para cambios en respaldo, restauración, exportación o paquete de soporte de tienda. Exige copia consistente con WAL, verificación, restauración en otro equipo y consentimiento para incluir datos."
---

# Respaldo y recuperación

**Versión:** 1.0  
**Prioridad:** P0  
**Dueño:** DeepSeek  
**Revisión:** 2026-11-23  
**Fuente:** [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md), [H1](../../../06-referencias/h1-respaldo-restauracion.md).

## Propósito

Garantizar que el negocio pueda recuperar sus datos después de un error, un robo, un cambio de equipo o una actualización fallida. Un respaldo solo cuenta si se restauró y se verificó.

## Hechos que debes asumir

- H1 ya implementó:
  - Respaldo exportable a `Documentos\SistemaTienda` en Windows y diálogo de compartir en Android.
  - Restauración desde Ajustes con confirmación, respaldo previo y cierre de la ventana en Windows.
  - Paquete de soporte con `resumen.txt`, `LEEME.txt` y base opcional.
  - WAL, `busy_timeout=30000`, `synchronous=NORMAL` e instancia única en Windows.
  - Conexiones de respaldo sin pooling.
  - Exportar, restaurar y paquete de soporte visibles solo para el dueño; restauración valida `Configurar` en el servicio.
- La suite de H1 quedó en 373 pruebas; CI en verde en el run `45301168757`, con Windows y Android compilando.
- La verificación manual en Windows y Android, la restauración en otro dispositivo y las dos instancias siguen pendientes.
- El cifrado de respaldos es parte de H2, no de H1.

## Cuándo se activa

- Cambios en respaldo, restauración o exportación.
- Migraciones de esquema o actualizaciones.
- Paquete de soporte o diagnóstico.
- Cambio de equipo o recuperación de un cliente.
- Cualquier incidente de pérdida de datos.

## Reglas inviolables

1. **Respaldo consistente.** Usa la API de respaldo de SQLite o el procedimiento de H1; no copies el archivo con `-wal` abierto.
2. **Verifica antes de mover.** Comprueba integridad y que el archivo se puede abrir antes de reemplazar nada.
3. **Respaldo previo a restaurar.** Nunca restaures sin conservar la base actual.
4. **Confirmación explícita.** Restaurar reemplaza datos; exige confirmación y explica el efecto.
5. **Restauración probada en otro equipo.** Un respaldo no está validado hasta que se restaura en una instalación independiente.
6. **Dos instancias no comparten base.** La instancia única es parte de la recuperación.
7. **Consentimiento para datos.** El paquete de soporte incluye la base solo si el dueño lo autoriza y entiende qué contiene.
8. **Fuera del almacenamiento privado.** El respaldo debe poder salir del dispositivo (Documentos, USB, share).
9. **Cifrado pendiente.** No prometas respaldos cifrados hasta que H2 los implemente y pruebe.
10. **No compartir por canales públicos.** El paquete puede contener ventas, clientes y fiados.

## Flujo

1. Identifica si el cambio toca respaldo, restauración, exportación o soporte.
2. Revisa `RespaldoLocal.cs`, `RespaldoService.cs` y `PaqueteSoporteService.cs`.
3. Agrega o actualiza la prueba de WAL y restauración.
4. Genera un respaldo con datos de prueba.
5. Restaura en una base independiente y compara conteos.
6. Prueba el paquete de soporte sin base y con base.
7. Verifica que la segunda instancia se bloquea.
8. Reporta ruta, tamaño, verificación y resultado de la restauración.

## Casos borde obligatorios

- Respaldo con WAL activo y conexión abierta.
- Restauración sobre una base con datos.
- Restauración en otra ruta o equipo.
- Paquete de soporte sin consentimiento.
- Paquete de soporte con base y datos personales.
- Dos instancias en Windows.
- Actualización interrumpida (H5).

## Criterio de aceptación

- Restauración correcta en instalación independiente.
- La base restaurada conserva datos y esquema.
- Dos instancias no corrompen la base.
- El paquete sin base no contiene datos del negocio.
- El paquete con base es consistente y se generó con consentimiento.
- La suite de respaldo/WAL queda verde.

## Anti-patrones

- Copiar `tienda.db` con el bloc de notas o el explorador mientras la app está abierta.
- Restaurar sin respaldo previo.
- Incluir la base en el paquete “para que soporte vea todo”.
- Compartir el ZIP por WhatsApp sin avisar qué contiene.
- Decir “respaldo listo” sin haber restaurado nunca.
- Ignorar el job MAUI porque “las pruebas pasan”.

## Pendientes de H1 que afectan esta skill

- CI en verde (run `45301168757`); Windows y Android compilan.
- Verificación manual en Windows y Android.
- Restauración en otro dispositivo.
- Prueba de dos instancias.
- Confirmar que el paquete de soporte no se comparte sin consentimiento.
- PR [#40](https://github.com/DanielCB096/tienda/pull/40) abierta; pendiente merge tras la verificación manual.

## Referencias

- [H1 — respaldo, restauración y WAL](../../../06-referencias/h1-respaldo-restauracion.md)
- `tienda/SistemaTienda/SistemaTienda.Infrastructure/RespaldoLocal.cs`
- `tienda/SistemaTienda/SistemaTienda.Application/Services/RespaldoService.cs`
- `tienda/SistemaTienda/SistemaTienda.Application/Services/PaqueteSoporteService.cs`
- `tienda/SistemaTienda/SistemaTienda.Tests/RespaldoWalTests.cs`
- `tienda/SistemaTienda/docs/estado-h1.md`

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-23 | Creación con el estado real de H1, incluido el CI pendiente |
