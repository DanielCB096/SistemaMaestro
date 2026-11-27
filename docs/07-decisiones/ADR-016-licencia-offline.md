# ADR-016 — Licencia offline sin bloqueo

- **Fecha:** 2026-11-27
- **Estado:** Aceptado; verificado en Windows el 2026-11-27
- **Hito:** Comercialización de POSale

## Contexto

POSale está funcionalmente completo y el siguiente paso es venderlo. El plan
maestro pide una licencia offline firmada, con periodo de gracia y recuperación
manual, sin atar la instalación al hardware. Bloquear la caja por una licencia
vencida puede dejar a un negocio sin vender, así que la política elegida con el
dueño es **solo avisar**.

## Decisión

- La licencia es **perpetua**; el soporte y las actualizaciones tienen su propia
  fecha (`SoporteHasta`) y no bloquean la app.
- El archivo `.poslic` es JSON con un payload en base64 y una firma
  **RSA-PSS/SHA-256** con llave de 3072 bits. La app lleva solo la llave pública.
- La licencia **no se ata al hardware**: se puede mover a otra instalación o
  restaurar con la carpeta de datos. El control es por confianza y soporte.
- Campos: producto (`POSale`), cliente, folio, fecha de emisión, tipo, cajas,
  soporte hasta y notas. La app valida producto, firma y datos mínimos.
- **Prueba de 30 días** desde la primera apertura. El estado se guarda en
  `licencia-estado.json`, junto a la base. Si el archivo se borra, la prueba
  puede reiniciarse: es una limitación aceptada del modo sin bloqueo.
- **Nunca se bloquea una venta.** Inicio muestra un aviso cuando la prueba está
  por vencer, terminó, la licencia es inválida o el soporte venció.
- La importación se hace pegando el contenido del `.poslic` en Ajustes, para no
  depender de selectores de archivo que fallan en Windows sin empaquetar.
- Importar una licencia exige `Configurar` (dueño) y deja bitácora `Licencia`.
- La llave privada vive **fuera del repositorio**, en la máquina del proveedor.
  La herramienta `SistemaTienda.Licencias` genera llaves, emite y verifica.
- Los archivos viven junto a la base: `licencia.poslic` y
  `licencia-estado.json`.

## Consecuencias

- El producto se puede entregar y mover sin activación en línea.
- Alguien podría copiar la licencia a otra tienda; se acepta porque el soporte y
  la relación comercial son el control real.
- Si el cliente pierde la licencia, el proveedor la reemite con el mismo folio o
  uno nuevo; no hay recuperación automática.
- La fecha de soporte es informativa: no impide operar, solo recuerda renovar.
- El respaldo de la base no incluye la licencia; se puede volver a importar.

## Verificación

- `LicenciasTests`: firma válida, contenido alterado, prueba vigente y vencida,
  importación con bitácora, firma inválida, empleado sin permiso, soporte vencido
  y producto equivocado.
- Herramienta `SistemaTienda.Licencias`: generar llaves, emitir y verificar.
- Verificado en Windows el 2026-11-27: Inicio sin aviso y Ajustes con la licencia activa de Abarrotes La Esquina (POS-DEMO-001). Android pendiente.
- La llave pública se incluye como constante compilada; el intento de recurso embebido se descartó porque no se encontraba al ejecutar.
