# Piloto de Tienda V2

**Estado:** preparado para ejecutar (2026-11-25).  
**Inicio:** cuando se confirme la tienda; el sistema ya cumple H1–H6, 483 pruebas y verificación en Windows y Android.

## Condiciones

- Un negocio, una caja y usuarios definidos.
- 30 días.
- Gratuito o con descuento a cambio de colaboración.
- Capacitación inicial y revisión semanal.
- Registro de errores, diferencias de caja y dificultades de uso.
- Retroalimentación semanal.
- Testimonio final y autorización de uso comercial.
- Sin obligación de compra; precio de lanzamiento si continúa.

## Criterios de aceptación

- 30 días de operación real con una caja.
- ≥ 95 % de las ventas registradas en el sistema.
- ≥ 90 % de los cortes con diferencia $0.00 y diferencia acumulada ≤ $50.
- Cero pérdida de datos y respaldo verificado al menos una vez al día.
- Restauración probada en un equipo de prueba.
- Cero incidentes S1 abiertos más de 4 horas.
- Dueño y personal recomiendan el sistema (≥ 4 de 5).

Detalle y métricas: [criterios-de-exito.md](../../../tienda/SistemaTienda/docs/08-piloto/criterios-de-exito.md).

## Kit y documentación

Todo vive en [`tienda/SistemaTienda/docs/08-piloto`](../../../tienda/SistemaTienda/docs/08-piloto/README.md):

- Plan, riesgos y puertas de decisión.
- Instalación y validación del día 0, con checklist imprimible.
- Capacitación para dueño y cajeros, con evaluación de competencia.
- Tarjeta de una página para el mostrador.
- Guion de 30 días y revisiones semanales.
- Registro de incidencias por severidad.
- Privacidad, consentimiento y fin del piloto.
- Criterios de éxito y decisión continuar / extender / detener.

El kit se arma con [`scripts/piloto-preparar.ps1`](../../scripts/piloto-preparar.ps1):
incluye la app autocontenida, el instalador `h5-instalar.ps1`, la documentación y un
`LEEME-PRIMERO.txt` con el SHA-256 del paquete.

## Qué se vende antes del piloto

- Diagnóstico y demostración.
- Levantamiento y limpieza de catálogo con vista previa de importación.
- Reservación del piloto.
- Instalación y capacitación presencial.
- Acompañamiento semanal y recuperación ante fallas.
