# Plan maestro v2 — Tienda + Gym → plataforma modular

**Fecha:** 23 de noviembre de 2026  
**Estado:** aprobado con condiciones el 2026-11-23; H1 autorizado.  
**Fuentes:** auditoría técnica de `tienda` y `gym-dotnet`; revisión independiente de 526 líneas; rondas con ChatGPT (producto/negocio), Claude (arquitectura/riesgo) y Gemini (producto/UX/operaciones).  
**Alcance:** plan de 90 días para dejar `tienda` vendible y preparar la extracción futura del núcleo. No se modifica ningún repositorio.

---

## 1. Resumen ejecutivo

La conclusión de las tres IA y de la auditoría es la misma:

> **No construir la plataforma universal ahora.** Los próximos 90 días deben convertir `tienda` en un producto confiable, instalable y vendible; después se añade un módulo de gimnasio como extensión; solo entonces se evalúa el núcleo universal.

La versión 2 de `tienda` no compite por cantidad de módulos. Compite por **tranquilidad operativa**:

- Que el dueño cierre caja sin descuadres.
- Que controle fiados y gastos.
- Que un empleado no vea utilidades ni borre ventas.
- Que funcione sin internet.
- Que se pueda respaldar, restaurar y actualizar sin perder datos.

El gimnasio no se integra en estos 90 días. Se usa como especificación para el módulo futuro.

---

## 2. Decisiones cerradas para v2

| # | Decisión | Recomendación | Riesgo principal |
|---|---|---|---|
| 1 | Producto foco | Tienda v2, no plataforma universal | Dejar el núcleo para después; no hay ingreso nuevo mientras tanto |
| 2 | Plataforma comercial | **Windows primero**. Android se mantiene, pero no es el canal principal hasta resolver actualización, respaldo y soporte en campo | Perder clientes que solo tienen tablet Android |
| 3 | Cliente ideal | Abarrotes, purificadoras y minisúper de 1–3 cajas y 1–4 empleados, con internet intermitente | Excluir forrajeras y negocios con báscula hasta validarla |
| 4 | Alcance v2 | Ventas/caja, inventario, compras, gastos, fiado, reportes, usuarios/permisos, respaldo/restauración, importación, arqueo ciego, hardware básico | Alcance amplio para 13 semanas |
| 5 | Fuera de v2 | CFDI nativo, nube, básculas, gimnasio, multitienda, sincronización, configurador, licenciamiento criptográfico completo | Prometer lo que no está operable |
| 6 | Precio base | **$5,900 MXN** licencia de pago único, una instalación y una caja | Percepción de precio alto sin casos de éxito |
| 7 | Precio profesional | **$7,900 MXN** con más usuarios, reportes avanzados y funciones validadas | Canibalizar la básica o confundir la oferta |
| 8 | Instalación/capacitación | **$1,000–$1,500 MXN** | Costo real de traslado y tiempo |
| 9 | Soporte | **$350–$450 MXN/mes** opcional; WhatsApp en horario laboral, respuesta inicial ≤1 día hábil; visitas aparte | Clientes que esperan soporte ilimitado por pago único |
| 10 | Piloto | **30 días, semana 9–13**, gratuito o con descuento a cambio de retroalimentación y testimonio | Pilotar antes de cerrar caja/stock |
| 11 | CFDI | Extensión futura. v2 **no timbra**; entrega datos para autofacturar o se integra con PAC después. Validar con contador | Vender “POS fiscal” sin CFDI |
| 12 | Licenciamiento | Archivo de licencia firmado, offline, con período de gracia y recuperación manual. **Sin HWID rígido en v2** | Copia del instalador entre vecinos |
| 13 | Base de datos | SQLite-first. Sin SQL Server/PostgreSQL central en v2 | Crecimiento futuro; se resuelve después |
| 14 | Multi-tenant | No implementar. Cada cliente tiene su instalación | Retrofit costoso si algún día se centraliza |
| 15 | IDs | `Guid.CreateVersion7()` en tablas nuevas; no migrar las existentes ahora | Convivencia temporal de dos esquemas |

---

## 3. Producto v2 pulido

### 3.1 Promesa comercial

> **“Vende rápido, controla tus fiados y cierra tu caja con confianza, incluso sin internet.”**

Evitar prometer “3 minutos” o “cero diferencias” como eslogan absoluto: son metas operativas, no garantías.

### 3.2 Cliente ideal

- Abarrotes, purificadora o minisúper.
- 1–3 cajas.
- 1–4 empleados.
- Internet intermitente o nulo.
- Hoy usa libreta, Excel o un sistema que no le cuadra la caja.

**Excluir de v2:** forrajeras, restaurantes, talleres y cualquier negocio que dependa de báscula o de facturación electrónica.

### 3.3 Flujos críticos de extremo a extremo

1. **Alta inicial:** importar catálogo CSV/Excel con vista previa y reporte de errores.
2. **Venta rápida:** búsqueda instantánea, lector de barras, pago mixto, ticket térmico y apertura de cajón.
3. **Fiado:** alta de cliente, cargo, abono e historial.
4. **Gasto de caja chica:** un solo efecto sobre caja; nunca dos.
5. **Corte ciego:** el cajero declara el efectivo antes de ver el esperado; solo el dueño ve el esperado.
6. **Respaldo/restauración:** copia local, exportación a USB/carpeta y restauración probada.
7. **Soporte:** exportar paquete de diagnóstico (logs, versión, esquema y base opcional) para WhatsApp.

### 3.4 Qué NO incluye v2

- Facturación CFDI nativa.
- Respaldo en la nube.
- Básculas conectadas.
- Multitienda o multiusuario avanzado.
- Módulo de gimnasio.
- Sincronización entre dispositivos.
- Configurador visual de módulos.
- Licenciamiento criptográfico completo.

### 3.5 Criterio de “listo para vender”

- 14 días consecutivos de operación real en un negocio piloto.
- Cero diferencias **inexplicadas** en cortes; las diferencias operativas se documentan.
- Respaldo y restauración probados en otro dispositivo.
- Permisos verificados: un Empleado no ve utilidad ni costos.
- Cobro habitual en menos de 10 segundos como meta, no como condición absoluta.
- Instalación, actualización y rollback probados.
- Hardware básico validado: impresora térmica, lector USB y cajón.

---

## 4. Roadmap de 90 días

### 4.1 Vista por semanas

| Semanas | Negocio | Técnico | Puerta |
|---|---|---|---|
| 1–2 | Definir cliente, promesa, alcance y precio | H1: respaldo/restauración in-app, exportación, paquete de soporte, WAL, `busy_timeout`, instancia única | Restaurar en otro dispositivo |
| 2–4 | Entrevistar 5 negocios; preparar acuerdo de piloto | H2: permisos por acción, bloqueo persistente, manejador global, timeout de sesión, respaldos cifrados | Empleado sin acceso a utilidad/costos |
| 3–6 | Seleccionar candidatos a piloto; validar hardware | H3: suite de caracterización | Suite verde en CI |
| 6–8 | Ajustar oferta y soporte con retroalimentación | H4: stock único, gasto/caja unificado, ventas mixtas, bitácora transaccional, arqueo ciego | Corte cuadra al 100 % en pruebas |
| 8–9 | Preparar instalación y capacitación | H5: instalador, migración automática con respaldo, rollback; `date(Fecha)` y escape CSV | Actualización fallida vuelve a la versión anterior |
| 9–10 | Iniciar piloto | H6: importación CSV, búsqueda instantánea, tickets en espera | Cliente operando sin bloqueos |
| 10–13 | Piloto de 30 días, correcciones y lanzamiento | Soporte y estabilización | 14 días sin pérdida de datos ni descuadres |

### 4.2 Hitos técnicos

**H1 — Confianza y recuperación (semanas 1–2)**

- Respaldo y restauración desde la app, no solo consola.
- Exportación del respaldo fuera del dispositivo.
- Paquete de soporte: logs, versión, esquema y base opcional con datos sensibles excluibles.
- WAL, `busy_timeout` e instancia única.
- Prueba: restaurar en otro dispositivo; dos instancias no corrompen.

**H2 — Control de acceso y errores (semanas 2–4)**

- Permisos por acción: altas, utilidad, costos, caja, reportes.
- Bloqueo de login persistente.
- Timeout de sesión.
- Manejador global de excepciones.
- Respaldos cifrados.
- Prueba: Empleado no ve utilidad ni crea proveedores; el bloqueo sobrevive al reinicio.

**H3 — Red de seguridad (semanas 3–6)**

- Caracterización de venta simple, mixta y fiada.
- Anulación: stock, caja y saldo.
- Corte con gastos en efectivo y tarjeta.
- Abonos, compras con cambio de costo, congelamiento de precios, reporte por método.
- Prueba: suite verde antes de tocar lógica.

**H4 — Dinero exacto (semanas 6–8)**

- Una sola fuente de stock: log de movimientos como verdad; caché transaccional y conciliación.
- Gasto con un solo efecto de caja; nunca pago + retiro.
- Venta mixta reportada por pago, no por documento duplicado.
- Bitácora dentro de la transacción.
- Arqueo ciego.
- Prueba: corte cuadra en todos los escenarios.

**H5 — Instalación y actualización (semanas 8–9)**

- Instalador Windows con manifiesto de versión y esquema.
- Actualización: respaldo, migración, verificación, arranque de prueba y rollback.
- Migración automática de SQLite con respaldo previo.
- Correcciones rápidas: `date(Fecha)` e inyección de fórmulas en CSV.
- Prueba: actualización interrumpida deja la versión anterior operativa.

**H6 — Onboarding y mostrador (semanas 9–10)**

- Importación CSV/Excel con plantilla, vista previa, validación por fila y reversión por lote.
- Búsqueda instantánea y tickets en espera.
- Prueba: 500–3,000 productos importados sin duplicados.

**Piloto (semanas 10–13)**

- Un abarrotes real, una caja, usuarios definidos.
- 30 días, gratuito o con descuento.
- Revisión semanal, registro de errores y diferencias.
- Testimonio y autorización para uso comercial.

### 4.3 Deferido a después del piloto

- Inmutabilidad completa y checksums de migración.
- Cifrado de la base completa (evaluar SQLCipher).
- Licenciamiento por HWID.
- Sincronización, nube, multiusuario avanzado.
- Básculas.
- CFDI nativo.
- Núcleo universal y módulo gimnasio.

---

## 5. Arquitectura futura (después de v2)

### 5.1 Principios

- Monolito modular, no microservicios.
- Núcleo de documentos, pagos, caja y terceros; verticales retail y gym.
- SQLite-first; proveedor abstracto solo cuando exista un cliente que lo pague.
- Sin multi-tenant; cada instalación es un negocio.
- `Guid.CreateVersion7()` para IDs nuevos.
- `idempotency_key` en operaciones financieras.
- Append-only para documentos; anulaciones como documentos nuevos.
- Stock: log de movimientos + snapshots/cierres para rendimiento.
- Saldos de cuentas derivados o actualizados en la misma transacción, con conciliación.
- Auditoría en la misma transacción con `correlation_id`.
- CFDI como extensión desacoplada con cola de timbrado.
- Actualizaciones con manifiesto, respaldo, migración, verificación y rollback.

### 5.2 Correcciones obligatorias al modelo de documentos

- **Gasto en efectivo:** un solo registro con un único efecto sobre caja. No crear pago y retiro a la vez.
- **Anulación:** una sola regla para “ventas netas” (estado ANULADO o referencia de anulación, no ambas).
- **Saldos:** no mantener caché sin actualización transaccional y conciliación.
- **Inventario:** no depender solo de `SUM(movimientos)` para siempre; usar snapshots por cierre.
- **IDs:** decidir UUIDv7 nativo; no introducir ULID si no aporta.
- **Offline:** no prometer sincronización; diseñar `nodo_origen_id` y outbox solo cuando haya un cliente que la necesite.

---

## 6. Modelo comercial y de soporte

### 6.1 Oferta

| Producto | Precio tentativo | Incluye |
|---|---:|---|
| Tienda V2 Básica | $5,900 MXN | Una instalación, una caja, ventas, inventario, compras, gastos, fiado, reportes, permisos, respaldo |
| Tienda V2 Profesional | $7,900 MXN | Más usuarios, reportes avanzados y funciones validadas |
| Instalación y capacitación | $1,000–$1,500 MXN | Configuración, catálogo inicial, capacitación |
| Soporte y actualizaciones | $350–$450 MXN/mes | WhatsApp en horario laboral, respuesta ≤1 día hábil, actualizaciones |
| Visita presencial | Cotizada | Casos que no se resuelvan remoto |

### 6.2 Reglas comerciales

- No vender licencias definitivas de V2 antes de validar el piloto.
- Sí ofrecer diagnóstico, demostración y levantamiento de catálogo.
- No prometer CFDI, nube, básculas ni gimnasio.
- No prometer soporte 24/7.
- No prometer compatibilidad universal con hardware.

### 6.3 Acuerdo de piloto

- 30 días, un negocio, una caja.
- Precio preferente o gratuito.
- Capacitación inicial y revisión semanal.
- Registro de errores, diferencias de caja y dificultades.
- Retroalimentación semanal.
- Testimonio final y autorización de uso comercial.
- Sin obligación de compra; precio de lanzamiento si continúa.

---

## 7. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Pilotar antes de cerrar caja/stock | Pérdida de confianza | Piloto en semana 9–10, no antes |
| Hardware incompatible | Devoluciones y soporte | Probar impresora, lector y cajón reales; documentar modelos |
| Actualizaciones en campo | Costo de soporte | Instalador con rollback y migración automática |
| Pérdida de datos | Reputación | Respaldo exportable, restauración probada, cifrado |
| CFDI mal prometido | Riesgo legal/comercial | v2 no timbra; validar con contador |
| Licenciamiento laxo | Copia del instalador | Archivo firmado, gracia y recuperación; no HWID rígido |
| Soporte ilimitado por pago único | Insostenible | Contrato, límites y plan mensual |
| Alcance excesivo | No llegar a vender | Congelar v2; todo lo demás es post-piloto |
| Dependencia de un solo proveedor/IA | Sesgo | Triangulación ChatGPT/Claude/Gemini + verificación en código |

---

## 8. Modelo de colaboración con las IA

### 8.1 Roles

| Rol | Experto | Responsabilidad |
|---|---|---|
| Hechos, código y ejecución | DeepSeek | Auditar, verificar, implementar, medir, escribir ADRs |
| Producto, negocio y pricing | ChatGPT | Cliente, oferta, licencias, soporte, orden comercial, validación |
| Arquitectura y riesgo | Claude | Dominio, concurrencia, seguridad, pruebas, gates, revisión adversarial |
| Producto/UX/operaciones | Gemini | Flujos, onboarding, hardware, soporte, huecos de producto |
| Dueño del proyecto | Tú | Aprueba decisiones, pone límites y valida con clientes |

### 8.2 Protocolo

1. **Decision Brief** de una página: contexto, hechos, decisión, opciones, criterio de aceptación.
2. **Ronda independiente:** cada experto responde su ángulo, sin ver a los otros.
3. **Contraste:** se comparten respuestas anonimizadas y cada uno critica errores y omisiones.
4. **Síntesis:** DeepSeek verifica contra el código y escribe un ADR.
5. **Puerta:** no se implementa hasta que el ADR esté aprobado.

### 8.3 Reglas

- Etiquetar `[HECHO]`, `[HIPÓTESIS]`, `[RECOMENDACIÓN]`.
- Citar archivos, tablas o métodos.
- No aceptar datos fiscales, de hardware o plazos sin verificación.
- Una decisión por ronda; máximo dos rondas.
- No pedir “diseña todo” en un solo prompt.
- No tocar repositorios hasta cerrar la decisión.

### 8.4 Cuotas y continuidad

- Los planes gratuitos tienen límites; cuando uno se agota, se espera al restablecimiento.
- Presupuesto semanal: 1–2 preguntas por experto, 3–5 en total.
- Un experto principal + un revisor; el tercero solo para decisiones de alto riesgo.
- Si un experto no está disponible, se continúa con los otros y se marca “revisión pendiente”.
- La ruta crítica H1–H4 no se bloquea por cuota: se ejecuta con evidencia del código y pruebas.
- Cada respuesta se guarda como resumen en `docs/05-colaboracion-ia/rondas/` y se actualiza la cola.

---

## 9. Siguiente ronda por experto

**ChatGPT (negocio):**

- Redactar el guion de venta y la objeción “¿por qué no uso Excel?”.
- Definir contrato de piloto y política de soporte.
- Validar precios con 5 entrevistas.
- Eliminar de la oferta nube, CFDI y básculas.

**Claude (técnico):**

- Especificar H1–H4 con criterios de aceptación y pruebas.
- Diseñar el instalador/actualización/rollback y el paquete de soporte.
- Revisar el modelo de documentos/pagos/caja con las correcciones del §5.2.
- Definir la matriz de pruebas de hardware y corte de energía.

**Gemini (producto/UX/operaciones):**

- Diseñar los flujos de onboarding, venta rápida, corte ciego y soporte.
- Definir la experiencia de importación de catálogo y tickets en espera.
- Revisar accesibilidad, mensajes de error y capacitación.
- Proponer el checklist de instalación en un negocio real.

**DeepSeek (ejecución):**

- Verificar cada afirmación contra el código.
- Crear `decision-brief-v1.md` y los ADR.
- Implementar H1 en `tienda` cuando se apruebe.
- Mantener el registro de decisiones y el estado del piloto.

---

## 10. Decisiones pendientes de tu aprobación

1. ¿Aprobamos **Windows-first** para v2 y dejamos Android como soporte secundario?
2. ¿Aceptamos el cliente ideal y excluimos forrajeras/básculas de v2?
3. ¿Aceptamos el precio $5,900 / $7,900 y el soporte $350–$450/mes?
4. ¿Aceptamos piloto en semana 9–10, no antes?
5. ¿Aceptamos CFDI como extensión futura y v2 sin timbrado?
6. ¿Quién valida CFDI con contador y quién prueba hardware real?
7. ¿Autorizas empezar H1 (respaldo/restauración/exportación) en `tienda`?

---

## 11. Criterio de éxito de los 90 días

- Tienda v2 instalada en un negocio real.
- 14 días consecutivos sin pérdida de datos ni descuadres inexplicados.
- Respaldo y restauración probados.
- Permisos y caja confiables.
- 2–3 clientes de pago o pipeline con intención clara.
- Costo de soporte medido.
- Decisión documentada sobre el siguiente módulo (gimnasio) y sobre el núcleo.

---

**Fin del plan maestro v2.**
