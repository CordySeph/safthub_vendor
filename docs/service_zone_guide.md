# Service Zone Management Guide

This document provides a guide for administrators to manage service zones. A service zone is a geographical area where the platform operates. Restaurants can only be registered if their location falls within one of these defined zones.

All endpoints are prefixed with `/api/admin/service-zones` and require authentication with a JWT token for a user with the `admin` role and the `service-zones:manage` permission.

## Table of Contents
- [Create a Service Zone](#create-a-service-zone)
- [List All Service Zones](#list-all-service-zones)
- [Update a Service Zone](#update-a-service-zone)
- [Delete a Service Zone](#delete-a-service-zone)

---

## Create a Service Zone
Creates a new geographical area of service.

- **Endpoint:** `POST /api/admin/service-zones`
- **Permission:** `service-zones:manage`
- **Request Body (JSON):**
  - `name` (string, required): The name of the service zone (e.g., "Central Business District").
  - `polygon_wkt` (string, required): The geographical boundary in Well-Known Text (WKT) format for a `POLYGON`. Example: "POLYGON((100.5 13.7, 100.6 13.7, 100.6 13.8, 100.5 13.8, 100.5 13.7))"
  - `avg_radius` (float, optional): The average radius in kilometers associated with the service zone.

**Example `curl` Request:**
```bash
curl -X POST "http://localhost:8080/api/admin/service-zones" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Downtown Area",
    "polygon_wkt": "POLYGON((100.50 13.75, 100.55 13.75, 100.55 13.80, 100.50 13.80, 100.50 13.75))",
    "avg_radius": 5.0
  }'
```

**Success Response (201 Created):**
```json
{
    "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "Name": "Downtown Area",
    "Polygon": { ... },
    "AvgRadius": 5.0,
    "CreatedAt": "2025-11-20T10:00:00Z",
    "UpdatedAt": "2025-11-20T10:00:00Z"
}
```

---

## List All Service Zones
Retrieves a list of all currently defined service zones.

- **Endpoint:** `GET /api/admin/service-zones`
- **Permission:** `service-zones:manage`

**Example `curl` Request:**
```bash
curl -X GET "http://localhost:8080/api/admin/service-zones" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
[
    {
        "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "Name": "Downtown Area",
        "Polygon": { ... },
        "AvgRadius": 5.0,
        "CreatedAt": "2025-11-20T10:00:00Z",
        "UpdatedAt": "2025-11-20T10:00:00Z"
    }
]
```

---

## Update a Service Zone
Updates an existing service zone's name or average radius. Note: The polygon itself cannot be updated via this endpoint; you would need to delete and recreate the zone.

- **Endpoint:** `PATCH /api/admin/service-zones/:id`
- **Permission:** `service-zones:manage`
- **Request Body (JSON):**
  - `name` (string, optional): The new name for the service zone.
  - `avg_radius` (float, optional): The new average radius for the service zone.

**Example `curl` Request:**
```bash
curl -X PATCH "http://localhost:8080/api/admin/service-zones/<zone-id>" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Downtown Area"
  }'
```

**Success Response (200 OK):**
```json
{
    "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "Name": "Updated Downtown Area",
    "Polygon": { ... },
    "AvgRadius": 5.0,
    "CreatedAt": "2025-11-20T10:00:00Z",
    "UpdatedAt": "2025-11-20T10:15:00Z"
}
```

---

## Delete a Service Zone
Permanently deletes a service zone by its ID.

- **Endpoint:** `DELETE /api/admin/service-zones/:id`
- **Permission:** `service-zones:manage`

**Example `curl` Request:**
```bash
curl -X DELETE "http://localhost:8080/api/admin/service-zones/<zone-id>" \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

**Success Response (204 No Content):**
(No content is returned for a successful deletion.)

```