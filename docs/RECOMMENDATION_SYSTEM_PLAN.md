# Recommendation System Implementation Plan

This document outlines the plan to build a recommendation system for the food delivery application. The goal is to suggest relevant restaurants and menu items to users, enhancing their experience and driving engagement.

## Phase 1: Foundational Models & Services

This phase focuses on creating the necessary data structures and service stubs.

1.  **`UserPreference` Model:**
    *   **File:** `internal/models/user_preference.go`
    *   **Purpose:** To store users' explicit preferences, which act as strong signals for the recommendation engine.
    *   **Fields:**
        *   `UserID` (FK to `users.id`)
        *   `FavoriteCategories` (`[]string`)
        *   `PriceRangePreference` (`string`)

2.  **`RecommendedItem` Model:**
    *   **File:** `internal/models/recommended_item.go`
    *   **Purpose:** To store pre-calculated recommendations for each user, ensuring fast API response times.
    *   **Fields:**
        *   `UserID` (FK to `users.id`)
        *   `RecommendedItemID` (Can be a `RestaurantID` or `MenuID`)
        *   `RecommendationType` (e.g., `"popular"`, `"for_you"`)
        *   `Score` (A float to rank the recommendations)
        *   `GeneratedAt` (Timestamp)

3.  **`recommendation_service.go`:**
    *   **File:** `internal/services/recommendation_service.go`
    *   **Purpose:** To encapsulate the core business logic for generating all types of recommendations.
    *   **Initial Methods (Stubs):**
        *   `GeneratePopularRestaurants(location, priceRange)`
        *   `GenerateForYouRecommendations(userID)`
        *   `GenerateSimilarItemRecommendations(menuID)`

## Phase 2: Recommendation Generation (Batch Processing)

This phase involves creating a background process to perform the computationally intensive task of generating recommendations.

1.  **Background Job:**
    *   **Technology:** Use a job scheduler like `gocron` or a simple Go routine with a ticker.
    *   **Frequency:** Run periodically (e.g., every 24 hours).
    *   **Function:** The job will trigger the `recommendation_service` to generate and save recommendations to the `recommended_items` table.

2.  **"For You" Recommendation Logic:**
    *   **Algorithm:** A hybrid approach using collaborative filtering and content-based filtering.
    *   **Steps:**
        1.  Fetch the target user's order history.
        2.  Identify categories, price ranges, and specific items they have ordered.
        3.  **(Collaborative)** Find a set of "similar users" who have ordered similar items.
        4.  Recommend items that similar users have ordered but the target user has not.
        5.  **(Content-based)** Boost the score of items that match the user's `FavoriteCategories` and `PriceRangePreference` from their `UserPreference`.
        6.  Store the top N results in the `recommended_items` table.

3.  **"Popular" Recommendation Logic:**
    *   **Algorithm:** Based on overall order frequency, with location-based weighting.
    *   **Steps:**
        1.  Analyze all orders within a recent time window (e.g., last 7 days).
        2.  Count the occurrences of each `RestaurantID` and `MenuID`.
        3.  Apply a decay function so that newer orders have more weight.
        4.  When a user requests popular items, filter or boost results based on their location.

## Phase 3: API and UI Integration

This phase focuses on exposing the generated recommendations to the frontend application via an API.

1.  **`recommendation_handler.go`:**
    *   **File:** `internal/handlers/recommendation_handler.go`
    *   **Purpose:** To handle incoming HTTP requests for recommendations.
    *   **Method:** `GetRecommendations(c *gin.Context)`
        *   Reads the `UserID` from the JWT token.
        *   Fetches the pre-calculated recommendations from the `recommended_items` table.
        *   Supports filtering by `RecommendationType` via a query parameter (e.g., `/recommendations?type=for_you`).

2.  **API Route:**
    *   **File:** `internal/routes/api_routes.go` (or a relevant router file)
    *   **Endpoint:** `GET /v1/recommendations`
    *   **Handler:** `recommendationHandler.GetRecommendations`

3.  **Database Migrations:**
    *   Create new migration files for the `user_preferences` and `recommended_items` tables.
