## Table of Contents
- [Authentication](#authentication)
- [Rider Profile & Status](#rider-profile--status)
- [Vehicle Management](#vehicle-management)
- [Order (Job) Management](#order-job-management)
- [Wallet](#wallet)
- [Earnings](#earnings)
- [Admin](#admin)

---

## Authentication

These endpoints are for rider registration and login. They are grouped under the `/v2/riders` prefix and do not require a JWT token.

### Register as a New Rider
- **Endpoint:** `POST /v2/riders/register`
- **Description:** Allows a new user to register as a rider. Their account will be created with a `pending_approval` status and will require an administrator's approval before they can log in and use the service.
- **Handler:** `riderAuthHandler.Register`

**Request Body:**
```json
{
    "name": "John Doe",
    "phoneNumber": "+1234567890",
    "email": "john.doe@example.com",
    "password": "your_strong_password"
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/v2/riders/register \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "phoneNumber": "+1234567890", "email": "john.doe@example.com", "password": "your_strong_password"}'
```

**Success Response (201 Created):**
```json
{
    "message": "Rider registered successfully. Waiting for approval.",
    "riderID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6"
}
```

### Login
- **Endpoint:** `POST /v2/riders/login`
- **Description:** Authenticates an approved rider and returns a JWT (JSON Web Token) for accessing protected routes.
- **Handler:** `riderAuthHandler.Login`

**Request Body:**
```json
{
    "email": "john.doe@example.com",
    "password": "your_strong_password"
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/v2/riders/login \
  -H "Content-Type: application/json" \
  -d '{"email": "john.doe@example.com", "password": "your_strong_password"}'
```

**Success Response (200 OK):**
```json
{
    "token": "your.jwt.token"
}
```

---

## Rider Profile & Status

All endpoints in this section are prefixed with `/rider` and require an authenticated rider's JWT token in the `Authorization` header.

```
Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>
```

### Get My Rider Profile
- **Endpoint:** `GET /rider/me/profile`
- **Description:** Retrieves the detailed profile of the authenticated rider.
- **Handler:** `riderHandler.GetMyRiderProfile`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/me/profile \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "name": "John Doe",
    "phoneNumber": "+1234567890",
    "email": "john.doe@example.com",
    "isApproved": true,
    "status": "offline",
    "location": {
        "lat": 13.736717,
        "lon": 100.5398
    }
}
```

### Update Rider Status
- **Endpoint:** `PUT /rider/status`
- **Description:** Updates the rider's current status. Valid statuses are `offline`, `available`, `on_delivery`.
- **Handler:** `riderHandler.UpdateStatus`

**Request Body:**
```json
{
    "status": "available"
}
```

**Example `curl`:**
```bash
curl -X PUT http://localhost:8080/api/rider/status \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "available"}'
```

**Success Response (200 OK):**
```json
{
    "message": "Status updated successfully"
}
```

### Update Rider Location
- **Endpoint:** `PUT /rider/location`
- **Description:** Updates the rider's current geographical location.
- **Handler:** `riderHandler.UpdateLocation`

**Request Body:**
```json
{
    "lat": 13.736717,
    "lon": 100.539800
}
```

**Example `curl`:**
```bash
curl -X PUT http://localhost:8080/api/rider/location \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"lat": 13.736717, "lon": 100.539800}'
```

**Success Response (200 OK):**
```json
{
    "message": "Location updated successfully"
}
```

### Get My Performance Summary
- **Endpoint:** `GET /rider/performance/summary`
- **Description:** Retrieves the authenticated rider's performance summary, including average rating, total reviews, and recent feedback.
- **Handler:** `riderHandler.GetMyPerformanceSummary`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/performance/summary \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "average_rating": 4.5,
    "total_reviews": 120,
    "recent_reviews": [
        {
            "id": "review-uuid-1",
            "order_id": "order-uuid-1",
            "user_id": "user-uuid-1",
            "rider_id": "rider-uuid-1",
            "rating": 5,
            "comment": "Excellent service, very fast!",
            "created_at": "2025-11-16T14:30:00Z"
        },
        {
            "id": "review-uuid-2",
            "order_id": "order-uuid-2",
            "user_id": "user-uuid-2",
            "rider_id": "rider-uuid-1",
            "rating": 4,
            "comment": "Good delivery, polite rider.",
            "created_at": "2025-11-15T18:00:00Z"
        }
    ]
}
```

### Set Availability
- **Endpoint:** `PATCH /rider/availability`
- **Description:** Sets the rider's availability to online or offline.
- **Handler:** `riderHandler.SetAvailability`

**Request Body:**
```json
{
    "is_online": true
}
```

**Example `curl`:**
```bash
curl -X PATCH http://localhost:8080/api/rider/availability \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"is_online": true}'
```

**Success Response (200 OK):**
```json
{
    "message": "Availability updated successfully"
}
```

---

## Vehicle Management

Endpoints for managing the rider's vehicle information, prefixed with `/rider/my-vehicle`.

### Register My Vehicle
- **Endpoint:** `POST /rider/my-vehicle`
- **Description:** Allows an authenticated rider to register their vehicle details.
- **Handler:** `vehicleHandler.CreateVehicle`

**Request Body:**
```json
{
    "vehicleType": "motorcycle",
    "licensePlate": "ABC-1234",
    "model": "Honda Click",
    "color": "Red"
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/my-vehicle \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"vehicleType": "motorcycle", "licensePlate": "ABC-1234", "model": "Honda Click", "color": "Red"}'
```

**Success Response (201 Created):**
```json
{
    "ID": "v1-uuid-v1-uuid-v1",
    "RiderID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "VehicleType": "motorcycle",
    "LicensePlate": "ABC-1234",
    "Model": "Honda Click",
    "Color": "Red",
    "Status": "pending"
}
```

### Get My Vehicle Details
- **Endpoint:** `GET /rider/my-vehicle`
- **Description:** Retrieves the details of the authenticated rider's registered vehicle.
- **Handler:** `vehicleHandler.GetMyVehicle`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/my-vehicle \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "ID": "v1-uuid-v1-uuid-v1",
    "RiderID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "VehicleType": "motorcycle",
    "LicensePlate": "ABC-1234",
    "Model": "Honda Click",
    "Color": "Red",
    "Status": "approved"
}
```

### Update My Vehicle Details
- **Endpoint:** `PATCH /rider/my-vehicle`
- **Description:** Updates the details of the authenticated rider's registered vehicle.
- **Handler:** `vehicleHandler.UpdateMyVehicle`

**Request Body:**
```json
{
    "color": "Blue",
    "model": "Honda Wave"
}
```

**Example `curl`:**
```bash
curl -X PATCH http://localhost:8080/api/rider/my-vehicle \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"color": "Blue", "model": "Honda Wave"}'
```

**Success Response (200 OK):**
```json
{
    "ID": "v1-uuid-v1-uuid-v1",
    "RiderID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "VehicleType": "motorcycle",
    "LicensePlate": "ABC-1234",
    "Model": "Honda Wave",
    "Color": "Blue",
    "Status": "approved"
}
```

### Delete My Vehicle
- **Endpoint:** `DELETE /rider/my-vehicle/:vehicle_id`
- **Description:** Deletes the authenticated rider's registered vehicle.
- **Handler:** `riderHandler.DeleteMyVehicle`

**Path Parameters:**
- `vehicle_id` (string): The ID of the vehicle to delete.

**Example `curl`:**
```bash
curl -X DELETE http://localhost:8080/api/rider/my-vehicle/v1-uuid-v1-uuid-v1 \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "Vehicle deleted successfully"
}
```

---

## Order (Job) Management

Endpoints for finding and managing delivery jobs, prefixed with `/rider/orders`.

### Get Available Jobs
- **Endpoint:** `GET /rider/orders/available`
- **Description:** Retrieves a list of orders that are ready for pickup and available for delivery.
- **Handler:** `riderHandler.GetAvailableJobs`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/orders/available \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
[
    {
        "ID": "order-uuid-1",
        "RestaurantID": "restaurant-uuid-1",
        "DeliveryAddress": "123 Customer Rd, Bangkok",
        "TotalPrice": 450.00,
        "Status": "ready_for_pickup"
    }
]
```

### Get My Order History
- **Endpoint:** `GET /rider/orders/history`
- **Description:** Retrieves a list of the authenticated rider's completed orders, including earnings per trip and distance traveled.
- **Handler:** `riderHandler.GetMyOrderHistory`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/orders/history \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
[
    {
        "ID": "order-uuid-2",
        "RestaurantID": "restaurant-uuid-2",
        "DeliveryAddress": "456 Customer Ave, Bangkok",
        "TotalPrice": 300.00,
        "DeliveryFee": 50.00,
        "DistanceTraveled": 5.2,
        "Status": "delivered",
        "CreatedAt": "2025-11-16T15:00:00Z"
    }
]
```

### Accept a Job
- **Endpoint:** `POST /rider/orders/:order_id/accept`
- **Description:** Assigns the authenticated rider to an available order.
- **Handler:** `riderHandler.AcceptOrder`

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/orders/order-uuid-1/accept \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "Order accepted successfully"
}
```

### Reject a Job
- **Endpoint:** `POST /rider/orders/:order_id/reject`
- **Description:** Allows a rider to reject a job they were offered.
- **Handler:** `riderHandler.RejectOrder`

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/orders/order-uuid-1/reject \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "message": "Order rejected successfully"
}
```

### Update Order Status
- **Endpoint:** `PATCH /rider/orders/:order_id/status`
- **Description:** Allows the rider to update the status of an order they have accepted. Valid statuses include: `picked_up`, `delivering`, `delivered`.
- **Handler:** `riderHandler.UpdateOrderStatusByRider`

**Request Body:**
```json
{
    "status": "picked_up"
}
```

**Example `curl`:**
```bash
curl -X PATCH http://localhost:8080/api/rider/orders/order-uuid-1/status \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"status": "picked_up"}'
```

**Success Response (200 OK):**
```json
{
    "message": "Order status updated successfully"
}
```

### Get Order Route
- **Endpoint:** `GET /rider/orders/:order_id/route`
- **Description:** Retrieves the optimized route for an accepted order. It calculates two separate routes: one from the rider's current location to the restaurant, and a second from the restaurant to the customer's delivery address.
- **Handler:** `riderHandler.GetOrderRoute`

**Path Parameters:**
- `order_id` (string): The ID of the order for which to calculate the route.

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/orders/your-order-id/route \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "route_to_customer": {
        "geometry": "encoded_polyline_string_2",
        "duration": "15m30s",
        "distance": 5200.5
    },
    "route_to_restaurant": {
        "geometry": "encoded_polyline_string_1",
        "duration": "8m15s",
        "distance": 2100.0
    }
}
```
**Error Response (400 Bad Request):**
```json
{
    "error": "Rider's current location not available. Please update your location."
}
```

### WebSocket Notifications for Job Discovery
Riders can connect to a WebSocket endpoint to receive real-time notifications for new job assignments and updates.

- **Endpoint:** `GET /ws/rider`
- **Description:** Establishes a WebSocket connection for real-time job notifications. Requires an authenticated rider's JWT token.
- **Handler:** `handlers.ServeRiderWs`

**Connection Example (JavaScript):**
```javascript
const riderToken = "<YOUR_RIDER_JWT_TOKEN>";
const ws = new WebSocket(`ws://localhost:8080/api/ws/rider?token=${riderToken}`);

ws.onopen = () => {
    console.log("Connected to rider WebSocket");
};

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log("Received message:", data);
    if (data.type === "NEW_JOB_ASSIGNMENT") {
        alert(`New Job Assigned: Order ${data.orderId.substring(0, 8)} - ${data.message}`);
        // Further logic to display job details in UI
    } else if (data.type === "JOB_REJECTED") {
        alert(`Job Rejected: Order ${data.orderId.substring(0, 8)} - ${data.message}`);
        // Further logic to remove job from UI
    }
};

ws.onclose = () => {
    console.log("Disconnected from rider WebSocket");
};

ws.onerror = (error) => {
    console.error("WebSocket error:", error);
};
```

**Expected Message Types:**

-   **`NEW_JOB_ASSIGNMENT`**:
    ```json
    {
        "type": "NEW_JOB_ASSIGNMENT",
        "orderId": "order-uuid-xyz",
        "message": "You have been assigned to order #xyz. Tap to view details."
    }
    ```
    Sent when a new job is assigned to the rider.

-   **`JOB_REJECTED`**:
    ```json
    {
        "type": "JOB_REJECTED",
        "orderId": "order-uuid-xyz",
        "message": "Order #xyz has been removed from your queue."
    }
    ```
    Sent when a job previously offered to the rider is no longer available (e.g., rejected by the rider or taken by another rider).

---

## Wallet

### Request Wallet Top-Up
- **Endpoint:** `POST /rider/wallet/request-topup`
- **Description:** Submits a request to top up the rider's wallet. This is a `multipart/form-data` request.
- **Handler:** `handlers.RequestTopUp`

**Form Data:**
- `amount` (string): The amount to top up.
- `slip` (file): The image file of the payment slip.

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/wallet/request-topup \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -F "amount=500.00" \
  -F "slip=@/path/to/your/slip.jpg"
```

**Success Response (201 Created):**
```json
{
    "message": "Top-up request submitted successfully. Please wait for admin approval.",
    "request": {
        "ID": "topup-request-uuid",
        "RiderID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "Amount": 500.00,
        "SlipURL": "/uploads/slips/generated-uuid.jpg",
        "Status": "pending"
    }
}
```

### Request Payout
- **Endpoint:** `POST /rider/payouts/request`
- **Description:** Submits a request for a payout from the rider's wallet. The system will check if the rider has sufficient balance.
- **Handler:** `payoutHandler.CreateRiderPayoutRequest`

**Request Body:**
```json
{
    "amount": 1000.00
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/payouts/request \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000.00}'
```

**Success Response (201 Created):**
```json
{
    "id": "payout-request-uuid",
    "rider_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "amount": 1000.00,
    "status": "pending",
    "created_at": "2025-11-17T10:00:00Z"
}
```

---

## Earnings

All endpoints in this section are prefixed with `/rider` and require an authenticated rider's JWT token in the `Authorization` header.

### Get My Earnings Summary
- **Endpoint:** `GET /rider/earnings/summary`
- **Description:** Retrieves a summary of the authenticated rider's earnings, including a breakdown of delivery fees and tips, as well as total, daily, weekly, and monthly totals.
- **Handler:** `riderHandler.GetMyEarningsSummary`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/earnings/summary \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "total_delivery_fees": 15000.50,
    "total_tips": 1500.00,
    "grand_total_earnings": 16500.50,
    "total_trips": 150,
    "average_earning_per_trip": 110.00,
    "daily_earnings": 500.25,
    "weekly_earnings": 3500.75,
    "monthly_earnings": 12000.00
}
```

---

## Push Notifications Setup (FCM)

To enable push notifications for new job alerts, the backend integrates with Firebase Cloud Messaging (FCM). You need to set up a Firebase project and provide the service account key to the backend.

### Configuration Steps:

1.  **Create a Firebase Project:** Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project or use an existing one.
2.  **Generate a Service Account Key:**
    *   In your Firebase project, navigate to **Project settings** (gear icon) > **Service accounts**.
    *   Click on **Generate new private key** and then **Generate key**. This will download a JSON file containing your service account credentials.
    *   **Keep this file secure and do not commit it to version control.**
3.  **Provide Key Path to Backend:**
    *   Place the downloaded JSON file in a secure location on your server or local machine.
    *   Set the environment variable `FCM_SERVICE_ACCOUNT_KEY_PATH` to the absolute path of this JSON file.
    *   Set the environment variable `FCM_PROJECT_ID` to your Firebase project ID.
    *   Example in `.env` file:
        ```
        FCM_SERVICE_ACCOUNT_KEY_PATH=/path/to/your/firebase-adminsdk.json
        FCM_PROJECT_ID=your-firebase-project-id
        ```
    *   The backend will use this path to initialize the Firebase Admin SDK and send push notifications.

### Registering a Device for Notifications

Riders need to register their device's FCM token with the backend to receive notifications.

-   **Endpoint:** `POST /rider/device`
-   **Description:** Registers a rider's device token for receiving push notifications.
-   **Handler:** `riderHandler.RegisterDevice`

**Request Body:**
```json
{
    "device_token": "your_fcm_device_token_here"
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/device \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"device_token": "your_fcm_device_token_here"}'
```

**Success Response (200 OK):**
```json
{
    "message": "Device registered successfully"
}
```

---

## Push Notifications Setup (FCM)

To enable push notifications for new job alerts, the backend integrates with Firebase Cloud Messaging (FCM). You need to set up a Firebase project and provide the service account key to the backend.

### Configuration Steps:

1.  **Create a Firebase Project:** Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project or use an existing one.
2.  **Generate a Service Account Key:**
    *   In your Firebase project, navigate to **Project settings** (gear icon) > **Service accounts**.
    *   Click on **Generate new private key** and then **Generate key**. This will download a JSON file containing your service account credentials.
    *   **Keep this file secure and do not commit it to version control.**
3.  **Provide Key Path to Backend:**
    *   Place the downloaded JSON file in a secure location on your server or local machine.
    *   Set the environment variable `FCM_SERVICE_ACCOUNT_KEY_PATH` to the absolute path of this JSON file.
    *   Set the environment variable `FCM_PROJECT_ID` to your Firebase project ID.
    *   Example in `.env` file:
        ```
        FCM_SERVICE_ACCOUNT_KEY_PATH=/path/to/your/firebase-adminsdk.json
        FCM_PROJECT_ID=your-firebase-project-id
        ```
    *   The backend will use this path to initialize the Firebase Admin SDK and send push notifications.

### Registering a Device for Notifications

Riders need to register their device's FCM token with the backend to receive notifications.

-   **Endpoint:** `POST /rider/device`
-   **Description:** Registers a rider's device token for receiving push notifications.
-   **Handler:** `riderHandler.RegisterDevice`

**Request Body:**
```json
{
    "device_token": "your_fcm_device_token_here"
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/device \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"device_token": "your_fcm_device_token_here"}'
```

**Success Response (200 OK):**
```json
{
    "message": "Device registered successfully"
}
```

---

## Rider Support System

Endpoints for riders to manage their support tickets, prefixed with `/rider/support/tickets`.

### Create a Support Ticket
- **Endpoint:** `POST /rider/support/tickets`
- **Description:** Allows an authenticated rider to create a new support ticket.
- **Handler:** `supportHandler.CreateRiderTicketHandler`

**Request Body:**
```json
{
    "subject": "Issue with recent order delivery",
    "description": "Order #xyz was delivered to the wrong address. Please help!",
    "priority": "high"
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/support/tickets \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"subject": "Issue with recent order delivery", "description": "Order #xyz was delivered to the wrong address. Please help!", "priority": "high"}'
```

**Success Response (201 Created):**
```json
{
    "id": "ticket-uuid-1",
    "rider_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "subject": "Issue with recent order delivery",
    "description": "Order #xyz was delivered to the wrong address. Please help!",
    "status": "open",
    "priority": "high",
    "created_at": "2025-11-17T10:00:00Z"
}
```

### Get My Support Tickets
- **Endpoint:** `GET /rider/support/tickets`
- **Description:** Retrieves a paginated list of all support tickets created by the authenticated rider.
- **Handler:** `supportHandler.GetMyTicketsHandler`

**Query Parameters:**
- `page` (int, optional): Page number, defaults to 1.
- `limit` (int, optional): Number of items per page, defaults to 10.

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/support/tickets?page=1&limit=5 \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "data": [
        {
            "id": "ticket-uuid-1",
            "rider_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
            "subject": "Issue with recent order delivery",
            "status": "open"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 1
    }
}
```

### Get Support Ticket Details
- **Endpoint:** `GET /rider/support/tickets/:ticket_id`
- **Description:** Retrieves the details of a specific support ticket, including all replies.
- **Handler:** `supportHandler.GetTicketDetailsHandler`

**Path Parameters:**
- `ticket_id` (string): The ID of the ticket to retrieve.

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/rider/support/tickets/ticket-uuid-1 \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
{
    "ticket": {
        "id": "ticket-uuid-1",
        "rider_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "subject": "Issue with recent order delivery",
        "description": "Order #xyz was delivered to the wrong address. Please help!",
        "status": "open",
        "priority": "high",
        "created_at": "2025-11-17T10:00:00Z"
    },
    "replies": [
        {
            "id": "reply-uuid-1",
            "ticket_id": "ticket-uuid-1",
            "rider_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
            "message": "I'm waiting for a response.",
            "created_at": "2025-11-17T10:05:00Z"
        }
    ]
}
```

### Add Reply to a Support Ticket
- **Endpoint:** `POST /rider/support/tickets/:ticket_id/replies`
- **Description:** Adds a new reply to an existing support ticket.
- **Handler:** `supportHandler.AddReplyHandler`

**Path Parameters:**
- `ticket_id` (string): The ID of the ticket to add a reply to.

**Request Body:**
```json
{
    "message": "Still waiting for an update on this issue."
}
```

**Example `curl`:**
```bash
curl -X POST http://localhost:8080/api/rider/support/tickets/ticket-uuid-1/replies \
  -H "Authorization: Bearer <YOUR_RIDER_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"message": "Still waiting for an update on this issue."}'
```

**Success Response (201 Created):**
```json
{
    "id": "reply-uuid-2",
    "ticket_id": "ticket-uuid-1",
    "rider_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "message": "Still waiting for an update on this issue.",
    "created_at": "2025-11-17T10:10:00Z"
}
```

---

## Admin

This section is for endpoints that are used by administrators to manage riders. It requires an admin's JWT token.

### Get Available Riders
- **Endpoint:** `GET /admin/riders/available`
- **Description:** Retrieves a list of all riders with the status `available`.
- **Handler:** `riderHandler.GetAvailableRiders`

**Example `curl`:**
```bash
curl -X GET http://localhost:8080/api/admin/riders/available \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

**Success Response (200 OK):**
```json
[
    {
        "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "name": "John Doe",
        "phoneNumber": "+1234567890",
        "status": "available",
        "location": {
            "lat": 13.736717,
            "lon": 100.5398
        }
    }
]
```
--- End of content ---