# Platform Analytics Guide

This document provides a guide for administrators to interact with the platform analytics endpoints. All endpoints are prefixed with `/api/admin` and require authentication with a JWT token for a user with the `admin` role and appropriate permissions.

---

## Endpoints

### Get Platform Summary
- **Endpoint:** `GET /api/admin/analytics/summary`
- **Permission:** `analytics:view`
- **Description:** Retrieves a high-level summary of the entire platform's data. You can filter the "new sign-ups" data by providing a `period` query parameter.
- **Query Parameters:**
  - `period` (optional): `today`, `week`, `month`. If omitted, defaults to `all_time` and new sign-up counts will be zero.
- **Handler:** `handlers.GetPlatformSummary`

**Example `curl` (for last 7 days):**
```bash
curl -X GET "http://localhost:8080/api/admin/analytics/summary?period=week" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "total_revenue": 125500.75,
    "total_orders": 3500,
    "total_users": 1200,
    "total_restaurants": 150,
    "total_riders": 250,
    "new_users": 75,
    "new_restaurants": 12,
    "new_riders": 25
}
```
