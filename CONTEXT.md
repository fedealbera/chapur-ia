# Contexto del Proyecto: Chapur IA (B2B Mobile App)

Este documento sirve como referencia central sobre la arquitectura, stack tecnológico y dominio del proyecto **Chapur IA**. Es una aplicación móvil de fuerza de ventas para **Chapur S.A.**

## 1. Visión General
* **Propósito:** Aplicación móvil B2B que permite a vendedores y clientes de Chapur S.A. gestionar productos, carritos, pedidos y consultar el estado de cuentas corrientes.
* **Integración:** La aplicación consume una API REST que actúa como fachada/intermediario con el sistema ERP Legacy (Softland/VTR).

## 2. Stack Tecnológico (Frontend Móvil)
* **Framework:** Flutter (SDK `>=3.1.0 <4.0.0`)
* **Arquitectura:** Clean Architecture. El código en `lib/` está dividido en:
  * `core/`: Utilidades compartidas, manejo de errores, configuraciones de red.
  * `domain/`: Entidades de negocio, repositorios abstractos (interfaces), y casos de uso (Use Cases).
  * `data/`: Modelos (DTOs), repositorios concretos, y data sources (API remota, almacenamiento local).
  * `presentation/`: UI (Widgets, Pages) y State Management.
* **Manejo de Estado:** BLoC (`flutter_bloc`, `bloc`).
* **Programación Funcional:** `dartz` (para manejo de errores con `Either`).
* **Inyección de Dependencias:** `get_it` (configurado en `injection_container.dart`).
* **Networking:** `dio`.
* **Almacenamiento Local:** `shared_preferences` y `flutter_secure_storage`.
* **Serialización:** `json_annotation` y `json_serializable`.
* **Comparación de Objetos:** `equatable`.

## 3. Backend y API REST (`API.md`)
* **Base URL:** Típicamente `https://web.tmc.com.ar` (en desarrollo).
* **Autenticación:** JWT Bearer Token (válido por 8 horas).
* **Roles del Sistema:**
  * `Admin`: Administrador del portal.
  * `Salesperson`: Vendedor.
  * `Customer`: Cliente B2B (único con acceso al carrito).
* **Particularidades Técnicas:**
  * Cultura: `en-US` (usa punto decimal para montos).
  * Zona horaria: `America/Argentina/Buenos_Aires`.
  * Fechas: `DateOnly` (`YYYY-MM-DD`) o `DateTime` (ISO 8601).

### Módulos Principales de la API
1. **Auth (`/api/auth/login`):** Generación de token JWT.
2. **Productos (`/api/products`):** Listado y búsqueda. El stock se consolida de múltiples depósitos y se categoriza mediante estados semánticos (`VERDE`, `AMARILLO`, `ROJO`).
3. **Pedidos (`/api/orders`):** Gestión de órdenes. Internamente ligado al `legacyOrderId` de Softland.
4. **Carrito (`/api/cart`):** Exclusivo para clientes para preparar su orden.
5. **Clientes (`/api/customers`):** Búsqueda de información de clientes mapeada a la tabla `VTMCLH` de Softland.
6. **Cuenta Corriente (`/api/cuenta-corriente`):** Resumen y consulta de comprobantes fiscales (facturas y recibos), ejecutando procedures (`usp_ResumenCuenta`) directamente en el ERP.

## 4. Detalles de Negocio y ERP Legacy (Softland)
* **Tablas Críticas Mencionadas:**
  * `VTMCLH`: Tabla de clientes.
  * `STRMVK`: Tabla de consolidación de stock (filtra marcas específicas como 98=TMC, 343=TANTOR, y depósitos 01, 10, 13).
* **Manejo de Precios y Stock:** Los productos devuelven su `stockStatus`, que es vital para la decisión de compra en el front. Los montos se manejan en formato decimal estricto.

## 5. Próximos Pasos & Flujo de Trabajo
Al trabajar en este proyecto, siempre se debe:
1. Respetar la separación de responsabilidades impuesta por **Clean Architecture** (ej. no mezclar llamadas a `dio` en la capa de `presentation`).
2. Utilizar el patrón BLoC para toda interacción asíncrona de estado en la UI.
3. Manejar los fallos gracefully usando `Either` de la librería Dartz para no romper la app en runtime.
4. Si se agregan dependencias, registrarlas apropiadamente en `injection_container.dart`.
