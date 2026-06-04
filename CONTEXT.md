# Contexto del Proyecto: Chapur IA (B2B Mobile App)

Este documento sirve como referencia central sobre la arquitectura, stack tecnológico, dominio y estructura del proyecto **Chapur IA**. Es una aplicación móvil de fuerza de ventas para **Chapur S.A.**

---

## 1. Visión General
* **Propósito:** Aplicación móvil B2B que permite a vendedores, administradores y clientes de Chapur S.A. gestionar productos, carritos, pedidos y consultar el estado de cuentas corrientes.
* **Modo Invitado:** Los usuarios no registrados pueden explorar el catálogo libremente con ciertas limitaciones (precios ocultos, sin acceso al carrito y alertas visuales para iniciar sesión).
* **Integración:** La aplicación consume una API REST que actúa como fachada/intermediario con el sistema ERP Legacy (Softland/VTR).

---

## 2. Stack Tecnológico (Frontend Móvil)
* **Framework:** Flutter (SDK `>=3.1.0 <4.0.0`).
* **Arquitectura:** Clean Architecture estructurada en capas independientes dentro de `lib/`:
  * `core/`: Utilidades compartidas, manejo de errores, interceptores de red y constantes globales.
  * `domain/`: Entidades puras de negocio (entities), interfaces de repositorios y casos de uso (use cases).
  * `data/`: Modelos de datos (DTOs) con serialización JSON, implementaciones concretas de repositorios y orígenes de datos (remote data sources).
  * `presentation/`: Interfaz de usuario (páginas, widgets) y gestores de estado (BLoCs).
* **Manejo de Estado:** BLoC (`flutter_bloc`, `bloc`).
* **Programación Funcional:** `dartz` (para manejo de errores con el tipo disyuntivo `Either<Failure, Success>`).
* **Inyección de Dependencias:** `get_it` (centralizado en [injection_container.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/injection_container.dart)).
* **Conexión de Red:** `dio` con interceptor personalizado.
* **Almacenamiento Local:** `flutter_secure_storage` para tokens JWT y credenciales locales persistentes.
* **Imágenes y PDFs:** `cached_network_image` para imágenes y `share_plus` para compartir comprobantes en PDF.

---

## 3. Arquitectura Detallada de Archivos

A continuación se detalla la estructura y propósito de los archivos del proyecto en `lib/`:

### 3.1. Capa Core (`lib/core/`)
* [constants.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/core/constants/constants.dart): Define la dirección base de la API (`http://190.229.67.119/api`), constantes de almacenamiento seguro y los códigos de marcas fijas del sistema:
  * `98`: **TMC**
  * `343`: **TANTOR**
* [dio_interceptor.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/core/network/dio_interceptor.dart): Contiene `AuthInterceptor`. Maneja la inyección del token JWT en las cabeceras de autorización. Además, implementa el **Modo Invitado**: cuando detecta `GUEST_MODE`, intercepta las llamadas a `/products` y redirige internamente a `/products/guest`, normaliza el parámetro de búsqueda `q` a `search` e inyecta la cabecera `X-Api-Key` correspondiente.
* [error_handler.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/core/error/error_handler.dart): Intercepta excepciones de red (`DioException`) y generales del servidor, traduciéndolas a mensajes amigables en español e identificando estados HTTP críticos (400, 401, 403, 404, 500).
* [failures.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/core/error/failures.dart): Modela los fallos del sistema como objetos inmutables (`ServerFailure`, `CacheFailure`, `AuthFailure`).

### 3.2. Capa de Datos (`lib/data/`)
* **`datasources/remote/`**: Lógica de comunicación cruda con la API usando `Dio`:
  * [auth_remote_data_source.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/datasources/remote/auth_remote_data_source.dart): Login contra `/auth/login`.
  * [product_remote_data_source.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/datasources/remote/product_remote_data_source.dart): Consulta y detalle de productos.
  * [customer_remote_data_source.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/datasources/remote/customer_remote_data_source.dart): Búsqueda y ficha de clientes.
  * [order_remote_data_source.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/datasources/remote/order_remote_data_source.dart): Creación y consulta de pedidos.
  * [account_remote_data_source.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/datasources/remote/account_remote_data_source.dart): Resumen de Cta. Cte. e impresión/detalle de facturas y recibos.
  * [cart_remote_data_source.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/datasources/remote/cart_remote_data_source.dart): Gestión remota de ítems del carrito.
* **`repositories/`**: Implementan las interfaces definidas en la capa Domain, atrapan excepciones y devuelven tipos de datos funcionales `Either`:
  * [auth_repository_impl.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/repositories/auth_repository_impl.dart)
  * [product_repository_impl.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/repositories/product_repository_impl.dart)
  * [customer_repository_impl.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/repositories/customer_repository_impl.dart)
  * [order_repository_impl.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/repositories/order_repository_impl.dart)
  * [account_repository_impl.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/repositories/account_repository_impl.dart)
  * [cart_repository_impl.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/repositories/cart_repository_impl.dart)
* **`models/`**: Clases DTO que heredan de las entidades de dominio y proveen serialización `fromJson` y `toJson`:
  * [user_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/user_model.dart), [product_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/product_model.dart), [customer_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/customer_model.dart), [order_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/order_model.dart), [cart_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/cart_model.dart), [account_movement_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/account_movement_model.dart), [account_summary_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/account_summary_model.dart), [user_balance_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/user_balance_model.dart), [exchange_rate_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/exchange_rate_model.dart), [cart_discounts_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/cart_discounts_model.dart), [delivery_defaults_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/delivery_defaults_model.dart), [order_confirmation_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/order_confirmation_model.dart), [account_model.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/data/models/account_model.dart).

### 3.3. Capa de Dominio (`lib/domain/`)
* **`entities/`**: Modelos lógicos inmutables libres de anotaciones de frameworks externos:
  * [user.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/user.dart): Representa el usuario logueado con helpers de rol: `isAdmin`, `isSalesperson`, `isCustomer`, `isGuest`.
  * [product.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/product.dart): Atributos de producto y mapeos de `stockStatus`.
  * [customer.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/customer.dart): Información de cuenta de cliente, CUIT, saldo, límite de crédito, etc.
  * [cart.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/cart.dart) y [cart_item.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/cart_item.dart): Gestión del estado actual del carrito y sus líneas.
  * [order.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/order.dart): Orden de pedido con su estado, fecha, totales, datos de entrega e ítems de compra.
  * [account_summary.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/account_summary.dart) y [account_movement.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/entities/account_movement.dart): Datos y lista de movimientos (debe, haber, saldo, estado pendiente/aplicado) para el resumen de cuenta corriente.
  * *Otras entidades de soporte*: `exchange_rate.dart`, `delivery_defaults.dart`, `cart_discounts.dart`, `user_balance.dart`, `order_confirmation.dart`.
* **`repositories/`**: Interfaces de repositorios (ej. `IAuthRepository`, `IProductRepository`, `ICustomerRepository`, `IOrderRepository`, `IAccountRepository`, `ICartRepository`).
* **`usecases/`**: Encapsulan la lógica de negocio elemental de cada caso de uso:
  * `auth/`: [login_use_case.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/usecases/auth/login_use_case.dart).
  * `products/`: [get_products_use_case.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/usecases/products/get_products_use_case.dart) y `get_product_detail_use_case.dart`.
  * `customers/`: [customer_use_cases.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/usecases/customers/customer_use_cases.dart) (incluye `SearchCustomersUseCase` y `GetCustomerDetailUseCase`).
  * `orders/`: [order_use_cases.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/usecases/orders/order_use_cases.dart) (incluye `GetOrdersUseCase`, `GetOrderDetailUseCase` y `CreateOrderUseCase`).
  * `account/`: [account_use_cases.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/domain/usecases/account/account_use_cases.dart) (incluye `GetAccountSummaryUseCase`, `GetDocumentDetailUseCase` y `GetDocumentPdfUseCase`).
  * `cart/`: Casos de uso específicos para la operación fina del carrito, selección de cliente activo y desglose de descuentos.

### 3.4. Capa de Presentación (`lib/presentation/`)
* **`blocs/`**: Gestores de estado implementando el patrón BLoC:
  * `auth/`: [auth_bloc.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/blocs/auth/auth_bloc.dart) (Maneja el flujo de login, logout e inicio/recuperación de sesión).
  * `product/`: [product_bloc.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/blocs/product/product_bloc.dart) (Paginación e inicialización del catálogo).
  * `customer/`: [customer_bloc.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/blocs/customer/customer_bloc.dart) (Búsqueda y selección de clientes en el flujo del vendedor).
  * `order/`: [order_bloc.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/blocs/order/order_bloc.dart) (Consulta de historial, detalles de una orden y creación/confirmación de pedido).
  * `account/`: [account_bloc.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/blocs/account/account_bloc.dart) (Maneja el estado del resumen financiero y la generación/descarga de PDFs de comprobantes).
  * `cart/`: [cart_bloc.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/blocs/cart/cart_bloc.dart) (Carga del carrito, adición y remoción de ítems).
* **`pages/`**: Vistas completas de la aplicación:
  * [login_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/login_page.dart): Pantalla de login de la aplicación. Soporta el botón "Ingresar como Invitado".
  * [dashboard_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/dashboard_page.dart): Contenedor principal con barra de navegación dinámica según el rol del usuario (Invitado, Vendedor, Admin o Cliente).
  * [product_catalog_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/product_catalog_page.dart): Buscador y lista de productos con scroll infinito. Cuenta con selectores de cantidades, visualizadores de stock semánticos (verde/amarillo/rojo) y alertas de redirección (redirección a login para invitados o aviso para seleccionar cliente en rol vendedor).
  * [customer_search_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/customer_search_page.dart): Panel para que el vendedor/admin busque y seleccione al cliente activo del pedido.
  * [customer_home_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/customer_home_page.dart): Home personalizado para el cliente logueado con resumen de saldo pendiente/vencido, atajos rápidos de navegación e información de contacto.
  * [customer_detail_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/customer_detail_page.dart): Ficha técnica y comercial del cliente seleccionado por el vendedor.
  * [order_history_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/order_history_page.dart): Lista el historial de pedidos completados, destacando el `legacyOrderId` (ID de Softland) y el estado del pedido.
  * [order_detail_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/order_detail_page.dart): Muestra el desglose de productos y metadatos de un pedido realizado.
  * [cart_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/cart_page.dart): Muestra las líneas cargadas en el carrito, totales del pedido y un botón para proceder al checkout.
  * [checkout_form_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/checkout_form_page.dart): Formulario de envío y contacto requerido para la orden final.
  * [account_summary_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/account_summary_page.dart): Resumen de Cta. Cte. interactivo con filtros de fecha (desde/hasta), casilla de comprobantes pendientes y visualización de movimientos con atajos para ver o compartir en PDF.
  * [document_detail_page.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/pages/document_detail_page.dart): Detalla la factura (FCA) o recibo (RCB) seleccionado, simulando el documento fiscal con IVA desglosado (21% / 10.5%), CAE y código QR de AFIP.
* **`widgets/`**: Piezas reutilizables del sistema visual:
  * [custom_bottom_nav.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/widgets/custom_bottom_nav.dart): Barra de navegación con iconos personalizados.
  * [cart_icon_badge.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/widgets/cart_icon_badge.dart): Icono de carrito flotante con indicador de cantidad acumulada.
  * [exchange_rate_widget.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/presentation/widgets/exchange_rate_widget.dart): Muestra la cotización del dólar del sistema en la cabecera.

---

## 4. Detalles de Negocio y ERP Legacy (Softland)
* **Tablas Críticas Mencionadas en la Integración:**
  * `VTMCLH`: Tabla principal de clientes comerciales.
  * `STRMVK`: Tabla de consolidación de stock físico. Involucra depósitos clave (`01`, `10`, `13`) y marcas específicas (`98=TMC` y `343=TANTOR`).
* **Reglas del Negocio de Stock:**
  * El stock es consolidado y representado a través de un estado semántico (`stockStatus`):
    * `"VERDE"`: Stock por encima del mínimo (Disponible).
    * `"AMARILLO"`: Stock cercano al límite mínimo (Stock limitado).
    * `"ROJO"`: Stock agotado o crítico (No disponible).
  * Los clientes B2B visualizan estas etiquetas de disponibilidad para evitar fricciones. Los vendedores y administradores pueden ver la cantidad física numérica real de stock.
* **Cultura y Formatos Financieros:**
  * Cultura: `en-US` en llamadas a la API (uso de punto decimal en lugar de coma para los montos decimales).
  * Zona Horaria: `America/Argentina/Buenos_Aires`.
  * Fechas: `DateOnly` (`YYYY-MM-DD`) o `DateTime` (ISO 8601).

---

## 5. Próximos Pasos & Flujo de Trabajo
1. **Respetar Clean Architecture:** Mantener la separación de responsabilidades estricta. Nunca instanciar llamadas a librerías de red (`dio`) ni interactuar directamente con almacenamiento local (`secure_storage`) en widgets de presentación.
2. **Uso de BLoC:** Toda la reactividad de la interfaz se controla emitiendo eventos a sus respectivos BLoCs.
3. **Manejo Exclusivo de Errores con Either:** Usar la lógica de programación funcional provista por `dartz` para retornar `Failure` en lugar de propagar excepciones no controladas que puedan colapsar la app.
4. **Registro de Dependencias:** Al agregar nuevos repositorios, servicios o casos de uso, registrarlos en [injection_container.dart](file:///Users/federicoalbera/Documents/Proyectos/ChuroMobile/Chapur-IA/lib/injection_container.dart).
