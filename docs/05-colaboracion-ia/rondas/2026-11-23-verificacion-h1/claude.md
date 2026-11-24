# Ronda de verificación de H1 — Claude (arquitectura y riesgo)

**Fecha:** 2026-11-23  
**Sesión:** Claude web, cuenta Dani, modelo Sonnet 5.5  
**Pregunta:** criterio mínimo de aceptación manual de H1 y evidencia obligatoria antes del merge.  
**Advertencia de la sesión:** no vio el PR ni el código; los hechos vienen de la descripción de DeepSeek.

> Texto tal como lo devolvió la sesión. Las tablas venían separadas por tabuladores.

```text
Criterio de aceptación manual de H1 (PR #40)

Aclaración: no he visto el PR ni el código. Lo que sé de H1 viene de tu descripción; el resto son criterios de verificación.

[HECHO] CI en verde prueba lo que las pruebas automáticas cubren, no el comportamiento en un equipo real ni en un dispositivo Android. [RECOMENDACIÓN] La verificación manual debe usar una base con datos realistas (ventas, fiados, un corte), no una base vacía.

1) Escenarios mínimos
#	Plataforma	Pasos	Resultado esperado
W1	Windows	Con la app en uso, exportar respaldo a una carpeta externa (USB)	Archivo único, abre sin errores, incluye datos recientes (también lo que estaba en -wal)
W2	Windows	En otro equipo limpio, restaurar ese archivo	Mismas ventas, saldos de fiado y cortes; conteos coinciden con el original
W3	Windows	Restaurar sobre una base con datos	Se crea respaldo previo automático; se puede volver atrás
W4	Windows	Restaurar un archivo corrupto o truncado	Se rechaza con mensaje claro; la base actual queda intacta
W5	Windows	Abrir la app dos veces	La segunda instancia se niega a iniciar o avisa; sin corrupción
W6	Windows	Matar el proceso (o cortar energía) en medio de una venta	Al reabrir: venta completa o inexistente, nunca parcial
W7	Windows	Matar el proceso durante el respaldo	El respaldo anterior sigue válido
W8	Windows	Generar paquete de soporte	Contiene logs, versión y esquema; los datos personales están ofuscados o protegidos con contraseña según lo definido
W9	Windows	Dos operaciones simultáneas (venta mientras corre un respaldo)	Sin error "database is locked" visible al usuario
W10	Windows	Un usuario no técnico ejecuta W1 y W2 con instrucciones escritas	Lo logra sin ayuda
A1	Android	Exportar respaldo fuera del almacenamiento privado	El archivo es accesible y se puede copiar a otro dispositivo
A2	Android	Restaurar en otro dispositivo o tras reinstalar	Datos íntegros
A3	Android	Respaldo con la app enviada a segundo plano	Sin pérdida ni corrupción

[RECOMENDACIÓN] W10 es el criterio decisivo: si el dueño no puede restaurar solo, el P0 sigue abierto en la práctica.

2) Evidencia obligatoria

[RECOMENDACIÓN] Por cada escenario, en una carpeta del PR:

Resultado (pasa/falla), fecha, versión (commit) y equipo/dispositivo usado.
Captura o video corto de los pasos clave (W10 en video).
Para W2, A2: conteos antes y después (ventas, clientes, saldo total de fiado, última venta), comparados lado a lado.
Para W6/W7: descripción de cómo se simuló la interrupción y el estado al reabrir.
Hash del archivo de respaldo restaurado.
Lista de archivos que genera la base en disco (.db, -wal, -shm) antes y después del respaldo.
Persona que ejecutó y persona que revisó.

[HIPÓTESIS] El riesgo de respaldos incompletos por WAL es el más probable; W1 y W2 son los que mejor lo detectan.

3) Qué bloquea el merge y qué es deuda

Bloquea [RECOMENDACIÓN]:

Cualquier falla en W1 a W7 (pérdida o corrupción de datos).
W10 sin superar (el dueño no puede restaurar).
Respaldo restaurado con conteos distintos al original.
Fallo de A1 o A2 si Android se ofrece a algún cliente. Si Android no se ofrece todavía, [RECOMENDACIÓN] pasa a deuda, pero solo si queda documentado como "no apto para clientes".
Paquete de soporte con datos personales sin protección.

Puede quedar como deuda documentada [RECOMENDACIÓN]:

Mensajes de error poco pulidos pero seguros.
Mejoras de redacción en las instrucciones, siempre que W10 haya pasado.
Respaldo automático programado o recordatorios.
Cifrado del respaldo (ya conocida como ausente, según el informe), con aviso explícito en la documentación.
A3 en dispositivos poco comunes.
Rendimiento del respaldo con bases grandes, pero registrando el tamaño y tiempo medidos.

Regla de cierre [RECOMENDACIÓN]: ninguna deuda se acepta sin ficha con dueño, riesgo y fecha. Quien ejecuta la verificación no debe ser el único que decide el merge; que lo apruebe el dueño o un segundo rol.
```
