# Chapur B2B — REST API

API REST del portal B2B de Chapur S.A. Autenticación mediante **JWT Bearer Token**.

- **Base URL (dev):** `http://localhost:5175`
- **Swagger UI:** `/swagger`
- **Content-Type:** `application/json`
- **Cultura:** `en-US` (punto decimal)
- **Zona horaria de fechas:** America/Argentina/Buenos_Aires

## Autenticación

Todos los endpoints (excepto `POST /api/auth/login`) requieren el header:

```
Authorization: Bearer {token}
```

El token se obtiene desde `/api/auth/login` y tiene una validez de **8 horas**.

### Roles

| Rol           | Descripción                                         |
|---------------|-----------------------------------------------------|
| `Admin`       | Administrador del portal                            |
| `Salesperson` | Vendedor (Vendedor)                                 |
| `Customer`    | Cliente B2B — único rol con acceso al carrito       |

### Códigos de estado comunes

| Código | Significado                                                |
|--------|------------------------------------------------------------|
| 200    | OK                                                         |
| 400    | Bad Request — validación fallida o error de negocio        |
| 401    | Unauthorized — token ausente, inválido o expirado          |
| 403    | Forbidden — rol insuficiente                               |
| 404    | Not Found                                                  |

Errores devuelven el formato:
```json
{ "error": "Mensaje descriptivo" }
```

---

## 1. Auth — `/api/auth`

### POST `/api/auth/login`

Autentica al usuario y devuelve un JWT.

**Auth:** Anónimo

**Request body**
```json
{
  "email": "cliente@chapur.com.ar",
  "password": "12345678"
}
```

| Campo    | Tipo   | Requerido | Descripción             |
|----------|--------|-----------|-------------------------|
| email    | string | sí        | Email del usuario       |
| password | string | sí        | Contraseña en texto     |

**Response 200**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2026-04-15T00:58:27Z",
  "user": {
    "id": "c0f3e7a1-8f5b-4e2c-9d6a-3b1c4f8d7e2a",
    "email": "cliente@chapur.com.ar",
    "name": "Juan Pérez",
    "role": "Customer",
    "customerAccountNumber": "000123",
    "customerName": "ACME S.A.",
    "priceListCode": "13"
  }
}
```

**Response 401**
```json
{ "error": "Credenciales inválidas." }
```

---

## 2. Products — `/api/products`

**Auth:** JWT Bearer (cualquier rol)

### GET `/api/products`

Lista paginada de productos con filtros opcionales.

**Query parameters**

| Parámetro    | Tipo      | Default | Descripción                                |
|--------------|-----------|---------|--------------------------------------------|
| page         | int       | 1       | Página                                     |
| pageSize     | int       | 20      | Tamaño de página                           |
| search       | string    | null    | Búsqueda libre (nombre, descripción)       |
| productType  | string[]  | null    | Tipo(s) de producto                        |
| brandCode    | short[]   | null    | Código(s) de marca (ej. 98=TMC, 343=TANTOR)|

**Ejemplo:** `GET /api/products?page=1&pageSize=20&brandCode=98&brandCode=343&search=guantes`

**Response 200**
```json
{
  "items": [
    {
      "productType": "02",
      "articleCode": "02-01-0064",
      "name": "Guante Nitrilo M",
      "description": "Guante descartable nitrilo talle M x100",
      "brandCode": 98,
      "brandName": "TMC",
      "unitPrice": 12500.50,
      "priceListCode": "13",
      "imageUrl": "/content/product/02-01-0064.jpg",
      "stockStatus": "VERDE",
      "stockQuantity": 148
    }
  ],
  "total": 245,
  "page": 1,
  "pageSize": 20
}
```

> `stockStatus`: `"VERDE"` (stock > mínimo), `"AMARILLO"` (cerca del mínimo), `"ROJO"` (crítico/agotado).
> `stockQuantity` es el stock consolidado de depósitos `01`, `10`, `13`.

### GET `/api/products/search?q={query}`

Búsqueda rápida por texto libre.

**Query parameters**

| Parámetro | Tipo   | Default | Descripción            |
|-----------|--------|---------|------------------------|
| q         | string | —       | **Requerido.** Término |
| page      | int    | 1       |                        |
| pageSize  | int    | 20      |                        |

**Response 200:** mismo formato que `GET /api/products`.
**Response 400:** `{ "error": "Query parameter 'q' is required." }`

### GET `/api/products/{productType}/{articleCode}`

Detalle de un producto.

**Path parameters**

| Parámetro    | Tipo   | Descripción       |
|--------------|--------|-------------------|
| productType  | string | Tipo de producto  |
| articleCode  | string | Código de artículo|

**Ejemplo:** `GET /api/products/02/02-01-0064`

**Response 200**
```json
{
  "productType": "02",
  "articleCode": "02-01-0064",
  "name": "Guante Nitrilo M",
  "description": "Guante descartable nitrilo talle M x100",
  "brandCode": 98,
  "brandName": "TMC",
  "unitPrice": 12500.50,
  "priceListCode": "13",
  "imageUrl": "/content/product/02-01-0064.jpg",
  "stockStatus": "VERDE",
  "stockQuantity": 148,
  "technicalResources": [
    { "title": "Ficha Técnica", "url": "/content/tech/02-01-0064.pdf" }
  ]
}
```

**Response 404:** `{ "error": "Producto no encontrado." }`

---

## 3. Orders — `/api/orders`

**Auth:** JWT Bearer (cualquier rol).
Los clientes sólo ven sus propios pedidos; Admin/Vendedor ven todos.

### GET `/api/orders`

Lista de pedidos.

**Query parameters**

| Parámetro      | Tipo   | Default | Descripción                                            |
|----------------|--------|---------|--------------------------------------------------------|
| accountNumber  | string | null    | Filtra por cuenta de cliente (Admin/Vendedor)          |

**Response 200**
```json
[
  {
    "id": "7b2f1c4d-9e8a-4c5b-8f1d-2a3e4b5c6d7f",
    "orderNumber": "ORD-2026-000123",
    "legacyOrderId": "VTR-048129",
    "customerAccountNumber": "000123",
    "customerName": "ACME S.A.",
    "date": "2026-04-13T14:25:00",
    "status": "Submitted",
    "total": 248750.00,
    "itemCount": 6
  }
]
```

> `legacyOrderId` es el ID que devuelve Softland/VTR y es **el identificador primario** que se muestra en el portal.
> `status`: `Draft`, `Submitted`, `Confirmed`, `Dispatched`, `Delivered`, `Cancelled`.

### GET `/api/orders/{id}`

Detalle de un pedido.

**Path parameters**

| Parámetro | Tipo | Descripción       |
|-----------|------|-------------------|
| id        | Guid | ID interno (GUID) |

**Response 200**
```json
{
  "id": "7b2f1c4d-9e8a-4c5b-8f1d-2a3e4b5c6d7f",
  "orderNumber": "ORD-2026-000123",
  "legacyOrderId": "VTR-048129",
  "customerAccountNumber": "000123",
  "customerName": "ACME S.A.",
  "date": "2026-04-13T14:25:00",
  "status": "Submitted",
  "subtotal": 205578.51,
  "taxes": 43171.49,
  "total": 248750.00,
  "deliveryAddress": "Av. Siempreviva 742",
  "deliveryContact": "Juan Pérez",
  "deliveryPhone": "+54 11 4555-1234",
  "notes": "Entregar por la mañana",
  "estimatedDeliveryDate": "2026-04-18",
  "items": [
    {
      "articleCode": "02-01-0064",
      "description": "Guante Nitrilo M x100",
      "quantity": 12,
      "unitPrice": 12500.50,
      "subtotal": 150006.00,
      "stockStatus": "VERDE",
      "stockQuantity": 148
    }
  ]
}
```

**Response 404:** `{ "error": "Pedido no encontrado." }`

### POST `/api/orders`

Crea un pedido a partir del carrito actual.

**Auth:** JWT Bearer (cualquier rol con carrito activo; en la práctica `Customer`).

**Request body**
```json
{
  "deliveryAddress": "Av. Siempreviva 742",
  "deliveryContact": "Juan Pérez",
  "deliveryPhone": "+54 11 4555-1234",
  "notes": "Entregar por la mañana",
  "estimatedDeliveryDate": "2026-04-18"
}
```

| Campo                 | Tipo      | Requerido | Descripción                      |
|-----------------------|-----------|-----------|----------------------------------|
| deliveryAddress       | string    | sí        | Dirección de entrega             |
| deliveryContact       | string    | sí        | Persona de contacto              |
| deliveryPhone         | string    | sí        | Teléfono                         |
| notes                 | string    | no        | Observaciones                    |
| estimatedDeliveryDate | DateOnly  | no        | Fecha estimada (`YYYY-MM-DD`)    |

**Response 200**
```json
{ "orderId": "7b2f1c4d-9e8a-4c5b-8f1d-2a3e4b5c6d7f" }
```

**Response 400**
```json
{ "error": "El carrito está vacío." }
```

---

## 4. Cart — `/api/cart`

**Auth:** JWT Bearer — **Sólo rol `Customer`**.

### GET `/api/cart`

Obtiene el carrito del usuario autenticado.

**Response 200**
```json
{
  "items": [
    {
      "articleCode": "02-01-0064",
      "description": "Guante Nitrilo M x100",
      "quantity": 12,
      "unitPrice": 12500.50,
      "subtotal": 150006.00,
      "imageUrl": "/content/product/02-01-0064.jpg",
      "stockStatus": "VERDE",
      "stockQuantity": 148
    }
  ],
  "subtotal": 150006.00,
  "taxes": 31501.26,
  "total": 181507.26,
  "itemCount": 12
}
```

### POST `/api/cart/items`

Agrega un producto al carrito.

**Request body**
```json
{
  "articleCode": "02-01-0064",
  "quantity": 2
}
```

| Campo       | Tipo   | Requerido | Default | Descripción        |
|-------------|--------|-----------|---------|--------------------|
| articleCode | string | sí        | —       | Código de artículo |
| quantity    | int    | no        | 1       | Cantidad a agregar |

**Response 200**
```json
{ "message": "Producto agregado al carrito." }
```

### DELETE `/api/cart/items/{articleCode}`

Remueve un producto del carrito.

**Response 200**
```json
{ "message": "Producto removido del carrito." }
```

### DELETE `/api/cart`

Vacía el carrito.

**Response 200**
```json
{ "message": "Carrito vaciado." }
```

---

## 5. Customers — `/api/customers`

**Auth:** JWT Bearer (cualquier rol). Se consulta contra la tabla legacy `VTMCLH`.

### GET `/api/customers/search?term={term}`

Busca clientes por nombre, cuenta o CUIT.

**Query parameters**

| Parámetro | Tipo   | Default | Descripción                               |
|-----------|--------|---------|-------------------------------------------|
| term      | string | —       | **Requerido.** Mínimo 2 caracteres        |
| page      | int    | 1       |                                           |
| pageSize  | int    | 15      |                                           |

**Response 200**
```json
{
  "items": [
    {
      "accountNumber": "000123",
      "name": "ACME S.A.",
      "cuit": "30-71170843-6",
      "address": "Av. Corrientes 1234",
      "city": "CABA",
      "priceListCode": "13",
      "sellerCode": "015",
      "condicionIva": "RI"
    }
  ],
  "total": 3,
  "page": 1,
  "pageSize": 15
}
```

**Response 400:** `{ "error": "El termino de busqueda debe tener al menos 2 caracteres." }`

### GET `/api/customers/{accountNumber}`

Detalle de un cliente.

**Path parameters**

| Parámetro      | Tipo   | Descripción                              |
|----------------|--------|------------------------------------------|
| accountNumber  | string | Nro. de cuenta (N° de cliente en VTMCLH) |

**Response 200**
```json
{
  "accountNumber": "000123",
  "name": "ACME S.A.",
  "cuit": "30-71170843-6",
  "address": "Av. Corrientes 1234",
  "city": "CABA",
  "province": "CABA",
  "postalCode": "C1043",
  "priceListCode": "13",
  "sellerCode": "015",
  "sellerName": "Luis Castro",
  "condicionIva": "RI",
  "creditLimit": 5000000.00,
  "currentBalance": 1248750.25
}
```

**Response 404:** `{ "error": "Cliente no encontrado." }`

---

## 6. Cuenta Corriente — `/api/cuenta-corriente`

**Auth:** JWT Bearer (cualquier rol). Ejecuta el SP `usp_ResumenCuenta` contra Softland.

### GET `/api/cuenta-corriente/resumen`

Resumen de cuenta corriente del cliente.

**Query parameters**

| Parámetro       | Tipo     | Requerido | Default | Descripción                                         |
|-----------------|----------|-----------|---------|-----------------------------------------------------|
| accountNumber   | string   | sí        | —       | Nro. de cuenta (`@NroCta`)                          |
| fechaDesde      | DateTime | sí        | —       | Fecha desde (ISO 8601)                              |
| fechaHasta      | DateTime | sí        | —       | Fecha hasta (ISO 8601)                              |
| soloPendientes  | int      | no        | 0       | `1` = sólo pendientes; `0` = todos los movimientos  |

**Ejemplo:** `GET /api/cuenta-corriente/resumen?accountNumber=000123&fechaDesde=2026-01-01&fechaHasta=2026-04-14&soloPendientes=0`

**Response 200**
```json
{
  "accountNumber": "000123",
  "customerName": "ACME S.A.",
  "fechaDesde": "2026-01-01",
  "fechaHasta": "2026-04-14",
  "totalDebe": 2500000.00,
  "totalHaber": 1251249.75,
  "saldoFinal": 1248750.25,
  "items": [
    {
      "fecha": "2026-03-15",
      "documentCode": "FCA",
      "documentNumber": 12458,
      "puntoVenta": "00012",
      "descripcion": "Factura A 00012-00012458",
      "debe": 248750.00,
      "haber": 0.00,
      "saldo": 248750.00,
      "estado": "Pendiente",
      "vencimiento": "2026-04-14"
    },
    {
      "fecha": "2026-03-20",
      "documentCode": "RCB",
      "documentNumber": 8872,
      "puntoVenta": "00012",
      "descripcion": "Recibo 00012-00008872",
      "debe": 0.00,
      "haber": 150000.00,
      "saldo": 98750.00,
      "estado": "Aplicado",
      "vencimiento": null
    }
  ]
}
```

### GET `/api/cuenta-corriente/comprobante/{documentCode}/{documentNumber}`

Detalle de un comprobante (Factura A o Recibo) con datos para imprimir el PDF fiscal.

**Path parameters**

| Parámetro       | Tipo   | Descripción                                   |
|-----------------|--------|-----------------------------------------------|
| documentCode    | string | Código de comprobante (ej. `FCA`, `RCB`)      |
| documentNumber  | int    | Número de comprobante                         |

**Response 200**
```json
{
  "documentCode": "FCA",
  "documentNumber": 12458,
  "puntoVenta": "00012",
  "fecha": "2026-03-15",
  "letra": "A",
  "tipoCmp": 1,
  "companyCuit": "30-71170843-6",
  "companyName": "CHAPUR S.A.",
  "companyAddress": "...",
  "ingresosBrutos": "...",
  "inicioActividades": "...",
  "customer": {
    "accountNumber": "000123",
    "name": "ACME S.A.",
    "cuit": "30-71170843-6",
    "address": "Av. Corrientes 1234",
    "condicionIva": "RI"
  },
  "items": [
    {
      "articleCode": "02-01-0064",
      "description": "Guante Nitrilo M x100",
      "quantity": 12,
      "unitPrice": 12500.50,
      "discount": 0,
      "ivaRate": 21,
      "subtotal": 150006.00
    }
  ],
  "subtotal": 205578.51,
  "iva21": 31501.26,
  "iva105": 11670.23,
  "otrosImpuestos": 0,
  "total": 248750.00,
  "medioPagoDescripcion": "Cuenta Corriente",
  "cae": "75123456789012",
  "caeVencimiento": "2026-03-25",
  "qrUrl": "https://www.afip.gob.ar/fe/qr/?p=eyJ2ZXIiOjEs..."
}
```

**Response 404:** `{ "error": "Comprobante no encontrado." }`

---

## Ejemplos de uso con `curl`

### Login y uso del token
```bash
# 1. Obtener token
TOKEN=$(curl -s -X POST http://localhost:5175/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"cliente@chapur.com.ar","password":"Pass123!"}' \
  | jq -r .token)

# 2. Listar productos
curl -s http://localhost:5175/api/products?page=1&pageSize=10 \
  -H "Authorization: Bearer $TOKEN"

# 3. Agregar al carrito
curl -s -X POST http://localhost:5175/api/cart/items \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"articleCode":"02-01-0064","quantity":2}'

# 4. Crear pedido
curl -s -X POST http://localhost:5175/api/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "deliveryAddress":"Av. Siempreviva 742",
    "deliveryContact":"Juan Pérez",
    "deliveryPhone":"+54 11 4555-1234",
    "estimatedDeliveryDate":"2026-04-18"
  }'
```

---

## Notas de implementación

- **Cultura:** todo el binding se hace en `en-US` (ver `Program.cs`). Los montos decimales deben enviarse con **punto**, no con coma.
- **DateOnly** se serializa como `"YYYY-MM-DD"`.
- **DateTime** se espera en ISO 8601.
- Las respuestas con montos usan el tipo `decimal` (no notación científica).
- `stockStatus` se calcula contra la tabla `STRMVK` consolidando los depósitos `01`, `10`, `13` y filtrando marcas `98` y `343`.
- `customerName` en pedidos se enriquece desde `VTMCLH` porque `Order.Customer` no es una navegación EF real (es una entidad legacy).
