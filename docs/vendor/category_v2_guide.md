# Category API Guide (Version 2)

This document provides a guide for vendors to manage their product categories using the Version 2 API.

## Base Path & Authentication

-   **Base Path:** `/api/v2/categories`
-   **Authentication:** All endpoints require a JWT token for a user with the `vendor` role.

---

## 1. Create a Category

*   **Endpoint:** `POST /`
*   **Description:** Creates a new category for the vendor's restaurant.
*   **Permissions:** Requires `menu:manage` staff permission.

### Request Body
```json
{
  "name": "เครื่องดื่ม",
  "description": "กาแฟ, ชา, และน้ำผลไม้"
}
```

### Example `curl`
```bash
curl -L -X POST http://localhost:8080/api/v2/categories \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "เครื่องดื่ม",
    "description": "กาแฟ, ชา, และน้ำผลไม้"
  }'
```

### Success Response (201 Created)
```json
{
    "id": "a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab",
    "name": "เครื่องดื่ม",
    "description": "กาแฟ, ชา, และน้ำผลไม้",
    "created_at": "2025-11-26T10:00:00Z",
    "updated_at": "2025-11-26T10:00:00Z"
}
```

---

## 2. List All Categories

*   **Endpoint:** `GET /`
*   **Description:** Retrieves a list of all categories for the vendor's restaurant.
*   **Permissions:** Requires `menu:view` staff permission (or `menu:manage`).

### Example `curl`
```bash
curl -L -X GET http://localhost:8080/api/v2/categories \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

### Success Response (200 OK)
```json
[
    {
        "id": "a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab",
        "name": "เครื่องดื่ม",
        "description": "กาแฟ, ชา, และน้ำผลไม้",
        "created_at": "2025-11-26T10:00:00Z",
        "updated_at": "2025-11-26T10:00:00Z"
    },
    {
        "id": "b2c3d4e5-f6g7-4h5i-9j0k-1234567890bc",
        "name": "อาหารจานหลัก",
        "description": "อาหารจานหลักและสเต็ก",
        "created_at": "2025-11-26T10:01:00Z",
        "updated_at": "2025-11-26T10:01:00Z"
    }
]
```

---

## 3. Get a Single Category

*   **Endpoint:** `GET /:id`
*   **Description:** Retrieves details for a single category by its ID.
*   **Permissions:** Requires `menu:view` staff permission.

### Example `curl`
```bash
curl -L -X GET http://localhost:8080/api/v2/categories/a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

---

## 4. Update a Category

*   **Endpoint:** `PATCH /:id`
*   **Description:** Updates the name and/or description of an existing category.
*   **Permissions:** Requires `menu:manage` staff permission.

### Request Body
```json
{
  "name": "เครื่องดื่มและเบเกอรี่",
  "description": "กาแฟ, ชา, น้ำผลไม้ และขนมอบ"
}
```

### Example `curl`
```bash
curl -L -X PATCH http://localhost:8080/api/v2/categories/a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "เครื่องดื่มและเบเกอรี่"
  }'
```

### Success Response (200 OK)
(Returns the full, updated category object)

---

## 5. Delete a Category

*   **Endpoint:** `DELETE /:id`
*   **Description:** Deletes a category. Note: This may affect products that are associated with this category.
*   **Permissions:** Requires `menu:manage` staff permission.

### Example `curl`
```bash
curl -L -X DELETE http://localhost:8080/api/v2/categories/a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

### Success Response (200 OK)
```json
{
  "message": "Category deleted successfully"
}
```

---

# Public Endpoints

This section describes endpoints that are publicly accessible and do not require authentication. They are intended for use by customers and mobile applications.

## 1. List All Categories for a Restaurant

*   **Endpoint:** `GET /api/restaurants/:restaurant_id/v2/categories`
*   **Description:** Retrieves a list of all v2 categories for a specific restaurant.
*   **Authentication:** None required.

### Example `curl`
```bash
# Replace :restaurant_id with the actual ID of the restaurant
curl -L -X GET http://localhost:8080/api/restaurants/8612c85a-6c8f-46be-9648-c12ec0999dd6/v2/categories
```

### Success Response (200 OK)
```json
[
    {
        "id": "a1b2c3d4-e5f6-4a5b-8c9d-0123456789ab",
        "name": "เครื่องดื่ม",
        "description": "กาแฟ, ชา, และน้ำผลไม้",
        "created_at": "2025-11-26T10:00:00Z",
        "updated_at": "2025-11-26T10:00:00Z"
    },
    {
        "id": "b2c3d4e5-f6g7-4h5i-9j0k-1234567890bc",
        "name": "อาหารจานหลัก",
        "description": "อาหารจานหลักและสเต็ก",
        "created_at": "2025-11-26T10:01:00Z",
        "updated_at": "2025-11-26T10:01:00Z"
    }
]
```
