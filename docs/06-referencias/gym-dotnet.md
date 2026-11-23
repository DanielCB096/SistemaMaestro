# Referencia — `gym-dotnet`

**Repositorio:** <https://github.com/DanielCB096/gym-dotnet>  
**Producto:** gestión integral de gimnasio.  
**Stack:** .NET 10 Windows Service + ASP.NET Core/Kestrel + React 19 + SQL Server.

## Arquitectura real

- Servicio Windows que aloja Kestrel.
- 18 controladores, 16 módulos, 164 endpoints.
- `DataCenter` estático como localizador de servicios; sin DI de dominio.
- 41 tablas `GYM_*` + `ANXO_SEQUENCES`; entidades generadas desde `_ModelGym.xml`.
- Autenticación opaca con sesiones, PBKDF2 210k, MFA TOTP y RBAC.
- Frontend React con `CrudPage`, `useApiList` y kit UI.

## Fortalezas

- Seguridad y operación más maduras: MFA, sesiones, rate limiting, backups offsite, cuenta virtual.
- Módulos de negocio completos: socios, membresías, acceso, clases, rutinas, fisio, mantenimiento, finanzas.
- Scripts de respaldo, verificación, HTTPS e instalador.
- Base de componentes y patrones reutilizables.

## Problemas principales

- No compila de forma reproducible sin librerías GymCore externas y sin `LICENSE`.
- Estado global estático; API con `Dictionary<string, object>` sin DTOs.
- Sin migraciones versionadas; secuencias manuales.
- Carreras en ventas, caja, accesos y finanzas.
- CFDI incompleto, hardware POS no validado, soporte/actualizaciones en campo no resueltos.
- Documentación desactualizada.

## Papel en la migración

Fuente de reglas y patrones (identidad, MFA, backups, operación, componentes UI). No se usa como base directa hasta resolver licencia y reproducibilidad.
