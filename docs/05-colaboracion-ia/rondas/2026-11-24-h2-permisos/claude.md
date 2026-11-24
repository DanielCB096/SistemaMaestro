# Ronda H2 — Claude (arquitectura y riesgo)

**Fecha:** 2026-11-24
**Sesión:** Claude web, cuenta Dani, modelo Sonnet 5.5 (plan Free).
**Pregunta:** matriz definitiva, autorización, pruebas, bloqueo y respaldos cifrados de H2.
**Advertencia de la sesión:** no vio el código; los hechos del proyecto vienen de la descripción de DeepSeek.

> Texto tal como lo devolvió la sesión.

```text
Diseño de H2: permisos, bloqueo y respaldos cifrados
Diseño de H2: permisos, bloqueo y respaldos cifrados

Aclaración: no he visto el código. La matriz y los huecos son los que describes; las cifras criptográficas son prácticas actuales que conviene contrastar con una fuente vigente (OWASP) antes de fijarlas.

1) Matriz definitiva

[RECOMENDACIÓN] Separar “Consultar” en permisos por tipo de dato, y que nada nuevo sea implícito.

Acción	Dueño	Encargado	Empleado
Vender, consultar catálogo y stock	Sí	Sí	Sí
Ver costos, utilidad, valorizado	Sí	No (cambio)	No
Anular venta	Sí	Sí, con motivo obligatorio	No
Gastos, abonos, ingreso de caja, corte	Sí	Sí	No
Alta/edición de clientes y proveedores	Sí	Sí	Solo alta de cliente sin saldo inicial (opcional)
Compras y pagos a proveedor	Sí	Sí	No
Editar productos / cambiar precios y costos	Sí	Precio no, datos básicos sí	No
Exportar CSV/PDF	Sí	Solo ventas y caja	No
Respaldo, restauración, usuarios, paquete de soporte	Sí	No	No

Cambios y razón:

[HIPÓTESIS] Que el encargado vea costos y utilidad es una decisión de negocio, no técnica; mi propuesta es negarlo por defecto y habilitarlo con permiso explícito del dueño.
[RECOMENDACIÓN] Exportar es un permiso propio: es la vía de fuga de datos más barata.
[HECHO, según tu descripción] la compra actualiza el costo, y editar costos exige permiso distinto; la compra debe registrar el cambio de costo en bitácora.
Un saldo inicial en un alta equivale a crear deuda, así que solo el dueño o el encargado lo fijan.
2) Contra escalada de privilegios

[RECOMENDACIÓN]

Sí, exigir permiso al inicio de cada método público del servicio es el mínimo, pero no basta. Falla por omisión (los huecos (a) y (b) son ese caso) y no cubre cadenas de llamadas.
Hacer la autorización deny-by-default: una prueba automática que recorra todos los métodos públicos de servicios y falle si alguno no declara su permiso (o no está en una lista explícita de exentos).
Revalidar rol en operaciones sensibles (anulaciones, cambio de precios, restauración, usuarios, exportaciones, cambio de PIN) leyendo el rol de la base de datos, no solo de la sesión en memoria, porque un cambio de rol o baja hecho por el dueño debe surtir efecto de inmediato.
Que la sesión no sea modificable por la UI: solo el servicio de autenticación la escribe.
Verificar dentro de la misma transacción de la operación, para evitar que el permiso cambie entre el chequeo y la escritura.
Registrar en bitácora todo rechazo de autorización.
[HIPÓTESIS] AsyncLocal puede perder o filtrar contexto entre hilos; conviene probar que tareas en segundo plano no heredan una sesión ajena.
3) Pruebas mínimas

[RECOMENDACIÓN]

Matriz completa rol × método de servicio, esperando éxito o denegación explícita.
Llamada directa al servicio con sesión de Empleado sin pasar por la UI: debe fallar con excepción de autorización, sin efectos en la base.
Sin sesión: todo método protegido falla.
Cambio de rol o desactivación del usuario durante una sesión activa: la siguiente operación sensible se niega.
Prueba de cobertura: ningún método público sin declaración de permiso.
Exportar, reportes con costo y utilidad: datos omitidos para el rol sin permiso, no solo ocultos.
4) Bloqueo, inactividad y caja compartida

[RECOMENDACIÓN]

Bloqueo por intentos: contador por usuario, persistido en SQLite (no en memoria), con retardo progresivo (por ejemplo 3 intentos, luego esperas crecientes) y desbloqueo por el dueño. Registrar cada intento fallido.
[HIPÓTESIS] Un PIN de pocos dígitos tiene poco espacio de búsqueda; el límite persistente es lo que lo protege, así que la base no debe ser editable por el usuario sin que se note.
Inactividad: timeout configurable (corto en caja, p. ej. pocos minutos) que bloquea la pantalla sin cerrar la app, conservando la venta en curso; se reanuda con PIN del mismo usuario.
Caja compartida: “cambio rápido de usuario”: bloquear = ocultar y exigir PIN, sin reiniciar. Toda venta y operación queda atribuida al usuario que la autenticó, por lo que el cambio de usuario con una venta abierta debe pedir completarla o ponerla en espera.
[HIPÓTESIS] El reloj del equipo puede manipularse; usar tiempo monótono para los timeouts y registrar saltos grandes de reloj.
5) Respaldos cifrados

[RECOMENDACIÓN]

AES-256-GCM con clave derivada por PBKDF2-SHA256: sí, es aceptable y está disponible en .NET sin dependencias. Argon2id sería preferible, pero exigiría un paquete externo; para un solo desarrollador, PBKDF2 es válido si las iteraciones son altas.
Iteraciones: [HIPÓTESIS] OWASP recomienda del orden de 600,000 para PBKDF2-SHA256; verifica la cifra vigente. Guardar el número de iteraciones en el encabezado para poder subirlo luego.
Sal: aleatoria por respaldo, 16 bytes o más.
Nonce: 12 bytes aleatorios únicos por cifrado. Para archivos grandes, cifrar por bloques con nonce derivado de un contador, nunca reutilizado con la misma clave.
Formato: encabezado con marca y versión de formato, algoritmo, iteraciones, sal y nonce; después los datos cifrados y la etiqueta de autenticación. El encabezado va como datos asociados autenticados.
Integridad: la etiqueta GCM detecta cualquier alteración. Además, tras restaurar, ejecutar la verificación de integridad de SQLite y comparar conteos antes de reemplazar la base.
Contraseña: [HECHO, inherente al diseño] si se pierde, el respaldo es irrecuperable. Debe decidirse si es la del dueño o una clave de respaldo propia, entregada impresa.
Respaldos viejos sin contraseña: conservar la restauración de formato antiguo (detectando la ausencia de marca), pero avisar que no están protegidos; ofrecer re-cifrarlos y retirar los originales solo después de una restauración de prueba exitosa. No borrar automáticamente.
6) Tres riesgos que el código no cierra
Contraseña o PIN compartido y notas con clave. Un PIN pegado en el monitor o una contraseña de respaldo perdida anulan todo el diseño.
Acceso físico y a la cuenta de Windows. Un dispositivo único sin cifrado de disco ni cuenta protegida permite copiar la base directamente, sin pasar por la app.
Disciplina del dueño con altas y bajas. Un exempleado conserva su acceso mientras el dueño no lo desactive; es proceso, no software.

Crear una hoja de cálculo





ahora
Escribe un mensaje…







Claude es una IA y puede cometer errores. Verifica siempre las respuestas.
Sonnet 5.5
 Medio
```
