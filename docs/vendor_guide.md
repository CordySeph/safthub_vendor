# Vendor API Guide

This document serves as a comprehensive guide for vendors to effectively interact with the backend API. It outlines the available endpoints, required authentication methods, and provides detailed examples for managing your restaurant, menu, orders, discounts, and accessing analytics. By leveraging these APIs, vendors can integrate their systems, automate tasks, and gain deeper insights into their operations.

All vendor-specific endpoints are prefixed with `/api/vendor` and require authentication with a JWT token for a user with the `vendor` role.

## Table of Contents
- [Authentication](#authentication)
- [Restaurant Management](#restaurant-management)
- [Dashboard](#dashboard)
- [Menu Management](#menu-management)
- [Category Management](#category-management)
- [Order Management](#order-management)
- [Discount Management](#discount-management)
- [Analytics & Reporting](#analytics--reporting)
- [Review Management](#review-management)
- [Staff Management](#staff-management)

## Authentication

To access any vendor-specific API endpoint, you must first authenticate and obtain a JSON Web Token (JWT). This token verifies your identity as a vendor and grants you the necessary permissions to perform operations on your restaurant's data.

### Obtaining a JWT Token
Typically, a JWT token is obtained by logging in through a dedicated authentication endpoint (e.g., `/api/auth/login`). Once you successfully log in with your vendor credentials (email and password), the API will return a JWT token. This token usually has an expiration time, after which you will need to re-authenticate to get a new one.

### Using the JWT Token
The obtained JWT token must be included in the `Authorization` header of every subsequent API request. The format for this header is:

```
Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>
```

Replace `<YOUR_VENDOR_JWT_TOKEN>` with the actual token you received after authentication. Ensure there is a space between `Bearer` and your token.

---

## General `curl` Usage

`curl` is a command-line tool for making HTTP requests. Here's a breakdown of common flags used in the examples throughout this guide:

*   `curl`: The command itself.
*   `-L`: **Follow Redirects.** This flag is crucial. If the server responds with a 3xx redirect (e.g., 307 Temporary Redirect), `curl` will automatically follow the new location. Without this flag, `curl` might just output the redirect response without making the actual request to the final destination.
*   `-X <METHOD>`: **HTTP Method.** Specifies the HTTP method for the request (e.g., `GET`, `POST`, `PATCH`, `DELETE`).
*   `<URL>`: **Endpoint URL.** The full URL of the API endpoint you are targeting.
*   `-H "<HEADER>"`: **HTTP Header.** Adds a custom HTTP header to the request.
    *   `"Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"`: Used for authentication. Replace `<YOUR_VENDOR_JWT_TOKEN>` with your actual JWT.
    *   `"Content-Type: application/json"`: Informs the server that the request body is in JSON format.
*   `-d '<body>'`: **Request Body.** Sends data in the request body. This is typically used with `POST` and `PATCH` requests. The data should be a valid JSON string.

---

## Restaurant Management

This section details the endpoints available for vendors to manage their restaurant's profile, from initial registration to updating details and managing temporary closures.

### Register a Restaurant
- **Endpoint:** `POST /api/vendor/register-store`
- **Description:** This endpoint allows a vendor to submit their restaurant for registration. It's crucial that the restaurant's geographical coordinates (latitude and longitude) fall within a predefined service zone. Upon successful submission, the restaurant's application will enter a "pending" state. An administrator must review and approve the application before the restaurant becomes active on the platform. You will not be able to perform other vendor operations until your restaurant is approved.
- **Handler:** `handlers.RegisterRestaurant`

**Request Body:**
```json
{
    "name": "Delicious Eats Restaurant",
    "logo_url": "https://example.com/restaurant_logo.png",
    "cover_photo_url": "https://example.com/restaurant_cover.jpg",
    "phone_number": "0987654321",
    "restaurant_email": "info@deliciouseats.com",
    "description": "A fusion Thai restaurant with a great atmosphere.",
    "address": "123 Sukhumvit Road, Bangkok 10110",
    "latitude": 13.736717,
    "longitude": 100.539800,
    "business_hours": {
        "monday": { "open": "11:00", "close": "22:00" },
        "tuesday": { "open": "11:00", "close": "22:00" },
        "wednesday": { "open": "11:00", "close": "22:00" },
        "thursday": { "open": "11:00", "close": "22:00" },
        "friday": { "open": "11:00", "close": "23:00" },
        "saturday": { "open": "12:00", "close": "23:00" },
        "sunday": null
    },
    "category": "Thai, Fusion",
    "price_range": "$$"
}
```
*Note: `logo_url` and `cover_photo_url` are optional. If not provided, default images will be used.*

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/register-store \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Delicious Eats Restaurant", "logo_url": "https://example.com/restaurant_logo.png", "cover_photo_url": "https://example.com/restaurant_cover.jpg", "address": "123 Sukhumvit Road, Bangkok 10110", "latitude": 13.736717, "longitude": 100.539800, "category": "Thai, Fusion", "price_range": "$$$"}'
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method for creating a new resource.
*   `-d "{...}"`: Contains the JSON request body with restaurant details. Note the escaped double quotes within the JSON string.

**Success Response (201 Created):**
```json
{
    "message": "restaurant submitted for review"
}
```

**Error Response (400 Bad Request):**
```json
{
    "error": "LOCATION_NOT_SERVICED",
    "message": "restaurant location is not within any service zone"
}
```

### Get My Restaurant
- **Endpoint:** `GET /api/vendor/my-restaurant`
- **Description:** This endpoint allows an authenticated vendor to retrieve the complete profile details of their registered restaurant. This includes all information provided during registration, along with its current status (e.g., "pending", "approved", "rejected"), rating, and temporary closure status.
- **Handler:** `handlers.GetMyRestaurant`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/vendor/my-restaurant \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X GET`: Specifies the HTTP GET method for retrieving a resource.
*   No `-d` flag is used as GET requests typically do not have a request body.

**Success Response (200 OK):**
```json
{
    "ID": "bc462ade-9b4e-4750-8ad7-2d75ba363006",
    "OwnerID": "91bcfe46-6f1e-4357-a68f-e0dab16cf281",
    "WalletID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "Name": "Delicious Eats Restaurant",
    "LogoURL": "https://example.com/restaurant_logo.png",
    "CoverPhotoURL": "https://example.com/restaurant_cover.jpg",
    "PhoneNumber": "0987654321",
    "RestaurantEmail": "info@deliciouseats.com",
    "Description": "A fusion Thai restaurant with a great atmosphere.",
    "Address": "123 Sukhumvit Road, Bangkok 10110",
    "Location": {
        "Lat": 13.736717,
        "Lng": 100.5398
    },
    "ReviewCount": 0,
    "BusinessHours": {
        "monday": {"open": "11:00", "close": "22:00"}
    },
    "IsOpen": true,
    "Category": "Thai, Fusion",
    "PriceRange": "$$",
    "RejectReason": "",
    "Status": "approved",
    "Rating": 0,
    "IsTemporarilyClosed": false,
    "TemporaryClosureReason": "",
    "CreatedAt": "2025-10-23T10:00:00Z",
    "UpdatedAt": "2025-10-23T10:00:00Z"
}
```

### Update My Restaurant
- **Endpoint:** `PATCH /api/vendor/my-restaurant`
- **Description:** This endpoint allows a vendor to update specific details of their own restaurant. You only need to send the fields you wish to modify in the request body. Fields such as `id`, `ownerId`, `status`, and `rejectReason` cannot be updated via this endpoint.
- **Handler:** `handlers.UpdateMyRestaurant`

**Request Body (Example):**
```json
{
    "phone_number": "0998887777",
    "description": "The best authentic Thai food in town.",
    "price_range": "$$$",
    "cover_photo_url": "https://example.com/new_cover.jpg"
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/my-restaurant \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "0998887777", "price_range": "$$$", "cover_photo_url": "https://example.com/new_cover.jpg"}'
```

**`curl` Command Explanation:**
*   `-X PATCH`: Specifies the HTTP PATCH method for partially updating a resource.
*   `-d "{...}"`: Contains the JSON request body with the fields to be updated. Only include the fields you wish to modify.

**Success Response (200 OK):**
(The response will be the full, updated restaurant object, similar to the `GET /my-restaurant` response)

### Set Temporary Closure
- **Endpoint:** `PATCH /api/vendor/my-restaurant/closure`
- **Description:** Use this endpoint to temporarily close your restaurant for a period (e.g., for holidays, maintenance, or unforeseen circumstances) or to reopen it. You can optionally provide a reason for the closure.
- **Handler:** `handlers.SetTemporaryClosure`

**Request Body:**
```json
{
    "is_closed": true,
    "reason": "Staff holiday"
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/my-restaurant/closure \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"is_closed": true, "reason": "Staff holiday"}'
```

**`curl` Command Explanation:**
*   `-X PATCH`: Specifies the HTTP PATCH method for partially updating a resource.
*   `-d "{...}"`: Contains the JSON request body with the `is_closed` status and an optional `reason`.

**Success Response (200 OK):**
(The response will be the full, updated restaurant object)

### Check Location
- **Endpoint:** `POST /api/vendor/check-location`
- **Description:** This utility endpoint allows vendors to verify if a specific geographical location (latitude and longitude) falls within any of the defined service zones. This is particularly useful before attempting to register a new store, ensuring it can be serviced by the platform.
- **Handler:** `handlers.CheckLocation`

**Request Body:**
```json
{
    "latitude": 13.736717,
    "longitude": 100.539800
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/check-location \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"latitude": 13.736717, "longitude": 100.539800}'
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method.
*   `-d "{...}"`: Contains the JSON request body with the `latitude` and `longitude` to check.

---

## Dashboard

This section provides endpoints for vendors to access a comprehensive overview of their restaurant's performance and operational data.

### Get Restaurant Dashboard
- **Endpoint:** `GET /api/vendor/dashboard`
- **Description:** This endpoint retrieves a detailed dashboard summary for your restaurant. It includes key performance indicators (KPIs) such as total revenue, total orders, average order value, popular menu items, recent orders, order status breakdowns, revenue trends over time, average customer ratings, and low-stock alerts. You can filter this data by specifying a `period` query parameter to view insights for `today`, `week`, `month`, or `year`. If no period is specified, it defaults to `all_time`.
- **Query Parameter:** `period` (optional) - Values can be `today`, `week`, `month`, `year` (current calendar year), `year_to_date`. Defaults to `all_time`.
- **Handler:** `dashboardHandler.GetRestaurantDashboard`

**Example `curl`:**
```bash
# Get dashboard summary for the last 7 days
curl -L -X GET "http://localhost:8080/api/vendor/dashboard?period=week" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"

# Get dashboard summary from the beginning of the current year to date
curl -L -X GET "http://localhost:8080/api/vendor/dashboard?period=year_to_date" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"

# Get dashboard summary for today
curl -L -X GET "http://localhost:8080/api/vendor/dashboard?period=today" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"

# Get dashboard summary for the last month
curl -L -X GET "http://localhost:8080/api/vendor/dashboard?period=month" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"

# Get dashboard summary for the current calendar year
curl -L -X GET "http://localhost:8080/api/vendor/dashboard?period=year" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X GET`: Specifies the HTTP GET method.
*   `"http://localhost:8080/api/vendor/dashboard?period=week"`: The URL includes a query parameter `period=week` to filter the dashboard data.

**Success Response (200 OK):**
```json
{
    "analytics_summary": {
        "total_revenue": 1850.50,
        "total_orders": 50,
        "average_order_value": 37.01
    },
    "popular_items": [
        {
            "menu_item_name": "Pad Thai",
            "total_quantity_sold": 25,
            "total_revenue": 3125
        }
    ],
    "recent_orders": [
        {
            "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
            "Status": "delivered",
            "TotalPrice": 45.5,
            "CreatedAt": "2025-10-23T09:30:00Z"
        }
    ],
    "order_status_breakdown": {
        "pending": 2,
        "preparing": 5,
        "ready_for_pickup": 1
    },
    "revenue_over_time": [
        {
            "date": "2025-10-22T00:00:00Z",
            "revenue": 950.00
        },
        {
            "date": "2025-10-23T00:00:00Z",
            "revenue": 900.50
        }
    ],
    "average_rating": 4.85,
    "review_count": 150,
    "recent_reviews": [
        {
            "id": "review_uuid_1",
            "user_id": "...",
            "rating": 5,
            "comment": "Amazing food!",
            "created_at": "2025-10-23T11:00:00Z"
        }
    ],
    "low_stock_items": [
        {
            "ID": "variant_uuid_abc",
            "Name": "Pork",
            "Stock": 8
        }
    ],
    "restaurant_id": "bc462ade-9b4e-4750-8ad7-2d75ba363006"
}
```

---

## Category Management
These endpoints allow vendors to organize their menu items into logical categories, making it easier for customers to browse. These operations require the vendor's restaurant to be approved.

### Create a Category
- **Endpoint:** `POST /api/vendor/categories/`
- **Description:** Use this endpoint to create a new category for your restaurant's menu. Each category helps in structuring your menu offerings. For example, you might create categories like "Appetizers", "Main Courses", "Desserts", or "Drinks".
- **Handler:** `handlers.CreateCategory`

**Request Body:**
```json
{
    "name": "Computer Components"
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/categories/ \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Computer Components"}'
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method for creating a new resource.
*   `-d '{"name": "Computer Components"}'`: Contains the JSON request body with the `name` of the category to be created.

**Success Response (201 Created):**
```json
{
    "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "RestaurantID": "bc462ade-9b4e-4750-8ad7-2d75ba363006",
    "Name": "Computer Components",
    "CreatedAt": "2025-10-24T01:30:00Z",
    "UpdatedAt": "2025-10-24T01:30:00Z"
}
```

### Get All Categories
- **Endpoint:** `GET /api/vendor/categories/`
- **Description:** This endpoint retrieves a comprehensive list of all categories that have been created for your restaurant. This is useful for displaying existing categories or for populating dropdowns when creating or updating menu items.
- **Handler:** `handlers.GetCategories`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/vendor/categories/ \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X GET`: Specifies the HTTP GET method for retrieving resources.
*   No `-d` flag is used as GET requests typically do not have a request body.

---
**Success Response (200 OK):**
```json
[
    {
        "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "RestaurantID": "bc462ade-9b4e-4750-8ad7-2d75ba363006",
        "Name": "Computer Components",
        "CreatedAt": "2025-10-24T01:30:00Z",
        "UpdatedAt": "2025-10-24T01:30:00Z"
    },
    {
        "ID": "b2c3d4e5-f6g7-h8i9-j0k1-l2m3n4o5p6q7",
        "RestaurantID": "bc462ade-9b4e-4750-8ad7-2d75ba363006",
        "Name": "Peripherals",
        "CreatedAt": "2025-10-24T01:31:00Z",
        "UpdatedAt": "2025-10-24T01:31:00Z"
    }
]
```

### Update a Category
- **Endpoint:** `PATCH /api/vendor/categories/:category_id`
- **Description:** This endpoint allows a vendor to update the name of an existing category. The new category name must be unique within the vendor's restaurant.
- **Handler:** `handlers.UpdateCategory`

**Request Body:**
```json
{
    "name": "Updated Category Name"
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/categories/your_category_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Category Name"}'
```

**`curl` Command Explanation:**
*   `-X PATCH`: Specifies the HTTP PATCH method for partial updates.
*   `your_category_id`: Replace with the actual ID of the category to update.
*   `-d '{"name": "Updated Category Name"}'`: Contains the new category name.

**Success Response (200 OK):**
(Returns the updated category object)

**Error Response (500 Internal Server Error):**
```json
{
    "error": "Category name already exists",
    "details": "category with name 'Existing Category' already exists for this restaurant"
}
```

### Delete a Category
- **Endpoint:** `DELETE /api/vendor/categories/:category_id`
- **Description:** This endpoint permanently deletes a category. Note that deleting a category might affect existing menu items that are associated with it (e.g., they might become uncategorized or deleted depending on the system's foreign key constraints).
- **Handler:** `handlers.DeleteCategory`

**Example `curl`:**
```bash
curl -L -X DELETE http://localhost:8080/api/vendor/categories/your_category_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X DELETE`: Specifies the HTTP DELETE method.
*   `your_category_id`: Replace with the actual ID of the category to delete.

**Success Response (200 OK):**
```json
{
    "message": "category deleted successfully"
}
```

---

## Menu Management
These endpoints enable vendors to comprehensively manage their restaurant's menu, including adding new items, updating existing ones, and removing items. These operations require the vendor's restaurant to be approved.

### Get My Menu
- **Endpoint:** `GET /api/vendor/menu`
- **Description:** This endpoint allows an authenticated vendor to retrieve all menu items for their own restaurant. Unlike the public menu endpoint, this does not require specifying the `restaurant_id` in the URL, as it is derived from the authenticated vendor's context. This endpoint can potentially return more detailed information about menu items, such as internal stock levels or unpublished items, depending on its implementation.
- **Handler:** `handlers.GetVendorMenu`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/vendor/menu \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X GET`: Specifies the HTTP GET method for retrieving resources.
*   No `-d` flag is used as GET requests typically do not have a request body.

**Success Response (200 OK):**
```json
[
    {
        "ID": "menu_item_uuid_1",
        "Name": "Pad Thai",
        "Description": "Classic Thai stir-fried noodles.",
        "CategoryID": "category_uuid_1",
        "Images": [
            {"URL": "https://example.com/padthai.jpg"}
        ],
        "Tags": [
            {"Name": "Noodles"},
            {"Name": "Thai"}
        ],
        "Variants": [
            {
                "ID": "variant_uuid_1",
                "Name": "Regular",
                "Price": 120.00,
                "IsAvailable": true,
                "Stock": 50
            }
        ],
        "CreatedAt": "2025-10-24T01:00:00Z",
        "UpdatedAt": "2025-10-24T01:00:00Z"
    },
    {
        "ID": "menu_item_uuid_2",
        "Name": "Green Curry",
        "Description": "Spicy green curry with chicken.",
        "CategoryID": "category_uuid_1",
        "Images": [
            {"URL": "https://example.com/greencurry.jpg"}
        ],
        "Tags": [
            {"Name": "Curry"},
            {"Name": "Spicy"}
        ],
        "Variants": [
            {
                "ID": "variant_uuid_2",
                "Name": "Standard",
                "Price": 150.00,
                "IsAvailable": true,
                "Stock": 30
            }
        ],
        "CreatedAt": "2025-10-24T01:05:00Z",
        "UpdatedAt": "2025-10-24T01:05:00Z"
    }
]
```

### Create a Menu Item
- **Endpoint:** `POST /api/vendor/menu`
- **Description:** Use this endpoint to add a new item to your menu. The API supports two formats:
    1.  **Complex Item:** An item with multiple options (e.g., sizes, toppings). This is done by providing a `variants` array.
    2.  **Simple Item:** A straightforward item with no options. This is done by providing fields like `price`, `sku`, etc., at the top level of the request, without a `variants` array.

    **SKU Handling (Hybrid System):**
    - **Automatic Generation:** If you omit the `sku` field for a variant (or for a simple item), the system will automatically generate a unique SKU (e.g., `SKU-xxxxxx`). This is the recommended approach for most cases.
    - **Manual Input:** If you need to use a specific SKU (e.g., to match an existing inventory system), you can provide it in the `sku` field. The system will validate that the provided SKU is unique. If it already exists, the request will fail.
- **Handler:** `handlers.CreateMenuItem`

#### Example 1: Complex Item with Manual SKUs
 
**Request Body:**
```json
{
    "name": "Gaming Keyboard Pro",
    "description": "Mechanical keyboard with RGB lighting.",
    "categoryId": "b2c3d4e5-f6g7-h8i9-j0k1-l2m3n4o5p6q7",
    "imageURLs": [
        "https://example.com/keyboard.jpg"
    ],
    "tags": [
        "gaming",
        "new-arrival"
    ],
    "variants": [
        {
            "name": "Black - Red Switch",
            "price": 89.99,
            "costPrice": 45.00,
            "sku": "GKP-BLK-RED",
            "stock": 150
        },
        {
            "name": "White - Blue Switch",
            "price": 89.99,
            "costPrice": 45.00,
            "sku": "GKP-WHT-BLU",
            "stock": 120
        }
    ]
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/menu \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Gaming Keyboard Pro", "description": "Mechanical keyboard with RGB lighting.", "categoryId": "b2c3d4e5-f6g7-h8i9-j0k1-l2m3n4o5p6q7", "variants": [{"name": "Black - Red Switch", "price": 89.99, "sku": "GKP-BLK-RED", "stock": 150 }, {"name": "White - Blue Switch", "price": 89.99, "sku": "GKP-WHT-BLU", "stock": 120 }] }'
```

#### Example 2: Simple Item with Auto-Generated SKU

**Request Body (omitting `sku`):**
```json
{
    "name": "Iced Americano",
    "description": "Classic iced black coffee.",
    "categoryId": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "imageURLs": ["https://example.com/americano.jpg"],
    "tags": ["coffee", "beverage"],
    "price": 60.00,
    "cost": 25.00,
    "stock_quantity": 100,
    "is_active": true
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/menu \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Iced Americano", "description": "Classic iced black coffee.", "price": 60.00, "stock_quantity": 100}'
```

**Success Response (201 Created):**
```json
{
    "message": "menu item created successfully",
    "menuItem": {
        "ID": "...",
        "Name": "Iced Americano",
        "Variants": [
            {
                "ID": "...",
                "SKU": "SKU-xxxxxx" // Auto-generated SKU
            }
        ] 
    }
}
```

### Update a Menu Item
- **Endpoint:** `PATCH /api/vendor/menu/:menu_id`
- **Description:** This endpoint allows you to modify an existing menu item. You can update its name, description, category, image URLs, tags, and individual variants. When updating a variant's `sku`, the new SKU must be unique across all products in the system.
- **Handler:** `handlers.UpdateMenuItem`

**Request Body:**
```json
{
    "name": "Extra Spicy Basil Chicken",
    "variants": [
        {
            "id": "variant_uuid_to_update",
            "price": 13.00
        }
    ]
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/menu/your_menu_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Extra Spicy Basil Chicken", "variants": [{"id": "variant_uuid_to_update", "price": 13.00}]}'
```

**`curl` Command Explanation:**
*   `-X PATCH`: Specifies the HTTP PATCH method for partially updating a resource.
*   `your_menu_id`: Replace this with the actual ID of the menu item you wish to update.
*   `-d '{...}'`: Contains the JSON request body with the fields to be updated. Only include the fields you wish to modify.

**Success Response (200 OK):**
(Returns the full, updated menu item object)

### Delete a Menu Item
- **Endpoint:** `DELETE /api/vendor/menu/:menu_id`
- **Description:** This endpoint permanently removes a menu item from your restaurant's menu. Deleting a menu item will also remove all its associated variants.
- **Handler:** `handlers.DeleteMenuItem`

**Example `curl`:**
```bash
curl -L -X DELETE http://localhost:8080/api/vendor/menu/your_menu_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X DELETE`: Specifies the HTTP DELETE method for removing a resource.
*   `your_menu_id`: Replace this with the actual ID of the menu item you wish to delete.
*   No `-d` flag is used as DELETE requests typically do not have a request body.

---
**Success Response (200 OK):**
```json
{
    "message": "menu item deleted successfully"
}
```

---

## Add-on Management
These endpoints allow vendors to create, manage, and organize reusable add-on groups and individual add-on items for their menu. Add-on groups can then be attached to menu item variants to offer customization options to customers.

### Create an Add-on Group
- **Endpoint:** `POST /api/vendor/restaurants/:restaurant_id/addon-groups`
- **Description:** Creates a new add-on group for your restaurant. An add-on group defines a collection of customizable options (e.g., "Choose your sauce", "Add toppings").
- **Handler:** `addonHandler.CreateAddonGroup`

**Request Body:**
```json
{
    "name": "Choose your Sauce",
    "description": "Select one or more sauces for your dish.",
    "minSelection": 1,
    "maxSelection": 2
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Choose your Sauce", "description": "Select one or more sauces for your dish.", "minSelection": 1, "maxSelection": 2}'
```

**Success Response (201 Created):**
```json
{
    "ID": "addon_group_uuid",
    "RestaurantID": "restaurant_uuid",
    "Name": "Choose your Sauce",
    "Description": "Select one or more sauces for your dish.",
    "MinSelection": 1,
    "MaxSelection": 2,
    "CreatedAt": "...",
    "UpdatedAt": "..."
}
```

### Get an Add-on Group
- **Endpoint:** `GET /api/vendor/restaurants/:restaurant_id/addon-groups/:addon_group_id`
- **Description:** Retrieves the details of a specific add-on group, including its associated add-on items.
- **Handler:** `addonHandler.GetAddonGroup`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups/your_addon_group_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "ID": "addon_group_uuid",
    "RestaurantID": "restaurant_uuid",
    "Name": "Choose your Sauce",
    "Description": "Select one or more sauces for your dish.",
    "MinSelection": 1,
    "MaxSelection": 2,
    "AddonItems": [
        {
            "ID": "addon_item_uuid_1",
            "Name": "Tomato Sauce",
            "Price": 0.00
        },
        {
            "ID": "addon_item_uuid_2",
            "Name": "Chili Sauce",
            "Price": 0.50
        }
    ],
    "CreatedAt": "...",
    "UpdatedAt": "..."
}
```

### Update an Add-on Group
- **Endpoint:** `PATCH /api/vendor/restaurants/:restaurant_id/addon-groups/:addon_group_id`
- **Description:** Updates the details of an existing add-on group. Only the fields provided in the request body will be modified.
- **Handler:** `addonHandler.UpdateAddonGroup`

**Request Body:**
```json
{
    "description": "Select up to two sauces for your dish.",
    "maxSelection": 2
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups/your_addon_group_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"description": "Select up to two sauces for your dish.", "maxSelection": 2}'
```

**Success Response (200 OK):**
(Returns the updated add-on group object)

### Delete an Add-on Group
- **Endpoint:** `DELETE /api/vendor/restaurants/:restaurant_id/addon-groups/:addon_group_id`
- **Description:** Permanently deletes an add-on group and all its associated add-on items.
- **Handler:** `addonHandler.DeleteAddonGroup`

**Example `curl`:**
```bash
curl -L -X DELETE http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups/your_addon_group_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "Addon group deleted successfully"
}
```

### Create an Add-on Item
- **Endpoint:** `POST /api/vendor/restaurants/:restaurant_id/addon-groups/:addon_group_id/items`
- **Description:** Creates a new add-on item within a specific add-on group.
- **Handler:** `addonHandler.CreateAddonItem`

**Request Body:**
```json
{
    "name": "Extra Cheese",
    "description": "Add an extra layer of cheese.",
    "price": 1.50,
    "isAvailable": true
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups/your_addon_group_id/items \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Extra Cheese", "description": "Add an extra layer of cheese.", "price": 1.50, "isAvailable": true}'
```

**Success Response (201 Created):**
```json
{
    "ID": "addon_item_uuid",
    "AddonGroupID": "addon_group_uuid",
    "Name": "Extra Cheese",
    "Description": "Add an extra layer of cheese.",
    "Price": 1.50,
    "IsAvailable": true,
    "CreatedAt": "...",
    "UpdatedAt": "..."
}
```

### Update an Add-on Item
- **Endpoint:** `PATCH /api/vendor/restaurants/:restaurant_id/addon-groups/:addon_group_id/items/:addon_item_id`
- **Description:** Updates the details of an existing add-on item within a specific add-on group.
- **Handler:** `addonHandler.UpdateAddonItem`

**Request Body:**
```json
{
    "price": 2.00,
    "isAvailable": false
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups/your_addon_group_id/items/your_addon_item_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"price": 2.00, "isAvailable": false}'
```

**Success Response (200 OK):**
(Returns the updated add-on item object)

### Delete an Add-on Item
- **Endpoint:** `DELETE /api/vendor/restaurants/:restaurant_id/addon-groups/:addon_group_id/items/:addon_item_id`
- **Description:** Permanently deletes an add-on item from a specific add-on group.
- **Handler:** `addonHandler.DeleteAddonItem`

**Example `curl`:**
```bash
curl -L -X DELETE http://localhost:8080/api/vendor/restaurants/your_restaurant_id/addon-groups/your_addon_group_id/items/your_addon_item_id \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "Addon item deleted successfully"
}
```

---

## Order Management
These endpoints allow vendors to manage the lifecycle of orders placed with their restaurant, from viewing new orders to updating their status. These operations require the vendor's restaurant to be approved.

### Get Restaurant Orders
- **Endpoint:** `GET /api/vendor/orders`
- **Description:** This endpoint retrieves a list of all orders placed for your restaurant. You can filter the orders by their `status` (e.g., `pending`, `accepted`, `preparing`, `ready_for_pickup`, `delivered`, `rejected`) and paginate through the results using `page` and `limit` query parameters. This is essential for monitoring incoming orders and managing your order queue.
- **Handler:** `handlers.GetRestaurantOrders`

**Example `curl`:**
```bash
curl -L -X GET "http://localhost:8080/api/vendor/orders?status=pending" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X GET`: Specifies the HTTP GET method for retrieving resources.
*   `"http://localhost:8080/api/vendor/orders?status=pending"`: The URL includes a query parameter `status=pending` to filter orders by their status.

**Success Response (200 OK):**
```json
{
    "data": [
        {
            "ID": "order_uuid",
            "UserID": "...",
            "Status": "pending",
            "TotalPrice": 55.00,
            "CreatedAt": "..."
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 1
    }
}
```

### Accept an Order
- **Endpoint:** `POST /api/vendor/orders/:order_id/accept`
- **Description:** Use this endpoint to mark an incoming order as accepted. This typically signals to the customer that their order has been received and will be processed by the restaurant.
- **Handler:** `handlers.AcceptOrder`

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/orders/your_order_id/accept \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method.
*   `your_order_id`: Replace this with the actual ID of the order you wish to accept.
*   No `-d` flag is used as the action is performed via the URL.

**Success Response (200 OK):**
(Returns the updated order object with status "accepted")

### Reject an Order
- **Endpoint:** `POST /api/vendor/orders/:order_id/reject`
- **Description:** This endpoint allows you to reject an incoming order, for example, if an item is out of stock or the restaurant is unexpectedly closed. The customer will be notified of the rejection.
- **Handler:** `handlers.RejectOrder`

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/orders/your_order_id/reject \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method.
*   `your_order_id`: Replace this with the actual ID of the order you wish to reject.
*   No `-d` flag is used as the action is performed via the URL.

**Success Response (200 OK):**
(Returns the updated order object with status "rejected")

### Mark Order as Preparing
- **Endpoint:** `POST /api/vendor/orders/:order_id/prepare`
- **Description:** After accepting an order, use this endpoint to update its status to "preparing". This informs the customer that their food is being made.
- **Handler:** `handlers.PrepareOrder`

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/orders/your_order_id/prepare \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method.
*   `your_order_id`: Replace this with the actual ID of the order you wish to mark as preparing.
*   No `-d` flag is used as the action is performed via the URL.

**Success Response (200 OK):**
(Returns the updated order object with status "preparing")

### Update Order Status
- **Endpoint:** `PATCH /api/vendor/orders/:order_id/status`
- **Description:** This is a general endpoint to update the status of an order to various stages, such as "ready_for_pickup" or "delivered" (if the vendor handles delivery). The new status must be provided in the request body.
- **Handler:** `handlers.UpdateOrderStatusByVendor`

**Request Body:**
```json
{
  "status": "ready_for_pickup"
}
```

**Example `curl`:**
```bash
curl -L -X PATCH http://localhost:8080/api/vendor/orders/your_order_id/status \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "ready_for_pickup"}'
```

**`curl` Command Explanation:**
*   `-X PATCH`: Specifies the HTTP PATCH method for partially updating a resource.
*   `your_order_id`: Replace this with the actual ID of the order you wish to update.
*   `-d '{"status": "ready_for_pickup"}'`: Contains the JSON request body with the new `status` for the order.

---
**Success Response (200 OK):**
(Returns the updated order object)

---

## Discount Management
These endpoints allow vendors to create, manage, and retrieve promotional discounts for their restaurant. These operations require the vendor's restaurant to be approved.

### Create a Discount
- **Endpoint:** `POST /api/vendor/discounts`
- **Description:** Use this endpoint to create a new discount. You can define various properties for the discount, including a unique `code`, `type` (e.g., "percentage" or "fixed_amount"), `value`, minimum order value (`minOrderValue`), `startDate`, `endDate`, and whether the discount is `isActive`. This allows for flexible promotional campaigns.
- **Handler:** `handlers.CreateDiscount`

**Request Body:**
```json
{
    "code": "SUMMER10",
    "type": "percentage",
    "value": 10,
    "minOrderValue": 20.00,
    "startDate": "2025-06-01",
    "endDate": "2025-08-31",
    "isActive": true
}
```

**Example `curl`:**
```bash
curl -L -X POST http://localhost:8080/api/vendor/discounts \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"code": "SUMMER10", "type": "percentage", "value": 10, "minOrderValue": 20.00, "startDate": "2025-06-01", "endDate": "2025-08-31", "isActive": true}'
```

**`curl` Command Explanation:**
*   `-X POST`: Specifies the HTTP POST method for creating a new resource.
*   `-d '{...}'`: Contains the JSON request body with the details of the discount, including its code, type, value, and dates. The full request body is provided in the "Request Body" section above.

**Success Response (201 Created):**
(Returns the newly created discount object)

### Get All Discounts
- **Endpoint:** `GET /api/vendor/discounts`
- **Description:** This endpoint retrieves a list of all discounts associated with your restaurant. This is useful for reviewing active promotions, managing existing discounts, or displaying them to customers.
- **Handler:** `handlers.GetDiscountsByRestaurant`

**Example `curl`:**
```bash
curl -L -X GET http://localhost:8080/api/vendor/discounts \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

**`curl` Command Explanation:**
*   `-X GET`: Specifies the HTTP GET method for retrieving resources.
*   No `-d` flag is used as GET requests typically do not have a request body.

---
**Success Response (200 OK):**
(Returns a list of discount objects)

---

## Analytics & Reporting

These endpoints provide valuable insights into your restaurant's performance, helping you make informed business decisions. These operations require the vendor's restaurant to be approved.

### Get Sales Summary
- **Endpoint:** `GET /api/vendor/analytics/summary`
- **Description:** Provides a high-level summary of your restaurant's sales performance, including total revenue, total orders, and average order value.
- **Handler:** `handlers.GetAnalyticsSummary`
- **Example `curl`:**
  ```bash
  curl -L -X GET "http://localhost:8080/api/vendor/analytics/summary?period=week" \
    -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
  ```
- **Success Response (200 OK):**
  ```json
  {
      "total_revenue": 12550.75,
      "total_orders": 350,
      "average_order_value": 35.86
  }
  ```

### Get Financial Summary
- **Endpoint:** `GET /api/vendor/analytics/financial-summary`
- **Description:** Retrieves a comprehensive financial overview, including total revenue, total payouts, pending payouts, and the current balance (Revenue - Payouts).
- **Handler:** `handlers.GetFinancialSummary`
- **Example `curl`:**
  ```bash
  curl -L -X GET http://localhost:8080/api/vendor/analytics/financial-summary \
    -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
  ```
- **Success Response (200 OK):**
  ```json
  {
      "total_revenue": 50000.00,
      "total_payouts": 42000.00,
      "balance": 8000.00,
      "pending_payouts": 3000.00
  }
  ```

### Get Revenue Over Time
- **Endpoint:** `GET /api/vendor/analytics/revenue-over-time`
- **Description:** Provides a time-series breakdown of revenue. Aggregate by `day`, `week`, or `month` using the `period` query parameter.
- **Handler:** `handlers.GetRevenueOverTime`
- **Example `curl`:**
  ```bash
  curl -L -X GET "http://localhost:8080/api/vendor/analytics/revenue-over-time?period=day&filter_period=month" \
    -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
  ```
- **Success Response (200 OK):**
  ```json
  [
      { "date": "2025-10-20T00:00:00Z", "revenue": 1500.50 },
      { "date": "2025-10-21T00:00:00Z", "revenue": 1800.00 }
  ]
  ```

### Get Popular Items
- **Endpoint:** `GET /api/vendor/analytics/popular-items`
- **Description:** Identifies best-selling menu items. Use `?limit=5` to control the number of items returned.
- **Handler:** `handlers.GetPopularItems`
- **Example `curl`:**
  ```bash
  curl -L -X GET "http://localhost:8080/api/vendor/analytics/popular-items?limit=5" \
    -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
  ```
- **Success Response (200 OK):**
  ```json
  [
      { "menu_item_name": "Margherita Pizza", "total_quantity_sold": 120, "total_revenue": 4200 }
  ]
  ```

### Get Restaurant Transactions
- **Endpoint:** `GET /api/vendor/analytics/transactions`
- **Description:** Retrieves a paginated list of all orders (transactions). Filter by `period` (`today`, `week`, `month`) and use `page` and `limit` for pagination.
- **Handler:** `handlers.GetRestaurantTransactions`
- **Example `curl`:**
  ```bash
  curl -L -X GET "http://localhost:8080/api/vendor/analytics/transactions?period=month&page=1&limit=5" \
    -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
  ```
- **Success Response (200 OK):**
  ```json
  {
      "data": [
          { "ID": "order_uuid_1", "Status": "delivered", "TotalPrice": 25.50, "CreatedAt": "2025-11-18T10:00:00Z" }
      ],
      "pagination": { "currentPage": 1, "totalPages": 10, "totalItems": 50 }
  }
  ```

### Get Payout History
- **Endpoint:** `GET /api/vendor/analytics/payout-history`
- **Description:** Retrieves a paginated list of all payout requests and their statuses. Use `page` and `limit` for pagination.
- **Handler:** `handlers.GetPayoutHistory`
- **Example `curl`:**
  ```bash
h
  curl -L -X GET "http://localhost:8080/api/vendor/analytics/payout-history?page=1&limit=10" \
    -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
  ```
- **Success Response (200 OK):**
  ```json
  {
      "data": [
          {
              "ID": "payout_uuid_1",
              "RestaurantID": "restaurant_uuid",
              "Amount": 100.00,
              "Status": "approved",
              "RequestedAt": "2025-11-15T09:00:00Z",
              "ProcessedAt": "2025-11-16T10:00:00Z"
          }
      ],
      "pagination": { "currentPage": 1, "totalPages": 2, "totalItems": 15 }
  }
  ```

---

## Review Management

These endpoints allow vendors to manage customer reviews for their restaurant, specifically to reply to them. These operations require the vendor's restaurant to be approved.





### Reply to a Customer Review



- **Endpoint:** `POST /api/vendor/reviews/:review_id/reply`



- **Description:** This endpoint allows an approved vendor to post a public reply to a specific customer review for their restaurant. This helps in engaging with customers and addressing feedback.



- **Handler:** `reviewHandler.ReplyToReview`





**Request Body:**



```json



{



    "reply": "Thank you for your feedback! We appreciate your business and hope to see you again soon."



}



```





**Example `curl`:**



```bash



curl -L -X POST http://localhost:8080/api/vendor/reviews/your_review_id/reply \



  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \



  -H "Content-Type: application/json" \



  -d '{"reply": "Thank you for your feedback! We appreciate your business and hope to see you again soon."}'



```





**`curl` Command Explanation:**



*   `-X POST`: Specifies the HTTP POST method for creating a new resource (in this case, a reply).



*   `your_review_id`: Replace this with the actual ID of the review you wish to reply to.



*   `-d '{...}'`: Contains the JSON request body with the `reply` text.





**Success Response (200 OK):**



```json



{



    "ID": "review_uuid",



    "UserID": "user_uuid",



    "RestaurantID": "restaurant_uuid",



    "Rating": 5,



    "Comment": "Great food and service!",



    "Reply": "Thank you for your feedback! We appreciate your business and hope to see you again soon.",



    "RepliedAt": "2025-11-17T12:30:00Z",



    "CreatedAt": "2025-11-16T10:00:00Z",



    "UpdatedAt": "2025-11-17T12:30:00Z"



}



```





**Error Response (403 Forbidden):**



```json



{



    "error": "you can only reply to reviews for your own restaurant"



}



```



---



## Staff Management



These endpoints allow vendors to manage their restaurant staff, including creating new staff members, viewing existing staff, updating their roles, and removing them. These operations require the vendor's restaurant to be approved.



### Create a Staff Member

- **Endpoint:** `POST /api/vendor/staff`

- **Description:** Creates a new staff member and associates them with your restaurant. A new user account will be created for the staff member if one doesn't already exist with the provided email.

- **Handler:** `staffHandler.CreateStaff`



**Request Body:**

```json

{

    "name": "John Doe",

    "email": "john.doe@example.com",

    "password": "strong_password",

    "role": "manager"

}

```



**Example `curl`:**

```bash

curl -L -X POST http://localhost:8080/api/vendor/staff \

  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \

  -H "Content-Type: application/json" \

  -d '{"name": "John Doe", "email": "john.doe@example.com", "password": "strong_password", "role": "manager"}'

```



**Success Response (201 Created):**

(Returns the newly created staff member object)



---





### Get All Staff Members

- **Endpoint:** `GET /api/vendor/staff`

- **Description:** Retrieves a list of all staff members associated with your restaurant.

- **Handler:** `staffHandler.GetStaff`



**Example `curl`:**

```bash

curl -L -X GET http://localhost:8080/api/vendor/staff \

  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"

```



**Success Response (200 OK):**

(Returns a list of staff member objects)



---





### Update a Staff Member

- **Endpoint:** `PATCH /api/vendor/staff/:staff_id`

- **Description:** Updates the details of a specific staff member, such as their name or role.

- **Handler:** `staffHandler.UpdateStaff`



**Request Body (Example):**

```json

{

    "name": "Jane Doe",

    "role": "kitchen_staff"

}

```



**Example `curl`:**

```bash

curl -L -X PATCH http://localhost:8080/api/vendor/staff/your_staff_id \

  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \

  -H "Content-Type: application/json" \

  -d '{"name": "Jane Doe", "role": "kitchen_staff"}'

```



**Success Response (200 OK):**

(Returns the updated staff member object)



---





### Delete a Staff Member

- **Endpoint:** `DELETE /api/vendor/staff/:staff_id`

- **Description:** Removes a staff member's association with your restaurant. This is a soft delete and does not remove the underlying user account.

- **Handler:** `staffHandler.DeleteStaff`



**Example `curl`:**

```bash

curl -L -X DELETE http://localhost:8080/api/vendor/staff/your_staff_id \

  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"

```



**Success Response (200 OK):**

```json

{

    "message": "staff member deleted successfully"

}

```