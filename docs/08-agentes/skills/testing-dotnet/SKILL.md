---
name: testing-dotnet
description: "Úsala antes de refactorizar o corregir código de tienda. Exige prueba de caracterización, aislamiento de SQLite y una suite completa en verde como red de seguridad."
---

# Pruebas .NET

**Versión:** 1.0  
**Prioridad:** P0  
**Dueño:** DeepSeek  
**Revisión:** 2026-11-23  
**Fuente:** [ADR-002](../../../07-decisiones/ADR-002-catalogo-skills.md), auditoría, H1.

## Propósito

Convertir el comportamiento actual en una red de seguridad antes de tocarlo. No es una skill de teoría de TDD: es el procedimiento concreto para que un cambio en `tienda` no rompa caja, stock, permisos o respaldo.

## Hechos que debes asumir

- La suite usa xUnit y tiene **373 pruebas en verde** al cierre de H1.
- La auditoría contó 293 `[Fact]` y 25 `[Theory]` antes de H1; el número actual manda.
- `BaseDatosPrueba` crea una base temporal y una sesión para los tests.
- Las pruebas de H1 cubren WAL, `busy_timeout`, respaldo con WAL, respaldo sin sesión y paquete de soporte.
- Hay lógica de UI en code-behind y 30 handlers `async void`; no todo es fácil de probar sin extraer la regla.

## Cuándo se activa

- Antes de refactorizar.
- Antes de corregir un bug.
- Al agregar una regla de negocio.
- Al cambiar una migración, un permiso o un cálculo de dinero.
- Cuando la suite falla y no está claro si el fallo es del entorno o del cambio.

## Reglas inviolables

1. **Primero la prueba.** El bug se reproduce con una prueba que falla por la razón correcta.
2. **No se “arregla” la prueba para que pase.** Si el comportamiento esperado cambió, se actualiza con justificación y ADR.
3. **Una prueba, un comportamiento.** Nombres descriptivos en español, con el caso y el resultado esperado.
4. **Aislamiento.** Cada prueba usa su propia base temporal; no comparte estado con otra.
5. **Suite completa.** No basta la prueba nueva: hay que correr todas.
6. **Sin flakiness.** Una prueba que falla a veces se corrige o se retira; no se ignora.
7. **Datos reales, no.** Nunca uses bases, respaldos ni datos de clientes en pruebas.
8. **La prueba cita la regla.** Si implementa una regla de dinero, permisos o stock, referencia la skill o el ADR.

## Flujo

1. Ejecuta la línea base: `dotnet test SistemaTienda.sln -c Release`.
2. Escribe la prueba de caracterización o reproducción.
3. Confirma que falla por la razón esperada.
4. Implementa el cambio mínimo.
5. Ejecuta la prueba nueva y luego la suite completa.
6. Si el cambio toca UI o `async void`, extrae la regla a un servicio probado; no pruebes el evento de MAUI.
7. Reporta: prueba nueva, resultado antes/después y total de pruebas.

## Tipos de prueba

| Tipo | Uso | Ejemplo |
|---|---|---|
| Caracterización | Fijar comportamiento existente antes de refactorizar | Venta mixta reportada por pago |
| Regresión | Reproducir un bug reportado | Gasto con doble efecto de caja |
| Integración | Servicio + SQLite temporal | Respaldo con WAL y restauración |
| Permisos | Matriz rol×acción | Empleado no ve utilidad |
| Concurrencia | Dos conexiones o dos instancias | `database is locked` controlado |

## Criterio de aceptación

- La prueba nueva falla sin el cambio y pasa con él.
- La suite completa queda verde.
- Una regresión inyectada a propósito es detectada.
- No hay pruebas nuevas que dependan de hora, red o estado global.
- El total de pruebas se reporta y no baja sin justificación.

## Anti-patrones

- Cambiar el assert para que pase.
- Probar el code-behind en lugar de la regla.
- Compartir una base entre pruebas.
- `Thread.Sleep` para esperar.
- Omitir la suite completa “porque solo cambié una línea”.
- Llamar “caracterización” a una prueba que en realidad fija el comportamiento deseado, no el actual.

## Referencias

- `tienda/SistemaTienda/SistemaTienda.Tests/`
- `tienda/SistemaTienda/SistemaTienda.Tests/BaseDatosPrueba.cs`
- `tienda/SistemaTienda/SistemaTienda.Tests/RespaldoWalTests.cs`
- [H1 — pruebas](../../../06-referencias/h1-respaldo-restauracion.md)
- [Auditoría — métricas](../../../00-auditoria/metricas-y-evidencia.md)

## Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-23 | Creación con el estado de 373 pruebas de H1 |
