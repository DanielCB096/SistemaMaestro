# Ronda de aprobación — 2026-11-23

**Participantes:** ChatGPT, Claude, Gemini.  
**Objeto:** aprobar el alcance de Tienda V2 y autorizar el inicio de H1.  
**Resultado:** H1 autorizado por los tres, con condiciones y modificaciones.

## Votos

| Punto | ChatGPT | Claude | Gemini | Resultado |
|---|---|---|---|---|
| 1. Windows-first; Android secundario | SÍ | SÍ | SÍ | Aprobado |
| 2. Cliente ideal; excluir forrajeras/básculas | SÍ | SÍ | SÍ | Aprobado |
| 3. Precios $5,900 / $7,900 / soporte $350–450 | MODIFICAR | MODIFICAR | MODIFICAR | Tentativo; validar con clientes y medir costos |
| 4. Piloto semana 9–10, 30 días, tras H4 | SÍ | MODIFICAR | MODIFICAR | Aprobado el orden; fecha condicionada a puertas, no a calendario |
| 5. CFDI extensión; V2 no timbra | SÍ | SÍ | SÍ | Aprobado con comunicación clara |
| 6. Validaciones externas | MODIFICAR | MODIFICAR | MODIFICAR | Añadir privacidad/legal, seguridad, operación real y equipo limpio |
| 7. Iniciar H1 ya | SÍ | SÍ | SÍ | **AUTORIZADO** |

## Condiciones para H1

- Copia de seguridad del repositorio y de una base de ejemplo fuera del equipo.
- Rama dedicada, sin mezclar otros cambios.
- Las 318 pruebas existentes en verde antes de empezar.
- Prueba de aceptación: restaurar en otro dispositivo y evitar corrupción con dos instancias.
- Cuidado con WAL: el respaldo debe consolidar o copiar correctamente `-wal` y `-shm`.
- H1 no termina porque compile: termina cuando la recuperación esté probada.

## Modificaciones acordadas

### Precios

- Mantener $5,900 / $7,900 como precios de lanzamiento tentativos.
- No fijarlos como definitivos hasta medir horas reales de instalación y soporte.
- Definir diferencia funcional clara entre Básica y Profesional.
- Evaluar incluir 3 meses de soporte en la compra inicial.

### Piloto

- No arrancar por calendario; arrancar cuando se cumplan las puertas: suite verde, corte cuadrado, restauración probada, instalador con rollback.
- Hacer un ensayo interno de una semana con datos simulados antes del cliente.
- Elegir un negocio tolerante, cercano y no crítico.
- Gemini propone 14 días intensivos; ChatGPT y Claude prefieren 30 días. Decisión: duración se ajusta al piloto y a las puertas, no a una fecha fija.

### Validaciones adicionales

- Aviso de privacidad y tratamiento de datos (LFPDPPP).
- Contrato de licencia y soporte revisado por abogado.
- Régimen fiscal propio para facturar licencia y soporte.
- Revisión breve de seguridad de permisos y respaldos.
- Prueba de instalación/actualización en una PC Windows limpia.
- Shadowing de 2 horas en hora pico en una tienda real antes de congelar la UX.

## Decisión

**H1 autorizado.** Alcance:

- Respaldo y restauración desde la app.
- Exportación del respaldo fuera del dispositivo.
- Paquete de soporte.
- WAL, `busy_timeout` e instancia única.

No se añaden funcionalidades comerciales nuevas en H1.
