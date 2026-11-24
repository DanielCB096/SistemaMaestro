# Ronda de verificación manual de H1 — 2026-11-23

**Objeto:** definir el criterio de aceptación manual de H1 y contrastarlo con una ejecución real en Windows.  
**Participantes:** ChatGPT (producto/negocio), Claude (arquitectura/riesgo), Gemini (UX/operaciones) y DeepSeek (ejecución).  
**Resultado:** el núcleo de H1 en Windows pasa; Android, otro equipo físico, corte de energía y prueba con un dueño no técnico quedan pendientes. Se encontró y corrigió un fallo real de exportación cuando `Documentos` no es escribible.

## Lo que pidieron los expertos

### Claude — mínimo para mergear

- **W1:** exportar a una carpeta externa; el archivo debe incluir lo que estaba en `-wal`.
- **W2:** restaurar en otro equipo limpio; mismos conteos de ventas, fiados y cortes.
- **W3:** restaurar sobre una base con datos; respaldo previo automático.
- **W4:** rechazar archivo corrupto sin tocar la base actual.
- **W5:** dos instancias no deben operar a la vez.
- **W6/W7:** corte de energía en venta o respaldo sin corrupción.
- **W8:** paquete de soporte con versión, esquema y datos personales protegidos.
- **W9:** venta y respaldo simultáneos sin “database is locked”.
- **W10:** un dueño no técnico completa W1 y W2 sin ayuda.
- **A1–A3:** Android, solo si se ofrece a clientes; si no, deuda documentada.

**Bloquea:** fallas en W1–W7, W10, conteos distintos, Android ofrecido sin probar o paquete con datos sin protección.

### Gemini — UX para dueño no técnico

- Exportar a USB con mensaje claro de unidad y fecha.
- Restauración con advertencia de reemplazo y respaldo previo.
- Rechazo de archivo corrupto con mensaje no técnico.
- Paquete de soporte en Escritorio, con instrucción de qué hacer después.
- Apertura tras cierre abrupto sin “database is locked”.
- Doble ventana: avisar o traer al frente, no abrir dos instancias.

**Criterio:** ciclo exportar → simular borrado → restaurar → ZIP de soporte en menos de 3 minutos, sin ayuda verbal y sin errores técnicos.

### ChatGPT — promesa comercial

- Se puede prometer respaldo, restauración, exportación, operación local y estabilidad de SQLite.
- No se puede prometer cifrado, nube, CFDI, recuperación automática ni seguridad total.
- H1 no se anuncia como terminado hasta verificación manual y merge.

## Ejecución manual en Windows

**Entorno:** Windows 11, build Release, base de prueba aislada en `%TEMP%\opencode\h1-manual`. Tienda de prueba con 1 usuario dueño, 1 producto (`H1TEST`) y fondo de caja de $200.

| Escenario | Resultado | Evidencia |
|---|---|---|
| W1 Exportar respaldo | **PASA** con fallback | `Documentos` no permite crear archivos en este equipo; se usó `Escritorio\SistemaTienda\tienda-20261123-212648-exportacion.db` |
| W2 Restaurar | **PASA** | Producto `H1TEST`, usuario y configuración conservados |
| W3 Respaldo previo | **PASA** | `respaldos\tienda-20261123-212806-antes-restaurar.db` |
| W4 Archivo corrupto | **PASA** | Rechazado: “no pasó la verificación de integridad”; base intacta |
| W5 Dos instancias | **PASA** | La segunda muestra “SistemaTienda ya está abierto” |
| W8 Paquete sin base | **PASA** | ZIP con `LEEME.txt` y `resumen.txt`; sin `datos.db` |
| W8 Paquete con base | **PASA** | Confirmación explícita; ZIP con `datos.db`, producto y usuario |
| W6/W7 Corte de energía | **PENDIENTE** | Cubierto parcialmente por pruebas de WAL, no manual |
| W9 Venta + respaldo | **PENDIENTE** | No ejecutado manualmente |
| W10 Dueño no técnico | **PENDIENTE** | La ejecución fue automatizada |
| A1–A3 Android | **PENDIENTE** | Sin `adb` ni dispositivo/emulador |
| Otro equipo físico | **PENDIENTE** | Restauración probada en base aislada, no en hardware distinto |

## Hallazgo real

En este equipo, `C:\Users\PC\Documents` **no permite crear archivos** aunque el ACL muestre control total. `Directory.CreateDirectory` y `File.Copy` fallan con `FileNotFoundException`. Es un problema de la carpeta conocida (posible redirección/OneDrive), no de SQLite ni del respaldo.

La app original solo intentaba `Documentos\SistemaTienda`, así que la exportación fallaba con “Could not find file” y el usuario no podía sacar el respaldo. Se corrigió en `546900f`:

- `CarpetaExportacion` prueba en orden: `Documentos\SistemaTienda` → `Escritorio\SistemaTienda` → `Descargas\SistemaTienda`.
- Elige la primera donde realmente puede crear un archivo de prueba.
- Agrega 3 pruebas: primera carpeta, salta ruta inválida y falla si ninguna sirve.
- La app informa la ruta final en el diálogo.

## Decisión de la ronda

- **H1 en Windows:** aceptado en su núcleo (W1–W5, W8) con la corrección `546900f`.
- **Pendiente antes de anunciar H1 como terminado:** CI de `546900f`, Android si se ofrece, otro equipo físico, corte de energía y prueba con un dueño no técnico.
- **Deuda documentada:** cifrado de respaldos, respaldo automático programado y mejoras de redacción de mensajes, con aviso explícito de que no hay cifrado.
- **Regla:** ninguna deuda se acepta sin dueño, riesgo y fecha; el merge no lo decide solo quien ejecuta la verificación.

## Respuestas completas

- [Claude](2026-11-23-verificacion-h1/claude.md)
- [Gemini](2026-11-23-verificacion-h1/gemini.md)
- [ChatGPT](2026-11-23-verificacion-h1/chatgpt.md)

## Evidencia del código

- `SistemaTienda/SistemaTienda.Application/Services/CarpetaExportacion.cs`
- `SistemaTienda/SistemaTienda.Maui/Services/ExportacionRespaldoApp.cs`
- `SistemaTienda/SistemaTienda.Tests/CarpetaExportacionTests.cs`
- `SistemaTienda/docs/estado-h1.md` en la rama `feat/h1-respaldo-restauracion`
