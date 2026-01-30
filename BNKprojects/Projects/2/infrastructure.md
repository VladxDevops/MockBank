This is a list of Cloud Infrastructure that will be required for this project: 

Google Secret manager secrets: 


*   `mongo-uri`: The connection string for the MongoDB database.
*   `mongo-root-password`: The root password for MongoDB authentication.
*   `jwt-verification-key`: Public key to verify OIDC tokens.

Required GCP Services:
*   **Cloud Run**: To host the Node.js microservice (Serverless).
*   **Artifact Registry**: To store the Docker container images.
*   **Secret Manager**: To store and serve the secrets listed above.
*   **Cloud IAM**: To manage the Service Account for the Cloud Run instance.
*   **Cloud Logging**: To capture application logs (stdout/stderr).
