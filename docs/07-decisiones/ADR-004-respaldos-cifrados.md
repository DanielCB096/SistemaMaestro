# ADR-004 — Respaldos cifrados

- **Fecha:** 2026-11-24
- **Estado:** Aceptado; activación guiada pendiente
- **Hito:** H2.3
- **Consulta:** [ronda H2](../05-colaboracion-ia/rondas/2026-11-24-h2-permisos.md) y respuestas de respaldos en la misma carpeta

## Contexto

Los respaldos de Tienda V2 se guardan como archivos SQLite en claro y se exportan a USB o carpetas del usuario. Si el archivo se pierde o lo copia alguien sin permiso, quedan expuestos ventas, precios, costos y cartera de fiados.

Las tres consultas coincidieron:

- Guardar la clave en el almacenamiento seguro del sistema (DPAPI en Windows, Keystore en Android), no pedirla cada día.
- Cifrar todos los respaldos nuevos, automáticos y manuales, con la misma clave.
- Activar el cifrado por defecto en tiendas nuevas con un proceso guiado que incluya la tarjeta de recuperación y una restauración de prueba.

## Decisión

### Clave

- La app genera una **clave de respaldo aleatoria de 120 bits**, legible como 24 caracteres Base32 de Crockford (sin I, L, O ni U).
- La clave se guarda en el almacenamiento seguro del sistema: DPAPI por usuario en Windows, SecureStorage/Keystore en Android. **Nunca** se guarda en la base ni viaja dentro del respaldo.
- La **tarjeta de recuperación** muestra la clave para restaurar en otro equipo. Sin ella, el respaldo cifrado no se puede abrir.

### Formato

`AES-256-GCM` con clave derivada por `PBKDF2-SHA256` (600,000 iteraciones, sal de 16 bytes por archivo):

```
[0..4)   "STB1"
[4]      versión (1)
[5..9)   iteraciones (int32 LE)
[9..25)  sal (16 bytes)
[25..37) nonce (12 bytes)
[37..]   texto cifrado + etiqueta GCM (16 bytes)
```

El encabezado completo se autentica como dato asociado. La extensión del archivo es `.db.stb`.

### Comportamiento

- Al activar el cifrado, **todos** los respaldos nuevos se cifran: manuales y automáticos.
- Antes de borrar la copia en claro, la app descifra el archivo recién creado y lo compara con el original.
- Si la clave falta o falla el cifrado, **no se degrada en silencio**: se muestra un aviso y se registra el evento.
- Los respaldos viejos sin cifrar se siguen pudiendo restaurar; la app avisa que no están protegidos.
- Restaurar un `.stb` exige la clave; la app la pide y, si está en este equipo, la propone.

## Consecuencias

- Una USB perdida ya no expone la contabilidad de la tienda.
- **Si se pierde la clave y la tarjeta, nadie puede recuperar el respaldo, ni el soporte.** Debe quedar por escrito en el contrato.
- DPAPI ata la clave al usuario y equipo de Windows: reinstalar Windows invalida la copia local, por eso la tarjeta es obligatoria.
- En Android, el Keystore puede invalidarse al cambiar el bloqueo de pantalla; hay que probarlo en dispositivo.

## Pendiente (H2.3b)

- Activación guiada en el asistente inicial de tiendas nuevas, con tarjeta impresa y restauración de prueba antes de terminar.
- Cifrar también el paquete de soporte cuando incluye la base.
- Verificar DPAPI en Windows y Keystore en un Android físico; restaurar en otro equipo con la tarjeta.

## Verificación

- `CifradoRespaldoTests`: ida y vuelta, clave incorrecta, archivo alterado, sal y nonce distintos, clave inválida, 1 MB.
- `RespaldoCifradoServiceTests`: crear cifrado deja solo `.db.stb`, listar lo marca como cifrado, restaurar con clave correcta recupera el contenido, sin clave o con clave incorrecta no toca la base.
- Windows: activar, generar tarjeta, crear respaldo cifrado y restaurarlo; el respaldo previo `antes-restaurar` se crea y el indicador de cifrado sobrevive.
