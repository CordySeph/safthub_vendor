# Restaurant API Usage Guide

This guide provides comprehensive instructions for using all restaurant-related APIs in the backend system. The APIs are organized by user role and functionality.

## Table of Contents
- [Authentication](#authentication)
- [Public Restaurant APIs](#public-restaurant-apis)
- [User Restaurant APIs](#user-restaurant-apis)
- [Vendor Restaurant APIs](#vendor-restaurant-apis)
- [Admin Restaurant APIs](#admin-restaurant-apis)

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <YOUR_JWT_TOKEN>
```

### Get JWT Token
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-email@example.com",
    "password": "your-password"
  }'
```

## Public Restaurant APIs

These endpoints are accessible without authentication.

### List and Filter Restaurants
**Endpoint:** `GET /api/public/restaurants`

Retrieves a paginated list of all approved restaurants with advanced filtering options.

**Query Parameters:**
- `page` (optional): Page number, defaults to `1`
- `limit` (optional): Items per page, defaults to `10`
- `category` (optional): Filter by category (e.g., "Thai", "Italian")
- `tag` (optional): Filter by menu item tag (e.g., "Pizza", "Vegan")
- `name` (optional): Search by restaurant name (case-insensitive)
- `min_rating` (optional): Minimum rating filter
- `price_range` (optional): Price range filter ("$", "$$", "$$$")
- `latitude` & `longitude` (optional): User location for distance sorting
- `radius_km` (optional): Filter restaurants within radius
- `has_promotions` (optional): Show restaurants with active promotions
- `sort_by` (optional): Sort by `rating`, `price`, or `distance`
- `sort_order` (optional): `asc` or `desc`

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/public/restaurants?category=Italian&min_rating=4.5&sort_by=rating"
```

### Search Restaurants
**Endpoint:** `GET /api/search/restaurants`

Advanced restaurant search with flexible criteria.

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/search/restaurants?name=ร้านยำปูม้าเจ๊แหม่ม"
```

### Get Restaurant Details by ID
**Endpoint:** `GET /api/restaurants/:id`

Retrieves detailed information for a specific restaurant.

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/restaurants/bc462ade-9b4e-4750-8ad7-2d75ba363006"
```

## User Restaurant APIs

These endpoints require user authentication (role: "user").

### Favorite Restaurants Management

#### Add Restaurant to Favorites
**Endpoint:** `POST /api/auth/restaurants/:restaurant_id/favorite`

```bash
curl -X POST http://localhost:8080/api/auth/restaurants/bc462ade-9b4e-4750-8ad7-2d75ba363006/favorite \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

#### Remove Restaurant from Favorites
**Endpoint:** `DELETE /api/auth/restaurants/:restaurant_id/favorite`

```bash
curl -X DELETE http://localhost:8080/api/auth/restaurants/bc462ade-9b4e-4750-8ad7-2d75ba363006/favorite \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

#### Get Favorite Restaurants
**Endpoint:** `GET /api/auth/favorites`

```bash
curl -X GET http://localhost:8080/api/auth/favorites \
  -H "Authorization: Bearer <YOUR_USER_JWT_TOKEN>"
```

## Vendor Restaurant APIs

These endpoints require vendor authentication (role: "vendor").

### Register a Restaurant
**Endpoint:** `POST /api/vendor/register-store`

Submit a new restaurant for approval. The restaurant location must be within a service zone.

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

**Example Request:**
```bash
curl -X POST http://localhost:8080/api/vendor/register-store \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Delicious Eats Restaurant",
    "address": "123 Sukhumvit Road, Bangkok 10110",
    "latitude": 13.736717,
    "longitude": 100.539800,
    "category": "Thai, Fusion",
    "price_range": "$$"
  }'
```

### Get My Restaurant
**Endpoint:** `GET /api/vendor/my-restaurant`

Retrieve complete profile details of your registered restaurant.

```bash
curl -X GET http://localhost:8080/api/vendor/my-restaurant \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

### Update My Restaurant
**Endpoint:** `PATCH /api/vendor/my-restaurant`

Update specific restaurant details. Only send fields you want to modify.

**Request Body Example:**
```json
{
    "phone_number": "0998887777",
    "description": "The best authentic Thai food in town.",
    "price_range": "$$$",
    "cover_photo_url": "https://example.com/new_cover.jpg"
}
```

**Example Request:**
```bash
curl -X PATCH http://localhost:8080/api/vendor/my-restaurant \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "0998887777",
    "price_range": "$$$",
    "cover_photo_url": "https://example.com/new_cover.jpg"
  }'
```

### Set Temporary Closure
**Endpoint:** `PATCH /api/vendor/my-restaurant/closure`

Temporarily close or reopen your restaurant.

**Request Body:**
```json
{
    "is_closed": true,
    "reason": "Staff holiday"
}
```

**Example Request:**
```bash
curl -X PATCH http://localhost:8080/api/vendor/my-restaurant/closure \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"is_closed": true, "reason": "Staff holiday"}'
```

### Get Restaurant Orders
**Endpoint:** `GET /api/vendor/orders`

Retrieve orders for your restaurant with optional status filtering.

**Query Parameters:**
- `status` (optional): Filter by order status (e.g., "pending", "confirmed", "preparing", "ready", "delivering", "completed", "cancelled")

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/vendor/orders?status=pending" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

## Admin Restaurant APIs

These endpoints require admin authentication (role: "admin").

### Get Pending Restaurants
**Endpoint:** `GET /api/admin/restaurants/pending`

Retrieve restaurants awaiting admin approval.

```bash
curl -X GET "http://localhost:8080/api/admin/restaurants/pending" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

### Approve Restaurant
**Endpoint:** `POST /api/admin/restaurants/:id/approve`

Approve a pending restaurant.

```bash
curl -X POST "http://localhost:8080/api/admin/restaurants/bc462ade-9b4e-4750-8ad7-2d75ba363006/approve" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

### Reject Restaurant
**Endpoint:** `POST /api/admin/restaurants/:id/reject`

Reject a pending restaurant.

```bash
curl -X POST "http://localhost:8080/api/admin/restaurants/bc462ade-9b4e-4750-8ad7-2d75ba363006/reject" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

### Get Top Restaurants Analytics
**Endpoint:** `GET /api/admin/analytics/top-restaurants`

Get top 10 performing restaurants by revenue.

```bash
curl -X GET "http://localhost:8080/api/admin/analytics/top-restaurants" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

### Generate Revenue Report by Restaurant
**Endpoint:** `POST /api/admin/reports/revenue`

Generate CSV report of revenue aggregated by restaurant.

**Request Body:**
```json
{
    "start_date": "2025-01-01",
    "end_date": "2025-01-31"
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8080/api/admin/reports/revenue" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "start_date": "2025-01-01",
    "end_date": "2025-01-31"
  }'
```

## Common Response Formats

### Success Response (200 OK)
```json
{
    "data": [
        {
            "ID": "restaurant-uuid",
            "Name": "Restaurant Name",
            "Category": "Thai",
            "Rating": 4.5,
            "PriceRange": "$$",
            "Address": "123 Street, City",
            "IsOpen": true,
            "Status": "approved"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 5,
        "totalItems": 50
    }
}
```

### Error Response (400/404/401)
```json
{
    "error": "ERROR_CODE",
    "message": "Human readable error message"
}
```

## Common Error Codes

- `LOCATION_NOT_SERVICED`: Restaurant location is not within any service zone
- `UNAUTHORIZED`: Invalid or missing JWT token
- `FORBIDDEN`: User doesn't have permission for this action
- `NOT_FOUND`: Restaurant not found
- `VALIDATION_ERROR`: Invalid request data

## Tips for Developers

1. **Always include the JWT token** in Authorization headers for protected endpoints
2. **Use the correct user role** when registering users (user, vendor, admin)
3. **Handle pagination** for list endpoints using `page` and `limit` parameters
4. **Validate coordinates** - ensure latitude and longitude are within valid ranges
5. **Check restaurant status** - only approved restaurants appear in public listings
6. **Use appropriate HTTP methods** - GET for retrieval, POST for creation, PATCH for updates, DELETE for removal

## Testing the APIs

Use the provided curl examples to test each endpoint. Make sure to:
1. Replace placeholder values with actual data
2. Use valid JWT tokens for authentication
3. Ensure the server is running on `http://localhost:8080`
4. Handle CORS if testing from browsers

For comprehensive testing, consider using API testing tools like Postman or Insomnia, which allow you to save authentication tokens and create test collections.
