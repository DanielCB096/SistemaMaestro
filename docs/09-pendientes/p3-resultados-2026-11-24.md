# P3 — Resultados de usabilidad (2026-11-24)

**Estado:** sesión completada.  
**Participante:** persona del perfil objetivo, sin conocimiento técnico del sistema.  
**Examinador:** facilitador de la sesión.  
**App:** Windows, build de `tienda/main` (`82aa23e`), ApplicationId `com.sistematienda.p3`.  
**Datos:** ficticios; sin datos reales de clientes.

## Resultado general

El participante completó el flujo y **recomendaría el sistema**. La percepción fue “sencillo de utilizar y fácil de entender”, con buena disposición a usarlo en una tienda.

No hubo bloqueo total. Las fricciones se concentraron en tres puntos:

1. Ruta del respaldo.
2. QR del ticket que no se pudo escanear.
3. Falta de búsqueda dinámica en productos.

## Hallazgos

### F1 — Ruta del respaldo poco accionable

**Severidad:** P1 (confusión + tiempo perdido).  
**Evidencia del participante:** “la parte del respaldo… sería bueno que se añadiera un hipervínculo o algo que te permita copiar el path donde se guarda”.  
**Evidencia del examinador:** “navegar hasta donde marcaba la ventana no era tan fácil; no le permitía copiar o ir directamente a la ubicación seleccionando el texto”.

**Problema:** el mensaje muestra la ruta como texto plano. No se puede seleccionar, copiar ni abrir la carpeta desde el diálogo.

**Propuesta:**

- Botón **Copiar ruta** con `Clipboard`.
- Botón **Abrir carpeta** con el explorador de Windows.
- Mantener el nombre del archivo y la carpeta visibles.
- En restauración, abrir el selector en la carpeta de respaldos por defecto.
- Considerar una lista de “respaldos recientes” con acción **Restaurar** directa.

### F2 — QR del ticket no escaneable

**Severidad:** P1 (función de ticket/QR no cumple su promesa).  
**Evidencia del participante:** “el QR que el cliente no pudo escanear al cerrar la venta”; “no lo pude escanear en dispositivo Android”.

**Problema:** el QR es informativo y offline, pero el participante no logró leerlo desde un Android. Puede deberse a tamaño, zona de silencio, densidad del contenido, brillo de pantalla o distancia de la cámara.

**Propuesta:**

- Reproducir con 2–3 teléfonos y con el QR en pantalla y compartido como PNG.
- Aumentar tamaño y zona de silencio; usar corrección de errores `Q` o `H`.
- Reducir el contenido: folio, total y fecha en lugar de hasta diez productos.
- Añadir texto de respaldo visible y opción de compartir el ticket en texto.
- Si el QR sigue fallando, documentar que es solo informativo y no prometer escaneo.

### F3 — Falta de búsqueda dinámica en productos

**Severidad:** P1/P2 (fricción en el flujo más frecuente).  
**Evidencia del participante:** “la búsqueda dinámica en productos”; “mientras se ingresa el artículo a vender ir sugiriendo de los registrados”.

**Problema:** el POS no sugiere productos mientras se escribe; obliga a un paso adicional para buscar.

**Propuesta:**

- `TextChanged` con debounce (200–300 ms) en el buscador del POS.
- Mostrar los primeros 5–10 resultados con nombre, precio y stock.
- Permitir seleccionar con teclado y con toque.
- Mantener búsqueda por código de barras y Enter.
- Probar con 10 000 productos para evitar cargar todo el catálogo en cada tecla.

### F4 — Pulido visual

**Severidad:** P2.  
**Evidencia:** “tal vez solo mejorar un poco las interfaces”.

**Propuesta:** revisar jerarquía visual, tamaños táctiles, textos de ayuda y consistencia entre pantallas. No es bloqueante.

## Lo que funcionó

- Configuración inicial rápida.
- Login y operación entendibles.
- Venta y corte sin ayuda.
- Respaldo y restauración completados, aunque con fricción en la ruta.
- El participante recomendaría el sistema.

## Próximos cambios sugeridos

| Rama propuesta | Alcance | Prioridad |
|---|---|---|
| `fix/p3-respaldo-ruta` | Copiar ruta, abrir carpeta, selector inicial en respaldos, lista de recientes | Alta |
| `fix/ticket-qr-escaneo` | Reproducir y ajustar tamaño/quiet zone/contenido; pruebas con 2–3 teléfonos | Alta |
| `feat/pos-busqueda-dinamica` | Sugerencias mientras se escribe, debounce y pruebas con catálogo grande | Alta |
| `fix/ui-pulido` | Jerarquía visual y textos | Media |

## Evidencia

- Guion: [`p3-guion-participante.md`](p3-guion-participante.md).
- Observación: [`p3-observacion.md`](p3-observacion.md).
- Este documento es el registro de resultados; no contiene datos personales del participante.
