# Pendientes de H2

**Estado:** abiertos, anotados para después.
**Fecha:** 2026-11-25.
**Contexto:** H2.1 (permisos), H2.2 (sesión) y H2.3 (respaldos cifrados) están implementados y fusionados. El Keystore de Android se verificó el 2026-11-25; quedan verificaciones que dependen de otro equipo o de una persona.

## Tabla

| # | Pendiente | Prioridad | Por qué | Cómo cerrarlo | Criterio de aceptación |
|---|---|---|---|---|---|
| A1 | Keystore en Android | **Completado** | Verificado el 2026-11-25 en POCO X6 Pro 5G (Android 16) | Asistente con cifrado, respaldo automático y manual `.db.stb`, reinicio y restauración | La clave sobrevivió al reinicio y la restauración creó `antes-restaurar` |
| A2 | Restaurar en otro equipo con la tarjeta | Alta | Es la promesa central del cifrado: sin la tarjeta, el respaldo es irrecuperable | Llevar un `.db.stb` y la clave a otro equipo, restaurar | Los datos quedan íntegros y el respaldo previo se conserva |
| A3 | Restauración guiada en el asistente | Media | El asistente ya ofrece activar el cifrado y muestra la tarjeta, pero no obliga a probar una restauración | Añadir al asistente una prueba con un respaldo recién creado antes de terminar | El dueño restaura una copia sin ayuda antes de usar la tienda |
| A4 | Bloqueo por inactividad en Android | Media | Solo se probó en Windows | Dejar la caja sola los minutos configurados y volver | Aparece el bloqueo, el carrito se conserva y el PIN desbloquea |
| A5 | Intentos fallidos en Android | Media | La lógica es común, pero el teclado y los mensajes cambian | Fallar 5 veces el PIN en el dispositivo | Bloqueo de 3 minutos y mensaje correcto |

## Guion de A1 y A2

1. Instalar el APK Debug con `com.sistematienda.p3`.
2. Crear una tienda nueva o sembrar datos de demo.
3. Ajustes → **Activar respaldo cifrado** → guardar la clave.
4. **Crear respaldo ahora** y confirmar que aparece `tienda-*.db.stb`.
5. Cerrar por completo la app y volver a abrir.
6. Ajustes: debe seguir **Activado** y permitir crear respaldos sin pedir la clave.
7. Restaurar ese respaldo desde la lista: debe pedir o proponer la clave y dejar los datos intactos.
8. Copiar el `.db.stb` y la clave a otro equipo limpio, restaurar y comparar conteos.

## Nota

Si el teléfono no está disponible, A1–A5 quedan pendientes; no bloquean H3. El cifrado en Windows (DPAPI) sí está verificado.
