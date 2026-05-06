## Prerequisites

- [Go](https://golang.org/doc/install) (version 1.24.4 or later)
- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Installation

1. **Clone the repository:**

    ```bash
    git clone https://github.com/cordyseph/backend-go.git
    cd backend-go
    ```

2. **Install Go modules:**

    ```bash
    go mod tidy
    ```

## Configuration

1. **Create a `.env` file:**

    Create a `.env` file in the root directory of the project and add the following environment variables.

    ```env
    PORT=8080

    DB_HOST=localhost
    DB_PORT=5432
    DB_USER=postgres
    DB_PASSWORD=password123
    DB_NAME=backend_go_db

    JWT_SECRET=YOUR_GENERATED_SECRET
    JWT_EXPIRES_IN=72h

    FRONTEND_URL=http://localhost:3000

    SMTP_HOST=smtp.gmail.com
    SMTP_PORT=587
    SMTP_EMAIL=your.email@gmail.com
    SMTP_PASSWORD=your_app_password
    ```

2. **Generate a JWT Secret:**

    Use the built-in CLI command to generate a secure secret key:

    ```bash
    go run cmd/jwtgen/main.go
    ```

    Copy the generated secret and paste it into the `JWT_SECRET` field in your `.env` file.

## Running the Project

You can run the project using Docker (recommended) or natively.

### Using Docker

The `docker-compose.yml` file is configured to start the following services:

- **PostgreSQL:** A PostgreSQL database server.
- **pgAdmin:** A web-based administration tool for PostgreSQL.
- **Redis:** An in-memory data structure store.

To start the services, run the following command:

```bash
docker-compose up --build -d
```

To view logs for the backend application:

```bash
docker compose logs -f backend
```

To stop and remove all services:

```bash
docker-compose down
```

The services will be available at the following addresses:

- **PostgreSQL:** `localhost:5432`
- **pgAdmin:** `http://localhost:5050`
- **Redis:** `localhost:6379`

### Running Natively

To run the project natively, execute the following command:

```bash
go run cmd/server/main.go
```

The server will start on `http://localhost:8080`.

### Building and Running with Docker

Alternatively, you can build a Docker image of the application and run it as a standalone container.

**1. Build the Docker Image**

Use the `docker build` command from the project's root directory:

```bash
docker build -t backend-go-app .
```

This command builds an image based on the `Dockerfile` and tags it as `backend-go-app`.

**2. Run the Docker Container**

Before running, ensure your `.env` file is configured correctly. When running the application inside a Docker container, it cannot connect to services on `localhost`. You must change `DB_HOST` to `host.docker.internal` to connect to the PostgreSQL database running on your host machine.

```env
# .env file
DB_HOST=host.docker.internal
```

Now, run the container using the following command:

```bash
docker run --rm -p 8080:8080 --env-file .env backend-go-app
```

- `--rm`: Automatically removes the container when it exits.
- `-p 8080:8080`: Maps port 8080 from your local machine to port 8080 in the container.
- `--env-file .env`: Provides the environment variables from your `.env` file to the container.

## Testing

To run all the tests in the project, use the following command from the root directory:

```bash
go test ./...
```

This command will discover and run all test files (files ending with `_test.go`) in the project.

### Generating a Test Verification Token

For testing the email verification endpoint manually, you can use the `gentoken` utility. This script creates a new, unverified user in the database and prints a valid verification token to the console.

**1. Run the script:**

Make sure your database is running and your `.env` file is correctly configured. Then, run the following command from the project root:

```bash
go run cmd/gentoken/main.go EMAIL@VERIFICATION.COM
```

**2. Copy the Token:**

The script will output the generated token:

```token
--- Verification Token ---
abcdef1234567890...
--------------------------
```

**3. Test the Endpoint:**

Use the copied token to make a `GET` request to the verification endpoint:

```bash
curl -X GET http://localhost:8080/api/auth/verify-email?token=<your_token_here>
```

A successful verification will return:

```json
{
  "message": "email verified successfully"
}
```

## Monitoring

The project is equipped with a monitoring stack using Prometheus and Grafana, which are defined in the `docker-compose.yml` file.

- **Prometheus:** Collects metrics from the application. The Go application exposes a `/metrics` endpoint for this purpose.
- **Grafana:** Visualizes the data collected by Prometheus.

### How to Use

1. **Start all services:**

    ```bash
    docker compose up -d
    ```

2. **Access the services:**

    - **Prometheus:** Open `http://localhost:9090` in your browser. You can explore metrics and see the status of the `backend-go` target.
    - **Grafana:** Open `http://localhost:3001` in your browser. Log in with the default credentials (`admin` / `admin`).

3. **Configure Grafana:**

    - **Add Data Source:**

        - Go to Configuration (cog icon) > Data Sources.
        - Click "Add data source".
        - Select "Prometheus".
        - Set the **Prometheus server URL** to `http://prometheus:9090`.
        - Click "Save & Test".

    - **Create a Dashboard:**
        - Go to Dashboards (four squares icon) > New Dashboard.
        - Click "Add new panel".
        - In the query editor, select your Prometheus data source.
        - In the "Metrics browser" input, you can enter a metric name like `gin_requests_total` to see the total number of HTTP requests, or `gin_request_duration_seconds_sum` to see the sum of request latencies.

## Frontend Setup

This project has a separate frontend. Follow these steps to run it locally.

### Download and Run

1. **Clone the frontend repository:**

    ```bash
    git clone https://github.com/CordySeph/frontend
    ```

2. **Navigate into the directory and install dependencies:**

    ```bash
    cd frontend
    npm install
    ```

3. **Start the development server:**

    ```bash
    npm run dev
    ```
