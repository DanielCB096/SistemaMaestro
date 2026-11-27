# ADR-018 — Siguiente producto: Taller & Servicio Express

- **Fecha:** 2026-11-27
- **Estado:** Propuesto (requiere aprobación del dueño)
- **Hito:** Catálogo de productos SistemaMaestro

## Contexto

SistemaMaestro ya tiene POSale (retail), Centro Fit (gimnasio) y Clara (finanzas
personales). El equipo es muy pequeño y cada producto nuevo debe instalarse,
venderse y soportarse sin multiplicar el trabajo.

Se consultó a tres IAs con roles de producto, arquitectura y operación. Las tres
propusieron candidatos distintos y, tras una segunda ronda de crítica cruzada,
**las tres eligieron Taller & Servicio Express**.

## Decisión

1. **Construir Taller & Servicio Express** como vertical independiente, enfocado
   inicialmente en **reparación de celulares, cómputo y electrónica**, no en
   talleres mecánicos.
2. **No construir Maestro Central como producto comercial** todavía. Solo una
   pieza interna mínima dentro del instalador: reporte de versión, licencia y
   último respaldo, más respaldo automático al cierre.
3. **Validar antes de programar:** 8–15 entrevistas y 3 pilotos con pago parcial
   antes de escribir el MVP completo.

## Por qué gana

- El dolor es inmediato y caro: perder una orden o entregar un equipo sin cobrar
  el saldo cuesta más que el software.
- Todo ocurre en el mostrador: PC fija, ticket térmico, anticipo y entrega. No
  exige app móvil ni sincronización en la nube.
- Reutiliza gran parte de POSale: SQLite, caja, abonos, tickets, roles, MSI,
  licencias y respaldos.
- Se demuestra en cinco minutos y se vende sin depender de POSale.

## Alternativas descartadas

| Alternativa | Por qué no ahora |
|---|---|
| **Maestro Rutas** (purificadoras) | El reparto ocurre en la calle; exigiría app offline para repartidores. Mercado más estrecho y menor reutilización. Queda para una segunda ola. |
| **Maestro Central** (panel del dueño) | Retención, no adquisición; dolor latente y difícil de cobrar. Su valor se reduce a telemetría y respaldos internos. |
| **Agenda y cobros** (estética, consultorios) | Competencia fuerte con agendas gratuitas; mercado amplio pero menos diferenciado. |

## Consecuencias

- Nuevo dominio: órdenes de servicio, estados, anticipos, autorizaciones y
  garantías. No es un módulo de POSale.
- El piloto debe nacer con respaldo automático y reporte mínimo de salud; si no,
  el soporte se vuelve lineal.
- Nada de inventario avanzado, CFDI, WhatsApp API, app móvil ni personalizaciones
  por cliente en el MVP.
- Si no hay 3 pilotos con pago en 30 días, se detiene y se reconsidera el
  mercado; no se agregan funciones para rescatar el producto.

## Evidencia

- Ronda multi-modelo 2026-11-27 (ChatGPT, Claude, Gemini), dos rondas.
- Detalle de producto, MVP y validación:
  [taller-servicio-express.md](../03-producto/taller-servicio-express.md).
