# Ronda H2.3 — Claude (arquitectura y riesgo)

**Fecha:** 2026-11-24
**Pregunta:** clave maestra, alcance del cifrado y activación en tiendas nuevas.
**Advertencia de la sesión:** no vio el código; el criterio es de diseño.

## 1. Dónde guardar la clave: opción (a), con matiz

[RECOMENDACIÓN] Almacenamiento seguro del sistema (DPAPI en Windows, Keystore en Android) para los respaldos automáticos. Pedirla cada día fracasa: el dueño no técnico la desactivará o la anotará junto al equipo. Cifrar solo los manuales deja sin proteger lo más frecuente.

El matiz es qué se guarda. [RECOMENDACIÓN] No guardar la contraseña del dueño; guardar una **clave de respaldo aleatoria generada por la app**, protegida por DPAPI/Keystore. La contraseña del dueño y la tarjeta de recuperación derivan o envuelven esa misma clave para restaurar en otro equipo.

Límites que hay que declarar:

- [HECHO] DPAPI vincula la clave a la cuenta de Windows y al equipo. Si el equipo se pierde o se reinstala Windows, esa copia local no sirve; por eso la tarjeta de recuperación es obligatoria.
- [HIPÓTESIS] Alguien con la sesión de Windows abierta puede usar la clave sin contraseña. Protege el respaldo copiado a una USB perdida, no un equipo comprometido.
- [HIPÓTESIS] El Keystore de Android varía por dispositivo y puede invalidarse al cambiar el bloqueo de pantalla; verificar en A1/A2.

## 2. Automáticos: sí se cifran

[RECOMENDACIÓN] Cifrar todos, automáticos y manuales, con la misma clave. Mezclar crea falsa seguridad: el archivo sin cifrar es el que se copia o se pierde.

Condiciones:

- Verificar el respaldo recién cifrado (descifrar y comprobar integridad) antes de borrar el anterior.
- Si falta la clave o falla el cifrado, **no degradar en silencio a texto plano**: aviso visible y registro del evento.

## 3. Por defecto o con aviso

[RECOMENDACIÓN] Activado por defecto en tiendas nuevas, pero la activación solo se completa cuando el dueño confirma que guardó la tarjeta de recuperación.

[HIPÓTESIS] El mayor riesgo no es el atacante sino la pérdida de la clave. Por eso:

- Prueba de restauración guiada al activar, con un respaldo real.
- En tiendas existentes: opcional con aviso, sin forzar migración, conservando la restauración de respaldos viejos sin cifrar.

## Riesgos que el código no cierra

- La tarjeta de recuperación se pierde o se guarda junto al equipo.
- Cambio de equipo: restaurar exige la tarjeta; ensayarlo antes del primer cliente.
- Soporte: sin la clave, nadie puede recuperar los datos. Debe quedar por escrito en el contrato.
