# Local Keycloak Container Troubleshooting

This guide details how to build, run, and debug the Project 1 Keycloak container locally using Docker Compose.

## 1. Prerequisites
*   Docker installed and running.
*   `docker-compose` (or `docker compose` plugin).

## 2. Startup
1.  Navigate to the container directory:
    ```bash
    cd "BNKprojects/1/container"
    ```

2.  Start the environment (builds image and starts Postgres + Keycloak):
    ```bash
    docker-compose up --build
    ```

## 3. Verification
*   **Access:** Open http://localhost:8080.
*   **Admin Console:** Click "Administration Console".
*   **Credentials:**
    *   Username: `admin`
    *   Password: `admin`
    *(Defined explicitly in `docker-compose.yaml` for local dev only)*

## 4. Troubleshooting Steps

### View Logs
To see real-time logs if you ran in detached mode (`-d`), or to review history:
```bash
docker-compose logs -f keycloak
```

### Access Container Shell
If the container is running but behaving strangely, open a shell inside it to check files or network:
```bash
docker-compose exec keycloak /bin/bash
```

### Database Connection Issues
The local setup uses a dedicated Postgres container defined in the compose file.
*   **Host:** `postgres` (Service name in compose file).
*   **Port:** `5432`.
*   **User/Pass:** `keycloak` / `password`.

### Port Conflicts
*   **Error:** `Bind for 0.0.0.0:8080 failed: port is already allocated`.
*   **Fix:** Stop other services using port 8080 or modify `docker-compose.yaml` ports mapping (e.g., `"8081:8080"`).

## 5. Cleanup
Stop containers and remove volumes (resets local database state):
```bash
docker-compose down -v
```