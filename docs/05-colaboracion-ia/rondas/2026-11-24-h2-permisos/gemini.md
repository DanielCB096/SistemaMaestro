# Ronda H2 — Gemini (UX y operaciones)

**Fecha:** 2026-11-24
**Sesión:** Gemini web, cuenta Daniel Cuevas Bernal (plan Plus).
**Pregunta:** cómo se sienten en mostrador los controles de H2 (permisos, bloqueo, contraseña de respaldo).

> Texto tal como lo devolvió la sesión.

## 1. Visibilidad y manejo de acciones restringidas

En módulos administrativos (Reportes de utilidad, Costos, Configuración, Respaldos): ocultar por completo para el rol Empleado [RECOMENDACIÓN]. Evita curiosidad innecesaria y limpia la pantalla para cobrar más rápido [HIPÓTESIS].

En acciones operativas de mostrador (Cancelar partida, Aplicar descuento, Reimprimir ticket, Abrir cajón sin venta): mostrar activa y pedir autorización instantánea con PIN del Encargado o Dueño en un cuadro superpuesto, sin cancelar la venta en curso [RECOMENDACIÓN]. Deshabilitarla obliga a cancelar el carrito del cliente en hora pico y mostrar el error al final frustra y avergüenza al cajero frente a la fila [HIPÓTESIS].

## 2. Textos exactos para mostrador

- Sin permiso: «Esta acción requiere autorización. Pide a tu encargado que ingrese su PIN». [RECOMENDACIÓN]
- Pide al encargado: «Autorización de Encargado o Dueño para [nombre de la acción, ej. cancelar artículo]». [RECOMENDACIÓN]
- Sesión bloqueada: «Caja bloqueada por inactividad. Ingresa tu PIN para continuar o cambia de cajero». [RECOMENDACIÓN]

## 3. Inactividad en caja sola

Tiempo: 5 minutos de inactividad (configurable entre 2 y 15 minutos por el dueño) [RECOMENDACIÓN].

Comportamiento: bloqueo de pantalla manteniendo el carrito intacto en segundo plano [RECOMENDACIÓN]. Si el cliente fue por un producto olvidado, el cajero no pierde lo ya escaneado [HIPÓTESIS].

Cambio de persona: la pantalla de bloqueo pide PIN; si ingresa el mismo usuario, desbloquea al instante; si ingresa otro empleado/encargado, cambia la sesión activa atribuyendo los siguientes movimientos al nuevo usuario sin borrar el carrito actual [RECOMENDACIÓN].

## 4. Bloqueo por intentos fallidos

Límite: 5 intentos fallidos consecutivos [RECOMENDACIÓN].

Mensaje y salida en hora pico: «PIN bloqueado por 3 minutos por seguridad. Pide al Encargado que desbloquee tu usuario ahora o inicia con otra cuenta». [RECOMENDACIÓN] Nunca bloquees la terminal completa de forma permanente offline, o detienes las ventas de toda la tienda [HECHO].

## 5. Contraseña para respaldos cifrados

Flujo UX: no pedir una contraseña nueva en cada respaldo diario porque provoca que el dueño la anote en un papel pegado al monitor [HIPÓTESIS]. Definir una Clave Maestra de Respaldo única al configurar la tienda (idealmente su PIN de dueño más una palabra clave fácil de recordar) y ofrecer descargar una «Tarjeta de Recuperación» imprimible para guardar en su carpeta física con el contador [RECOMENDACIÓN].

Texto: «Protege tus ventas con una clave que solo tú conozcas. La necesitarás si cambias de computadora. Guárdala en un lugar seguro (no pegada a la caja)». [RECOMENDACIÓN]

## 6. Dónde se frena la operación y cómo evitarlo

El freno: pedir usuario + contraseña larga en cada desbloqueo o exigir salir de la pantalla de cobro para que el encargado autorice un error de escaneo [HIPÓTESIS].

La solución: usar PIN numérico de 4 a 6 dígitos en mostrador (teclado numérico rápido) y elevación de permisos en sitio (el encargado teclea su PIN sobre la venta actual, se ejecuta la acción y la sesión regresa automáticamente al cajero sin cerrar su turno) [RECOMENDACIÓN].
