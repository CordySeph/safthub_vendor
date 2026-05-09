# Inventory API Usage Guide

This guide provides instructions for using the Inventory Management System APIs. These endpoints allow vendors to manage their restaurant's stock levels, track history, and set up low-stock alerts.

## Base Path & Authentication

- **Base Path:** `/api/vendor/inventory`
- **Authentication:** All endpoints require a JWT token for a user with the `vendor` role for an approved restaurant.
- **Header:** `Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>`

---

## 1. Batch Update Stock

*   **Endpoint:** `PATCH /batch-update`
*   **Description:** Updates stock levels for multiple menu items (or variants) in a single request.
*   **Permissions:** Requires `menu:manage` staff permission.

### Example `curl`
```bash
curl -X PATCH http://localhost:8080/api/vendor/inventory/batch-update \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "updates": [
      {
        "menu_item_id": "1e6d10df-9b51-4f1b-a3b7-a0da6666aee9",
        "variant_id": "ab22c6f6-6ffd-46dd-9695-ef5f40852ddf",
        "stock": 45,
        "reason": "Sale recorded"
      }
    ]
  }'
```

---

## 2. Update Single Item Stock

*   **Endpoint:** `PATCH /:menu_item_id/stock`
*   **Description:** Updates the stock level for a specific menu item.
*   **Permissions:** Requires `menu:manage` staff permission.

### Example `curl`
```bash
curl -X PATCH http://localhost:8080/api/vendor/inventory/<menu_item_id>/stock \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "variant_id": "ab22c6f6-6ffd-46dd-9695-ef5f40852ddf",
    "stock": 30,
    "reason": "Restock"
  }'
```

---

## 3. Get Inventory Status

*   **Endpoint:** `GET /`
*   **Description:** Retrieves current stock levels for all items in the restaurant.
*   **Query Parameters:**
    *   `low_stock` (boolean, optional): Filter items with low stock.
    *   `out_of_stock` (boolean, optional): Filter out-of-stock items.
    *   `search` (string, optional): Search keyword.
    *   `page` (int, optional): Page number.
    *   `limit` (int, optional): Items per page.

### Example `curl`
```bash
curl -X GET "http://localhost:8080/api/vendor/inventory/?low_stock=true&page=1&limit=50" \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

---

## 4. Inventory History

*   **Endpoint:** `GET /history/:menu_item_id`
*   **Description:** Retrieves the change history for a specific menu item.

### Example `curl`
```bash
curl -X GET http://localhost:8080/api/vendor/inventory/history/<menu_item_id> \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

---

## 5. Alerts & Notifications

### Get Inventory Alerts
*   **Endpoint:** `GET /alerts`
*   **Description:** Retrieves all low-stock or out-of-stock alerts.

### Example `curl`
```bash
curl -X GET http://localhost:8080/api/vendor/inventory/alerts \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

### Mark Alert as Read
*   **Endpoint:** `PATCH /alerts/:alert_id/read`
*   **Description:** Marks a single alert as read.

### Example `curl`
```bash
curl -X PATCH http://localhost:8080/api/vendor/inventory/alerts/<alert_id>/read \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

### Mark All Alerts as Read
*   **Endpoint:** `PATCH /alerts/read-all`
*   **Description:** Marks all pending alerts as read.

### Example `curl`
```bash
curl -X PATCH http://localhost:8080/api/vendor/inventory/alerts/read-all \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

---

## 6. Alert Settings

### Get Alert Settings
*   **Endpoint:** `GET /alerts/settings`
*   **Description:** Retrieves the vendor's inventory alert preferences.

### Example `curl`
```bash
curl -X GET http://localhost:8080/api/vendor/inventory/alerts/settings \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>"
```

### Update Alert Settings
*   **Endpoint:** `PUT /alerts/settings`
*   **Description:** Updates the low-stock/out-of-stock thresholds and notification methods.

### Example `curl`
```bash
curl -X PUT http://localhost:8080/api/vendor/inventory/alerts/settings \
  -H "Authorization: Bearer <YOUR_VENDOR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "low_stock_threshold": 15,
    "out_of_stock_threshold": 0,
    "notification_methods": ["websocket", "email"],
    "is_enabled": true
  }'
```
