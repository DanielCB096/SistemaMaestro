# ADR-010 — Marca POSale e icono de la aplicación

- **Fecha:** 2026-11-25
- **Estado:** Aceptado
- **Hito:** Piloto

## Contexto

El nombre visible era “SistemaTienda”, el mismo nombre técnico del repositorio. Es
genérico, difícil de recordar y no dice qué hace. El icono seguía siendo el logo
genérico de .NET (cuadro morado con “NET”), que no representa el producto y confunde
en el escritorio o en Android.

## Decisión

- **Nombre visible:** **POSale**.
- **Descriptor:** “Punto de venta para tu tienda”.
- **Icono:** canasta de compras con etiqueta de precio y signo de peso, en verde
  `#2E6B4F`, crema `#F7F3E8` y contorno casi negro `#10231B`.
- **Formato:** SVG editable para icono completo, foreground adaptativo y splash.
  Se revisó a 256, 96, 48, 32 y 24 px; el contorno y el signo de peso mantienen la
  lectura en tamaños pequeños.

### Identificadores que NO cambian

Cambiar la marca no debe romper datos, respaldos ni actualizaciones:

| Elemento | Se conserva |
|---|---|
| Repositorio y solución | `SistemaTienda` |
| Espacios de nombres y ensamblados | `SistemaTienda.*` |
| ApplicationId | `com.sistematienda.tienda` |
| Carpeta de datos | `%LOCALAPPDATA%\SistemaTienda\com.sistematienda.tienda` |
| Producto del manifiesto | `SistemaTienda` (compatibilidad H5) |
| Variables | `SISTEMATIENDA_DB` |

La marca solo cambia `ApplicationTitle`, títulos de ventana, textos visibles,
nombre del paquete de instalación (`POSale-<versión>-win-x64.zip`) y documentación.

## Consecuencias

- El dueño ve “POSale” en el escritorio, Android y el instalador.
- Los respaldos y actualizaciones siguen funcionando sin migración.
- La documentación técnica puede seguir diciendo `SistemaTienda` en rutas y
  proyectos; la documentación de usuario dice POSale.
- Queda pendiente una búsqueda formal de marca/dominio y registrar el nombre si el
  piloto continúa. La búsqueda rápida no mostró un POS con ese nombre exacto.

## Verificación

- Icono renderizado por el pipeline de MAUI en Windows; revisión visual a varios
  tamaños.
- `dotnet build` de Windows sin advertencias.
- Pendiente: build de Android y revisión del icono adaptativo en el teléfono.
