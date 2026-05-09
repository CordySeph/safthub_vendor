# User API Guide

This guide provides details on API endpoints available to authenticated end-users of the platform.

All user-specific endpoints are prefixed with `/api/user` and require authentication with a JWT token for a user with the `user` role.

## Table of Contents
- [Authentication](#authentication)
- [Restaurant Discovery](#restaurant-discovery)
- [Address Management](#address-management)
- [Order Management](#order-management)
- [Profile Management](#profile-management)
- [Real-time Order Tracking](#real-time-order-tracking)

## Authentication

To access any user-specific API endpoint, you must first authenticate by logging in via `POST /api/auth/login` to obtain a JSON Web Token (JWT).

This token must be included in the `Authorization` header of every subsequent API request.

```
Authorization: Bearer <YOUR_USER_JWT_TOKEN>
```

---

## Restaurant Discovery

These endpoints allow users to discover and browse restaurants.

### List and Filter Restaurants
- **Endpoint:** `GET /api/public/restaurants`
- **Description:** Retrieves a paginated list of all approved restaurants. The list can be filtered by various criteria.
- **Handler:** `handlers.ListRestaurants`
- **Query Parameters:**
    - `page` (optional): The page number to retrieve. Defaults to `1`.
    - `limit` (optional): The number of items per page. Defaults to `10`.
    - `category` (optional): Filter by restaurant category (e.g., "Thai", "Italian").
    - `tag` (optional): Filter by a specific menu item tag (e.g., "Pizza", "Vegan").
    - `name` (optional): Search for restaurants by name (case-insensitive).
    - `min_rating` (optional): Filter for restaurants with a rating greater than or equal to the given value.
    - `price_range` (optional): Filter by price range (e.g., "$", "$$", "$$$").
    - `latitude` & `longitude` (optional): Provide user's location to sort by distance.
    - `radius_km` (optional): When used with `latitude` and `longitude`, filters restaurants within a specific radius.
    - `has_promotions` (optional): Set to `true` to only show restaurants with active promotions.
    - `sort_by` (optional): Sort results by `rating`, `price`, or `distance`.
    - `sort_order` (optional): `asc` or `desc`.

**Example `curl`:**
```bash
curl -L -X GET "http://localhost:8080/api/public/restaurants?category=Italian&tag=Pizza&min_rating=4.5"
```

**Success Response (200 OK):**
```json
{
    "data": [
        {
            "ID": "restaurant-uuid-1",
            "Name": "Luigi's Pizza",
            "Category": "Italian",
            "Rating": 4.8,
            ...
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 1
    }
}
```

---

## Address Management

These endpoints allow users to manage their saved delivery addresses.

### Create a New Address
- **Endpoint:** `POST /api/user/addresses`
- **Description:** Adds a new delivery address to the user's account. If it's the first address or if `is_default` is set to `true`, it will become the default delivery address.
- **Handler:** `addressHandler.CreateAddress`

**Request Body:**
```json
{
    "label": "Work",
    "address_line1": "123 Tech Park",
    "address_line2": "Floor 5, Building C",
    "city": "Bangkok",
    "state": "Bangkok",
    "zip_code": "10110",
    "country": "Thailand",
    "latitude": 13.7563,
    "longitude": 100.5018,
    "is_default": true
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/user/addresses \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"label": "Work", "address_line1": "123 Tech Park", "city": "Bangkok", "state": "Bangkok", "zip_code": "10110", "country": "Thailand", "latitude": 13.7563, "longitude": 100.5018, "is_default": true}'
```

**Success Response (201 Created):**
(Returns the newly created address object)

---

### List All Addresses
- **Endpoint:** `GET /api/user/addresses`
- **Description:** Retrieves a list of all addresses saved to the user's account, ordered with the default address first.
- **Handler:** `addressHandler.GetAddresses`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/user/addresses \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
[
    {
        "id": "uuid-of-default-address",
        "label": "Work",
        "address_line1": "123 Tech Park",
        "is_default": true,
        ...
    },
    {
        "id": "uuid-of-other-address",
        "label": "Home",
        "address_line1": "456 Home Street",
        "is_default": false,
        ...
    }
]
```

---

### Get a Single Address
- **Endpoint:** `GET /api/user/addresses/:address_id`
- **Description:** Retrieves the details of a single address by its ID.
- **Handler:** `addressHandler.GetAddressByID`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/user/addresses/your_address_id \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

---

### Update an Address
- **Endpoint:** `PATCH /api/user/addresses/:address_id`
- **Description:** Updates the details of a specific address. Only the fields provided in the request body will be updated.
- **Handler:** `addressHandler.UpdateAddress`

**Request Body (Example):**
```json
{
    "label": "Office",
    "address_line2": "Floor 6, Main Tower"
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/user/addresses/your_address_id \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"label": "Office", "address_line2": "Floor 6, Main Tower"}'
```

---

### Delete an Address
- **Endpoint:** `DELETE /api/user/addresses/:address_id`
- **Description:** Permanently deletes an address from the user's account.
- **Handler:** `addressHandler.DeleteAddress`

**Example `curl`:**
```bash
curl -L -X DELETE http://localhost:8080/api/user/addresses/your_address_id \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "address deleted successfully"
}
```

---

### Set an Address as Default
- **Endpoint:** `POST /api/user/addresses/:address_id/default`
- **Description:** Marks a specific address as the user's default delivery address. Any previously default address will be unset.
- **Handler:** `addressHandler.SetDefaultAddress`

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/user/addresses/your_address_id/default \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "address set as default successfully"
}
```

---

## Order Management

These endpoints allow users to view their order history and re-order previous purchases.

### List Order History
- **Endpoint:** `GET /api/user/orders`
- **Description:** Retrieves a paginated list of the user's past and current orders. Orders can be filtered by `status`.
- **Query Parameters:**
    - `status` (optional): Filter by order status (e.g., `pending`, `delivered`, `cancelled`).
    - `page` (optional): The page number to retrieve. Defaults to `1`.
    - `limit` (optional): The number of items per page. Defaults to `10`.
- **Handler:** `handlers.GetUserOrders`

**Example `curl`:**
```bash
curl -L -X GET "http://localhost:8080/api/user/orders?status=delivered&page=1" \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "data": [
        {
            "ID": "order-uuid-1",
            "Status": "delivered",
            "TotalPrice": 550.00,
            "CreatedAt": "2025-11-10T14:00:00Z",
            "Restaurant": { ... }
        }
    ],
    "pagination": {
        "total": 1,
        "page": 1,
        "limit": 10
    }
}
```

---

### Get Single Order Details
- **Endpoint:** `GET /api/user/orders/:order_id`
- **Description:** Retrieves the full details of a single order, including all order items.
- **Handler:** `handlers.GetOrderDetails`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/user/orders/your_order_id \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
(Returns the full order object, including the `OrderItems` array)

---

### Re-order a Previous Order
- **Endpoint:** `POST /api/user/orders/:order_id/reorder`
- **Description:** Clears the user's current cart and adds all items from a specified previous order. This is a quick way to start a new order based on a past one.
- **Handler:** `handlers.Reorder`

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/user/orders/your_order_id/reorder \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "Your previous order has been added to your cart."
}
```

**Error Response (500 Internal Server Error):**
(If some items could not be re-ordered, e.g., out of stock)
```json
{
    "error": "reorder completed with errors: could not add item 'Item Name': not enough stock"
}
```

---

## Profile Management

These endpoints allow users to manage their personal profile information and security settings.

### Change Password
- **Endpoint:** `PATCH /api/user/profile/password`
- **Description:** Allows the authenticated user to change their account password.
- **Handler:** `authHandler.ChangePassword`

**Request Body:**
```json
{
    "oldPassword": "current_password",
    "newPassword": "new_strong_password"
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/user/profile/password \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"oldPassword": "current_password", "newPassword": "new_strong_password"}'
```

**Success Response (200 OK):**
```json
{
    "message": "password changed successfully"
}
```

**Error Response (401 Unauthorized):**
```json
{
    "error": "Incorrect old password"
}
```

---

### Update Profile Picture
- **Endpoint:** `PATCH /api/auth/me/picture`
- **Description:** Allows the authenticated user to upload or update their profile picture.
- **Handler:** `authHandler.UploadProfilePicture`
- **Request Type:** `multipart/form-data`
- **Form Data:**
    - `profile_picture`: The image file to upload.

**Example `curl`:**
```bash
curl -X PATCH \
  http://localhost:8080/api/auth/me/picture \
  -H 'Authorization: Bearer <YOUR_USER_JWT_TOKEN>' \
  -H 'Content-Type: multipart/form-data' \
  -F 'profile_picture=@/path/to/your/image.jpg'
```

**Success Response (200 OK):**
```json
{
    "message": "profile picture uploaded successfully",
    "filePath": "uploads/avatars/unique-filename.jpg"
}
```

**Error Response (400 Bad Request):**
```json
{
    "code": "INVALID_INPUT",
    "message": "profile_picture file is required"
}
```

---

## Real-time Order Tracking

These endpoints allow users to track the real-time location of the rider assigned to their active order.

### Get Rider Location for an Order
- **Endpoint:** `GET /api/user/orders/:order_id/rider/location`
- **Description:** Retrieves the current latitude and longitude of the rider assigned to the specified order.
- **Handler:** `handlers.GetOrderRiderLocation`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/user/orders/your_order_id/rider/location \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "latitude": 13.7563,
    "longitude": 100.5018
}
```

**Error Response (404 Not Found):**
```json
{
    "error": "order not found or you do not have permission to view it"
}
```

**Error Response (500 Internal Server Error):**
```json
{
    "error": "no rider assigned to this order yet"
}
```