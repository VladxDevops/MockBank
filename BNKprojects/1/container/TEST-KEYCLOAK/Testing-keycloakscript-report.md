# Keycloak Test Script - Troubleshooting and Improvements Report

## 1. Findings

During the initial execution of the `test-keycloak.sh` script, the internal validation (Method A) consistently failed to fetch the Keycloak Admin Token. Analysis of the Cloud Run logs and the GCP configuration revealed the following:

*   **Database Resource Constraints:** The Cloud SQL instance (`keycloak-db-4d1747e6`) is deployed on the `db-f1-micro` tier. This tier is highly resource-constrained and prone to connection exhaustion during peak load or cold starts.
*   **JDBC Connection Pool Exhaustion:** Keycloak was experiencing severe database connection issues, leading to an `Acquisition timeout` when attempting to execute scheduled tasks or authenticate users. 
*   **Incorrect Secret Name:** The `test-keycloak.sh` script was attempting to fetch the admin password using the secret name `keycloak-admin-password`. However, the actual secret provisioned in GCP Secret Manager is named `keycloak-administrator-password`. This caused a `NOT_FOUND` error and forced a fallback to the default "admin" password, which hampered authentication.

## 2. Changes Made to `test-keycloak.sh`

To address these issues and make the script more resilient, the following changes were implemented:

1.  **Corrected Secret Reference:** Updated the script to fetch the admin password from the correct Secret Manager secret (`keycloak-administrator-password`).
2.  **Pre-flight Infrastructure Checks:** Added a `check_infrastructure_health` function. This function queries the Cloud SQL instance and VPC Connector states. It explicitly warns the user if the database is running on the `db-f1-micro` tier, alerting them to the potential for JDBC timeouts.
3.  **Retry Logic for Token Fetch:** Implemented a retry loop with exponential backoff (up to 3 attempts, 5 seconds apart) within the `run_internal_validation` function. This allows the script to gracefully handle transient `Acquisition timeout` errors during cold starts.
4.  **Increased Proxy Wait Time:** Extended the `setup_method_a` proxy health check wait time from 15 to 30 seconds to allow the Cloud Run container sufficient time to initialize, especially given the underpowered database.
5.  **Enhanced Diagnostic Hints:** Added contextual error messages directing the user to specific troubleshooting scenarios in `TROUBLESHOOTING.md` when the token fetch fails.

*Additionally, independent of the script, the `KC_DB_POOL_MAX_SIZE` environment variable on the Cloud Run service was reduced from `100` to `20` to better align with the `db-f1-micro` tier's capacity limits.*

## 3. Reasons and Resolutions

*   **Reason:** The script was failing because it could not authenticate (due to the wrong password secret) and because the database was overwhelmed by Keycloak's default connection pool size on a micro instance.
*   **Resolution:** By updating the secret name, implementing retry logic, and tuning down the database pool size via Cloud Run environment variables, the script and the service can now successfully retrieve the Keycloak Admin Token and validate the internal API.
*   **Current Status:** The script correctly confirms that the `Mockbankrealm` exists and that the `retail-app` client enforces the `PKCE S256` policy.

## 4. Verbatim Log Quotes

### JDBC Acquisition Timeout (Cloud Run Logs)
```text
Caused by: java.util.concurrent.TimeoutException
Caused by: java.sql.SQLException: Acquisition timeout while waiting for new connection
        at org.hibernate.engine.jdbc.spi.SqlExceptionHelper.convert(SqlExceptionHelper.java:94)
        at org.hibernate.engine.jdbc.spi.SqlExceptionHelper.convert(SqlExceptionHelper.java:108)
        at org.hibernate.exception.internal.StandardSQLExceptionConverter.convert(StandardSQLExceptionConverter.java:63)
2026-04-10 10:18:37,638 ERROR [org.keycloak.services.scheduled.ScheduledTaskRunner] (Timer-0) Failed to run scheduled task ClearExpiredEvents: org.hibernate.exception.GenericJDBCException: Unable to acquire JDBC Connection [Acquisition timeout while waiting for new connection] [n/a]
2026-04-10 10:18:26,239 ERROR [org.hibernate.engine.jdbc.spi.SqlExceptionHelper] (Timer-0) Acquisition timeout while waiting for new connection
2026-04-10 10:18:25,738 WARN  [org.hibernate.engine.jdbc.spi.SqlExceptionHelper] (Timer-0) SQL Error: 0, SQLState: null
```

### Secret Manager Error (Manual Execution)
```text
ERROR: (gcloud.secrets.versions.access) NOT_FOUND: Secret [projects/466592165334/secrets/keycloak-admin-password] not found or has no versions.
```
