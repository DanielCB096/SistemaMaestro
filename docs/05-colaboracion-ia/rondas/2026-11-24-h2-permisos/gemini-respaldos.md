# Ronda H2.3 — Gemini (UX y operaciones)

**Fecha:** 2026-11-24
**Sesión:** Gemini web, cuenta Daniel Cuevas Bernal (plan Plus).
**Pregunta:** dónde guardar la clave maestra, si se cifran los respaldos automáticos y si el cifrado es obligatorio en tiendas nuevas.

> Texto tal como lo devolvió la sesión (selección de la respuesta útil).

**1. Dónde guardar la clave maestra**

[RECOMENDACIÓN] (a) Almacenamiento seguro del sistema (DPAPI en Windows, Keystore en Android).

Por qué: un dueño no técnico no tecleará una contraseña cada noche al cerrar la tienda; la opción (b) mata la automatización y la (c) deja los respaldos diarios en texto plano en la carpeta local o USB, anulando el propósito de seguridad ante robo de equipo o acceso de un empleado [HIPÓTESIS]. Guardar la llave en el almacén nativo permite cifrar en segundo plano sin fricción y solo pedirla manualmente cuando se restaura en una computadora nueva [RECOMENDACIÓN].

**2. Alcance del cifrado**

[RECOMENDACIÓN] Cifrar absolutamente todos (automáticos, manuales y los incluidos en el paquete de soporte) una vez activa la clave maestra.

Por qué: para el tendero no existe diferencia conceptual entre un respaldo automático y uno manual; si uno sale cifrado y otro abierto, la protección contra copia no autorizada de su catálogo, precios y cartera de fiados queda rota [HIPÓTESIS]. Además, unificar el formato evita mantener dos flujos distintos de verificación e integridad en campo [RECOMENDACIÓN].

**3. Activación en tiendas nuevas**

[RECOMENDACIÓN] Obligatoria durante el asistente de configuración inicial, pero presentada de forma amigable y con salida inmediata para imprimir la Tarjeta de Recuperación.

Por qué: si se deja como «opcional con aviso», el 90% de los tenderos hará clic en «Omitir / Configurar después» por prisa al abrir su negocio y nunca activará la protección [HIPÓTESIS]. Integrarlo como el último paso del alta del dueño —exigiendo confirmar que imprimió o guardó su Tarjeta de Recuperación antes de finalizar— garantiza que el 100% de las instalaciones nuevas nazcan protegidas sin bloquear la operación diaria [RECOMENDACIÓN].
