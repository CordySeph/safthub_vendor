## Table of Contents
- [Authentication](#authentication)
- [Favorite Restaurants](#favorite-restaurants)
- [Address Management](#address-management)
- [Cart Management](#cart-management)
- [Order Management](#order-management)
- [Wallet Management](#wallet-management)
- [Search](#search)
- [Public](#public)
- [Customer Support Chat](#customer-support-chat)
- [Customer Support (Ticketing System)](#customer-support-ticketing-system)
- [Real-time Order Tracking (WebSocket)](#real-time-order-tracking-websocket)
- [Vendor](#vendor)
- [Rider](#rider)
- [Admin](#admin)

### Authentication

| Method | Endpoint                        | Description                   |
| :----- | :------------------------------ | :---------------------------- |
| `POST` | `/api/auth/register`                | Register a new user           |
| `POST` | `/api/auth/login`                   | Log in a user                 |
| `POST` | `/api/auth/verify-email`            | Verify a user's email         |
| `POST` | `/api/auth/resend-verification`     | Resend verification email     |
| `POST` | `/api/auth/forgot-password/request` | Request a password reset      |
| `POST` | `/api/auth/reset-password/confirm`  | Confirm a password reset      |
| `GET`  | `/api/auth/me`                      | Get the current user's profile|
| `PATCH`| `/api/auth/me`                      | Update the current user's profile|
| `POST` | `/api/auth/logout`                  | Log out the current user        |

#### Register a new user

Endpoint: `POST /api/auth/register`

This endpoint does not require authentication. You must provide a JSON body with the new user's information

Creates a new user account. The `role` field can be specified as `"user"`, `"vendor"`, or `"rider"`. If omitted, it defaults to `"user"`.

Based on the code in internal/handlers/auth_handler.go, the
  following fields are expected in the request body:

- `name` (string, required)
- `email` (string, required)
- `password` (string, required, min 6 characters)
- `phoneNumber` (string, optional)
- `role` (string, optional - e.g., "user", "vendor". If omitted, a default role is likely assigned)

##### How to use with `curl`

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.vendor@example.com",
    "password": "securepassword",
    "phoneNumber": "0987654321",
    "role": "vendor"
  }' 
    
```

##### Expected Response

Upon success, you will receive an HTTP 201 Created status and the following message:

```bash
{
  "message": "user registered successfully"
}
```

After successful registration, the system will send a verification email to the provided email address. The new user will then need to use the `/api/auth/verify-email` endpoint (by clicking the link in the email) to verify their account before they can log in.

#### Log in a user

##### Endpoint: `POST /api/auth/login`

You must provide the user's `email` and `password` in a JSON body.

##### How to use with `curl`

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword"
  }'

```

##### Expected Response (on Success)

If the credentials are correct and the user account is active (and verified), the API will return an `HTTP 200` OK status with a JWT token.

```bash
{
  "token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzI1MzI0MDAsInVzZXJfaWQiOiJhMWIyYzNkNC1lNWY2LWc3aDgt..."
}
```

Notes

- You can then use this token in the `Authorization: Bearer <TOKEN>` header for all subsequent requests to protected endpoints (like `GET /api/auth/me`).
- If the credentials are incorrect or the user is not verified, the API will likely return an `HTTP 401 Unauthorized` error.

#### Get user info

1. To Get Your Own Profile (as the logged-in user)

This is the most common way to get user info. You use the token you received upon login to fetch your own profile data.

Endpoint: `GET /api/auth/me`
Requires: The user's own JWT token in the Authorization header.

##### How to use with `curl`

```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H 'Authorization: Bearer <TOKEN>'

```

2. To Get a List of All Users (as an Admin)
This action is restricted to administrators and is used to retrieve a list of all users in the system.

##### Endpoint: GET /api/admin/users

Requires: An Admin's JWT token with the necessary permissions (specifically admins:manage as seen in the code).

##### How to use with `curl`

```bash
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer <ADMIN_JWT_TOKEN>"
```

#### User Verify a user's email

To verify a user's email, you use the following endpoint:

##### Endpoint: `GET /api/auth/verify-email

This process is different from other authenticated requests; it
  does not use a login JWT token.

#### How it Works

   1. After a user registers, the system sends them an email.
   2. This email contains a special verification link with a unique, single-use token.
   3. The user clicks this link, which makes a GET request to the endpoint with the token included as a query parameter in the URL.

You would take the verification token from the email link and append it to the URL.

Note: The URL must be in quotes for the command to work correctly in most shells.

```bash
curl -X GET "http://localhost:8080/api/auth/verify-email?token=<VERIFICATION_TOKEN>"
```

##### Expected Response

If the token is valid and has not expired, you will get this response:

```bash
{
  "message": "email verified successfully"
}

```

#### Resend verification email

resend the verification email, you need to send a POST request to the following endpoint:

##### Endpoint: `POST /api/auth/resend-verification`

This endpoint is used if a user did not receive their initial verification email or if the link has expired.

It does not require a login token. Instead, you must provide the user's email in a JSON request body.

#### How to use with curl

```bash
curl -X POST http://localhost:8080/api/auth/resend-verification \
  -H 'Content-Type: application/json' \
  -d '{
        "email": "user-to-verify@example.com"
}'

```

##### Expected Response

If the request is successful, the system will send a new verification email to the specified address and you will receive the following response:

```bash
{
  "message": "verification email sent successfully"
}

```

Note: This endpoint is typically rate-limited to prevent users from spamming the email service.

#### Request a password reset

```bash
curl -X POST http://localhost:8080/api/auth/forgot-password/request \
  -H "Content-Type: application/json" \
  -d '{
        "email": "user-who-forgot@example.com"
}'

```

```bash
{
  "message": "if the email exists, a reset link has been sent"
}

```

#### Confirm a password reset

```bash
curl -X POST http://localhost:8080/api/auth/reset-password/confirm \
  -H "Content-Type: application/json" \
  -d '{
        "token": "<TOKEN_FROM_EMAIL>",
        "newPassword": "YourNewStrongPassword123"
}'

```

```bash
{
  "message": "password reset successful"
}

```

#### Get the current user's profile

```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>"

```

```bash
{
  "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
  "name": "Your Name",
  "email": "user@example.com",
  "phoneNumber": "0812345678",
  "role": "user",
  "verified": true,
  "createdAt": "2023-10-27T10:00:00Z"
}

```

#### Update the current user's profile

Send a PATCH request with the Authorization header and a JSON body containing the data to be updated.

```bash
curl -X PATCH http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer <YOUR_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
      "name": "New Updated Name",
      "phoneNumber": "0898765432"
}'
```

##### Note on Partial Updates

Since this is a PATCH request, you can send only the fields you wish to update. For example, to update only the name, your data would be:

```bash
{
  "name": "Just Updating My Name"
}
```

##### Expected Response

Upon success, the API will return the entire updated user profile object.

```bash
{
  "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
  "name": "New Updated Name",
  "email": "user@example.com",
  "phoneNumber": "0898765432",
  "role": "user",
  "verified": true,
  "createdAt": "2023-10-27T10:00:00Z"
}

```

#### Log out the current user

You simply need to provide the Authorization header with your token.

```bash
curl -X POST http://localhost:8080/api/auth/logout \
 -H "Authorization: Bearer <YOUR_JWT_TOKEN>"

```

##### Expected Response

If the token is valid, you will receive a success message.

```bash
{
  "message": "logged out successfully"
}
```

After this, the token you used will no longer be valid for accessing protected endpoints like `GET /api/auth/me`.

### Favorite Restaurants

Allows authenticated users to manage their list of favorite restaurants.

| Method   | Endpoint                                       | Description                            |
| :------- | :--------------------------------------------- | :------------------------------------- |
| `POST`   | `/api/auth/restaurants/:restaurant_id/favorite`  | Add a restaurant to favorites.         |
| `DELETE` | `/api/auth/restaurants/:restaurant_id/favorite`  | Remove a restaurant from favorites.    |
| `GET`    | `/api/auth/favorites`                          | Get a list of all favorite restaurants.|

#### Add a Restaurant to Favorites

```bash
curl -X POST http://localhost:8080/api/auth/restaurants/<restaurant-id>/favorite \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Remove a Restaurant from Favorites

```bash
curl -X DELETE http://localhost:8080/api/auth/restaurants/<restaurant-id>/favorite \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Get Favorite Restaurants

```bash
curl -X GET http://localhost:8080/api/auth/favorites \
  -H "Authorization: Bearer <your-jwt-token>"
```

### Address Management

Allows authenticated users to manage multiple delivery addresses on their profile.

| Method   | Endpoint                               | Description                        |
| :------- | :------------------------------------- | :--------------------------------- |
| `POST`   | `/api/auth/addresses`                  | Add a new address.                 |
| `GET`    | `/api/auth/addresses`                  | List all saved addresses.          |
| `PUT`    | `/api/auth/addresses/:address_id`      | Update an existing address.        |
| `DELETE` | `/api/auth/addresses/:address_id`      | Delete an address.                 |
| `POST`   | `/api/auth/addresses/:address_id/default`| Set an address as the default.     |

#### Add a New Address

Requires a JSON body with the address details.

```bash
curl -X POST http://localhost:8080/api/auth/addresses \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Home",
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "postal_code": "12345",
    "country": "USA",
    "phone_number": "0812345678",
    "contact_name": "John Doe"
  }'
```

#### List Your Addresses

```bash
curl -X GET http://localhost:8080/api/auth/addresses \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Update an Address

Requires a JSON body with the fields to be updated.

```bash
curl -X PUT http://localhost:8080/api/auth/addresses/<address-id> \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "My Home",
    "street": "123 Main Street, Apt 4B",
    "city": "Anytown",
    "state": "CA",
    "postal_code": "12345",
    "country": "USA"
  }'
```

#### Set an Address as Default

```bash
curl -X POST http://localhost:8080/api/auth/addresses/<address-id>/default \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Delete an Address

```bash
curl -X DELETE http://localhost:8080/api/auth/addresses/<address-id> \
  -H "Authorization: Bearer <your-jwt-token>"
```

### Cart Management

Allows authenticated users to manage their shopping cart.

| Method   | Endpoint                       | Description                  |
| :------- | :----------------------------- | :--------------------------- |
| `GET`    | `/api/cart`                    | Get all items in the cart.   |
| `POST`   | `/api/cart`                    | Add an item to the cart.     |
| `DELETE` | `/api/cart/items/:cart_item_id`| Remove an item from the cart.|

#### Get Cart

Retrieves the current user's shopping cart.

```bash
curl -X GET http://localhost:8080/api/cart \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Add Item to Cart

Adds a menu item to the cart. If the item is already in the cart, its quantity is increased.

**Request Body:**

```json
{
  "menu_item_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
  "quantity": 1
}
```

```bash
curl -X POST http://localhost:8080/api/cart \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "menu_item_id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "quantity": 1
  }'
```

#### Remove Item from Cart

Removes a specific item from the user's cart.

```bash
curl -X DELETE http://localhost:8080/api/cart/items/<cart-item-id> \
  -H "Authorization: Bearer <your-jwt-token>"
```

### Order Management

Allows users to place and manage their orders.

| Method   | Endpoint                       | Description                   |
| :------- | :----------------------------- | :---------------------------- |
| `POST`   | `/api/orders/checkout`         | Place a new order from the cart.|
| `GET`    | `/api/orders/:order_id`        | Get details of a single order.|
| `DELETE` | `/api/orders/:order_id`        | Cancel an order.              |
| `GET`    | `/api/orders/:order_id/receipt`| Get a receipt for an order.   |

#### Checkout

Creates an order from the items currently in the user's cart.

```bash
curl -X POST http://localhost:8080/api/orders/checkout \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Get Order Details

Retrieves the details for a specific order placed by the user.

```bash
curl -X GET http://localhost:8080/api/orders/<order-id> \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Cancel Order

Allows a user to cancel their own order, typically only possible before the restaurant accepts it.

```bash
curl -X DELETE http://localhost:8080/api/orders/<order-id> \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Get Order Receipt

Retrieves a simplified receipt for a completed order.

```bash
curl -X GET http://localhost:8080/api/orders/<order-id>/receipt \
  -H "Authorization: Bearer <your-jwt-token>"
```

### Wallet Management

Provides endpoints for users to manage their digital wallet.

| Method   | Endpoint                | Description                         |
| :------- | :---------------------- | :---------------------------------- |
| `GET`    | `/api/wallet`           | Get the user's wallet balance.      |
| `POST`   | `/api/wallet/deposit`   | Add funds to the wallet.            |
| `GET`    | `/api/wallet/transactions`| Get the user's transaction history. |

#### Get Wallet Balance

Retrieves the current balance of the user's wallet.

```bash
curl -X GET http://localhost:8080/api/wallet \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Deposit to Wallet

Simulates a deposit of funds into the user's wallet.

**Request Body:**

```json
{
  "amount": 50.00
}
```

```bash
curl -X POST http://localhost:8080/api/wallet/deposit \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50.00
  }'
```

#### Get Transaction History

Retrieves a list of all transactions (deposits, payments) for the user's wallet.

```bash
curl -X GET http://localhost:8080/api/wallet/transactions \
  -H "Authorization: Bearer <your-jwt-token>"
```


### Search

Retrieves a list of restaurants based on a flexible set of search and filter criteria.

**Endpoint:** `GET /api/search/restaurants`

**Query Parameters:**

| Parameter     | Type    | Description                                                                                               | Example                               |
| :------------ | :------ | :-------------------------------------------------------------------------------------------------------- | :------------------------------------ |
| `q`           | string  | A text query to search against restaurant names (case-insensitive).                                       | `?q=Pizza`                            |
| `category`    | string  | A text query to search against the category field (case-insensitive).                                     | `?category=Thai`                      |
| `tags`        | string  | A comma-separated list of tag names. Finds restaurants matching ALL specified tags.                       | `?tags=Thai,Healthy`                  |
| `rating`      | float   | The minimum average rating for restaurants (e.g., 4.0).                                                   | `?rating=4.5`                         |
| `price_range` | string  | The price range symbol (e.g., "$", "$$").                                                                 | `?price_range=$$`                     |
| `promotions`  | boolean | Set to `true` to find restaurants with active promotions, `false` for those without.                      | `?promotions=true`                    |
| `sort_by`     | string  | The sorting criteria. Valid values: `rating_desc`, `distance_asc`.                                        | `?sort_by=rating_desc`                |
| `lat`        | float   | User's latitude. Required for `distance_asc` sorting.                                                     | `?lat=13.7563`                        |
| `lon`        | float   | User's longitude. Required for `distance_asc` sorting.                                                    | `?lon=100.5018`                       |
| `page`       | integer | The page number for pagination. Defaults to `1`.                                                          | `?page=2`                             |
| `limit`      | integer | The number of items per page. Defaults to `10`.                                                           | `?limit=5`                            |

**Example Requests:**

```bash
# Find restaurants with "Burger" in their name with a rating of at least 4
curl "http://localhost:8080/api/search/restaurants?q=Burger&rating=4"

# Find restaurants tagged as "Italian" and sort by highest rating
curl "http://localhost:8080/api/search/restaurants?tags=Italian&sort_by=rating_desc"

# Find restaurants sorted by distance from a specific point (requires lat/lon)
curl "http://localhost:8080/api/search/restaurants?sort_by=distance_asc&lat=13.7563&lon=100.5018"
```

### Public

This section describes endpoints that do not require authentication.

#### List Restaurants

Retrieves a list of approved restaurants with advanced filtering and sorting.

**Endpoint:** `GET /api/restaurants`

**Query Parameters:**

| Parameter         | Type    | Description                                                                                                                        |
| :---------------- | :------ | :---------------------------------------------------------------------------------------------------------------------------------- |
| `page`            | integer | The page number for pagination. Defaults to `1`.                                                                                   |
| `limit`           | integer | The number of items per page. Defaults to `10`.                                                                                    |
| `category`        | string  | Filter by restaurant category.                                                                                                     |
| `name`            | string  | Filter by restaurant name (case-insensitive partial match).                                                                        |
| `min_rating`      | float   | Filter by minimum average rating.                                                                                                  |
| `latitude`        | float   | User's latitude for distance-based filtering and sorting. Required if `longitude` and `radius_km` or `sort_by=distance` are used.    |
| `longitude`       | float   | User's longitude for distance-based filtering and sorting. Required if `latitude` and `radius_km` or `sort_by=distance` are used.   |
| `radius_km`       | float   | The radius in kilometers to search within. Requires `latitude` and `longitude`.                                                    |
| `price_range`     | string  | Filter by price range (e.g., "$", "$$").                                                                                                |
| `dietary_options` | string  | Comma-separated list of dietary tags (e.g., `vegetarian`, `vegan`).                                                                |
| `has_promotions`  | boolean | Filter for restaurants that have active promotions.                                                                                |
| `sort_by`         | string  | The field to sort by. Valid values are `rating`, `price`, `distance`.                                                              |
| `sort_order`      | string  | The sort order. Valid values are `asc` or `desc`. Defaults to `asc`.                                                               |

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/restaurants?category=Thai&min_rating=4&sort_by=distance&sort_order=asc"
```

**Example Request (Search by Name):**

```bash
curl -X GET "http://localhost:8080/api/restaurants?name=ร้านยำปูม้าเจ๊แหม่ม"
```

#### Get Restaurant Details by ID

Retrieves detailed information for a specific approved restaurant by its ID.

**Endpoint:** `GET /api/restaurants/:id`

**Path Parameters:**

| Parameter | Type   | Description                               |
| :-------- | :----- | :---------------------------------------- |
| `id`      | string | The unique ID of the restaurant.          |

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/restaurants/bc462ade-9b4e-4750-8ad7-2d75ba363006"
```

**Example Response:**

```json
{
    "ID": "bc462ade-9b4e-4750-8ad7-2d75ba363006",
    "OwnerID": "91bcfe46-6f1e-4357-a68f-e0dab16cf281",
    "Name": "ร้านยำปูม้าเจ๊แหม่ม",
    "LogoURL": "https://example.com/logo.png",
    "PhoneNumber": "0812345678",
    "Address": "123 ถนนลาดพร้าว",
    "Latitude": 13.799278,
    "Longitude": 100.5018,
    "BusinessHours": null,
    "IsOpen": false,
    "Category": "ยำ, อีสาน",
    "PriceRange": "$",
    "RejectReason": "",
    "Status": "approved",
    "Rating": 0,
    "IsTemporarilyClosed": false,
    "TemporaryClosureReason": "",
    "CreatedAt": "2025-10-01T10:18:28.559705Z",
    "UpdatedAt": "2025-10-01T10:27:01.4828663Z"
}
```

**Error Response (404 Not Found):**

```json
{
    "error": "restaurant with ID <YOUR_RESTAURANT_ID> not found or not approved"
}
```
### Customer Support Chat

Provides real-time chat functionality for an order, allowing the customer, restaurant vendor, and eventually support agents to communicate.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/chat/ws/:order_id` | Establishes a WebSocket connection for real-time chat. |
| `GET` | `/api/chat/history/:order_id` | Retrieves the full chat history for an order. |

#### Connecting to the Chat (WebSocket)

To connect to the chat for a specific order, an authenticated user (customer or vendor associated with the order) must establish a WebSocket connection.

**Example using `wscat`:**

First, install `wscat` if you don't have it:

```bash
npm install -g wscat
```

Then, connect to the endpoint, providing your JWT token in the `Authorization` header.

```bash
wscat -c "ws://localhost:8080/api/chat/ws/<order-id>" \
  -H "Authorization: Bearer <your-jwt-token>"
```

Once connected, you can send and receive messages in real-time. Messages sent from the client are broadcast to all other participants in the chat room.

**Message Format (from server):**
Messages received from the server will be in JSON format:

```json
{
  "message": "Hello, is my order almost ready?",
  "user_id": "a1b2c3d4-…",
  "timestamp": "2025-09-16T12:30:00Z"
}
```

#### Retrieving Chat History

To get all past messages for an order's chat room.

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/chat/history/<order-id>" \
  -H "Authorization: Bearer <your-jwt-token>"
```

**Example Response:**

```json
[
    {
        "ID": "e1f2g3h4-…",
        "ChatRoomID": "i1j2k3l4-…",
        "UserID": "a1b2c3d4-…",
        "Message": "Hi, I have a question about my order.",
        "User": null,
        "CreatedAt": "2025-09-16T12:25:00Z"
    },
    {
        "ID": "m1n2o3p4-…",
        "ChatRoomID": "i1j2k3l4-…",
        "UserID": "q1r2s3t4-…",
        "Message": "Of course, what is it?",
        "User": null,
        "CreatedAt": "2025-09-16T12:25:30Z"
    }
]
```

### Customer Support (Ticketing System)

Provides endpoints for users to create and manage support tickets, and for admins to manage them.

#### User-Facing Endpoints

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `POST` | `/api/support/tickets` | Create a new support ticket. |
| `GET` | `/api/support/tickets` | Get a list of the user's own tickets. |
| `GET` | `/api/support/tickets/:ticket_id` | Get details for a single ticket. |
| `POST` | `/api/support/tickets/:ticket_id/replies` | Add a reply to a ticket. |

**Create a new ticket:**

```bash
curl -X POST http://localhost:8080/api/support/tickets \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "My order was incorrect",
    "description": "The pizza I received had pineapples, but I did not order them.",
    "priority": "high"
  }'
```

**Add a reply to a ticket:**

```bash
curl -X POST http://localhost:8080/api/support/tickets/<ticket-id>/replies \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Any updates on this issue?"
  }'
```

#### Admin
-Facing Endpoints

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/support/tickets` | Get a list of all tickets (filterable by status). |
| `POST` | `/api/admin/support/tickets/:ticket_id/assign` | Assign a ticket to an agent. |
| `PATCH` | `/api/admin/support/tickets/:ticket_id/status` | Update the status of a ticket. |

**Get all open tickets:**

```bash
curl -X GET "http://localhost:8080/api/admin/support/tickets?status=open" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Assign a ticket:**

```bash
curl -X POST http://localhost:8080/api/admin/support/tickets/<ticket-id>/assign \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "<agent-user-id>"
  }'
```

**Update ticket status:**

```bash
curl -X PATCH http://localhost:8080/api/admin/support/tickets/<ticket-id>/status \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in_progress"
  }'
```

### Real-time Order Tracking (WebSocket)

The system provides real-time updates for order status and rider location via WebSockets. This allows the frontend to build a live tracking experience for the user.

#### Connection

To receive updates for a specific order, the client must establish a WebSocket connection to the following endpoint:

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/ws/track/:order_id` | Establishes a WebSocket connection for a specific order. |

**Authentication:** This endpoint is public and does not require a JWT token. Authorization is implicit through knowledge of the unique `order_id`.

**Example Connection (`wscat`):**

```bash
wscat -c "ws://localhost:8080/api/ws/track/<your-order-id>"
```

#### Incoming Messages

Once connected, the client can expect to receive the following message types in JSON format. The `type` field indicates the kind of update.

##### 1. Order Status Update

Sent when the order's status changes (e.g., accepted, preparing, delivered).

**Message `type`:** `ORDER_STATUS_UPDATE`

**Payload:**

```json
{
  "type": "ORDER_STATUS_UPDATE",
  "orderId": "a1b2c3d4-..",
  "status": "delivering",
  "timestamp": "2025-09-17T12:30:00Z"
}
```

##### 2. Rider Location Update

Sent periodically by the rider's device while they are on an active delivery.

**Message `type`:** `RIDER_LOCATION_UPDATE`

**Payload:**

```json
{
  "type": "RIDER_LOCATION_UPDATE",
  "orderId": "a1b2c3d4-..",
  "riderId": "r1s2t3u4-..",
  "latitude": 13.7563,
  "longitude": 100.5018
}
```

### Vendor

This section outlines endpoints available to users with the `vendor` role. These endpoints are prefixed with `/api/vendor` and require authentication.

#### Dashboard

Retrieves a comprehensive dashboard for the vendor's restaurant, including an analytics summary, a list of popular items, and recent orders.

**Endpoint:** `GET /api/vendor/dashboard`

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/vendor/dashboard" \
  -H "Authorization: Bearer <your-jwt-token>"
```

**Example Response:**

```json
{
    "analytics_summary": {
        "total_revenue": 12550.75,
        "total_orders": 350,
        "average_order_value": 35.86
    },
    "popular_items": [
        {
            "menu_item_name": "Margherita Pizza",
            "total_quantity_sold": 120,
            "total_revenue": 4200
        },
        {
            "menu_item_name": "Garlic Bread",
            "total_quantity_sold": 95,
            "total_revenue": 950
        }
    ],
    "recent_orders": [
        {
            "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
            "user_id": "...",
            "restaurant_id": "...",
            "status": "delivered",
            "total_price": 45.50,
            "created_at": "2025-09-17T10:00:00Z"
        }
    ],
    "restaurant_id": "r1s2t3u4-v5w6-x7y8-z9a0-b1c2d3e4f5g6"
}
```

#### Advanced Order Management

##### Get Restaurant Orders

Retrieves a list of orders for the vendor's restaurant. Orders can be filtered by status.

**Endpoint:** `GET /api/vendor/orders`

**Query Parameters:**

| Parameter | Type    | Description                                                                                                                               |
| :-------- | :------ | :---------------------------------------------------------------------------------------------------------------------------------------- |
| `page`    | integer | The page number for pagination. Defaults to `1`.                                                                                          |
| `limit`   | integer | The number of items per page. Defaults to `10`.                                                                                         |
| `status`  | string  | Filter orders by status. Possible values: `pending`, `accepted`, `preparing`, `ready_for_pickup`, `picked_up`, `delivered`, `cancelled`. |

**Example Request:**

```bash
# Get all pending orders for the restaurant
curl -X GET "http://localhost:8080/api/vendor/orders?status=pending" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Accept an Order

Marks an incoming order as accepted by the restaurant.

**Endpoint:** `POST /api/vendor/orders/:order_id/accept`

**Example Request:**

```bash
curl -X POST "http://localhost:8080/api/vendor/orders/<order-id>/accept" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Reject an Order

Marks an incoming order as rejected by the restaurant.

**Endpoint:** `POST /api/vendor/orders/:order_id/reject`

**Example Request:**

```bash
curl -X POST "http://localhost:8080/api/vendor/orders/<order-id>/reject" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Mark Order as Preparing

Updates the order status to indicate that the kitchen has started preparing it.

**Endpoint:** `POST /api/vendor/orders/:order_id/prepare`

**Example Request:**

```bash
curl -X POST "http://localhost:8080/api/vendor/orders/<order-id>/prepare" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Update Order Status

Allows for more granular status updates.

**Endpoint:** `PATCH /api/vendor/orders/:order_id/status`

**Request Body:**

```json
{
  "status": "ready_for_pickup"
}
```

**Possible Status Values:** `pending`, `accepted`, `preparing`, `ready_for_pickup`, `picked_up`, `delivered`, `cancelled`.

**Example Request:**

```bash
curl -X PATCH "http://localhost:8080/api/vendor/orders/<order-id>/status" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "ready_for_pickup"}'

#### Analytics & Reporting

Provides endpoints for vendors to access sales data and performance metrics.

##### Get Sales Summary
Retrieves a summary of total revenue, total orders, and average order value.

**Endpoint:** `GET /api/vendor/analytics/summary`

**Example Request:**
```bash
curl -X GET "http://localhost:8080/api/vendor/analytics/summary" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Get Popular Items

Retrieves a list of the best-selling menu items, sorted by quantity sold.

**Endpoint:** `GET /api/vendor/analytics/popular-items`

**Query Parameters:**

| Parameter | Type    | Description                             |
| :-------- | :------ | :-------------------------------------- |
| `limit`   | integer | The number of items to return. Defaults to `10`. |

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/vendor/analytics/popular-items?limit=5" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Get Revenue Over Time

Retrieves revenue data aggregated over a specific time period.

**Endpoint:** `GET /api/vendor/analytics/revenue-over-time`

**Query Parameters:**

| Parameter | Type   | Description                                       |
| :-------- | :----- | :------------------------------------------------ |
| `period`  | string | The time period to group by. `day`, `week`, or `month`. Defaults to `day`. |

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/vendor/analytics/revenue-over-time?period=week" \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Restaurant Management

Endpoints for vendors to manage their restaurant profile.

##### Check Location

Checks if a given geographical location is within any of the service zones. This is useful for vendors to verify a location before submitting a full registration.

- **Method:** `POST`
- **URL:** `/api/vendor/check-location`
- **Authentication:** Requires a JWT for a user with the `vendor` role.
- **Request Body (JSON):**
    ```json
    {
      "latitude": 13.736717,
      "longitude": 100.539800
    }
    ```
- **Success Response (in service zone):**
    ```json
    {
      "in_service_zone": true,
      "message": "This location is within a service zone."
    }
    ```
- **Success Response (not in service zone):**
    ```json
    {
      "in_service_zone": false,
      "message": "This location is outside of all service zones."
    }
    ```
- **Example `curl`:**
    ```bash
    curl -X POST http://localhost:8080/api/vendor/check-location \
      -H "Authorization: Bearer <your-vendor-jwt-token>" \
      -H "Content-Type: application/json" \
      -d '{
        "latitude": 13.736717,
        "longitude": 100.539800
      }'
    ```

##### Register a Restaurant

This endpoint is used by vendors to register a new restaurant in the system. The submitted restaurant information will be saved and set to a "pending" status, awaiting approval from an administrator.

**1. Endpoint Details**

*   **Method:** `POST`
*   **URL:** `/api/vendor/register-store`

**2. Authentication**

You must have a valid JSON Web Token (JWT) for a user with the `vendor` role and include it in the request header.

**3. Request Headers**

You must specify the following request headers:

*   `Content-Type`: `application/json`
*   `Authorization`: `Bearer <your_jwt_token>`
    *   Replace `<your_jwt_token>` with the JWT you received after logging in as a vendor.

**4. Request Body (JSON)**

You must send the restaurant information in JSON format within the request body. The fields include both required and optional parameters:

**Required Fields in Request Body:**

*   `Name` (string): **(Required)** The name of your restaurant.
*   `Address` (string): **(Required)** The full address of the restaurant.
*   `Latitude` (float64): **(Required)** The latitude coordinate of the restaurant's location (e.g., `13.736717`).
*   `Longitude` (float64): **(Required)** The longitude coordinate of the restaurant's location (e.g., `100.539800`).

**Optional Fields (but recommended) in Request Body:**

*   `LogoURL` (string): URL of the restaurant's logo (e.g., `"https://example.com/logo.png"`)
*   `PhoneNumber` (string): Contact phone number for the restaurant (e.g., `"0812345678"`)
*   `RestaurantEmail` (string): **(New)** Specific email address for restaurant contact (e.g., `"contact@myrestaurant.com"`)
*   `Description` (string): **(New)** A brief description of your restaurant (e.g., `"Authentic Thai cuisine with a cozy ambiance, established over 20 years ago."`)
*   `BusinessHours` (JSON object): The operating hours of the restaurant for each day.
    *   Each day (e.g., `monday`, `tuesday`, ...) is an object with `open` and `close` fields.
    *   `open` and `close` values are strings in "HH:MM" format (e.g., `"09:00"`, `"22:00"`)
    *   If the restaurant is closed on a specific day, you can specify `null` for that day.
    *   **Example `BusinessHours` structure:**
        ```json
        {
            "monday": { "open": "11:00", "close": "22:00" },
            "tuesday": { "open": "11:00", "close": "22:00" },
            "wednesday": { "open": "11:00", "close": "22:00" },
            "thursday": { "open": "11:00", "close": "22:00" },
            "friday": { "open": "11:00", "close": "23:00" },
            "saturday": { "open": "12:00", "close": "23:00" },
            "sunday": null
        }
        ```
*   `Category` (string): The type of cuisine the restaurant serves (e.g., `"Thai"`, `"Burger"`, `"Italian"`)
*   `PriceRange` (string): The price range of the restaurant (e.g., `"$"` for inexpensive, `"$$"` for moderate, `"$$$"` for expensive).

**Fields Automatically Handled by Backend (Do Not Send in Request Body):**

*   `ID` (uuid.UUID): Unique restaurant ID (generated by the system).
*   `OwnerID` (uuid.UUID): User ID of the restaurant owner (derived from JWT).
*   `WalletID` (*uuid.UUID): Wallet ID for the restaurant (generated by the system).
*   `IsOpen` (bool): Open/closed status (determined by the system based on business hours).
*   `RejectReason` (string): Reason for rejection (used by administrators).
*   `Status` (string): Restaurant status (automatically set to `"pending"`).
*   `Rating` (float64): Average review rating (default value `0.00`).
*   `ReviewCount` (int): **(New)** Total number of reviews (default value `0`).
*   `IsTemporarilyClosed` (bool): Temporary closure status (default `false`).
*   `TemporaryClosureReason` (string): Reason for temporary closure.
*   `CreatedAt` (time.Time): Date and time of restaurant creation (generated by the system).
*   `UpdatedAt` (time.Time): Date and time of last restaurant data update (generated by the system).

**Complete Example Request Body:**

```json
{
    "Name": "Delicious Eats Restaurant",
    "LogoURL": "https://example.com/restaurant_logo.png",
    "PhoneNumber": "0987654321",
    "RestaurantEmail": "info@deliciouseats.com",
    "Description": "A fusion Thai restaurant with a great atmosphere, perfect for any occasion.",
    "Address": "123 Sukhumvit Road, Khlong Toei Nuea, Watthana, Bangkok 10110",
    "Latitude": 13.736717,
    "Longitude": 100.539800,
    "BusinessHours": {
        "monday": { "open": "11:00", "close": "22:00" },
        "tuesday": { "open": "11:00", "close": "22:00" },
        "wednesday": { "open": "11:00", "close": "22:00" },
        "thursday": { "open": "11:00", "close": "22:00" },
        "friday": { "open": "11:00", "close": "23:00" },
        "saturday": { "open": "12:00", "close": "23:00" },
        "sunday": null
    },
    "Category": "Thai, Fusion",
    "PriceRange": "$$"
}
```

**5. Expected Response**

*   **Success Case (Status Code: `201 Created`)**
    ```json
    {
        "message": "restaurant submitted for review"
    }
    ```
*   **Error Case (Status Code: `400 Bad Request`)**
    *   If the JSON data is invalid or incomplete as required.
    ```json
    {
        "error": "Invalid JSON format"
    }
    ```
    *   Or other error messages indicating data issues.
*   **Error Case (Status Code: `500 Internal Server Error`)**
    *   If an internal server error occurs, such as a database connection issue.
    ```json
    {
        "error": "failed to register restaurant"
    }
    ```

**6. Additional Notes**

*   **Important:** The restaurant's location (defined by `Latitude` and `Longitude`) **must** fall within a pre-defined Service Zone. If the location is outside of all service zones, the registration will fail.
*   After submitting restaurant information, the restaurant will be in a `pending` status and must await administrator approval before appearing in the application.
*   Since new fields have been added to the `models.Restaurant` struct, you will need to **rebuild and restart your server** for the database schema changes to take effect (the `db.AutoMigrate()` function will handle this automatically upon server startup).

##### Get My Restaurant

Retrieves the profile of the restaurant owned by the logged-in vendor.

**Endpoint:** `GET /api/vendor/my-restaurant`

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/vendor/my-restaurant" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Update My Restaurant

Updates the details of the vendor's restaurant.

**Endpoint:** `PATCH /api/vendor/my-restaurant`

**Request Body (send only fields to update):**

```json
{
  "phone_number": "0899998888",
  "price_range": "$$$"
}
```

**Example Request:**

```bash
curl -X PATCH "http://localhost:8080/api/vendor/my-restaurant" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "0899998888"
  }'
```

##### Set Temporary Closure

Allows a vendor to temporarily close their restaurant.

**Endpoint:** `PATCH /api/vendor/my-restaurant/closure`

**Request Body:**

```json
{
  "is_temporarily_closed": true,
  "temporary_closure_reason": "Staff holiday"
}
```

**Example Request:**

```bash
curl -X PATCH "http://localhost:8080/api/vendor/my-restaurant/closure" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "is_temporarily_closed": true,
    "temporary_closure_reason": "Staff holiday"
  }'
```

#### Menu Management

Endpoints for vendors to manage their restaurant's menu. These endpoints require the vendor's restaurant to be approved.

##### Create a Menu Item

Adds a new item to the restaurant's menu.

**Endpoint:** `POST /api/vendor/menu`

**Request Body:**

```json
{
  "name": "Spicy Basil Chicken",
  "description": "Classic Thai dish with holy basil and chili.",
  "price": 12.50,
  "category": "Main Dishes",
  "stock": 50
}
```

**Example Request:**

```bash
curl -X POST "http://localhost:8080/api/vendor/menu" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Spicy Basil Chicken",
    "description": "Classic Thai dish with holy basil and chili.",
    "price": 12.50,
    "category": "Main Dishes",
    "stock": 50
  }'
```

##### Update a Menu Item

Updates an existing menu item.

**Endpoint:** `PATCH /api/vendor/menu/:menu_id`

**Example Request:**

```bash
curl -X PATCH "http://localhost:8080/api/vendor/menu/<menu-id>" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "price": 13.00,
    "stock": 45
  }'
```

##### Delete a Menu Item

Removes a menu item from the restaurant's menu.

**Endpoint:** `DELETE /api/vendor/menu/:menu_id`

**Example Request:**

```bash
curl -X DELETE "http://localhost:8080/api/vendor/menu/<menu-id>" \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Discount Management

Endpoints for vendors to create and manage discounts for their restaurant.

##### Create a Discount

Creates a new discount.

**Endpoint:** `POST /api/vendor/discounts`

**Request Body:**

```json
{
  "code": "SUMMER10",
  "discount_type": "percentage",
  "value": 10,
  "start_date": "2025-06-01T00:00:00Z",
  "end_date": "2025-08-31T23:59:59Z",
  "min_purchase": 20.00
}
```

**Example Request:**

```bash
curl -X POST "http://localhost:8080/api/vendor/discounts" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "SUMMER10",
    "discount_type": "percentage",
    "value": 10,
    "start_date": "2025-06-01T00:00:00Z",
    "end_date": "2025-08-31T23:59:59Z",
    "min_purchase": 20.00
  }'
```

##### Get All Discounts

Retrieves all discounts for the vendor's restaurant.

**Endpoint:** `GET /api/vendor/discounts`

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/vendor/discounts" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Get Discount by ID

Retrieves a single discount by its ID.

**Endpoint:** `GET /api/vendor/discounts/:id`

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/vendor/discounts/<discount-id>" \
  -H "Authorization: Bearer <your-jwt-token>"
```

##### Update a Discount

Updates an existing discount.

**Endpoint:** `PATCH /api/vendor/discounts/:id`

**Example Request:**

```bash
curl -X PATCH "http://localhost:8080/api/vendor/discounts/<discount-id>" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "value": 15
  }'
```

##### Delete a Discount

Deletes a discount.

**Endpoint:** `DELETE /api/vendor/discounts/:id`

**Example Request:**

```bash
curl -X DELETE "http://localhost:8080/api/vendor/discounts/<discount-id>" \
  -H "Authorization: Bearer <your-jwt-token>"
```


### Rider

Endpoints for riders to manage deliveries and earnings. Require `rider` role.

#### Get Available Jobs

Retrieves a list of delivery jobs that are ready for pickup.

**Endpoint:** `GET /api/rider/orders/available`

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/rider/orders/available" \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Accept a Job

Accepts an available delivery job.

**Endpoint:** `POST /api/rider/orders/:order_id/accept`

**Example Request:**

```bash
curl -X POST "http://localhost:8080/api/rider/orders/<order-id>/accept" \
  -H "Authorization: Bearer <your-jwt-token>"
```

#### Update Job Status

Updates the status of an accepted job (e.g., to "picked_up" or "delivered").

**Endpoint:** `PATCH /api/rider/orders/:order_id/status`

**Request Body:**

```json
{
  "status": "picked_up"
}
```

**Possible Status Values:** `picked_up`, `delivered`.

**Example Request:**

```bash
curl -X PATCH "http://localhost:8080/api/rider/orders/<order-id>/status" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "picked_up"}'
```

#### Get Earnings Summary

Retrieves a summary of the rider's earnings.

**Endpoint:** `GET /api/rider/earnings/summary`

**Example Request:**

```bash
curl -X GET "http://localhost:8080/api/rider/earnings/summary" \
  -H "Authorization: Bearer <your-jwt-token>"
```

### Admin

### Admin API Endpoints

This section details the API endpoints available to administrators for managing various aspects of the platform. All admin endpoints require authentication with an admin JWT token and specific permissions.

#### Dashboard Management

Requires `dashboard:view` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/dashboard` | Retrieves a comprehensive dashboard summary for the entire platform. |

**Get Admin Dashboard Summary:**

```bash
curl -X GET "http://localhost:8080/api/admin/dashboard" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Example Response:**

```json
{
  "total_users": 1000,
  "total_restaurants": 250,
  "total_riders": 150,
  "total_orders": 5000,
  "total_revenue": 150000.75,
  "pending_restaurants": 10,
  "pending_riders": 5,
  "open_support_tickets": 20
}
```

#### Reporting

Requires `reports:view` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `POST` | `/api/admin/reports/orders` | Generates and exports a CSV report of orders within a specified date range. |
| `POST` | `/api/admin/reports/revenue` | Generates and exports a CSV report of revenue aggregated by restaurant within a specified date range. |

**Generate Order Export Report:**

```bash
curl -X POST "http://localhost:8080/api/admin/reports/orders" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": "2025-12-31T23:59:59Z",
    "status": ["delivered", "completed"]
  }'
```

**Generate Revenue Report:**

```bash
curl -X POST "http://localhost:8080/api/admin/reports/revenue" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": "2025-12-31T23:59:59Z"
  }'
```

#### Staff Role & Permission Management

Requires `roles:manage` permission for all endpoints.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/staff-roles` | Retrieves a list of all staff roles. |
| `POST` | `/api/admin/staff-roles` | Creates a new staff role. |
| `GET` | `/api/admin/staff-roles/:role_id` | Retrieves a single staff role by its ID. |
| `PUT` | `/api/admin/staff-roles/:role_id` | Updates an existing staff role's name. |
| `DELETE` | `/api/admin/staff-roles/:role_id` | Deletes a staff role. |
| `POST` | `/api/admin/staff-roles/:role_id/permissions` | Updates the permissions associated with a role. |
| `GET` | `/api/admin/permissions` | Retrieves a list of all available permissions in the system. |

**List All Staff Roles:**
```bash
curl -X GET "http://localhost:8080/api/admin/staff-roles" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Create a New Staff Role:**
```bash
curl -X POST "http://localhost:8080/api/admin/staff-roles" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Finance Manager"
  }'
```

**Get a Single Staff Role:**
```bash
curl -X GET "http://localhost:8080/api/admin/staff-roles/<role-id>" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Update a Staff Role:**
```bash
curl -X PUT "http://localhost:8080/api/admin/staff-roles/<role-id>" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Head of Finance"
  }'
```

**Delete a Staff Role:**
```bash
curl -X DELETE "http://localhost:8080/api/admin/staff-roles/<role-id>" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Update Role Permissions:**
```bash
curl -X POST "http://localhost:8080/api/admin/staff-roles/<role-id>/permissions" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "permission_ids": ["permission-id-1", "permission-id-2"]
  }'
```

**List All Available Permissions:**
```bash
curl -X GET "http://localhost:8080/api/admin/permissions" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Restaurant Management

Requires `restaurants:manage` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/restaurants/pending` | Retrieves a list of restaurants awaiting admin approval. |
| `POST` | `/api/admin/restaurants/:id/approve` | Approves a pending restaurant. |
| `POST` | `/api/admin/restaurants/:id/reject` | Rejects a pending restaurant. |

**Get Pending Restaurants:**

```bash
curl -X GET "http://localhost:8080/api/admin/restaurants/pending" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Approve Restaurant:**

```bash
curl -X POST "http://localhost:8080/api/admin/restaurants/<restaurant-id>/approve" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Reject Restaurant:**

```bash
curl -X POST "http://localhost:8080/api/admin/restaurants/<restaurant-id>/reject" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Order Management

Requires `orders:manage` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/orders` | Retrieves a list of all orders in the system. |
| `POST` | `/api/admin/orders/:order_id/confirm-payment` | Confirms payment for an order. |
| `POST` | `/api/admin/orders/:order_id/cancel-payment` | Cancels payment for an order. |
| `PATCH` | `/api/admin/orders/:order_id/status` | Updates the status of an order. |
| `POST` | `/api/admin/orders/:order_id/assign-rider` | Assigns a rider to an order. |

**List All Orders:**

```bash
curl -X GET "http://localhost:8080/api/admin/orders" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Confirm Order Payment:**

```bash
curl -X POST "http://localhost:8080/api/admin/orders/<order-id>/confirm-payment" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Cancel Order Payment:**

```bash
curl -X POST "http://localhost:8080/api/admin/orders/<order-id>/cancel-payment" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Update Order Status:**

```bash
curl -X PATCH "http://localhost:8080/api/admin/orders/<order-id>/status" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"status": "delivered"}'
```

**Assign Rider to Order:**

```bash
curl -X POST "http://localhost:8080/api/admin/orders/<order-id>/assign-rider" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"rider_id": "<rider-user-id>"}'
```

#### User Management

Requires `users:manage` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `POST` | `/api/admin/users/:id/ban` | Bans a user. |
| `POST` | `/api/admin/users/:id/unban` | Unbans a user. |

**Ban User:**

```bash
curl -X POST "http://localhost:8080/api/admin/users/<user-id>/ban" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Unban User:**

```bash
curl -X POST "http://localhost:8080/api/admin/users/<user-id>/unban" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Rider Wallet Management

Requires `wallets:credit` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `POST` | `/api/admin/riders/credit-wallet` | Credits a rider's wallet. |

**Credit Rider Wallet:**

```bash
curl -X POST "http://localhost:8080/api/admin/riders/credit-wallet" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"rider_id": "<rider-user-id>", "amount": 100.00}'
```

#### Top-Up Request Management

Requires `wallets:credit` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/topup-requests` | Lists all top-up requests. |
| `POST` | `/api/admin/topup-requests/:id/approve` | Approves a top-up request. |
| `POST` | `/api/admin/topup-requests/:id/reject` | Rejects a top-up request. |

**List Top-Up Requests:**

```bash
curl -X GET "http://localhost:8080/api/admin/topup-requests" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Approve Top-Up Request:**

```bash
curl -X POST "http://localhost:8080/api/admin/topup-requests/<request-id>/approve" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Reject Top-Up Request:**

```bash
curl -X POST "http://localhost:8080/api/admin/topup-requests/<request-id>/reject" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Super Admin - Role Management

Requires `admins:manage` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/users` | Lists all users in the system. |
| `POST` | `/api/admin/users/:id/assign-role` | Assigns a role to a user. |

**List All Users:**

```bash
curl -X GET "http://localhost:8080/api/admin/users" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Assign Role to User:**

```bash
curl -X POST "http://localhost:8080/api/admin/users/<user-id>/assign-role" \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{"role_name": "admin"}'
```

#### Service Zone Management

Admins are responsible for defining the geographical areas where the service is available. A restaurant can only be registered if its location falls within one of these defined zones. These endpoints require `service-zones:manage` permission and authentication via an admin JWT token.

##### Create a Service Zone

Creates a new geographical area of service.

- **Method:** `POST`
- **URL:** `/api/admin/service-zones`
- **Headers:**
    - `Authorization`: `Bearer <admin-jwt-token>`
    - `Content-Type`: `application/json`
- **Body (JSON):**
    - `name` (string, required): The name of the service zone.
    - `polygon_wkt` (string, required): The geographical boundary in Well-Known Text (WKT) format for a `POLYGON`.
    - `avg_radius` (float, optional): The average radius associated with the service zone.

**Example `curl` Request:**

```bash
curl -X POST http://localhost:8080/api/admin/service-zones \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Central Business District",
    "polygon_wkt": "POLYGON((100.506000 13.791000, 100.499072 13.795000, 100.492144 13.791000, 100.492144 13.783000, 100.499072 13.779000, 100.506000 13.783000, 100.506000 13.791000))",
    "avg_radius": 5.5
  }'
```

**Success Response (`201 Created`):**

```json
{
    "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "Name": "Central Business District",
    "Polygon": {
        // Formatted Polygon data
    },
    "CreatedAt": "2025-10-16T10:00:00Z",
    "UpdatedAt": "2025-10-16T10:00:00Z"
}
```

##### List All Service Zones

Retrieves a list of all currently defined service zones.

- **Method:** `GET`
- **URL:** `/api/admin/service-zones`
- **Headers:**
    - `Authorization`: `Bearer <admin-jwt-token>`

**Example `curl` Request:**

```bash
curl -X GET http://localhost:8080/api/admin/service-zones \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Success Response (`200 OK`):**

```json
[
    {
        "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "Name": "Central Business District",
        "Polygon": { ... },
        "CreatedAt": "2025-10-16T10:00:00Z",
        "UpdatedAt": "2025-10-16T10:00:00Z"
    }
]
```

##### Update a Service Zone

Updates the name or average radius of an existing service zone.

- **Method:** `PATCH`
- **URL:** `/api/admin/service-zones/:id`
- **Headers:**
    - `Authorization`: `Bearer <admin-jwt-token>`
    - `Content-Type`: `application/json`
- **Body (JSON):**
    - `name` (string, optional): The new name for the service zone.
    - `avg_radius` (float, optional): The new average radius for the service zone.

**Example `curl` Request:**

```bash
curl -X PATCH http://localhost:8080/api/admin/service-zones/<service-zone-id> \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Business District",
    "avg_radius": 6.0
  }'
```

**Success Response (`200 OK`):**

```json
{
    "ID": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "Name": "Updated Business District",
    "Polygon": { ... },
    "AvgRadius": 6.0,
    "CreatedAt": "2025-10-16T10:00:00Z",
    "UpdatedAt": "2025-10-16T10:00:00Z"
}
```

##### Delete a Service Zone

Deletes a service zone by its ID.

- **Method:** `DELETE`
- **URL:** `/api/admin/service-zones/:id`
- **Headers:**
    - `Authorization`: `Bearer <admin-jwt-token>`

**Example `curl` Request:**

```bash
curl -X DELETE http://localhost:8080/api/admin/service-zones/<service-zone-id> \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Success Response (`204 No Content`):**

(No content is returned for a successful DELETE operation)

#### Platform Analytics

Provides endpoints for admins to access platform-wide analytics and performance metrics. Requires `analytics:view` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/analytics/summary` | Retrieves a summary of all platform data (revenue, users, etc.). |
| `GET` | `/api/admin/analytics/top-restaurants` | Get a list of the top 10 performing restaurants by revenue. |
| `GET` | `/api/admin/analytics/top-riders` | Get a list of the top 10 performing riders by deliveries. |

**Example Request (Platform Summary):**

```bash
curl -X GET "http://localhost:8080/api/admin/analytics/summary" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Rider Management

Provides endpoints for admins to manage rider applications. Requires `riders:manage` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/riders/pending` | Retrieves a list of all riders awaiting approval. |
| `POST` | `/api/admin/riders/:id/approve` | Approves a rider's application and activates their account. |
| `DELETE` | `/api/admin/riders/:id/reject` | Rejects a rider's application and deletes their record. |

**Example Request (Get Pending Riders):**

```bash
curl -X GET "http://localhost:8080/api/admin/riders/pending" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Approve Rider

- **Endpoint:** `POST /api/admin/riders/:id/approve`
- **Description:** Approves a rider's application and activates their account. Once approved, the rider can log in using their registered email and password.
- **Handler:** `adminHandler.ApproveRider`

**Path Parameters:**

| Parameter | Type   | Description                               |
| :-------- | :----- | :---------------------------------------- |
| `id`      | string | The unique ID of the rider to approve.    |

**Example `curl` Request:**

```bash
curl -X POST http://localhost:8080/api/admin/riders/a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6/approve \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

**Success Response (200 OK):**

```json
{
    "message": "Rider approved successfully",
    "rider": {
        "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "name": "John Doe",
        "email": "john.doe@example.com",
        "isApproved": true,
        "status": "offline"
    }
}
```

#### Admin Support Endpoints

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/support/tickets` | Get a list of all tickets (filterable by status). |
| `POST` | `/api/admin/support/tickets/:ticket_id/assign` | Assign a ticket to an agent. |
| `PATCH` | `/api/admin/support/tickets/:ticket_id/status` | Update the status of a ticket. |

**Get all open tickets:**

```bash
curl -X GET "http://localhost:8080/api/admin/support/tickets?status=open" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

#### Rider Vehicle Management

Provides endpoints for admins to manage rider vehicle applications. Requires `riders:manage` permission.

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/admin/riders/vehicles/pending` | Retrieves a list of all rider vehicles awaiting approval. |
| `POST` | `/api/admin/riders/vehicles/:vehicle_id/approve` | Approves a rider's vehicle. |
| `POST` | `/api/admin/riders/vehicles/:vehicle_id/reject` | Rejects a rider's vehicle. |

**Example Request (Get Pending Rider Vehicles):**

```bash
curl -X GET "http://localhost:8080/api/admin/riders/vehicles/pending" \
  -H "Authorization: Bearer <admin-jwt-token>"
```

**Success Response (200 OK):**

```json
[
    {
        "id": "v1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "riderId": "r1d2e3f4-g5h6-i7j8-k9l0-m1n2o3p4q5r6",
        "vehicleType": "motorcycle",
        "licensePlate": "ABC-123",
        "model": "Honda Click",
        "color": "Red",
        "status": "pending_approval"
    }
]
```

**Approve Rider Vehicle:**

- **Endpoint:** `POST /api/admin/riders/vehicles/:vehicle_id/approve`
- **Description:** Approves a rider's vehicle.
- **Handler:** `adminHandler.ApproveRiderVehicle`

**Path Parameters:**

| Parameter    | Type   | Description                               |
| :----------- | :----- | :---------------------------------------- |
| `vehicle_id` | string | The unique ID of the vehicle to approve.  |

**Example `curl` Request:**

```bash
curl -X POST http://localhost:8080/api/admin/riders/vehicles/v1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6/approve \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>"
```

**Success Response (200 OK):**

```json
{
    "message": "Rider vehicle approved successfully",
    "vehicle": {
        "id": "v1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "riderId": "r1d2e3f4-g5h6-i7j8-k9l0-m1n2o3p4q5r6",
        "vehicleType": "motorcycle",
        "licensePlate": "ABC-123",
        "model": "Honda Click",
        "color": "Red",
        "status": "approved"
    }
}
```

**Reject Rider Vehicle:**

- **Endpoint:** `POST /api/admin/riders/vehicles/:vehicle_id/reject`
- **Description:** Rejects a rider's vehicle.
- **Handler:** `adminHandler.RejectRiderVehicle`

**Path Parameters:**

| Parameter    | Type   | Description                               |
| :----------- | :----- | :---------------------------------------- |
| `vehicle_id` | string | The unique ID of the vehicle to reject.   |

**Request Body:**

```json
{
    "reason": "Vehicle does not meet safety standards."
}
```

**Example `curl` Request:**

```bash
curl -X POST http://localhost:8080/api/admin/riders/vehicles/v1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6/reject \
  -H "Authorization: Bearer <YOUR_ADMIN_JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Vehicle does not meet safety standards."
  }'
```

**Success Response (200 OK):**

```json
{
    "message": "Rider vehicle rejected successfully",
    "vehicle": {
        "id": "v1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
        "riderId": "r1d2e3f4-g5h6-i7j8-k9l0-m1n2o3p4q5r6",
        "vehicleType": "motorcycle",
        "licensePlate": "ABC-123",
        "model": "Honda Click",
        "color": "Red",
        "status": "rejected",
        "approvalNotes": "Vehicle does not meet safety standards."
    }
}
```

**Assign a ticket:**

```bash
curl -X POST http://localhost:8080/api/admin/support/tickets/<ticket-id>/assign \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "<agent-user-id>"
  }'
```

**Update ticket status:**

```bash
curl -X PATCH http://localhost:8080/api/admin/support/tickets/<ticket-id>/status \
  -H "Authorization: Bearer <admin-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in_progress"
  }'
```

### Real-time Order Tracking (WebSocket)

The system provides real-time updates for order status and rider location via WebSockets. This allows the frontend to build a live tracking experience for the user.

#### Connection

To receive updates for a specific order, the client must establish a WebSocket connection to the following endpoint:

| Method | Endpoint | Description | 
| :--- | :--- | :--- |
| `GET` | `/api/ws/track/:order_id` | Establishes a WebSocket connection for a specific order. |

**Authentication:** This endpoint is public and does not require a JWT token. Authorization is implicit through knowledge of the unique `order_id`.

**Example Connection (`wscat`):**

```bash
wscat -c "ws://localhost:8080/api/ws/track/<your-order-id>"
```

#### Incoming Messages

Once connected, the client can expect to receive the following message types in JSON format. The `type` field indicates the kind of update.

##### 1. Order Status Update

Sent when the order's status changes (e.g., accepted, preparing, delivered).

**Message `type`:** `ORDER_STATUS_UPDATE`

**Payload:**

```json
{
  "type": "ORDER_STATUS_UPDATE",
  "orderId": "a1b2c3d4-..",
  "status": "delivering",
  "timestamp": "2025-09-17T12:30:00Z"
}
```

##### 2. Rider Location Update

Sent periodically by the rider's device while they are on an active delivery.

**Message `type`:** `RIDER_LOCATION_UPDATE`

**Payload:**

```json
{
  "type": "RIDER_LOCATION_UPDATE",
  "orderId": "a1b2c3d4-..",
  "riderId": "r1s2t3u4-..",
  "latitude": 13.7563,
  "longitude": 100.5018
}
```