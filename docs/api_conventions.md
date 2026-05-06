## API Conventions

### Standardized Error Responses

To ensure consistency and predictability, the API uses a standardized format for error responses. This makes it easier for frontend clients to handle errors systematically. The new error handling logic is located in `internal/utils/error_response.go`.

#### 1. Generic Errors

For general errors (e.g., "not found," "internal server error"), use the `utils.SendError` function.

- **Function Signature:** `func SendError(c *gin.Context, statusCode int, code string, message string)`
- **Example:**
  - **Before:** `c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})`
  - **After:** `utils.SendError(c, http.StatusNotFound, "USER_NOT_FOUND", "User not found")`
- **Resulting JSON:**
  ```json
  {
    "error": {
      "code": "USER_NOT_FOUND",
      "message": "User not found"
    }
  }
  ```

#### 2. Validation Errors

For errors that occur during input validation with `c.ShouldBindJSON()`, use the `utils.SendValidationError` function. It automatically parses the validation errors and formats them.

- **Function Signature:** `func SendValidationError(c *gin.Context, err error)`
- **Example:**
  - **Before:**
    ```go
    if err := c.ShouldBindJSON(&input); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }
    ```
  - **After:**
    ```go
    if err := c.ShouldBindJSON(&input); err != nil {
        utils.SendValidationError(c, err)
        return
    }
    ```
- **Resulting JSON:** This provides detailed feedback on which fields failed validation.
  ```json
  {
    "code": "VALIDATION_ERROR",
    "errors": [
      {
        "field": "Email",
        "message": "Invalid email format"
      },
      {
        "field": "Password",
        "message": "Should be at least 8 characters"
      }
    ]
  }
  ```
