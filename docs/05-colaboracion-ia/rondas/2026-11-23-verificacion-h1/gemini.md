# Ronda de verificación de H1 — Gemini (UX y operaciones)

**Fecha:** 2026-11-23  
**Sesión:** Gemini web, cuenta Daniel Cuevas Bernal (plan Plus)  
**Pregunta:** qué debe verificar un dueño no técnico en respaldo, restauración y paquete de soporte.

> Texto tal como lo devolvió la sesión. Las tablas venían separadas por tabuladores.

```text
1. Comprobaciones de UX y operación para un dueño no técnico

Exportar respaldo a memoria USB externa: Conectar una USB y guardar el respaldo fuera del disco interno [RECOMENDACIÓN].

Mensaje esperado: "Respaldo guardado correctamente en [Unidad USB] con fecha y hora" [RECOMENDACIÓN].

Fallo típico: El selector abre una ruta oculta de Windows (AppData) que el dueño no sabe encontrar o no deja elegir su USB [HIPÓTESIS].

Restaurar respaldo con protección contra sobrescritura accidental: Seleccionar un archivo de respaldo viejo y restaurarlo [RECOMENDACIÓN].

Mensaje esperado: Advertencia clara: "Se reemplazarán tus ventas actuales por las del [fecha]. Se guardará una copia de seguridad automática antes de continuar" + confirmación explícita [RECOMENDACIÓN].

Fallo típico: Restaura en silencio o lanza una excepción técnica si el archivo está bloqueado por otro proceso [HIPÓTESIS].

Intento de restauración con archivo corrupto o ajeno: Cargar un PDF, una foto o un archivo truncado en el botón de restaurar [RECOMENDACIÓN].

Mensaje esperado: "Este archivo no es un respaldo válido de Tienda. Tus datos actuales no fueron modificados" [RECOMENDACIÓN].

Fallo típico: La aplicación se cierra de golpe o deja la base de datos en blanco [HIPÓTESIS].

Generar paquete de soporte en un clic: Presionar "Crear paquete de soporte" y ubicar el archivo resultante para enviarlo por WhatsApp Web [RECOMENDACIÓN].

Mensaje esperado: "Paquete listo en el Escritorio: soporte-tienda-AAAAMMDD.zip. Envíalo a soporte" + botón "Abrir carpeta" [RECOMENDACIÓN].

Fallo típico: El archivo se guarda sin extensión visible o en una carpeta interna inaccesible desde el navegador [HIPÓTESIS].

Apertura tras cierre abrupto (simulación de apagón): Matar el proceso desde el Administrador de tareas a mitad de una consulta y volver a abrir [HECHO].

Mensaje esperado: El sistema abre en menos de 5 segundos sin errores ni pérdida de los últimos registros [RECOMENDACIÓN].

Fallo típico: Mensaje de "database is locked" o ventana congelada [HECHO].

Bloqueo de doble ventana: Hacer doble clic dos veces seguidas en el ícono de la aplicación [HECHO].

Mensaje esperado: Trae al frente la ventana ya abierta o avisa: "El sistema ya está abierto en otra ventana" [RECOMENDACIÓN].

Fallo típico: Abre dos instancias simultáneas o falla silenciosamente sin avisar por qué no abre [HIPÓTESIS].

2. Qué confunde o falta en los textos actuales

Jerga técnica innecesaria: Términos como SQLite, WAL, busy_timeout, hash o logs asustan al tendero; deben traducirse a "copia de seguridad", "datos de ventas" y "reporte de diagnóstico" [RECOMENDACIÓN].

Falta de contexto temporal en archivos: Si el nombre sugerido del respaldo no incluye fecha y hora legible (Respaldo_Tienda_2026-11-23_2130.bak), el dueño sobrescribe su único respaldo bueno con uno vacío [HIPÓTESIS].

Ausencia de guía tras generar el paquete de soporte: Falta instruir qué hacer después de crear el ZIP (ej. "Adjunta este archivo en tu chat de WhatsApp de soporte") [RECOMENDACIÓN].

3. Criterio de "listo para mostrar a un cliente"

El flujo de H1 está listo para merge y demostración cuando un usuario sin conocimientos de cómputo completa el ciclo exportar a USB -> simular borrado -> restaurar desde USB -> generar ZIP de soporte en Escritorio en menos de 3 minutos, sin ayuda verbal y sin ver un solo mensaje de error técnico [RECOMENDACIÓN].
```
