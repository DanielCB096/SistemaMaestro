# P3 — Hoja de observación del facilitador

**Objetivo:** medir si un dueño no técnico completa el flujo básico sin ayuda verbal.  
**Duración:** 30–45 min.  
**Regla:** no guiar, no señalar botones, no corregir en vivo. Solo observar y anotar.

## Preparación

1. Cierra la app de prueba y deja la base vacía (escenario `limpio`):

```powershell
powershell -ExecutionPolicy Bypass -File C:\opentelemety\SistemaMaestro\scripts\p3-preparar.ps1 -Reset
```

La prueba de primera vez exige base vacía: el participante debe pasar por el asistente y elegir su PIN. Si quieres una demo con datos, usa `-Semilla demo` (PIN 1234), pero no es la prueba P3.

2. Verifica el acceso directo `Prueba P3 - SistemaTienda` en el Escritorio.
3. Imprime o muestra [`p3-guion-participante.md`](p3-guion-participante.md).
4. Ten a mano la tabla de datos de prueba.
5. Si se graba pantalla o audio, pide consentimiento.

## Datos de la sesión

| Campo | Valor |
|---|---|
| Fecha | |
| Participante (nombre o alias) | |
| Perfil (abarrotes, purificadora, minisúper) | |
| ¿Usó PC antes? | |
| Hora de inicio / fin | |
| ¿Se grabó? | |

## Registro por tarea

| # | Tarea | Tiempo | ¿Completó? | Dudas o errores | ¿Necesitó ayuda? |
|---|---|---|---|---|---|
| 1 | Abrir y configurar tienda | | | | |
| 2 | Login con PIN | | | | |
| 3 | Alta de producto | | | | |
| 4 | Venta en efectivo | | | | |
| 5 | Corte de caja | | | | |
| 6 | Crear y exportar respaldo | | | | |
| 7 | Restaurar y reabrir | | | | |
| 8 | Cerrar sesión | | | | |

## Observaciones cualitativas

- ¿Dónde se detuvo más tiempo?
- ¿Qué etiquetas o mensajes no entendió?
- ¿Intentó hacer algo que la app no permite?
- ¿Qué hizo con el teclado, el ratón o la pantalla?
- ¿Comprendió la diferencia entre “respaldo”, “exportar” y “restaurar”?
- ¿Confió en el corte de caja?
- ¿Vio el cambio correcto? ($20)
- ¿Encontró el archivo exportado?
- ¿Entendió que restaurar reemplaza los datos?

## Resultado

| Criterio | Resultado |
|---|---|
| Completó el flujo sin ayuda | Sí / No |
| Cometió un error recuperable | Sí / No |
| Se bloqueó | Sí / No |
| Recomendaría el sistema | Sí / No / Tal vez |

## Cierre

1. Agradecer.
2. Ejecutar `p3-reset.ps1` para dejar limpio.
3. Registrar los hallazgos en un documento nuevo:

```text
docs/09-pendientes/p3-resultados-YYYYMMDD.md
```

4. Clasificar cada hallazgo:

- **P0:** impide operar o pone en riesgo datos.
- **P1:** confunde y requiere ayuda.
- **P2:** fricción menor o mejora de texto.

## Nota

Un fallo de la persona no es un fallo de la persona: es un fallo del sistema o de las instrucciones. Registrar sin corregir en vivo.
