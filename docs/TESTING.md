# Testing Guide

This document provides comprehensive information about testing the backend application.

## Overview

The backend application includes a comprehensive testing suite covering:
- Unit tests for services and handlers
- Integration tests for complete workflows
- Performance benchmarks
- Mock-based testing

## Test Structure

```
tests/
  test_config.go              # Test configuration and utilities
  rider_integration_test.go   # Rider V2 integration tests
  
internal/
  services/
    rider_service_v2_test.go  # Rider service unit tests
  handlers/
    rider_handler_v2_test.go  # Rider handler unit tests
```

## Running Tests

### All Tests
```bash
make test
```

### Rider-Specific Tests
```bash
make test-rider
```

### Integration Tests
```bash
make test-integration
```

### Unit Tests Only
```bash
make test-unit
```

### Performance Benchmarks
```bash
make test-performance
```

### Coverage Report
```bash
make test-coverage
```

## Test Categories

### 1. Unit Tests
- **Purpose**: Test individual functions and methods in isolation
- **Location**: `internal/services/*_test.go`, `internal/handlers/*_test.go`
- **Tools**: testify, mock, gomock

#### Example: Service Test
```go
func TestRiderService_GetRiderProfile(t *testing.T) {
    // Setup
    mockService := new(MockRiderService)
    riderID := uuid.New()
    
    // Mock expectations
    mockService.On("GetRiderProfile", riderID).Return(expectedProfile, nil)
    
    // Execute
    profile, err := mockService.GetRiderProfile(riderID)
    
    // Assert
    assert.NoError(t, err)
    assert.Equal(t, expectedProfile.ID, profile.ID)
    mockService.AssertExpectations(t)
}
```

### 2. Integration Tests
- **Purpose**: Test complete workflows and API endpoints
- **Location**: `tests/*_test.go`
- **Database**: In-memory SQLite for isolation

#### Example: Integration Test
```go
func (suite *RiderIntegrationTestSuite) TestRiderFullWorkflow() {
    // Create test data
    user := suite.createTestUser("test-rider", "rider@test.com", "rider")
    
    // Test API endpoint
    w := httptest.NewRecorder()
    req := httptest.NewRequest("GET", "/api/rider/profile", nil)
    req.Header.Set("X-User-ID", user.ID.String())
    
    suite.router.ServeHTTP(w, req)
    
    // Assert response
    assert.Equal(t, http.StatusOK, w.Code)
}
```

### 3. Performance Tests
- **Purpose**: Benchmark critical operations
- **Location**: `tests/*_test.go` (Benchmark functions)
- **Tools**: Go's built-in testing package

#### Example: Benchmark Test
```go
func BenchmarkRiderService_GetNearbyRiders(b *testing.B) {
    // Setup
    mockService := new(MockRiderService)
    
    // Reset timer
    b.ResetTimer()
    
    // Run benchmark
    for i := 0; i < b.N; i++ {
        _, err := mockService.GetNearbyRiders(lat, lng, radius, vehicleType)
        if err != nil {
            b.Fatalf("Unexpected error: %v", err)
        }
    }
}
```

## Test Configuration

### Environment Setup
Tests use a separate configuration:
- **Database**: In-memory SQLite
- **Logging**: Silent mode
- **Environment**: Test mode

### Test Database
```go
func GetTestDB() *gorm.DB {
    db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{
        Logger: logger.Silent,
    })
    if err != nil {
        log.Fatalf("Failed to connect to test database: %v", err)
    }
    return db
}
```

### Mock Services
Generate mocks using:
```bash
make mocks
```

## Test Coverage

### Coverage Targets
- **Services**: 80% minimum
- **Handlers**: 80% minimum
- **Integration**: 70% minimum
- **Overall**: 75% minimum

### Coverage Report
```bash
make test-coverage
```
This generates:
- `coverage.out` - Raw coverage data
- `coverage.html` - HTML coverage report

## Test Data Management

### Test Fixtures
- Created dynamically in tests
- Cleaned up automatically
- Isolated between test runs

### Example: Test Data Creation
```go
func (suite *RiderIntegrationTestSuite) createTestUser(username, email, role string) *models.User {
    user := &models.User{
        Username: username,
        Email:    email,
        Role:     role,
        Password: "hashed_password",
    }
    
    suite.db.Create(user)
    return user
}
```

## API Testing

### HTTP Testing
Use `httptest` for HTTP endpoint testing:
```go
func TestAPIEndpoint(t *testing.T) {
    w := httptest.NewRecorder()
    req := httptest.NewRequest("GET", "/api/rider/profile", nil)
    req.Header.Set("Authorization", "Bearer "+token)
    
    router.ServeHTTP(w, req)
    
    assert.Equal(t, http.StatusOK, w.Code)
}
```

### Authentication Testing
Mock JWT middleware:
```go
router.Use(func(c *gin.Context) {
    userID := c.GetHeader("X-User-ID")
    if userID != "" {
        c.Set("user_id", userID)
    }
    c.Next()
})
```

## Performance Testing

### Benchmark Categories
1. **Database Operations**: Query performance
2. **API Endpoints**: Response time
3. **Business Logic**: Algorithm efficiency
4. **Concurrent Operations**: Scalability

### Running Benchmarks
```bash
make test-performance
```

### Benchmark Results
```
BenchmarkRiderService_GetNearbyRiders-8   	  100000	     12345 ns/op	    2048 B/op	      12 allocs/op
BenchmarkRiderHandler_GetProfile-8        	  200000	      6789 ns/op	    1024 B/op	       8 allocs/op
```

## Error Testing

### Error Scenarios
- Invalid input validation
- Database connection errors
- Authentication failures
- Authorization failures
- Business logic violations

### Example: Error Test
```go
func TestRiderService_GetRiderProfile_Error(t *testing.T) {
    mockService := new(MockRiderService)
    riderID := uuid.New()
    
    mockService.On("GetRiderProfile", riderID).Return(nil, gorm.ErrRecordNotFound)
    
    profile, err := mockService.GetRiderProfile(riderID)
    
    assert.Error(t, err)
    assert.Nil(t, profile)
    assert.Equal(t, gorm.ErrRecordNotFound, err)
}
```

## Continuous Integration

### GitHub Actions
Tests run automatically on:
- Pull requests
- Push to main branch
- Release candidates

### CI Configuration
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
      - run: make test
      - run: make test-coverage
```

## Best Practices

### 1. Test Organization
- Group related tests in test suites
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

### 2. Mock Usage
- Mock external dependencies
- Use interfaces for mocking
- Verify mock expectations

### 3. Data Management
- Use test fixtures
- Clean up test data
- Isolate test runs

### 4. Performance
- Benchmark critical paths
- Monitor test execution time
- Optimize slow tests

### 5. Coverage
- Aim for high coverage
- Focus on business logic
- Review coverage gaps

## Troubleshooting

### Common Issues

#### 1. Database Connection Errors
```bash
# Reset test database
make db-reset
```

#### 2. Mock Generation Issues
```bash
# Regenerate mocks
make mocks
```

#### 3. Test Failures
```bash
# Run specific test
go test -v ./tests/... -run TestSpecificFunction

# Run with verbose output
go test -v ./...
```

#### 4. Coverage Issues
```bash
# Check coverage for specific package
go test -coverprofile=coverage.out ./internal/services/
go tool cover -html=coverage.out -o coverage.html
```

## Test Metrics

### Key Metrics
- **Test Count**: Number of tests
- **Coverage**: Code coverage percentage
- **Pass Rate**: Percentage of passing tests
- **Execution Time**: Total test execution time
- **Performance**: Benchmark results

### Monitoring
- Track test metrics over time
- Set up alerts for test failures
- Monitor performance regressions

## Contributing

### Adding New Tests
1. Follow existing test patterns
2. Use appropriate test type (unit/integration)
3. Add to Makefile targets if needed
4. Update documentation

### Test Review Checklist
- [ ] Test covers happy path
- [ ] Test covers error scenarios
- [ ] Test uses proper assertions
- [ ] Test cleans up resources
- [ ] Test has descriptive name
- [ ] Test follows project conventions

## Resources

### Documentation
- [Go Testing Package](https://golang.org/pkg/testing/)
- [Testify Documentation](https://github.com/stretchr/testify)
- [Gin Testing Guide](https://gin-gonic.com/docs/examples/testing)

### Tools
- [golangci-lint](https://golangci-lint.run/)
- [mockgen](https://github.com/golang/mock)
- [goose](https://github.com/pressly/goose)

### Examples
- [Go Testing Patterns](https://github.com/golang/go/wiki/Testing)
- [Test-Driven Development](https://go.dev/blog/test-driven-development)
- [Table-Driven Tests](https://go.dev/blog/subtests)
