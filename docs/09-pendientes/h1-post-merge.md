# Pendientes post-H1

**Estado:** abiertos, anotados para después.  
**Fecha:** 2026-11-24.  
**Contexto:** H1 está mergeado en `tienda/main` (`82aa23e`); Android y Windows pasan las pruebas funcionales. Estos pendientes son de campo, hardware o personas, no de código pendiente.

## Tabla

| # | Pendiente | Prioridad | Por qué | Cómo cerrarlo | Criterio de aceptación |
|---|---|---|---|---|---|
| P1 | Probar en otro equipo físico/tablet | Alta | Solo se probó en POCO X6 Pro 5G / Android 16 y en el equipo Windows de desarrollo | Instalar el APK firmado en un segundo dispositivo Android 10+ arm64 y repetir el checklist de `h1-android.md` | Exportar, restaurar, paquete sin base y con base pasan; sin crashes ni descuadres |
| P2 | Corte de energía real | Alta | El cierre forzado no equivale a un corte eléctrico; hay que validar WAL y recuperación | Usar un dispositivo de prueba con datos ficticios y un corte controlado (regleta o apagado) durante venta, respaldo, migración y restauración | Venta completa o inexistente; respaldo anterior intacto; base abre sin corrupción; restauración conserva datos o revierte al respaldo previo |
| P3 | Prueba con dueño no técnico | **Completado** | Sesión realizada el 2026-11-24 | Participante completó el flujo y recomendaría el sistema; hallazgos en [`p3-resultados-2026-11-24.md`](p3-resultados-2026-11-24.md) | Flujo entendible; fricciones en respaldo, QR y búsqueda |
| P4 | Acceso de colaborador en GitHub | Media | La cuenta de Edge no puede abrir PR (`must be a collaborator`); se usó fast-forward | Agregar la cuenta a `DanielCB096/tienda` como colaboradora o usar una cuenta con permiso | Se puede abrir y mergear una PR de prueba sin fast-forward |
| P5 | Iniciar H2 | Media | Siguiente hito del plan, no bloquea H1 | Permisos por acción, bloqueo persistente, timeout de sesión, manejador global y respaldos cifrados | H2 cumple sus pruebas y CI; ver plan maestro |
| P6 | Ruta de respaldo accionable | **Completado** | `fix/p3-respaldo-ruta` (`53a35fe`, fusionada en `290cde6`): copiar ruta, abrir carpeta y respaldos recientes | Verificado en Windows: la ruta se copia, la carpeta se abre y la restauración desde la lista cierra la app y crea `antes-restaurar` | El usuario llega a la carpeta o restaura sin navegar a mano |
| P7 | QR del ticket no escaneable | Alta | P3: un Android no pudo leer el QR | Reproducir con 2–3 teléfonos; ajustar tamaño, zona de silencio, corrección y contenido | El QR se escanea desde pantalla y desde PNG compartido |
| P8 | Búsqueda dinámica en POS | **Completado** | `feat/pos-busqueda-dinamica` (`c57fef0`, fusionada en `main` `c57fef0`): `SugerirProductos` con debounce de 250 ms y hasta 8 coincidencias | Verificado en Windows: sugerencias al escribir, orden por prefijo, escaneo intacto, stock 0 conserva lista y 7 pruebas nuevas (389 en total) | El cajero encuentra y agrega el producto sin paso extra |

## Detalle de P2 — corte de energía

Escenarios mínimos:

1. **Venta en curso:** apagar durante el cobro. Al reiniciar, la venta debe estar completa o no existir; stock, caja y folio consistentes.
2. **Respaldo en curso:** apagar durante `VACUUM INTO`. El respaldo anterior debe seguir íntegro; no debe quedar un `.db` corrupto como último respaldo.
3. **Migración en curso:** apagar durante una migración de esquema. La app debe abrir en la versión anterior o completar la migración; nunca dejar la base a medias.
4. **Restauración en curso:** apagar durante el reemplazo. Debe quedar la base anterior o la restaurada, con `antes-restaurar` disponible.
5. **Corte de caja en curso:** apagar durante el cierre. El corte debe quedar completo o inexistente; no debe duplicar movimientos.

Registrar en `docs/06-referencias/h1-android.md` o en una nueva ronda de verificación:

- Fecha, dispositivo, versión del APK.
- Escenario y momento del corte.
- Estado al reiniciar.
- Conteos/importes antes y después.
- Captura o log si falla.

## Detalle de P3 — dueño no técnico

**Materiales preparados:**

- Resultados: [`p3-resultados-2026-11-24.md`](p3-resultados-2026-11-24.md).
- Guion del participante: [`p3-guion-participante.md`](p3-guion-participante.md).
- Hoja de observación: [`p3-observacion.md`](p3-observacion.md).
- Preparar/limpiar la app: `scripts\p3-preparar.ps1 -Reset` y `scripts\p3-reset.ps1`.
- App aislada: `com.sistematienda.p3`, acceso directo **“Prueba P3 - SistemaTienda”** en el Escritorio.
- Datos de prueba: tienda Abarrotes La Esquina, PIN 2468, producto P3-001, venta de 2 refrescos, fondo $200.
- Datos precargados opcionales: `scripts\p3-preparar.ps1 -Semilla demo` deja ventas, clientes, proveedores, compras, gastos, caja y un corte; PIN 1234. No se usa para la prueba de primera vez.

**Datos de prueba automatizados:** `tienda` incorpora `SistemaTienda.Semilla` con escenarios `limpio`, `configurado` y `demo`. Detalle en [`tienda/SistemaTienda/docs/07-pruebas/datos-de-prueba.md`](../../tienda/SistemaTienda/docs/07-pruebas/datos-de-prueba.md). Para P3 se usa `limpio` porque el asistente de primera vez solo se valida con la base vacía.

Guion sugerido:

1. Abrir la app e iniciar sesión con PIN.
2. Registrar una venta en efectivo y ver el cambio.
3. Consultar el corte pendiente y cerrar caja.
4. Crear un respaldo y exportarlo.
5. Restaurar el respaldo.
6. Anotar cada duda o paso confuso.

No dar instrucciones verbales durante la prueba; solo observar y registrar.

## Detalle de P1 — otro equipo

Checklist mínimo:

- Instalar el APK con ensamblados embebidos.
- Configurar tienda y PIN.
- Exportar respaldo y verificar el share sheet.
- Restaurar un respaldo desde Descargas.
- Paquete de soporte sin base y con base.
- Verificar ZIP con `run-as`.
- Confirmar que la app no pierde datos al reiniciar.

## Relación con H2

H2 puede iniciar en paralelo. Estos pendientes no bloquean el desarrollo de H2, pero sí deben cerrarse antes de ofrecer H1 a clientes fuera del piloto.

## Enlaces

- [H1 — verificación Android](../06-referencias/h1-android.md)
- [H1 — respaldo y restauración](../06-referencias/h1-respaldo-restauracion.md)
- [Plan maestro v2](../01-plan/plan-maestro-v2.md)
