# ADR-008 — Instalación, actualización y reversión

- **Fecha:** 2026-11-25
- **Estado:** Aceptado; verificación en campo pendiente
- **Hito:** H5

## Contexto

La app se distribuía compilando desde el repositorio. No había manifiesto de versión, paquete instalable ni forma de volver atrás si una actualización dejaba la base inservible. El dueño no es técnico y la tienda no tiene internet.

## Decisión

### Paquete y manifiesto

- Cada versión se publica como un ZIP con la app de Windows y `manifiesto.json`.
- El paquete es **autocontenido**: incluye el runtime de .NET (`coreclr.dll`), así que la tienda no necesita instalar nada más. Se activa con `-p:H5Empaquetar=true`, que solo aplica al objetivo de Windows y no afecta al build diario ni a Android.
- El manifiesto declara `producto`, `versionApp`, `versionEsquema` y la fecha de generación.
- `versionEsquema` sale de `Migraciones.VersionActual`; el empaquetador lo pide con `SistemaTienda.Semilla --manifiesto` para no duplicar el número a mano.
- La app compara la versión de la base con la que conoce. Si la base es más nueva, se niega a abrirla en vez de degradarla.

### Instalación por versiones

- Las versiones se guardan en `%LOCALAPPDATA%\SistemaTienda\app\versiones\<versión>`.
- `actual.json` es el puntero a la versión activa y a la anterior.
- La copia se hace en `<versión>.tmp` y se renombra al final; el puntero cambia solo cuando la copia terminó. Una copia interrumpida deja la versión anterior operativa.
- Los datos viven en `%LOCALAPPDATA%\SistemaTienda\com.sistematienda.tienda\Data` y nunca se mueven con la app.

### Actualización de la base

- `ActualizadorEsquema` crea un respaldo `antes-migrar` verificado, aplica las migraciones pendientes y ejecuta un arranque de prueba: integridad, claves foráneas, tablas esenciales y una escritura que se revierte.
- Si una migración falla o la verificación no pasa, restaura el respaldo automáticamente y deja la versión anterior de los datos.
- La app usa este camino al arrancar (`DatabaseTools.InicializarBaseDeDatos`).
- Las migraciones siguen siendo una por transacción; el respaldo cubre el caso de que falle una migración intermedia.

### Reversión

- `h5-instalar.ps1 -Revertir` devuelve el puntero a la carpeta anterior; la versión fallida se conserva para diagnóstico.
- La reversión de datos usa el respaldo `antes-migrar`; no se reescribe el historial ni se borran tablas a mano.

### Correcciones incluidas

- **Fechas por día**: las consultas ya usaban `date(Fecha)` sobre la hora local; se fijó con una prueba de borde (23:59 y 00:01).
- **CSV**: los campos de texto libre que empiezan con `=`, `+`, `-`, `@`, tabulador o retorno se exportan con apóstrofo. Los importes negativos siguen siendo números y no se alteran.

## Consecuencias

- El dueño instala un ZIP y actualiza sin internet; el paquete anterior queda disponible.
- Una actualización fallida no deja la tienda sin sistema: o se migra y verifica, o se restaura.
- El costo es más disco (dos versiones) y un paso manual para abrir la versión activa hasta que exista un acceso directo administrado por el instalador.
- La verificación en una máquina limpia y con corte de energía real sigue pendiente.

## Verificación

- `ActualizacionTests` cubre manifiesto, base al día, esquema viejo, migración fallida, verificación fallida y base más nueva.
- `MigracionesRespaldoTests` sigue cubriendo el respaldo previo y la migración v3 → v4.
- `ExportadorCsvTests` cubre la neutralización de fórmulas y los importes negativos.
- `FechasLocalesTests` fija el filtro por día local en los bordes.
- Suite completa: 459 pruebas.
- `h5-instalar.ps1` se probó con paquetes simulados: instalar 1.0.0, actualizar a 1.1.0, revertir a 1.0.0 y rechazar un manifiesto inválido sin mover el puntero.
- El paquete real 1.1.0 se generó, se instaló en una carpeta temporal, la app autocontenida arrancó y creó su base, se actualizó a un 1.1.1 y se revirtió a 1.1.0 conservando ambas carpetas.
