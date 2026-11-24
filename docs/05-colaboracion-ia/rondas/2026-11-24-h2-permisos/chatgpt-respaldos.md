# Ronda H2.3 — ChatGPT (producto)

**Fecha:** 2026-11-24
**Pregunta:** dónde guardar la clave maestra, alcance del cifrado y activación en tiendas nuevas.

## 1. ¿Dónde guardar la clave maestra?

[RECOMENDACIÓN] Almacenamiento seguro del sistema operativo: DPAPI en Windows, Android Keystore en Android.

[HECHO] Esto permite que los respaldos automáticos usen la clave protegida sin solicitarla cada día.

[RECOMENDACIÓN] La tarjeta de recuperación debe permitir recuperar el acceso al cambiar o perder el equipo. La clave protegida localmente no debe ser el único medio de recuperación.

## 2. ¿Cifrar automáticos y manuales?

[RECOMENDACIÓN] Ambos. Una vez activado, todos los respaldos nuevos se cifran: automáticos sin intervención, manuales con la misma protección. Los antiguos sin cifrar se pueden restaurar con advertencia.

[HECHO] Dejar los automáticos sin cifrar mantendría una copia vulnerable y debilitaría la protección ofrecida.

## 3. ¿Activarlo por defecto en tiendas nuevas?

[RECOMENDACIÓN] Sí, con configuración guiada: definir la clave maestra, generar la tarjeta, confirmar que se guardó en un lugar separado del equipo y verificar que el respaldo cifrado se puede restaurar.

[HIPÓTESIS] La activación predeterminada reduce olvidos y configuraciones inseguras en negocios con dueños no técnicos.

[RECOMENDACIÓN] Si el proceso no termina, mostrar claramente que los respaldos aún no están cifrados. No presentar esa instalación como protegida.

## Decisión aprobada

| Punto | Decisión |
|---|---|
| Almacenamiento | DPAPI / Android Keystore |
| Respaldos automáticos | Cifrados |
| Respaldos manuales | Cifrados |
| Tiendas nuevas | Predeterminado con configuración guiada |

[RECOMENDACIÓN] Condición de lanzamiento: probar la restauración en otro equipo y con la tarjeta de recuperación. Un respaldo cifrado que el dueño no puede recuperar no es una protección comercialmente aceptable.
