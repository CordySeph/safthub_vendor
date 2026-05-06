# Testing System Revamp Plan for backend-go

This document outlines a comprehensive plan for revamping the testing system for the `backend-go` project from scratch. The goal is to establish a robust, maintainable, and efficient testing strategy.

## Overall Philosophy

*   **Layered Testing:** Implement unit, integration, and (optionally) end-to-end tests to cover different levels of application functionality.
*   **Clear Separation of Concerns:** Tests should focus on a single aspect: unit tests for individual functions/methods, integration tests for interactions between components, and E2E tests for full system flows.
*   **Fast Feedback:** Prioritize fast-executing unit tests to provide quick feedback during development, reserving slower integration and E2E tests for less frequent runs (e.g., in Continuous Integration).
*   **Maintainability:** Emphasize writing clear, readable, and well-structured tests that are easy to understand and update.
*   **Test Data Management:** Implement effective strategies for managing test data, such as database seeding and transaction-based rollbacks, to ensure test isolation and repeatability.

---

## Phase 1: Foundation & Unit Testing (High Priority)

This phase focuses on making the codebase testable at a granular level and implementing isolated unit tests.

1.  **Frameworks/Libraries:**
    *   **Go's `testing` package:** The standard library for all basic test execution.
    *   **`stretchr/testify`:** A widely used assertion toolkit and mocking framework (`mock` sub-package) that is already a dependency in the project.
    *   **`gopkg.in/h2non/gock.v1` (or similar):** For mocking external HTTP requests (e.g., to services like OSRM, FCM, or any other third-party APIs).

2.  **Strategy:**
    *   **Unit Tests:** Develop tests that focus on individual functions, methods, or small components, ensuring their internal logic is correct. All external dependencies (database, external APIs, other services) should be mocked.
    *   **Mocks:** Create mock interfaces for services, repositories, and external clients to effectively isolate the unit under test.

3.  **Implementation Steps:**
    *   **Define Repository Interfaces:** For each service that interacts with the database (e.g., `OrderService`, `RestaurantService`, `UserService`, `RecommendationService`), define a corresponding interface (e.g., `OrderRepository`, `RestaurantRepository`, `UserRepository`, `RecommendationRepository`). This abstracts the database access logic.
    *   **Implement Database Repositories:** Create concrete implementations of these repository interfaces that interact with `gorm.DB` (e.g., `GormOrderRepository`).
    *   **Refactor Services for Dependency Injection:** Modify service constructors (e.g., `NewOrderService`) to accept their dependencies (such as repository interfaces and other service interfaces) as arguments instead of directly calling `db.GetDB()` or `NewSomeService()`. This makes services easily testable by allowing mock dependencies to be injected.
    *   **Implement Mock Repositories:** Create mock implementations for the defined repository interfaces using `stretchr/testify/mock`. These mocks will simulate database interactions without needing an actual database connection during unit tests.
    *   **Write Unit Tests for Services:** Develop comprehensive unit tests for the core business logic within each service. These tests will inject mock repositories and other mock services to ensure the service's logic functions correctly in isolation.
    *   **Write Unit Tests for Handlers:** Create unit tests for API handlers, focusing on request parsing, validation, and calling the appropriate service methods. These tests will inject mock service layers to avoid external dependencies.

---

## Phase 2: Integration Testing (Medium Priority)

This phase focuses on testing the interactions between different components, typically involving a real database.

1.  **Strategy:**
    *   **Dedicated Test Database:** Utilize a dedicated PostgreSQL database instance for integration tests to ensure a realistic environment.
    *   **Robust Database Setup/Teardown:** Implement a centralized `TestMain` function (located, for example, in a `cmd/server` or `internal/testutils` package) to manage the test database lifecycle:
        *   Establish a connection to the test database.
        *   Automatically run all necessary database migrations.
        *   Seed essential baseline data (e.g., roles, default users) before each test run or test suite.
        *   Implement mechanisms to truncate relevant tables or rollback transactions before each individual test case to ensure test isolation.
    *   **Test Scenarios:** Focus on testing the interaction paths:
        *   Between a service and its repository.
        *   Between a handler, a service, and its underlying repository/database.
        *   Between different services.
    *   **HTTP Testing:** Use Go's `net/http/httptest` package (`httptest.NewRecorder` and `httptest.NewRequest`) to simulate HTTP requests against the Gin router, capturing and asserting on the HTTP responses.

2.  **Implementation Steps:**
    *   **`internal/testutils` Package:** Create a new package `internal/testutils` to centralize helper functions for database setup, test data generation, and other common testing patterns.
    *   **Integration Tests for Repositories:** Write tests specifically for the repository implementations to verify they correctly persist and retrieve data from the database.
    *   **Integration Tests for Services:** Test service methods that involve complex database interactions, transactions, or dependencies on other services. These tests will use the real test database.
    *   **Integration Tests for API Endpoints:** Develop tests that cover the full request-response cycle for API endpoints, including the Gin router, middleware, handlers, services, and database interactions.

---

## Phase 3: End-to-End Testing (Lower Priority / Future)

This phase covers testing the complete system as a whole, typically from a user's perspective.

1.  **Frameworks/Tools (Consideration):**
    *   **`Godog` (Behavior-Driven Development):** A framework for writing high-level, human-readable tests that describe the system's behavior.
    *   **`Selenium` / `Playwright`:** If the project includes a frontend, these tools would be used for simulating user interactions with the UI. (This is generally out of scope for a backend-only revamp but mentioned for completeness of E2E testing).

2.  **Strategy:**
    *   Test critical user flows that span multiple services and potentially external systems (e.g., user registration, login, placing an order, tracking delivery, submitting a review).
    *   Ideally run against a fully deployed staging environment that closely mirrors production.

---

## Phase 4: Code Coverage & CI/CD Integration

This phase integrates testing into the development workflow and monitors test quality.

1.  **Code Coverage:**
    *   Utilize Go's built-in tools: `go test -cover` to generate coverage profiles and `go tool cover -html` to view reports.
    *   Set clear and achievable targets for code coverage (e.g., aiming for 80% or higher for unit tests of critical paths).

2.  **CI/CD Integration:**
    *   Configure Continuous Integration tools (e.g., GitHub Actions, GitLab CI, Jenkins) to automatically run all tests on every pull request and push to main branches.
    *   Integrate linting (`golangci-lint`), static analysis, and security scanning tools into the CI pipeline to maintain code quality and identify potential issues early.

---

## Next Steps

I recommend starting with **Phase 1: Foundation & Unit Testing**. The immediate actionable items are:

1.  **Define Repository Interfaces:** For core entities like `Order`, `Restaurant`, `User`, and `Recommendation`.
2.  **Refactor Service Constructors:** To accept these newly defined interfaces, enabling dependency injection.
3.  **Implement Mock Repositories:** To facilitate isolated testing of service logic.

This approach will significantly enhance the testability and maintainability of the `backend-go` codebase.
