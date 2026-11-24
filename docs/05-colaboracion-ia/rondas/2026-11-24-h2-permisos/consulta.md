# Ronda H2 — permisos por acción y sesión

**Fecha:** 2026-11-24
**Objeto:** fijar la matriz rol × acción de H2.1 y el diseño de bloqueo, timeout y respaldos cifrados de H2.2–H2.3.
**Participantes:** ChatGPT (producto/negocio), Claude (arquitectura/riesgo), Gemini (UX/operaciones).
**Quién sintetiza:** DeepSeek (OpenCode), con aprobación de Daniel.

> Copia el bloque de cada experto en su sesión web y pega la respuesta completa. No hace falta que vean las respuestas de los otros.

## Contexto común (va en las tres consultas)

Tienda V2 es una app .NET MAUI + SQLite, **100 % offline**, para abarrotes, purificadoras y minisúper de 1–3 cajas y 1–4 empleados. Un dispositivo por tienda. El dueño puede tener empleados con PIN propio; hoy hay tres roles:

- **Dueño:** todo, incluida configuración, usuarios, bitácora y respaldos.
- **Encargado:** opera el turno; puede vender, anular, gastos, abonos, clientes, proveedores, compras, inventario y corte.
- **Empleado:** solo vender y consultar.

Matriz vigente (resumen real del código):

| Acción | Dueño | Encargado | Empleado |
|---|---|---|---|
| Vender | Sí | Sí | Sí |
| Anular venta | Sí | Sí | No |
| Consultar (incluye ver costos y utilidad) | Sí | Sí | **Sí** |
| Merma | Sí | Sí | No |
| Gasto | Sí | Sí | No |
| Abono de fiado | Sí | Sí | No |
| Editar cliente / proveedor | Sí | Sí | No |
| Baja y reactivación de cliente / proveedor | Sí | No | No |
| Compras y pagos a proveedor | Sí | Sí | No |
| Editar producto / entrada de inventario | Sí | Sí | No |
| Precios y costos | Sí | No | No |
| Ajuste de inventario | Sí | No | No |
| Desactivar producto | Sí | No | No |
| Corte de caja / ingreso de caja | Sí | Sí | No |
| Retiro de caja | Sí | No | No |
| Exportar CSV/PDF | Sí | Sí | Sí (por heredar Consultar) |
| Respaldo / restauración | Sí | No | No |
| Configuración, usuarios, bitácora | Sí | No | No |

Huecos ya detectados en el código:

1. `AgregarClienteFiado` y `AgregarProveedor` **no validan permiso**: un empleado puede crear clientes o proveedores si llama al servicio.
2. Reportes y estados de cuenta muestran **costo y utilidad** a cualquiera con `Consultar`, incluido el empleado.
3. Las exportaciones CSV/PDF **no tienen permiso propio**; hoy las puede hacer un empleado.
4. Las acciones de la interfaz se ocultan por rol, pero la autorización real debe quedar en el servicio.

Restricciones del producto: sin nube, sin servidor, sin dependencias de pago; dinero en centavos enteros; el historial no se edita; un solo dispositivo por tienda.

---

## Pregunta para ChatGPT (producto y negocio)

En una tienda de barrio con 1–4 empleados y alta rotación, ¿qué debe poder hacer un **empleado** sin frenar el mostrador, y qué debe quedar solo en manos del dueño o del encargado? Responde en estos puntos:

1. **Clientes:** ¿el empleado debe crear un cliente nuevo para vender a fiado, o eso lo hace solo el encargado? ¿Y crear proveedores?
2. **Costos y utilidad:** ¿el empleado y el encargado deben ver costo, margen y utilidad? ¿Qué le prometerías al dueño?
3. **Deudas de clientes:** ¿el empleado debe ver el saldo de un cliente al cobrar fiado? ¿Y el directorio completo con saldos?
4. **Exportar:** ¿quién debe poder exportar CSV/PDF de ventas, estados de cuenta y reportes?
5. **Fricción:** ¿qué restricción te parece que el dueño va a querer quitar a la semana porque le estorba?
6. **Promesa comercial:** escribe una frase que el dueño pueda decirle a un empleado sobre lo que puede y no puede hacer, sin ambigüedad.

Devuelve una tabla rol × acción con tu recomendación y marca cada fila como `[HECHO]`, `[HIPÓTESIS]` o `[RECOMENDACIÓN]`.

---

## Pregunta para Claude (arquitectura y riesgo)

Revisa el diseño de H2 y responde como revisor adversarial. No necesitas el código completo; con esta descripción basta.

1. **Matriz:** propón la matriz definitiva rol × acción para una tienda de 1–4 empleados. Marca qué cambiarías de la matriz vigente y por qué.
2. **Autorización:** ¿qué reglas mínimas exiges para que no haya escalada de privilegios? Considera llamadas directas al servicio, sesión en memoria (`AsyncLocal`), PIN compartido y UI que oculta botones. ¿Basta exigir permiso al inicio de cada método o hace falta algo más (p. ej., revalidar rol en operaciones sensibles)?
3. **Pruebas:** define el conjunto mínimo de pruebas de la matriz, incluyendo el caso “el rol llama al servicio directamente y debe fallar”. ¿Qué combinaciones no pueden faltar?
4. **Bloqueo y sesión:** propón intentos, duración del bloqueo, timeout de inactividad y dónde persistir el estado (tabla SQLite vs almacenamiento seguro). ¿Cómo se bloquea una caja compartida sin obligar al dueño a reiniciar la app?
5. **Respaldos cifrados:** confirma o corrige AES-256-GCM + PBKDF2-SHA256, iteraciones, sal, nonce, formato del archivo y verificación de integridad. ¿Qué harías con los respaldos existentes sin contraseña?
6. **Riesgo residual:** enumera los tres riesgos que no se pueden cerrar solo con código y que deben quedar documentados.

Marca cada afirmación como `[HECHO]`, `[HIPÓTESIS]` o `[RECOMENDACIÓN]`. Si algo depende de una decisión del dueño, dilo.

---

## Pregunta para Gemini (UX y operaciones)

El dueño de una tienda pequeña trabaja con el mostrador lleno y empleados que rotan. Responde en estos puntos:

1. **Denegar sin frenar:** cuando un empleado intenta algo que no le toca, ¿qué es mejor: ocultar la acción, mostrarla deshabilitada con explicación, o dejarla y mostrar el error al final? Considera prisa, cambio de turno y vergüenza frente al cliente.
2. **Mensajes:** escribe el texto exacto (en español de México, breve) para “no tienes permiso para…”, “pide al encargado…” y “tu sesión se bloqueó”.
3. **Sesión compartida:** si la caja queda sola, ¿bloqueo automático a los cuántos minutos? ¿Se cierra la sesión o se pide el PIN del mismo usuario? ¿Qué pasa si el que vuelve es otro empleado?
4. **Bloqueo por intentos:** ¿cuántos intentos antes de bloquear? ¿Qué mensaje y qué alternativa le das al empleado si se bloquea en hora pico?
5. **Respaldos cifrados:** ¿cómo le pides la contraseña al dueño sin que la olvide ni la escriba en un papel pegado al monitor? ¿Qué texto usarías?
6. **Riesgo operativo:** ¿qué parte de H2 puede volver más lenta la operación y cómo lo evitarías?

Marca cada propuesta como `[HECHO]`, `[HIPÓTESIS]` o `[RECOMENDACIÓN]`.

---

## Qué hará DeepSeek con las respuestas

1. Consolidar coincidencias y discrepancias en `2026-11-24-h2-permisos.md`.
2. Escribir **ADR-003 — Matriz de permisos por acción** con la decisión aprobada por Daniel.
3. Implementar H2.1 con la matriz y las pruebas rol × acción.
4. Dejar en `docs/09-pendientes/h1-post-merge.md` lo que dependa de hardware o de una persona.
