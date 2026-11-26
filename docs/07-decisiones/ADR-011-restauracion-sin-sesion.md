# ADR-011 — Restauración guiada sin sesión

- **Fecha:** 2026-11-26
- **Estado:** Aceptado; prueba manual pendiente
- **Hito:** H2 / piloto

## Contexto

La restauración ya existía en **Ajustes**, pero exigía iniciar sesión con permiso de
configuración. En un equipo nuevo, con la base vacía, no hay usuarios; y si la base
no abre por una migración fallida, la app queda en la pantalla de error. En ambos
casos el dueño no podía llegar a Ajustes para recuperar su respaldo.

## Decisión

- **Instalación nueva:** el asistente ofrece **Restaurar un respaldo**. Solo se
  permite cuando la base no tiene usuarios (`ContarUsuarios() == 0`); después se
  inicia sesión con el PIN del respaldo.
- **Arranque fallido:** la pantalla de error ofrece la misma restauración mediante
  `RestaurarEnRecuperacion`, porque no hay sesión posible.
- **Condiciones en ambos casos:** confirmación explícita, clave de 24 caracteres si
  el archivo es `.db.stb`, respaldo de seguridad `antes-restaurar` y aviso de que se
  reemplaza la base.
- **Windows:** los selectores de MAUI/WinRT fallan con `0x80004005` en la app sin
  empaquetar; se pide la ruta del archivo en un cuadro de texto. Android usa el
  selector del sistema.
- **Después de restaurar:** se navega al login; el dueño entra con los usuarios del
  respaldo. No se conserva la sesión anterior.
- **Sin bitácora en la base reemplazada:** la operación ocurre antes de tener una
  base válida o usuarios; el archivo `antes-restaurar` y la UI son la evidencia.

## Consecuencias

- El dueño puede recuperar en otro equipo o tras una migración fallida sin ayuda
  del desarrollador.
- La restauración sigue sin ser un bypass de PIN: el respaldo trae sus propios
  usuarios y hay que conocer el PIN.
- Un tercero con acceso físico al equipo y un respaldo podría reemplazar la base;
  ya podía reinstalar la app. Se mitiga con el PIN y el control del respaldo.
- Sigue pendiente la prueba manual en Windows y Android y la restauración con la
  tarjeta en **otro** equipo (A2).

## Verificación

- `RestauracionInstalacionTests`: instalación nueva con respaldo plano y cifrado,
  rechazo si ya hay tienda, sin confirmación no toca nada, clave incorrecta no
  restaura y recuperación sin sesión.
- La app compila para Windows sin advertencias.
- Suite completa: 489 pruebas.
- Verificado en Windows el 2026-11-26 sobre la base P3: se pulsó **Restaurar un respaldo**, se pegó la ruta, se confirmó y el PIN 1234 entró a la tienda restaurada (3 usuarios, 53 productos). Pendiente la pantalla de arranque fallido, Android y un selector más amable en Windows.
