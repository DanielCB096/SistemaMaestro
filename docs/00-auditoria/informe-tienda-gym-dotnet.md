# Informe técnico comparativo: `tienda` y `gym-dotnet`

**Fecha:** 23 de noviembre de 2026  
**Repositorios analizados:** `DanielCB096/tienda` y `DanielCB096/gym-dotnet`  
**Método:** análisis estático de solo lectura sobre copias locales clonadas. No se compiló ni se ejecutó nada. No se modificó, creó ni eliminó ningún archivo de los repositorios.  
**Alcance:** estructura, arquitectura real, modelos, funcionalidades, dependencias, código reutilizable, deuda técnica y propuesta de migración a un sistema universal (tienda + gimnasio).

> **Nota metodológica:** cuando la documentación de un repositorio contradice al código, este informe prioriza el código. Las rutas se expresan relativas al repositorio; las copias de trabajo estuvieron en `C:\Users\anxoD\AppData\Local\Temp\opencode\repos\tienda` y `...\gym-dotnet`.

---

## 0. Resumen ejecutivo

| Dimensión | `tienda` | `gym-dotnet` |
|---|---|---|
| Producto | POS local-first para tiendas pequeñas | Gestión integral de gimnasio |
| Plataforma | .NET 8 (librerías) + MAUI .NET 10 (Windows/Android) + consola | .NET 10 Windows Service + ASP.NET Core/Kestrel + React 19 |
| Datos | SQLite local, 18 tablas, esquema v14 | SQL Server, 41 tablas `GYM_*` + `ANXO_SEQUENCES` |
| Persistencia | ADO.NET crudo (`DatabaseTools`, ~1,996 líneas) | GymCore (`DatabaseTools`) + SQL crudo + `Session` |
| UI | XAML MAUI con code-behind; consola de ~1,917 líneas | SPA React + Vite/Tailwind; kiosco HTML aparte |
| Autenticación | PIN PBKDF2 + roles estáticos | Sesiones Bearer opacas + MFA TOTP + OTP + RBAC |
| Tamaño aprox. | ~17,000 líneas C# (sin docs/XAML), 40 archivos de prueba | ~37,900 líneas C# (incluye generados) + ~9,950 JS/JSX |
| Pruebas | 293 `[Fact]` + 25 `[Theory]`; SQLite temporal | 99 `[Fact]` + 5 `[Theory]`; integración opcional contra SQL Server |
| Estado | MVP funcional, verificado en Windows y Android | Producción local, versión 1.7.6, con deuda operativa |

**Conclusión ejecutiva:**

- **`tienda`** tiene un núcleo técnico aprovechable (`Dinero`, `Result`, `Texto`, PDF/CSV, QR, migraciones, respaldos, auditoría, PIN), pero su arquitectura es un monolito por capas con un *god object* de persistencia, sin interfaces, sin asincronía y con lógica de negocio duplicada entre servicios, infraestructura y code-behind.
- **`gym-dotnet`** es un monolito modular alojado como servicio Windows, con seguridad y operación más maduras (PBKDF2 210k, sesiones opacas, MFA, backups offsite, cuenta virtual), pero acoplado al esquema `GYM_*`, a GymCore y a un estado global estático; no compila de forma reproducible sin las librerías externas y tiene carreras de concurrencia en ventas, caja, accesos y finanzas.
- **Ninguno sirve tal cual como base del sistema universal.** `tienda` aporta reglas y componentes de retail; `gym-dotnet` aporta identidad, operación y componentes de plataforma. La migración debe extraer un núcleo común y tratar ambos como verticales.

---

## 1. Árbol de carpetas y proyectos

### 1.1 `tienda`

```text
tienda/
├─ .github/workflows/ci.yml
├─ AGENTS.md · CLAUDE.md · CLAUDE-tienda.md · prompt.txt
└─ SistemaTienda/
   ├─ SistemaTienda.sln                    (5 proyectos; MAUI queda fuera)
   ├─ docs/
   │  ├─ 00-contexto/ · 01-arquitectura/ · 02-modulos/
   │  ├─ 03-procesos/ · 05-decisiones/ · 06-operacion/ · 07-pruebas/
   │  └─ changelog.md · deuda-tecnica.md · roadmap.md · coordinacion.md
   ├─ SistemaTienda.Core/                  19 .cs
   ├─ SistemaTienda.Infrastructure/        3 .cs
   ├─ SistemaTienda.Application/Services/  15 .cs
   ├─ SistemaTienda.Presentation/           1 .cs (consola)
   ├─ SistemaTienda.Maui/                  43 .cs + XAML (fuera de la solución)
   │  ├─ Models/                           15 modelos de vista
   │  ├─ Pages/                            15 pantallas
   │  ├─ Services/                         7 helpers MAUI
   │  └─ Platforms/{Android,Windows}/
   └─ SistemaTienda.Tests/                 40 .cs
```

| Proyecto | TFM | Referencias | Paquetes relevantes |
|---|---|---|---|
| `SistemaTienda.Core` | `net8.0` | ninguna | ninguno |
| `SistemaTienda.Infrastructure` | `net8.0` | Core | `Microsoft.Data.Sqlite` 8.0.10, `SQLitePCLRaw.bundle_e_sqlite3` |
| `SistemaTienda.Application` | `net8.0` | Core, **Infrastructure** | `DocumentFormat.OpenXml` 3.5.1, `Net.Codecrete.QrCodeGenerator` 3.2.1 |
| `SistemaTienda.Presentation` | `net8.0` | Core, Infrastructure, Application | — |
| `SistemaTienda.Maui` | `net10.0-android`, `net10.0-windows10.0.19041.0` | Core, Application, **Infrastructure** | `Microsoft.Maui.Controls`, QrCodeGenerator |
| `SistemaTienda.Tests` | `net8.0` | Core, Infrastructure, Application | xUnit 2.9.2, `Microsoft.NET.Test.Sdk` 17.11.1 |

**Observaciones estructurales:**

- La solución contiene **5 proyectos**; `SistemaTienda.Maui` se compila aparte con .NET 10 y workloads MAUI. No está incluido en `.sln`.
- No hay `Directory.Build.props`, `Directory.Packages.props`, `global.json`, `.editorconfig` ni `TreatWarningsAsErrors`.
- No existen interfaces de repositorio ni contratos entre capas.
- `Nullable` está deshabilitado en todos los proyectos salvo MAUI.
- Las versiones de paquetes se repiten manualmente (`OpenXml` y `QrCodeGenerator`).

### 1.2 `gym-dotnet`

```text
gym-dotnet/
├─ GymService.slnx                         (solo 2 proyectos)
├─ GymService/
│  ├─ Program.cs · DataCenter.cs · ServiceImplementation.cs
│  ├─ Controllers/                         18 controladores
│  ├─ Modules/                             16 módulos de negocio
│  ├─ Models/
│  │  ├─ _ModelGym.xml                     fuente de verdad del esquema
│  │  └─ Generated/                        41 entidades + registro de mapeo
│  ├─ Services/                            web, BD, email, import, export,
│  │                                       RBAC, health, hosted services
│  ├─ Tools/                               CurrentUser, SecurityValidation,
│  │                                       converter JSON
│  └─ appsettings.example.json · nls.xml
├─ GymService.Tests/                       unitarias + Integration/
├─ GymServiceFront/                       React 19 + Vite 8 + Tailwind 4
│  ├─ src/pages/ (21) · components/ (22) · hooks/ · context/ · services/
│  └─ public/kiosk-app/index.html          kiosco HTML independiente
├─ GymServiceSetup/ · installer/           PowerShell + WiX 5
├─ deploy/                                https, kiosk-pc, maintenance,
│                                         monitoring, offsite, security
├─ Tools/GymModelGenerator/               generador contra GymCore
├─ docs/ · graphify-out/ · .opencode/
└─ *.ps1                                  backup, build, publish, verify
```

| Proyecto | TFM / stack | Dependencias |
|---|---|---|
| `GymService` | `net10.0-windows7.0` | 4 proyectos **externos** `Anxo*` vía `$(GymLibsRoot)`, `Microsoft.AspNetCore.App`, ClosedXML, CsvHelper, JWT, QRCoder, Swashbuckle, MailKit, BouncyCastle |
| `GymService.Tests` | `net10.0-windows7.0` | xUnit, `Microsoft.Data.SqlClient`, GymCore |
| `GymServiceFront` | React 19.3, Vite 8.3, Tailwind 4.3 | axios, react-router-dom 7, lucide-react, qrcode.react |
| `GymServiceSetup` / `installer` | PowerShell / WiX 5 | MSI, servicio Windows, firewall, ACL |
| `Tools/GymModelGenerator` | `net10.0` | fuentes externas de `AnxoDatabaseGenerator` |

**Observación estructural crítica:** el repositorio **no compila de forma reproducible**. `GymService.csproj` exige `third_party/gym-core` (no versionado) o `GYM_LIBS_ROOT`; no hay `LICENSE` y el README declara “Propietario – Centro Fit”. `Tools/GymModelGenerator` solo contiene el `.csproj` y compila fuentes externas.

### 1.3 Métricas comparadas

| Métrica | `tienda` | `gym-dotnet` |
|---|---|---|
| Líneas C# | ~17,000 (sin docs/XAML) | ~37,900 (incluye ~900 KB de entidades generadas) |
| Líneas frontend | XAML aparte | ~9,950 JS/JSX en 55 archivos |
| Tablas | 18 | 41 `GYM_*` + `ANXO_SEQUENCES` |
| Controladores | — | 18 |
| Endpoints | consola por menús | 164 rutas HTTP |
| Módulos de negocio | 7 servicios principales | 16 |
| Migraciones | v1–v14 versionadas | DDL aditivo al arrancar, sin versionado |
| Pruebas | 318 atributos (293 Fact + 25 Theory) | 104 métodos (99 Fact + 5 Theory) |

---

## 2. Arquitectura real de cada aplicación

### 2.1 `tienda`: monolito por capas con un “god object” de datos

**Grafo real de dependencias:**

```text
Core  ←  Infrastructure  ←  Application  ←  Presentation (consola)
  ↑            ↑                 ↑
  └────────────┴──────────── Maui (referencia también Infrastructure)
```

- **Core** es puro: entidades anémicas y utilidades (`Dinero`, `Texto`, `ProcessResult`), sin SQLite, IO, MAUI ni red.
- **Infrastructure** contiene `DatabaseTools` (~1,996 líneas, ~72 métodos públicos, 164 sentencias SQL), que mezcla conexión, esquema, migraciones, CRUD y operaciones de negocio transaccionales (`RegistrarVenta`, `AnularVenta`, `RegistrarCorteCaja`, `RegistrarCompraProveedor`).
- **Application** contiene servicios que validan permisos, reglas y coordinan `DatabaseTools`: `ConfiguracionService`, `InventoryService`, `VentaService`, `CorteCajaService`, `ReporteUtilidadService`, `RespaldoService`, `BitacoraService`, `AutorizacionService`, exportadores, lector XLSX, QR y ticket.
- **Presentation** es una consola monolítica de ~1,917 líneas y ~81 métodos; duplica flujos de MAUI, aunque delega en los mismos servicios.
- **Maui** usa XAML + code-behind, sin ViewModels ni MVVM. Servicios singleton, páginas transient.
- **Sesión:** `SesionActual` es estática (`AsyncLocal<UsuarioSistema>`); `SesionApp.Aplicar()` se invoca manualmente antes de operaciones porque los eventos de MAUI no conservan el contexto.
- **Asincronía:** 0 métodos `async`, 0 `await`, 0 `Task<>` en Core, Infrastructure, Application y Presentation. En MAUI hay 30 handlers `async void`, varios sin `catch`.
- **Esquema:** bootstrap en `Database.cs` + 14 versiones con `PRAGMA user_version`; respaldo previo a migrar, `foreign_key_check` e `integrity_check`.
- **Persistencia:** ADO.NET directo sobre SQLite, sin EF, Dapper ni repositorios; una conexión nueva por operación; sin WAL, `busy_timeout`, retry ni instancia única.
- **Composición:** MAUI usa `Microsoft.Extensions.DependencyInjection`; la consola construye todo a mano; las pruebas también.

**Flujo real de una venta:**

1. `PosPage` arma el carrito y valida en UI (`PuedeCobrar`).
2. `VentaService.RegistrarVenta` autoriza `Vender`, valida líneas, usuario, pago, montos, configuración, productos activos y congela precio/costo/IVA.
3. `DatabaseTools.RegistrarVenta` abre transacción: verifica stock contra `SUM(MovimientoInventario.Cantidad)`, inserta `Ventas`, `VentaLineas`, movimientos negativos y actualiza el saldo de fiado.
4. `VentaService` escribe la bitácora **después del commit**, en otra conexión/transacción.
5. `PosPage` vuelve a leer las líneas, genera el ticket con `TicketService`, crea el QR con `QrImagenService` y abre `TicketPage`.

**Flujo real de un corte de caja:**

`CajaPage` → `CorteCajaService.ObtenerResumenPendiente` → `DatabaseTools.ObtenerResumenCajaPendiente` (tres conexiones) → cálculo de esperado en UI → conteo por denominaciones → `CorteCajaService.RegistrarCorte` → `DatabaseTools.RegistrarCorteCaja` en transacción (recalcula totales, inserta `CortesCaja` y `CorteCajaDesglose`) → bitácora después del commit.

**Veredicto:** arquitectura limpia solo en el nombre. La dirección `Application → Infrastructure` y `UI → Infrastructure` impide sustituir SQLite o probar la aplicación con dobles. La lógica de negocio está repartida entre servicios, `DatabaseTools` y code-behind.

### 2.2 `gym-dotnet`: monolito modular alojado como servicio Windows

**Arranque real:**

```text
Program.Main
  → ServiceConsole / ServiceImplementation.Start()
    → OODatabaseManager.Connect (GymCore → SQL Server)
    → DatabaseService.InitializeSchema (DDL aditivo desde _ModelGym.xml)
    → InitializeBusinessModules (16 módulos en DataCenter.BusinessProcess)
    → WebServerService.Start (Kestrel embebido)
```

- **No usa DI para el dominio.** `Host.CreateDefaultBuilder` se usa solo para el pipeline web; los módulos se construyen a mano y se guardan en `DataCenter`, un *service locator* estático.
- **Controladores:** 18, ~164 endpoints. Reciben `Dictionary<string, object>`, llaman a `DataCenter.BusinessProcess.X` y devuelven `Dictionary`.
- **Módulos:** 16 (`Identity`, `Members`, `Access`, `Sales`, `Inventory`, `Cash`, `Classes`, `Routines`, `Fisio`, `Maintenance`, `Billing`, `Finance`, `Reports`, `Kiosk`, `Staff`, `Dashboard`). Hay llamadas directas entre algunos (ver sección 5).
- **Datos:** lecturas con SQL parametrizado sobre `DatabaseTools`; escrituras con `Session.InsertObject`, `InsertObjectWithID`, `UpdateObjectChanges`, `DeleteObject`. PK `BIGINT` sin `IDENTITY`, asignadas por `ANXO_SEQUENCES`.
- **Esquema:** `_ModelGym.xml` es la fuente de verdad; el generador produce 41 entidades y `ModelGym.MappingObjects`. Al arrancar, `DatabaseService` crea tablas/columnas/índices/FK faltantes de forma aditiva; no hay migraciones versionadas.
- **Autenticación:** no usa `UseAuthentication/UseAuthorization` (comentados). `SecurityValidation` valida un Bearer opaco contra `GYM_SESSIONS` en cada petición; `RolePermissionMiddleware` resuelve el permiso con `PermissionMatrix` (52 entradas de ruta, 27 permisos).
- **Frontend:** SPA React servida desde `wwwroot`; axios con `baseURL: '/api'`, token en `localStorage`, `AuthContext` + `ProtectedRoute`, `CrudPage` genérico y `useApiList`.
- **Kiosco:** HTML/JS independiente (`public/kiosk-app/index.html`, 33 KB) con token de dispositivo de 90 días.
- **Asincronía:** 0 `async` en controladores y módulos; todo el IO es síncrono.

**Flujo real de login:**

`POST /api/auth/login` → `AuthController` → `IdentityModule` busca usuario, verifica bloqueo y PBKDF2-SHA256 (210,000 iteraciones). Si MFA está activo, devuelve `requiresMfa` y un `mfaToken` HMAC de un solo uso; tras verificar TOTP o código de respaldo crea `GYM_SESSIONS` con SHA-256 del token (64 bytes, 8 h) y devuelve token + permisos. El front lo guarda en `localStorage`.

**Flujo real de alta de socio:**

`POST /api/members` → `MembersModule.CreateMember` → valida nombre/apellido, email duplicado (consulta, sin UNIQUE), busca plan por nombre exacto, pre-genera IDs y, en una sola `Session`, inserta `GYM_MEMBERS` y `GYM_MEMBERSHIPS`. Envía correo de bienvenida síncrono. **No crea pago** aunque asigne plan.

**Flujo real de cobro de membresía:**

`POST /api/members/{id}/payments` → `MembersModule.AssignMembership`/`RecordPayment` → valida plan/membresía, aplica crédito a favor, inserta `GYM_PAYMENTS`, extiende/reactiva la membresía, vincula a `GYM_CASH_SESSIONS` si hay caja abierta y genera recibo HTML. No crea factura ni actualiza finanzas/banco.

**Veredicto:** módulos claros, pero acoplados por tablas, estado global y contratos sin tipo. La seguridad está por encima de la media artesanal, pero la arquitectura no es portable ni testeable sin SQL Server/GymCore.

### 2.3 Comparación arquitectónica

| Aspecto | `tienda` | `gym-dotnet` |
|---|---|---|
| Estilo | Monolito en capas nominales | Monolito modular sobre servicio Windows |
| Límites reales | Difusos: persistencia contiene negocio | Módulos claros, acoplados por tablas y estado global |
| DI | Sí, con dependencias concretas | Parcial: solo pipeline web; dominio estático |
| Contratos | Clases de dominio, sin DTOs de API | `Dictionary<string, object>` en toda la API |
| Migraciones | Versionadas (`user_version`, 14 versiones) | DDL aditivo al arrancar, sin versionado |
| Asincronía | Ninguna en librerías; `async void` en UI | Ninguna en controladores/módulos |
| Testabilidad | Buena en servicios; nula en UI | Buena en módulos aislados; mala por estado global |
| Reproducibilidad | Compila con SDK 8 + SDK 10 para MAUI | No compila sin GymCore externo |

---

## 3. Modelos y entidades

### 3.1 `tienda` — 18 tablas SQLite

| Tabla | Propósito | Campos/relaciones clave |
|---|---|---|
| `ConfiguracionTienda` | Configuración única | `ImpuestoPredeterminado`, `ComisionTarjeta`, `FondoCajaInicial`, `FiadoActivado`, `LimiCreditoCliente`, `RespaldoIntervaloDias` |
| `UsuariosSistema` | Usuarios | `PINHash` (PBKDF2 100k), `Rol` (Dueño/Encargado/Empleado), `PermisosEspeciales` (sin uso) |
| `Productos` | Catálogo | `CodigoBarras` único, `Costo`, `Precio`, `Stock` (caché), `StockMinimo`, `Impuesto`, `Activo` |
| `MovimientoInventario` | Libro de stock | `ProductoId`, `Tipo`, `Cantidad` firmada, `CostoUnitario`, `Motivo`, `Usuario` |
| `Ventas` | Cabecera de venta | `Total`, `CostoTotal`, `PagoEfectivo/Tarjeta/Fiado`, `ComisionTarjeta`, `EfectivoRecibido`, `ClienteId`, `MetodoPago` |
| `VentaLineas` | Detalle congelado | `PrecioUnitario`, `CostoUnitario`, `Importe`, `ImpuestoPorcentaje`, `ImpuestoImporte` |
| `AnulacionesVenta` | Anulación inmutable | `VentaId UNIQUE`, `Usuario`, `Motivo` |
| `ClientesFiado` | Clientes | `SaldoActual`, `Activo`, `Telefono` |
| `AbonosFiado` | Abonos | `ClienteId`, `Monto`, `MetodoPago`, `Usuario` |
| `Proveedores` | Proveedores | `SaldoPendiente`, `Activo`, `Clave` |
| `ComprasProveedor` / `CompraProveedorLineas` | Compras | Cabecera + detalle con costo y cantidad |
| `PagosProveedor` | Pagos inmutables | `Monto`, `SaldoAnterior/Nuevo`, `MetodoPago`, `MovimientoCajaId` |
| `CortesCaja` | Corte | `Desde/Hasta`, fondo, ventas por método, abonos, ingresos/retiros, esperado/contado/diferencia |
| `CorteCajaDesglose` | Conteo por denominación | `CorteCajaId`, `ValorCentavos`, `Cantidad` |
| `MovimientosCaja` | Ingresos/retiros | `Tipo`, `Monto`, `Motivo`, `Usuario` |
| `Gastos` | Gastos | `Concepto`, `Monto`, `MetodoPago`, `Origen`, `Observaciones`; **sin usuario** |
| `Bitacora` | Auditoría | `Accion`, `Entidad`, `EntidadId`, `Antes`, `Despues`, `Usuario`, `Motivo` |

**Entidades de dominio (`Core`):** `Producto`, `Venta`, `VentaLinea`, `AnulacionVenta`, `ClienteFiado`, `VentaFiadaCliente`, `AbonoFiadoCliente`, `EstadoCuentaCliente`, `Proveedor`, `PagoProveedor`, `CompraProveedor`, `CorteCaja`, `MovimientoCaja`, `CorteCajaDesglose`, `Gasto`, `RegistroBitacora`, `ReporteUtilidad`, `PeriodoReporte`, `ComparacionReporte`, `ConfiguracionTienda`, `UsuarioSistema`, `Dinero`, `Texto`, `ProcessResult`.

**Invariantes del modelo:**

- Dinero en centavos enteros (`long`/`INTEGER`); porcentajes en `decimal`.
- El stock es la suma de movimientos; nunca se edita directamente.
- El historial no se borra: se corrige con movimientos nuevos.
- Precio, costo e IVA se congelan por línea al vender.
- Bajas lógicas en productos, clientes y proveedores.

**Problemas del modelo:**

- `Productos.Stock` es una caché de la suma de movimientos; la venta valida contra la suma, pero la UI y el valorizado usan la caché. Doble fuente de verdad.
- `Gastos` no guarda usuario; la trazabilidad queda solo en `Bitacora`.
- `Venta.Anulada` no es columna: se calcula con `EXISTS`.
- `CorteCajaDesglose.Subtotal` no se persiste; se calcula al leer.
- No hay `CHECK` constraints.
- Los triggers de inmutabilidad solo cubren 6 tablas; `Ventas`, `VentaLineas`, `CortesCaja`, `MovimientosCaja` y `AbonosFiado` no los tienen.
- `UsuarioDueñoPINHash` y `PermisosEspeciales` no se usan.
- No hay cifrado de base ni de respaldos.

**DTOs de UI:** 15 clases `*Fila.cs` en `SistemaTienda.Maui/Models`, con `Color` de MAUI y textos formateados; no son DTOs de transporte.

### 3.2 `gym-dotnet` — 41 tablas `GYM_*` + `ANXO_SEQUENCES`

| Dominio | Tablas |
|---|---|
| Identidad | `GYM_USERS`, `GYM_PERMISSIONS`, `GYM_ROLE_PERMISSIONS`, `GYM_SESSIONS`, `GYM_OTP_CODES` |
| Socios y cobros | `GYM_MEMBERS`, `GYM_MEMBERSHIP_PLANS`, `GYM_MEMBERSHIPS`, `GYM_PAYMENTS`, `GYM_MEMBER_CREDITS`, `GYM_INVOICES`, `GYM_SCHEDULED_REPORTS` |
| Acceso | `GYM_ACCESS_CODES`, `GYM_ACCESS_LOG`, `GYM_KIOSK_DEVICES` |
| Retail | `GYM_INVENTORY`, `GYM_INVENTORY_MOVEMENTS`, `GYM_SALES`, `GYM_SALE_ITEMS`, `GYM_SUPPLIERS`, `GYM_PURCHASE_ORDERS`, `GYM_PURCHASE_ORDER_ITEMS`, `GYM_CASH_SESSIONS` |
| Clases | `GYM_CLASS_TYPES`, `GYM_CLASS_SESSIONS`, `GYM_CLASS_RESERVATIONS` |
| Rutinas | `GYM_EXERCISES`, `GYM_ROUTINE_PLANS`, `GYM_ROUTINE_PLAN_EXERCISES`, `GYM_ROUTINE_ASSIGNMENTS`, `GYM_WORKOUTS`, `GYM_MEASUREMENTS` |
| Fisioterapia | `GYM_FISIO_PACKAGES`, `GYM_FISIO_APPOINTMENTS` |
| Mantenimiento | `GYM_EQUIPMENT`, `GYM_MAINTENANCE_TICKETS` |
| Finanzas | `GYM_BANK_ACCOUNTS`, `GYM_BANK_TRANSACTIONS` |
| Personal | `GYM_STAFF`, `GYM_STAFF_SHIFTS`, `GYM_PUSH_SUBSCRIPTIONS` |

**Características:**

- PK `BIGINT` sin `IDENTITY`, asignadas por secuencias; reiniciarlas puede colisionar.
- Auditoría automática en todas las tablas: `CREATED_AT`, `UPDATED_AT`, `CREATED_BY`, `LAST_UPDATED_BY`, `LAST_UPDATE_LOG`, `OBJECT_VERSION`.
- Entidades generadas (`IDatabaseObject` + `MappingObject`) de ~17–27 KB cada una; no se editan a mano.
- El XML define 41 tablas, 640 atributos, 34 FK y 59 índices (11 UNIQUE, 48 NON_UNIQUE).
- Separación conceptual correcta: estado de cuenta del socio ≠ estado de membresía; crédito a favor por cancelación; códigos de acceso de un solo uso.

**Relaciones débiles o ausentes:**

- `GYM_SALES.MEMBER_ID` no tiene FK a `gym_members`.
- `GYM_SALES.CASH_SESSION_ID` y `GYM_PAYMENTS.CASH_SESSION_ID` no tienen FK a `gym_cash_sessions`.
- `GYM_INVOICES` no se enlaza con ventas ni pagos.
- `GYM_CLASS_SESSIONS.INSTRUCTOR_ID` no tiene FK a `gym_staff`.
- `RESOLVED_BY`, `MEASURED_BY`, `ASSIGNED_BY`, `AUTHORIZED_BY` no tienen FK a usuarios.
- `GYM_MEMBERS.EMAIL` no es UNIQUE; la unicidad se comprueba solo en código y hay carrera.
- No hay tabla de eventos/historial de membresía.
- No hay `TENANT`, `BRANCH`, `SUCURSAL` ni `LOCATION_ID`; el esquema es de un solo gimnasio.

### 3.3 Diferencias de modelado relevantes para unificar

| Tema | `tienda` | `gym-dotnet` |
|---|---|---|
| Dinero | Entero en centavos | `decimal` exacto |
| Identificadores | `INTEGER` autoincremental | `BIGINT` por secuencia |
| Auditoría | Tabla `Bitacora` explícita | Columnas de auditoría en cada fila + logs |
| Bajas | Lógicas (`Activo`) | Estados (`active`, `cancelled`, `frozen`) |
| Multisucursal | No existe | No existe |
| Moneda | MXN implícita | MXN implícita |

---

## 4. Funcionalidades implementadas

### 4.1 `tienda`

| Módulo | Estado | Detalle |
|---|---|---|
| Configuración inicial | Completo | Asistente, datos de tienda, impuesto, comisión, fondo, fiado, respaldo |
| Usuarios y PIN | Completo/parcial | Alta/edición, PIN PBKDF2, roles; sin baja ni permisos por usuario |
| Permisos | Parcial | Matriz estática en servicios; faltan permisos en altas y lectura excesiva para Empleado |
| Catálogo | Completo/parcial | Alta/edición/búsqueda por nombre y código, desactivación, stock mínimo; sin filtro por categoría ni exportación |
| Inventario | Completo/parcial | Entradas, salidas, mermas, ajustes, historial, valorizado; sin conteo físico, variantes ni caducidad |
| Importación | Completo/parcial | CSV y XLSX de productos con filas omitidas; no es todo-o-nada y solo cubre productos |
| POS | Completo/parcial | Efectivo, tarjeta, mixto, fiado; IVA incluido congelado; cambio; ticket texto + QR; sin descuentos, venta en espera ni devolución parcial |
| Ventas | Parcial | Detalle, reimpresión y anulación total; **no hay consulta histórica en app ni en consola** |
| Clientes/fiado | Completo/parcial | Saldo, abonos con método, estado de cuenta CSV/PDF, baja lógica; límite de crédito global, no por cliente |
| Proveedores | Completo/parcial | Compras con detalle, pagos con método y retiro de caja, estado de cuenta, baja lógica; sin devoluciones ni órdenes de compra |
| Gastos | Parcial | Alta y resumen; sin edición, fecha retroactiva, categorías ni reporte en app |
| Caja | Completo/parcial | Corte, conteo por denominaciones, diferencia con motivo, ingresos/retiros, historial; sin apertura/turno ni PDF |
| Reportes | Completo/parcial | Utilidad por periodo, desglose por método, comparación, CSV/PDF; sin ventas por día/producto ni flujo de efectivo |
| Respaldo | Completo/parcial | Manual, automático al login/logout, verificación, respaldo previo a migrar; restauración solo consola; sin cifrado ni nube/USB |
| Bitácora | Completo/parcial | Registro y consulta; no atómica y sin auditoría de login/restauración/exportaciones |
| Consola | Completo | ~81 métodos; cubre operaciones no presentes en la app |
| Pruebas | Amplio | Servicios, cálculos, migraciones, exportaciones; sin UI, concurrencia, rendimiento ni seguridad |

**Ausencias declaradas:** descuentos, venta en espera, devolución parcial, entidad de merma con costo, actualización automática de costo en entrada manual, movimiento de caja por anulación, estados de cuenta firmados/envío, catálogo por proveedor y órdenes de compra, ventas históricas, edición de gastos, pagos al personal, multi-rubro real.

### 4.2 `gym-dotnet`

| Módulo | Estado | Detalle |
|---|---|---|
| Identity | Completo | Login, logout, sesiones opacas, cambio/reset de contraseña, MFA TOTP, códigos de respaldo, OTP por correo, bootstrap, RBAC |
| Members | Completo/parcial | Socios, planes, membresías, renovación, congelar/reanudar, cancelar con crédito, pagos, recibos; sin portal ni auto-renovación real |
| Access | Completo/parcial | Códigos de 6 dígitos, validación, override manual, bitácora, límite diario; sin anti-passback ni offline |
| Kiosk | Completo/parcial | Registro de dispositivo, token 90 días, validación, equipos no disponibles; `last_seen` sin actualizar |
| Sales | Completo/parcial | POS, devoluciones totales, venta offline marcada, recibos HTML; sin offline real, pago mixto ni código de barras |
| Inventory | Completo/parcial | Productos, stock, movimientos, proveedores, órdenes de compra, importación; sin variantes, lotes, almacenes ni COGS |
| Cash | Completo/parcial | Apertura/cierre, sesión actual, historial, efectivo esperado; una sola caja global, sin gastos/retiros/denominaciones |
| Classes | Completo/parcial | Tipos, sesiones, reservas, lista de espera, asistencia; sin recurrencia, conflictos ni elegibilidad por plan |
| Routines | Completo/parcial | Ejercicios, planes, ejercicios por plan, asignaciones, entrenamientos, medidas; sin metas/progreso ni gráficas |
| Fisio | Completo/parcial | Paquetes, citas, estados, consumo de sesión; sin terapeuta/agenda, historia clínica ni cobro |
| Maintenance | Completo/parcial | Equipos, tickets, prioridades, estados, cierre; sin preventivo, repuestos ni costos |
| Billing | Parcial | Facturas, estados; sin CFDI 4.0, PDF/XML, líneas ni vínculo con pagos |
| Finance | Parcial | Cuentas, transacciones, conciliación, importación CSV; sin ledger, conciliación automática ni actualización de saldo |
| Reports | Completo/parcial | 7 reportes Excel y programados por correo; sin CSV, filtros de fecha en UI ni por sucursal |
| Staff | Completo/parcial | Empleados, usuarios, turnos, check-in/out, ausencia, resumen; sin push real, nómina ni solapamiento |
| Dashboard | Completo/parcial | Contadores del día, tendencias, vencimientos, stock bajo, caja; falla para CASHIER y el front hace 5 llamadas redundantes |
| Import | Completo/parcial | Socios e inventario CSV/Excel, plantillas, codificaciones, errores por fila; sin jobs, historial ni dry-run |
| Notificaciones | Parcial | SMTP y outbox; push sin emisor |
| Respaldos | Completo | Full/log, offsite cifrado, verificación, monitoreo |
| Pruebas | Medio | Integración omitida sin SQL Server; sin frontend/E2E |

**Pendientes declarados:** CFDI operativo, PDF de facturas, push real, búsqueda global/campana, visor de auditoría, pasarela de pagos, sincronización offline real, multi-sucursal, pruebas en VM limpia.

---

## 5. Dependencias entre módulos

### 5.1 `tienda`

```text
Core ──► Infrastructure ──► Application ──► Presentation
  ▲             ▲                ▲
  └─────────────┴──────────── Maui
```

- **Sin ciclos de proyecto**, pero con **ciclo lógico** `Application ↔ Infrastructure`: la aplicación conoce `DatabaseTools` y este contiene reglas de negocio.
- Todos los servicios dependen de una única instancia de `DatabaseTools`; `VentaService` crea su propio `BitacoraService`.
- No hay interfaces ni puertos: las páginas MAUI dependen de clases concretas.
- `Maui` referencia `Infrastructure` y usa `DatabaseTools` en `ArranqueApp`.
- `Program` (consola) lee la base directamente para imprimir el ticket.
- `ConfiguracionService` es un servicio ómnibus: autenticación/PIN, usuarios, configuración, gastos, clientes, proveedores, compras y pagos.
- `InventoryService` lo usan POS, Inventario y Proveedores.
- `CorteCajaService` depende de ventas, abonos, gastos y movimientos de caja por base de datos.
- `ReporteUtilidadService` mezcla cinco consultas sobre ventas, líneas, movimientos y gastos.
- Dependencias ocultas: `SesionActual` global, `DateTime.Now`, sistema de archivos, APIs de MAUI.

**Riesgo principal:** cualquier cambio en `Database.cs` impacta a todos los módulos y a ambas interfaces.

### 5.2 `gym-dotnet`

```text
Controllers ──► DataCenter (static) ──► BusinessProcess ──► 16 Modules
                                                   │
                                                   ├─► DatabaseTools (GymCore) ─► SQL Server
                                                   ├─► EmailService
                                                   └─► CurrentUser (AsyncLocal)

RolePermissionMiddleware ──► IdentityModule + PermissionMatrix
Hosted services ──► MaintenanceService / ScheduledReportHostedService ──► Reports + Email
ImportController ──► BulkImportService
ReportsController ──► ReportExportService
Frontend (axios) ──► 164 endpoints
Kiosk HTML ──► endpoints públicos con token de dispositivo
```

**Llamadas directas entre módulos:**

- `MembersModule → CashModule.GetOpenSessionId`.
- `SalesModule → CashModule.GetOpenSessionId` y `InventoryModule.RecordMovement`.
- `ReportsModule → ReportExportService` y `EmailService`.
- `StaffController → IdentityModule + StaffModule`.
- `ScheduledReportHostedService → ReportsModule`.
- `CleanupHostedService → MaintenanceService`.
- `MaintenanceService → EmailService`.

- `DataCenter` es un localizador de servicios global; el orden de inicialización importa y `Reset()` debe limpiar manualmente los 16 módulos.
- `PermissionMatrix` duplica el conocimiento de las rutas: toda ruta nueva debe registrarse o el middleware la deniega.
- El frontend conoce los endpoints y formas de respuesta; no hay cliente generado ni tipos compartidos.
- El kiosco es un cliente independiente con su propio HTML/JS, token y configuración de URL.
- Los scripts de respaldo/monitoreo dependen de nombres de servicio, rutas, tareas programadas y credenciales externas.

**Duplicación de infraestructura:**

- 155 llamadas a `SecurityValidation.ValidateAuthentication` en controladores, aunque el middleware ya validó el token.
- 299 referencias a `DataCenter.BusinessProcess.*`.
- 159 `catch (Exception ex)` en módulos y 198 en todo el backend.
- 16 copias de `GetColumnIndex` y 16 de `GetRowValue`.
- La validación de permisos está en `PermissionMatrix.RolePermissions`, `PermissionMatrix.RoutePermissions` y `IdentityModule.SeedDefaultPermissions`/`GetPermissions`.

**Riesgo principal:** el estado global y los `Dictionary` sin tipo hacen que los errores aparezcan en tiempo de ejecución, no de compilación.

### 5.3 Dependencias transversales

- Ambos usan contexto de usuario global (estático/AsyncLocal).
- Ambos tienen IO síncrono en la ruta crítica.
- Ambos carecen de contratos tipados entre UI y dominio.
- Ambos dependen de un único desarrollador/entorno para scripts, credenciales y tareas.
- La auditoría es distinta (tabla explícita vs columnas por fila) y sin identificador de correlación común.

---

## 6. Código reutilizable

### 6.1 `tienda`

| Activo | Ruta | Reutilización | Acoplamiento |
|---|---|---|---|
| `Dinero` | `SistemaTienda.Core/Dinero.cs` | Alta: centavos, porcentajes, IVA incluido, formato | Ninguno |
| `ProcessResult` / `ProcessResult<T>` | `Core/Result.cs` | Alta: resultados sin excepciones | Ninguno |
| `Texto` | `Core/Texto.cs` | Alta: normalización sin acentos | Ninguno |
| `ConteoEfectivo` / `CorteCajaDesglose` | `Core/` | Alta: denominaciones MXN y desglose | Bajo |
| `PeriodoReporte` / `ComparacionReporte` | `Core/` | Media: periodos y comparación | Bajo |
| `PdfDocumento` | `Application/Services/PdfDocumento.cs` | Alta: escritor PDF básico (texto, líneas, paginación) | Ninguno, pero usa ASCII |
| `ExportadorCsv` / `ExportadorPdf` | `Application/Services` | Alta para el motor; baja para columnas/plantillas | Medio |
| `QrImagenService` | `Application/Services` | Alta: PNG QR sin dependencias de dibujo | Bajo |
| `TicketService` | `Application/Services` | Media: formato de ticket | Bajo |
| `RespaldoService` / `RespaldoLocal` | `Application` / `Infrastructure` | Media: copia/restauración SQLite | Alto a SQLite |
| `Migraciones` / `MigradorEsquema` | `Infrastructure/Migraciones.cs` | Alta como patrón versionado | Alto a SQLite |
| `DatabaseTools.ExecuteReportObject(s)` | `Infrastructure/Database.cs` | Media: mapeo genérico por reflexión | Alto al god object |
| `LectorProductosXlsx` | `Application/Services` | Media: importación Excel | Medio |
| `ResultadoImportacionProductos` | `Application/Services` | Alta como patrón de importación con errores por fila | Ninguno |
| `BaseDatosPrueba` | `Tests` | Alta como patrón de prueba aislada | SQLite |
| `NavegacionApp`, `SesionApp`, `Exportacion*App`, `QrImagenApp` | `Maui/Services` | Media: integración MAUI | Alto a MAUI |

**No reutilizar tal cual:** `Database.cs`, `Program.cs` de consola, code-behind de páginas, `ConfiguracionService` ómnibus y la matriz estática de permisos.

### 6.2 `gym-dotnet`

| Activo | Ruta | Reutilización | Acoplamiento |
|---|---|---|---|
| `SecurityValidation` | `GymService/Tools/SecurityValidation.cs` | Alta: PBKDF2, hash SHA-256, permisos | A `DataCenter`/Identity |
| `PermissionMatrix` | `Services/RolePermissionMiddleware.cs` | Media: concepto ruta→permiso | Rutas concretas; 400+ líneas |
| `EmailService` | `Services/EmailService.cs` | Alta: SMTP, outbox, HTML | Configuración |
| `BulkImportService` | `Services/BulkImportService.cs` | Alta: CSV/Excel, UTF-8/Latin-1, validación | Modelos concretos |
| `ReportExportService` | `Services/ReportExportService.cs` | Alta: 7 reportes Excel | Esquema gym |
| `DatabaseService` | `Services/DatabaseService.cs` | Baja/Media: DDL aditivo | XML/GymCore |
| `GymHealthCheck` / `GymReadinessCheck` | `Services/GymHealthCheck.cs` | Alta: salud de BD/servicio | GymCore |
| `MaintenanceService` / `CleanupHostedService` | `Services/` | Alta: limpieza de sesiones/OTP/códigos | Esquema gym |
| `ScheduledReportHostedService` | `Services/` | Alta: ejecución programada + correo | Reports/Email |
| Scripts de respaldo/offsite/monitoreo | `*.ps1`, `deploy/` | Alta operativamente: full/log, 7z AES, OneDrive, verificación | Windows/SQL Server |
| `CrudPage`, `useApiList`, UI kit | `GymServiceFront/src` | Alta: CRUD genérico, tabla, modal, paginación | API con sobre estándar |
| `api.js`, `AuthContext`, `ProtectedRoute` | `GymServiceFront/src` | Alta: interceptor, sesión, rutas | `localStorage`, API |
| `Layout.jsx` | `GymServiceFront/src/components` | Alta: navegación y permisos visuales | Rutas |
| `DatabaseFixture` | `Tests/Integration` | Alta: BD temporal por suite | SQL Server |
| `GymModelGenerator` | `Tools/` | Baja: generación de entidades | GymCore/XML |
| Kiosco HTML | `public/kiosk-app` | Media: flujo de acceso | API/token |

**No reutilizar tal cual:** `DataCenter`, controladores con `Dictionary`, `_ModelGym.xml`/entidades generadas, `DatabaseService` como sustituto de migraciones, autenticación casera y el esquema de secuencias.

### 6.3 Solapamiento y extracción a un núcleo común

| Capacidad | Qué tomar de `tienda` | Qué tomar de `gym-dotnet` |
|---|---|---|
| Dinero | Centavos enteros, `Dinero` | Precisión `decimal`, reglas de redondeo |
| Ventas/POS | Congelamiento de precio/costo/IVA, anulación total, ticket/QR | Devoluciones, recibos, venta offline marcada |
| Caja | Corte por periodo, denominaciones, diferencia con motivo | Sesiones de caja, vínculo con ventas/pagos |
| Inventario | Movimientos firmados, stock como suma, mermas | Órdenes de compra, movimientos, kardex |
| Clientes | Fiado, abonos, estado de cuenta | Socios, créditos, ciclos de membresía |
| Identidad | Roles simples, PIN local | Sesiones, MFA, OTP, RBAC, recuperación |
| Auditoría | Bitácora con antes/después | Columnas de auditoría por fila |
| Reportes | CSV/PDF, utilidad, comparación | Excel, reportes programados |
| Operación | Respaldo local automático | Respaldo SQL, offsite cifrado, monitoreo |
| UI | Formatos y flujo POS | `CrudPage`, `useApiList`, kit UI |

**Extraíble a un kernel compartido:** `Dinero`, `Result`, `Texto`, `PeriodoReporte`, motor PDF/CSV, QR, importación con errores por fila, migraciones, backup/verify/restore, auditoría, identidad/permisos, configuración de plataforma, shell MAUI, pruebas de integración con SQLite y kit UI React.

---

## 7. Problemas técnicos y deuda técnica

### 7.1 `tienda`

#### Críticos (P0)

1. **Riesgo de pérdida de datos en Android.** La base y los respaldos viven en almacenamiento privado (`FileSystem.AppDataDirectory`). No hay exportación del respaldo ni restauración desde la app; si se pierde o bloquea el dispositivo, se pierden ambos.
2. **Migración fallida sin recuperación in-app.** `ErrorPage` muestra rutas, pero no permite restaurar; en Android no hay consola ni acceso fácil a la carpeta.
3. **Permisos faltantes en altas.** `ConfiguracionService.AgregarClienteFiado` y `AgregarProveedor` no llaman a `Autorizar`, y las páginas muestran “Nuevo” sin ocultarlo. Un Empleado podría crear clientes/proveedores con saldo inicial.
4. **Lectura excesiva para Empleado.** Tiene `Consultar`, y `ReporteUtilidadService` solo exige ese permiso; las 10 pestañas están siempre visibles. Puede ver utilidad, costos, caja, deudas y valorizado.
5. **Bloqueo de login efímero.** Los 3 intentos viven en la instancia de `LoginPage`, que es `Transient`; al reabrir la app se reinicia. No hay bloqueo persistente ni auditoría de intentos.
6. **Sin baja de usuarios, sin timeout de sesión y sin cifrado** de base ni respaldos.

#### Altos (P1)

7. **God object de persistencia.** `Database.cs` (~1,996 líneas, ~72 métodos, 164 SQL) mezcla acceso a datos, transacciones y reglas de negocio.
8. **Violación de capas.** `Application → Infrastructure` y `Maui/Presentation → Infrastructure`. No hay interfaces ni puertos.
9. **Lógica de negocio en code-behind.** 157 referencias a cálculos/formatos de dinero en páginas; `InventarioPage` ~1,145 líneas, `ProveedoresPage` ~894, `ClientesPage` ~600, `CajaPage` ~585, `AjustesPage` ~533. Sin ViewModels ni pruebas de UI.
10. **Todo síncrono en librerías.** 0 `async/await`; en MAUI hay 30 handlers `async void`, varios sin `catch`. Un `SELECT` lento congela la UI y una excepción no controlada puede tumbar la app.
11. **Sesión global frágil.** `SesionActual` estático + `SesionApp.Aplicar()` manual; si se olvida, la autorización falla cerrada pero la auditoría falla abierta.
12. **Auditoría no atómica.** La bitácora se escribe después del commit; si falla, la operación queda sin registro. Restauración, login, intentos fallidos y exportaciones no se auditan.
13. **Doble fuente de stock.** La venta valida contra `SUM(MovimientoInventario.Cantidad)`, pero la UI y el valorizado usan `Productos.Stock`.
14. **`date(Fecha)` inutiliza índices** en ventas y reportes; SQLite no puede usar `IX_Ventas_Fecha` ni `IX_Gastos_Fecha`.
15. **Carga completa y búsqueda en memoria.** `BuscarPorNombre` carga todos los productos; el POS carga todos los clientes; no hay paginación.
16. **N+1 y lecturas sin transacción.** Compras/cortes consultan detalles por fila; el resumen de caja abre tres conexiones.
17. **Corte sin bloqueo de doble cierre** y sin entidad de apertura/turno.
18. **Gasto con `Origen` y `MetodoPago` independientes.** La UI permite “Caja” + “Tarjeta”; el corte resta por origen y puede descuadrar el efectivo.
19. **La compra actualiza `Productos.Costo` con permiso `RegistrarCompra`**, mientras que editar precio/costo exige `CambiarPrecios` (solo Dueño). Vía indirecta para cambiar costos.
20. **Reporte por método duplica ventas mixtas.** Una venta mixta se cuenta en efectivo y en tarjeta, cada una con `COUNT(*)`.
21. **Sin WAL, `busy_timeout`, retry ni instancia única.** Dos procesos/ventanas pueden abrir la misma base.
22. **Esquema duplicado.** `Database.CrearEsquemaBase` y `Migraciones.cs` describen las mismas tablas; una base nueva se crea en v1 y aplica 13 migraciones, incluida la reconstrucción total de v4.
23. **CSV sin escape de fórmulas.** No se prefija `=`, `+`, `-`, `@`; un nombre malicioso puede ejecutarse al abrir el CSV en Excel.
24. **Código muerto:** `Database.BuscarProductosPorNombre`, `ActualizarSaldoCliente`, `VentaService.ObtenerVentas`, `InventoryService.ReducirStockVenta` (solo pruebas), `ConfiguracionService.UsuarioTieneRol` (solo pruebas), `Program.MostrarModuloPendiente`.

#### Medios y bajos (P2)

25. **Dos frontends duplicados.** Consola y MAUI repiten flujos, textos y validaciones; la consola sigue siendo necesaria para restaurar.
26. **Brechas funcionales:** sin descuentos, sin entidad de merma, costo no actualizado en entrada manual, anulación sin movimiento de caja, estados de cuenta sin firma/envío, sin catálogo por proveedor/OC, gastos sin edición/fecha/reporte, sin venta histórica.
27. **Compatibilidad de frameworks.** Librerías `net8.0` + MAUI `net10.0`; compilar la app exige SDK 10 y workloads.
28. **Seguridad en reposo.** PIN PBKDF2 correcto, pero base y respaldos sin cifrar; PIN de 4–6 dígitos; sin bloqueo persistente.
29. **Sin pruebas de UI, concurrencia, rendimiento ni seguridad.** Android verificado en un solo fabricante.
30. **Campos y etiquetas inconsistentes.** `UsuarioDueñoPINHash` y `PermisosEspeciales` sin uso; resumen “cobrados” incluye fiado; sin filtro por categoría; fechas UTC históricas.
31. **PDF ASCII** pierde acentos y eñes; la documentación dice Latin-1.
32. **Inmutabilidad parcial.** Triggers solo en 6 tablas; faltan en ventas, cortes y abonos.
33. **Paginación, resúmenes precalculados y cifrado opcional** que la documentación menciona no están implementados.

#### Contradicciones documentación/código en `tienda`

| Documento | Afirmación | Código |
|---|---|---|
| `deuda-tecnica.md` | “La consulta de ventas de fechas anteriores sigue solo en la consola” | No existe en consola ni app; `VentaService.ObtenerVentas` no se usa |
| `roadmap.md` / `deuda-tecnica.md` | “Respaldo al iniciar y cerrar la app” | Solo login y logout explícito; no hay hook de cierre |
| `roadmap.md` | “PDF con Latin-1” | `PdfDocumento` usa ASCII |
| `AGENTS.md` | “El historial no se edita ni se borra” | Triggers solo en 6 tablas |
| `stack-tecnologico.md` | “Paginación y resúmenes precalculados” | No existen |
| `stack-tecnologico.md` | “Cifrado opcional del archivo SQLite” | No existe |
| `Database.cs` | “La base queda en su versión anterior si falla una migración” | Queda en la última versión aplicada con éxito |
| `roadmap.md` / `AGENTS.md` | “368 pruebas” | 293 Fact + 25 Theory; 368 casos expandidos; sin UI |

### 7.2 `gym-dotnet`

#### Críticos (P0)

1. **Repositorio no reproducible.** `third_party/gym-core` no está versionado; se requieren librerías `Anxo*` externas (`GymLibsRoot`), CI en runner self-hosted y no hay `LICENSE` (README: “Propietario”).
2. **Estado global estático.** `DataCenter` + `BusinessProcess` + `CurrentUser`; sin DI de dominio ni ámbitos por petición. Difícil de testear y escalar.
3. **API sin contratos tipados.** 398 usos de `Dictionary<string, object>`; no existen DTOs (aunque el README los anuncia). Conversiones y errores en tiempo de ejecución.
4. **Autenticación casera.** `UseAuthentication/UseAuthorization` comentados; validación de sesión contra BD en cada petición; token en `localStorage` (XSS); middleware de permisos por prefijo de ruta, frágil ante colisiones.
5. **Sin migraciones versionadas.** DDL aditivo al arrancar desde XML; cambios destructivos y sincronización manual de `ANXO_SEQUENCES`; PK sin `IDENTITY`.
6. **Lock-in Windows/SQL Server.** `net10.0-windows7.0`, servicio Windows, SQL Server Express, scripts PowerShell y tareas programadas. No corre en Linux/contenedores.

#### Altos (P1)

7. **Manejo de errores inconsistente.** 159 `catch` en módulos y 198 en el backend; sin manejador global; se mezclan errores de negocio con fallos técnicos.
8. **SQL embebido y dinámico.** 231 literales SQL en módulos/servicios; `whereClause` por concatenación (parametrizado, pero dependiente del proveedor). Sin repositorios.
9. **Duplicación de infraestructura.** 164 endpoints, 150 operaciones de módulo, 155 validaciones de token en controladores, 299 referencias a `DataCenter`, 16+16 copias de helpers y una matriz de 52 rutas/27 permisos.
10. **Pruebas insuficientes y condicionadas.** 104 métodos; integración omitida sin `GYM_TEST_DB_PASSWORD` (puede pasar sin ejecutar); sin pruebas de frontend ni E2E.
11. **CI/release desactualizados.** `ci.yml` pasa `-p:AnxoRoot` pero el `.csproj` usa `GymLibsRoot`/`GYM_LIBS_ROOT`; `release.yml` pasa `-AnxoRoot` a `publish.ps1`, que no lo acepta. El CI no compila frontend ni MSI.
12. **Operación compleja.** Respaldos full/log/offsite con 7z, OneDrive y ACL; verificación semanal; CA HTTPS por equipo; provisión de kiosco; cuenta virtual y ACLs; clave MFA respaldada aparte.
13. **Frontend frágil.** JavaScript sin TypeScript, sin pruebas, páginas de 18–21 KB (`Finance`, `Procurement`, `Security`), lógica de fetch/formatos repetida, `CrudPage` acoplada a endpoints.
14. **Documentación desactualizada.** README dice ~67 endpoints (hay 164), 36 tablas (hay 41), “JWT” (no hay), “DTOs/” (no existe).
15. **Funciones anunciadas sin implementar.** Push sin emisor, búsqueda global/campana inertes, PDF de facturas, visor de auditoría, CFDI diferido, offline sin cola.
16. **Seguridad/configuración.** Secretos en `appsettings.json`; login SQL `db_owner` + `CREATE ANY DATABASE`; CORS con credenciales; sin HSTS/CSP; MFA depende de una clave respaldada manualmente.
17. **Rendimiento.** Paginación por `OFFSET`, `SELECT *`, consultas por fila, sin pruebas de carga; rate limiting en memoria por IP.
18. **Multisucursal ausente.** No hay `tenant_id`/`branch_id`; el esquema asume un solo gimnasio.
19. **Marca y licencia.** Namespaces/ensamblados `Anxo*`/`Ax*`; fase C de rebranding pendiente; librerías de terceros sin licencia clara.

#### Hallazgos de seguridad y concurrencia

**Seguridad:**

- **`POST /api/access/code/validate` es público y no exige token de dispositivo.** El `deviceId` es solo `kiosk-` + primeros 8 caracteres del token; el backend no lo valida. Cualquiera en la red con un código válido de 6 dígitos puede consumirlo.
- **`POST /api/auth/bootstrap` es público.** Si la instalación queda accesible antes de crear el owner, cualquiera puede reclamar la cuenta. No exige loopback ni token de instalación.
- **OTP no vinculado a usuario.** `request` acepta cualquier email y `purpose`; `verify` solo marca usado, no crea sesión ni identifica al socio.
- **Códigos de acceso y OTP con SHA-256 sin sal** sobre 6 dígitos; `HMAC_KEY` existe pero no se usa.
- **Logout del frontend solo borra `localStorage`**; no llama a `/api/auth/logout`.
- **`ProtectedRoute` confía en `localStorage`**; no valida el token contra el backend.
- **Rate limit global definido pero no aplicado:** solo auth, OTP, acceso y kiosco tienen `[EnableRateLimiting]`; `auth` usa `QueueLimit=5`.
- **`ServiceImplementation` cae a `sa`** si falta `Database:User`; `SERVICE_DATA`/`install-service.ps1` usan `LocalSystem` por defecto.
- **Secretos en texto plano** en `appsettings.json`: BD, `MfaEncryptionKey`, SMTP, VAPID y `AdminResetToken`.
- **Sin CSP/HSTS/X-Frame-Options**; token en `localStorage`; CORS con `AllowCredentials`.
- **`LegacyPasswordPrefix = "argon2id$"`** pero la verificación real es SHA-256(sal + password); prefijo engañoso.
- **Nonce del desafío MFA en memoria**; se pierde al reiniciar y no sirve en multi-instancia.
- **`DELETE /api/sales/{saleId}` borra físicamente la venta y sus ítems**, reponiendo stock; contradice la regla “los históricos no se borran”.

**Concurrencia e idempotencia:**

- No hay transacciones con aislamiento explícito, `UPDLOCK`, `ROWVERSION` ni claves de idempotencia.
- Venta: dos ventas concurrentes pueden **sobrevender** stock.
- Abrir caja: dos aperturas concurrentes pueden crear **dos cajas abiertas**.
- Validar código: el mismo código puede **consumirse dos veces**.
- Transacción bancaria: **lost update**; dos retiros pueden dejar saldo negativo.
- Crear socio: email duplicado por carrera; `gym_members.email` no es UNIQUE.
- Reserva de clase: `lock` sobre `ConcurrentDictionary` **solo protege una instancia**.
- Fisio: `lock` por paquete igualmente **process-local**.
- Turnos: solo detecta `SCHEDULED_START` exacto, no solapamiento.
- Reportes programados: sin bloqueo; dos instancias pueden enviar el mismo reporte dos veces.
- `OBJECT_VERSION` existe pero no se usa para control optimista.

#### Huecos funcionales concretos

- `CreateMember` con plan **no crea pago**.
- `CancelMembership` calcula el crédito con el **precio de lista**, no con el importe pagado.
- `AssignMembership` no limpia `EXPIRY_NOTICE_SENT_AT` al renovar.
- `Sales` confía en el `taxAmount` del cliente; `Sales:TaxRate` no se usa y el front hardcodea 16%.
- `Finance.GetReconciliationSummary` suma importes absolutos sin distinguir depósitos/retiros.
- `Finance.ImportMovements` no actualiza el saldo de la cuenta.
- `Billing` marcar una factura como pagada no crea pago ni actualiza caja/finanzas.
- `Classes` no valida membresía activa, plan ni `INCLUDES_CLASSES`, y no detecta conflictos de instructor/sala.
- `Fisio` no cobra el paquete; el precio es informativo.
- `Kiosk.last_seen` se lee pero nunca se actualiza; no hay offline real.
- `Dashboard` falla para CASHIER por falta de `reports.view`; el front lo oculta con `catch`.
- `Reports` no tiene filtros de fecha en la UI aunque los endpoints los aceptan.
- No hay `member delete`; el front solo usa `user.permissions` en `StaffUsersPanel`.
- `GenericPage.jsx` existe pero no se usa; búsqueda global y campana de `Layout.jsx` son inertes.

#### Contradicciones documentación/código en `gym-dotnet`

| Documento | Afirmación | Código |
|---|---|---|
| `README.md` | 36 tablas | 41 `GYM_*` (42 con `ANXO_SEQUENCES`) |
| `README.md` | Reportes CSV programados | Solo Excel |
| `README.md` / `PROJECT_CONTEXT.md` | JWT | Token opaco en BD; JWT no se usa |
| `README.md` | Carpeta `DTOs/` | No existe |
| `PROJECT_CONTEXT.md` | 40 tablas, 113 pruebas, 20 páginas | 41 tablas, 104 métodos, 18 rutas/21 páginas |
| `DEPLOYMENT.md` | .NET 8, `sa`, LocalSystem, Swagger siempre | .NET 10, `gym_app`, cuenta virtual, Swagger off |
| `README.md` | 14/15 módulos/controllers | 16 módulos, 18 controllers, 164 rutas |
| `docs/qa` | 135/135 pruebas | 99 Fact + 5 Theory; integración puede pasar sin ejecutar |
| `docs/qa` | Cabeceras/HSTS/CORS aplazados | Confirmado: no hay cabeceras/HSTS; `auth` QueueLimit=5 |

También hay *mojibake* en `PROJECT_CONTEXT.md`, `DEPLOYMENT.md` y `CHANGELOG.md`.

### 7.3 Problemas transversales

- **Contexto de usuario global** en ambos, con fugas potenciales.
- **Contratos sin tipos** (gym) o servicios concretos (tienda), lo que impide clientes generados y pruebas de contrato.
- **IO síncrono** en ambos; ninguno tiene `async` en la ruta crítica.
- **Políticas de dinero distintas** (centavos vs decimal), lo que complica la consolidación.
- **Auditoría distinta** (tabla explícita vs columnas por fila) sin correlación común.
- **Dependencia de un solo desarrollador/entorno** para scripts, credenciales y tareas.
- **Documentación extensa pero desincronizada** del código.

---

## 8. Propuesta de migración al sistema universal

### 8.1 Principio rector

No reescribir ambos sistemas desde cero. Construir un **monolito modular** nuevo con un **kernel compartido** y migrar por verticales mediante estrangulamiento (*strangler*), reutilizando reglas y activos, no los archivos.

**Arquitectura objetivo:**

```text
Universal.Kernel          dinero, resultados, reloj, IDs, texto, paginación
Universal.Domain          entidades y reglas por contexto
Universal.Application     casos de uso, puertos, validación, autorización
Universal.Infrastructure  EF Core/Dapper, proveedores SQLite/SQL Server/PostgreSQL,
                          archivos, correo, impresión, respaldos
Universal.Api             ASP.NET Core, OpenAPI, auth, rate limiting, health
Universal.Worker          reportes programados, limpieza, respaldos, sync
Universal.Web             React + TypeScript (panel y kiosco)
Universal.Mobile          MAUI opcional para nodo offline de tienda
Universal.Tests           unitarias, integración por proveedor, E2E
```

**Decisiones recomendadas:**

- **Contratos tipados** (DTOs + OpenAPI) y cliente generado para el front.
- **DI con ámbitos por petición**; prohibir `DataCenter` estático y `DatabaseTools` global.
- **Migraciones versionadas** (EF Core Migrations o FluentMigrator), no DDL aditivo.
- **Asincronía de extremo a extremo**.
- **Multi-tenant y multisucursal desde el día uno**: `tenant_id`, `branch_id`, `currency`.
- **Proveedor de BD abstracto**: PostgreSQL o SQL Server como canónico; SQLite para nodo offline de tienda.
- **Auditoría append-only** con `actor_id`, `tenant_id`, `entity`, `entity_id`, `action`, `before`, `after`, `correlation_id`, `occurred_at`.
- **Autorización por permisos**, no por rutas; evaluar políticas/recursos.

### 8.2 Contextos y verticales

**Núcleo compartido (horizontal):**

1. Identidad y acceso: usuarios, roles, permisos, sesiones, MFA, OTP, dispositivos.
2. Terceros: clientes, socios, proveedores, personal.
3. Catálogo: productos, servicios, planes, precios, impuestos.
4. Ventas y POS: ventas, líneas, devoluciones, recibos.
5. Pagos, caja y facturación: pagos, abonos, sesiones/cortes, denominaciones, CFDI.
6. Inventario y compras: movimientos, stock, proveedores, órdenes.
7. Agenda y servicios: clases, citas, mantenimiento.
8. Reportes y finanzas: utilidad, conciliación, exportaciones.
9. Auditoría y notificaciones.
10. Operación: importación/exportación, impresión, respaldos, salud.

**Verticales:**

- **Retail:** código de barras, fiado, mermas, compras a proveedor, ticket/QR.
- **Gym:** membresías, créditos, control de acceso, kiosco, clases, rutinas, medidas, fisio, equipos.
- **Futuras:** servicios profesionales, restaurante, etc., reutilizando núcleo.

### 8.3 Mapa de datos propuesto

| Origen | Destino universal |
|---|---|
| `UsuariosSistema` + `GYM_USERS/PERMISSIONS/ROLE_PERMISSIONS/SESSIONS` | `users`, `roles`, `permissions`, `role_permissions`, `sessions` |
| `ClientesFiado` + `GYM_MEMBERS` | `parties` + `retail_customers` / `gym_members` |
| `Proveedores` + `GYM_SUPPLIERS` | `parties` + `suppliers` |
| `Productos` + `GYM_INVENTORY` | `catalog_items` + `stock_movements` |
| `Ventas/VentaLineas` + `GYM_SALES/SALE_ITEMS` | `sales`, `sale_items` |
| `AbonosFiado` + `GYM_PAYMENTS` + `PagosProveedor` | `payments` |
| `CortesCaja/MovimientosCaja/CorteCajaDesglose` + `GYM_CASH_SESSIONS` | `cash_sessions`, `cash_movements`, `cash_denominations` |
| `ComprasProveedor/Lineas` + `GYM_PURCHASE_ORDERS/ITEMS` | `purchase_orders`, `purchase_order_items` |
| `GYM_MEMBERSHIP_PLANS/MEMBERSHIPS/MEMBER_CREDITS` | `gym_plans`, `gym_memberships`, `gym_credits` |
| `GYM_ACCESS_CODES/LOG/KIOSK_DEVICES` | `gym_access_*` |
| `GYM_CLASS_*`, `GYM_ROUTINE_*`, `GYM_FISIO_*`, `GYM_EQUIPMENT/MAINTENANCE_*` | tablas de vertical gym |
| `Bitacora` + columnas de auditoría | `audit_log` |
| `GYM_SCHEDULED_REPORTS` | `scheduled_reports` |

**Política de dinero:** adoptar **enteros en unidades menores** (como tienda) y convertir los `decimal` de gym con una tasa/redondeo único; almacenar moneda por operación.

**IDs:** conservar `legacy_id` y `legacy_source` para trazabilidad; nuevos IDs `BIGINT` o UUIDv7.

### 8.4 Qué reutilizar, adaptar y descartar

| Activo | Decisión |
|---|---|
| Reglas de inventario por movimientos, corte de caja, fiado, IVA congelado, ticket/QR | **Reutilizar** como especificación y pruebas |
| Reglas de membresía, crédito, acceso, secuencias de kiosco | **Reutilizar** como especificación y pruebas |
| `Dinero`, `ProcessResult`, `Texto`, `ConteoEfectivo`, exportadores CSV/PDF, `EmailService`, `BulkImportService`, `ReportExportService` | **Reutilizar/portar** con interfaces |
| `SecurityValidation`, `PermissionMatrix`, `RolePermissionMiddleware` | **Adaptar** a ASP.NET Core Identity/JWT + políticas |
| `CrudPage`, `useApiList`, kit UI, `api.js`, `AuthContext`, `Layout` | **Reutilizar** con TypeScript y cliente generado |
| Scripts de respaldo/offsite/monitoreo | **Reutilizar** como runbooks, reimplementar en el worker |
| `DatabaseTools`, `DataCenter`, `BusinessProcess`, entidades generadas, `_ModelGym.xml` | **Descartar** como mecanismo; conservar el conocimiento del esquema |
| Code-behind MAUI, consola monolítica, controladores con `Dictionary` | **Descartar**; reemplazar por ViewModels y DTOs |
| `GymModelGenerator` | **Descartar**; migraciones + entidades tipadas |
| Kiosco HTML standalone | **Adaptar** a componente del front o app ligera con el mismo contrato |

### 8.5 Plan por fases

| Fase | Alcance | Resultado | Estimación preliminar |
|---|---|---|---|
| 0. Descubrimiento y salvaguardas | Glosario, paridad funcional, políticas de dinero/IDs/tenancy, exportación/restauración de datos, pruebas de caracterización | Backlog, mapa de migración y datos protegidos | 2–3 semanas |
| 1. Kernel + identidad | Kernel, auth/RBAC/MFA, auditoría, migraciones, CI, contratos | Base transversal probada | 3–5 semanas |
| 2. Núcleo comercial | Catálogo, ventas, pagos, caja, inventario, compras, reportes | Vertical retail en el nuevo núcleo | 6–10 semanas |
| 3. Vertical gym | Socios, planes, membresías, créditos, acceso/kiosco, clases, rutinas, fisio, equipos | Vertical gym en el nuevo núcleo | 8–12 semanas |
| 4. Datos y operación | ETL SQLite/SQL Server, conciliación, respaldos, impresión, reportes programados | Migración verificada | 4–6 semanas |
| 5. Piloto y corte | Paridad, doble lectura, capacitación, corte por tenant | Producción | 4–6 semanas |

**Total orientativo:** 8–12 meses con un desarrollador asistido por IA; 3–5 meses con un equipo pequeño. La estimación depende de la licencia de GymCore, la calidad de los datos, la decisión offline/servidor y la paridad funcional.

### 8.6 Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Librerías GymCore sin licencia/versión | Resolver licencia y versionar antes de invertir; si no, reimplementar acceso a datos |
| Pérdida de datos de tienda en Android | Exportación/restauración desde la app y copia fuera del dispositivo antes de migrar |
| Diferencias de dinero/redondeo | Política única de unidades menores + pruebas de conciliación |
| Pérdida de datos al migrar | ETL idempotente, `legacy_id`, doble lectura, respaldos y reconciliación por totales |
| Offline vs servidor | Definir por vertical: tienda como nodo SQLite con outbox; gym online |
| Alcance excesivo | Priorizar paridad funcional, no nuevas features, durante la migración |
| Doble mantenimiento | Congelar features en legacy; solo correcciones críticas |
| Seguridad | Identity estándar, secretos fuera de repo, cifrado en reposo, auditoría inmutable |
| Concurrencia | Transacciones, `UPDLOCK`/control optimista, claves de idempotencia y locks distribuidos |
| Rendimiento | Pruebas de carga desde la fase 2; índices y paginación por keyset |

### 8.7 Criterios de éxito

- Un solo esquema y una sola autenticación.
- Caja, ventas e inventario compartidos.
- Dos verticales operando sobre el mismo núcleo.
- Conciliación 100 % con los totales legacy.
- Cero pérdida de datos.
- CI reproducible sin dependencias locales.
- Contratos tipados y cliente generado.
- Pruebas de UI/E2E y de concurrencia.

---

## Anexo A — Métricas del análisis

| Métrica | `tienda` | `gym-dotnet` |
|---|---|---|
| Archivos C# | 121 | 125 |
| Líneas C# | ~18,918 (incluye MAUI) | ~41,853 (incluye generados) |
| XAML | 17 archivos / 3,246 líneas | — |
| JS/JSX | — | 55 archivos / ~9,950 líneas |
| Tablas | 18 | 41 + `ANXO_SEQUENCES` |
| Entidades generadas | — | 41 archivos de 17–27 KB |
| Endpoints | menús de consola | 164 rutas |
| Controladores | — | 18 |
| Módulos | 7 servicios principales | 16 |
| Pruebas | 293 `[Fact]` + 25 `[Theory]` | 99 `[Fact]` + 5 `[Theory]` |
| Migraciones | v1–v14 | Sin versionado |
| SQL embebido | 164 sentencias | ~231 literales |
| `Dictionary<string, object>` | — | ~398 |
| `catch (Exception)` | 26 en servicios | 159 en módulos / 198 backend |

## Anexo B — Evidencia principal

**`tienda`:**

- `SistemaTienda/SistemaTienda.Infrastructure/Database.cs` — god object, 18 tablas, ventas, cortes.
- `SistemaTienda/SistemaTienda.Infrastructure/Migraciones.cs` — v1–v14, runner y respaldo.
- `SistemaTienda/SistemaTienda.Infrastructure/RespaldoLocal.cs` — `VACUUM INTO`, verificación.
- `SistemaTienda/SistemaTienda.Application/Services/` — 15 servicios.
- `SistemaTienda/SistemaTienda.Presentation/Program.cs` — consola, 1,917 líneas.
- `SistemaTienda/SistemaTienda.Maui/Pages/` — 15 pantallas con code-behind.
- `SistemaTienda/SistemaTienda.Maui/Models/` — 15 modelos de vista.
- `SistemaTienda/SistemaTienda.Tests/` — 40 archivos.
- `SistemaTienda/docs/` — documentación, deuda y contradicciones.

**`gym-dotnet`:**

- `GymService/Program.cs`, `ServiceImplementation.cs`, `DataCenter.cs`.
- `GymService/Services/WebServerService.cs`.
- `GymService/Services/RolePermissionMiddleware.cs`.
- `GymService/Modules/Identity/IdentityModule.cs`.
- `GymService/Tools/SecurityValidation.cs`, `CurrentUser.cs`.
- `GymService/Services/DatabaseService.cs`.
- `GymService/Models/_ModelGym.xml`, `Models/Generated/`.
- `GymService/Services/BulkImportService.cs`, `ReportExportService.cs`, `EmailService.cs`.
- `GymServiceFront/src/App.jsx`, `context/AuthContext.jsx`, `services/api.js`, `hooks/useApiList.js`, `components/CrudPage.jsx`.
- `GymServiceFront/public/kiosk-app/index.html`.
- `deploy/`, `installer/`, `GymServiceSetup/`, scripts de respaldo.
- `docs/pendientes.md`, `docs/qa-2026-11-21.md`, `docs/reglas-negocio.md`, `CHANGELOG.md`, `README.md`.

## Anexo C — Criterios de este informe

1. Se priorizó el código sobre la documentación cuando hubo contradicción.
2. Las cifras son aproximadas y sirven para dimensionar, no como contrato.
3. No se ejecutaron build, pruebas ni migraciones; no se validó comportamiento en vivo.
4. No se modificó ningún archivo de `tienda` ni de `gym-dotnet`.
5. El análisis no se registró en graphify; `gym-dotnet` tiene un grafo en `graphify-out/`, pero no se consultó ni actualizó.

---

**Fin del informe.**
