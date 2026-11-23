# Métricas y evidencia de la auditoría

**Fuente:** `docs/00-auditoria/informe-tienda-gym-dotnet.md`.

| Métrica | `tienda` | `gym-dotnet` |
|---|---|---|
| Archivos C# | 121 | 125 |
| Líneas C# | ~18,918 | ~41,853 |
| XAML | 17 archivos / 3,246 líneas | — |
| JS/JSX | — | 55 archivos / ~9,950 líneas |
| Tablas | 18 | 41 + `ANXO_SEQUENCES` |
| Endpoints | menús de consola | 164 rutas |
| Controladores | — | 18 |
| Módulos | 7 servicios principales | 16 |
| Pruebas | 293 `[Fact]` + 25 `[Theory]` | 99 `[Fact]` + 5 `[Theory]` |
| Migraciones | v1–v14 | Sin versionado |
| SQL embebido | 164 sentencias | ~231 literales |
| `Dictionary<string, object>` | — | ~398 |
| `catch (Exception)` | 26 en servicios | 159 en módulos / 198 backend |

## Evidencia principal

- `Database.cs` ~1,996 líneas, ~72 métodos públicos, lógica y persistencia mezcladas.
- `Program.cs` ~1,917 líneas, ~81 métodos.
- `ConfiguracionService` ~946 líneas, 54 miembros públicos.
- `InventarioPage.xaml.cs` ~1,145 líneas; `ProveedoresPage` ~894.
- `IdentityModule.cs` ~2,167 líneas; `MembersModule.cs` ~1,526.
- `_ModelGym.xml`: 41 tablas, 640 atributos, 34 FK, 59 índices.
- gym: 155 validaciones de token en controladores; 299 referencias a `DataCenter`.

## Nota

Las cifras son aproximadas y sirven para dimensionar. No sustituyen una medición de build, pruebas o rendimiento.
