# Ronda de verificación de H1 — ChatGPT (producto y negocio)

**Fecha:** 2026-11-23  
**Sesión:** ChatGPT web, cuenta Daniel Cuevas Bernal (plan Free)  
**Pregunta:** qué se puede prometer comercialmente después de H1 y qué no.

> Texto tal como lo devolvió la sesión. Las tablas venían separadas por tabuladores.

```text
1. Afirmaciones vendibles después de validar H1
[RECOMENDACIÓN] Respaldo de información: «Puedes generar respaldos de la información de tu negocio para proteger tus operaciones».
[RECOMENDACIÓN] Restauración: «Si ocurre un problema, puedes recuperar tu información mediante un respaldo válido».
[RECOMENDACIÓN] Exportación: «Puedes guardar una copia de tu información fuera del equipo para conservarla».
[RECOMENDACIÓN] Operación local: «El sistema funciona sin depender de una conexión permanente a internet».
[RECOMENDACIÓN] Mayor estabilidad de base de datos: «Hemos incorporado mejoras para gestionar las operaciones locales de SQLite y evitar que se ejecuten varias instancias de la aplicación simultáneamente».

Importante: no anunciar estas mejoras como garantías absolutas de que nunca habrá pérdida de datos o fallos.

2. Lo que NO debemos prometer todavía
Afirmación	Estado y razón
Base de datos cifrada	[HECHO] H1 no acredita cifrado de datos ni respaldos.
Respaldo automático en la nube	[HECHO] No existe infraestructura de sincronización o almacenamiento remoto validada.
Facturación CFDI integrada	[HECHO] V2 no timbra ni está integrada con un PAC.
Recuperación automática ante cualquier fallo	[HECHO] Tener restauración no significa recuperación automática ni protección ante todos los escenarios.
Seguridad total contra robo de información	[HECHO] WAL y respaldos no sustituyen controles completos de seguridad, permisos y protección de archivos.
3. Checklist de demostración para cliente piloto

Preparación

Instalar la versión candidata en Windows.
Registrar productos, precios y existencias.
Crear usuarios con diferentes permisos.
Registrar ventas, compras y gastos.

Demostración H1

Generar un respaldo.
Exportarlo a una ubicación externa.
Verificar que el archivo existe y tiene contenido válido.
Restaurar el respaldo en una instalación de prueba independiente.
Comprobar productos, ventas, inventario y saldos restaurados.
Abrir dos veces la aplicación y comprobar que no se ejecutan dos instancias simultáneas.
Realizar operaciones consecutivas y comprobar que los datos permanecen consistentes.

Validación operativa

Simular cierre inesperado y comprobar recuperación.
Registrar incidencias y documentar resultados.
Confirmar que el cliente puede generar y recuperar un respaldo sin ayuda técnica.
Decisión comercial

[RECOMENDACIÓN] H1 no debe anunciarse como terminado hasta completar verificación manual y merge.

Después, podemos vender una propuesta concreta: un sistema de negocio local que permite respaldar y recuperar información sin depender de internet.

La promesa debe ser confiabilidad comprobada, no invulnerabilidad.
```
