# Instrucciones para agentes

Este repositorio es la **fuente de verdad documental** de SistemaMaestro. El código de producto vive en [`DanielCB096/tienda`](https://github.com/DanielCB096/tienda). No se toca `gym-dotnet` desde aquí.

## Antes de escribir código (obligatorio)

1. Lee [`docs/08-agentes/ONBOARDING.md`](docs/08-agentes/ONBOARDING.md).
2. Ejecuta:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\preparar-entorno.ps1
   ```

   Esto copia las 6 skills P0 a OpenCode y a `~/.agents/skills`, instala `graphify` y verifica .NET, Android SDK y `adb`.

3. Verifica que OpenCode cargó las skills:
   - `graphify`
   - `protocolo-de-cambio`
   - `sqlite-local`
   - `dinero-y-reglas-caja`
   - `testing-dotnet`
   - `seguridad-permisos`
   - `backup-recovery`

4. Verifica las herramientas:
   - `dotnet --version`
   - `dotnet workload list`
   - `adb devices -l`
   - `java -version`

5. Lee el estado actual:
   - [`docs/06-referencias/h1-respaldo-restauracion.md`](docs/06-referencias/h1-respaldo-restauracion.md)
   - [`docs/06-referencias/h1-android.md`](docs/06-referencias/h1-android.md)
   - [`docs/08-agentes/catalogo-skills.md`](docs/08-agentes/catalogo-skills.md)

## Reglas de trabajo

- Carga `protocolo-de-cambio` antes de tocar código.
- Rama dedicada, línea base de pruebas y evidencia al final.
- No trabajar directamente en `main` de `tienda` sin rama.
- Una decisión por ADR; documenta antes de implementar.
- No secretos, credenciales, bases de datos ni respaldos reales en el repositorio.

## Estado actual (2026-11-24)

- **H1 mergeado** en `tienda` `main` (merge `41c5983`, PR #40).
- **CI de `main` en verde** (Windows y Android compilan).
- **Verificación manual Windows:** W1–W5 y W8 pasan.
- **Verificación manual Android:** **PASA**. Exportar, restaurar, paquete sin base y paquete con base verificados en POCO X6 Pro 5G / Android 16. Evidencia en [`docs/06-referencias/h1-android.md`](docs/06-referencias/h1-android.md).
- **Corrección Android:** `fix/android-soporte-cache`, commit `67af2a5`, 378/378 pruebas. CI en verde (run `45424725218`). Fusionada a `main` por fast-forward (`84dc8e1..67af2a5`) porque la cuenta de Edge no puede abrir PR (`must be a collaborator`).
- **Limpieza de advertencias:** `chore/instancia-unica-warnings`, commit `82aa23e`, CI verde (run `45442442966`); Android queda en 0 advertencias. Fusionada a `main` por fast-forward (`67af2a5..82aa23e`).
- **Skills:** 6 P0 instaladas; P1/P2 definidas en el catálogo.
- **Graphify:** instalado (`0.9.114`) y skill visible en OpenCode y `~/.agents/skills`; el grafo de `tienda` no se versiona.

## Siguiente paso

1. Probar en otro equipo físico/tablet, corte de energía y dueño no técnico.
2. Iniciar **H2**: permisos por acción, bloqueo persistente, timeout de sesión, manejador global y respaldos cifrados.
