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
    sudo docker-compose up --build
    ```

## 3. Verification
*   **Access:** Open http://localhost:8080. You should see the "Welcome to Keycloak" landing page.
*   **DB Check:** If the page loads, the database connection is successful.
*   **Admin Console:** Click "Administration Console".
*   **Credentials:**
    *   Username: `admin`
    *   Password: `admin`
    *(Defined explicitly in `docker-compose.yaml` for local dev only)*


## 4. Troubleshooting Steps

**Note on Terminals:** If you ran `docker-compose up` without the `-d` flag, your current terminal (**Terminal A**) is locked. Open a second terminal (**Terminal B**) to run the commands below.

### 4.1 Discover Container Name
Before running `exec` or `stats`, find the exact name of your running container:
`sudo docker ps --format "table {{.Names}}\t{{.Status}}"`

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

### Docker Permission Denied
*   **Error:** `permission denied while trying to connect to the Docker daemon socket`.
*   **Fix:** Run with `sudo` or add your user to the docker group:
    ```bash
    sudo usermod -aG docker $USER
    newgrp docker
    ```

### Browser Error: Connection Refused
*   **Error:** `ERR_CONNECTION_REFUSED` or "This site can't be reached".
*   **Symptom:** `curl -i http://localhost:8080/health/live` returns `404 Not Found`.
    *   **Cause:** The health check extension is disabled.
    *   **Fix:** Ensure `KC_HEALTH_ENABLED=true` is set in the `Dockerfile` **before** the `kc.sh build` step. If using `start --optimized`, the feature must be enabled at build-time.
    *   **Test:** Try removing `--optimized` from the startup command in `docker-compose.yaml` to see if "auto-build" mode resolves the 404.
*   **Cause 2 (Most Likely):** Keycloak is still starting. Java applications can take 30-60 seconds to initialize.
    *   **Fix:** Watch the terminal logs. Wait until you see: `Listening on: http://0.0.0.0:8080`.
*   **Cause 3:** Container crashed.
    *   **Fix:** Check container status:
        ```bash
        sudo docker-compose ps
        ```
        If State is `Exit`, check logs for errors:
        ```bash
        sudo docker-compose logs keycloak
        ```

### Container Crash on Startup (Race Condition)
*   **Error:** `Connection to postgres:5432 refused` followed by `keycloak-1 exited with code 1`.
*   **Cause:** Keycloak tried to connect while Postgres was restarting during its initialization phase.
*   **Fix:** Ensure `docker-compose.yaml` has a `healthcheck` configured for Postgres and Keycloak waits for `service_healthy`.

### Verifying Health Check Extensions
If Cloud Run probes are failing with 404 even with `KC_HEALTH_ENABLED=true` set in Terraform:
1.  **Verify Image Configuration:** Check if the health extension was included during the build phase:
    ```bash
    sudo docker-compose exec keycloak /opt/keycloak/bin/kc.sh show-config | grep health
    ```
    **Note:** Seeing `kc.health-enabled = true (KcEnvVarConfigSource)` (even if multiple times) confirms the setting is active. If this is missing, the health endpoints will return 404.
2.  **Manual Endpoint Test:** Use curl from within the container or host:
    ```bash
    # From host
    curl -i http://localhost:8080/health/live
    ```
    A successful response should be `200 OK` with `{"status": "UP"}`.

## 5. Cleanup
Stop containers and remove volumes (resets local database state):
```bash
docker-compose down -v
```