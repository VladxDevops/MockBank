Project 2: 
Build Docker Application: Using the GCP Cloud Shell: 
gcloud auth configure-docker us-south1-docker.pkg.dev

cd to the directory where the Dockerfile is located:
cd /home/arisvargas/bankdir/Bank/BNKprojects/2/container

Build Docker Container: 
Build Image: 
docker build -t us-south1-docker.pkg.dev/bankproject-486308/<ARTIFACT_REGISTRY_REPOSITORY_ID>/transaction-service:v1 .
Template: docker build -t us-south1-docker.pkg.dev/bankproject-486308/<ARTIFACT_REGISTRY_REPOSITORY_ID>/transaction-service:v1 .

# Format: LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:TAG
docker tag bank-transaction-service:v1 us-south1-docker.pkg.dev/bankproject-486308/<ARTIFACT_REGISTRY_REPOSITORY_ID>/transaction-service:v1


Push Docker Image using Docker push: 
docker push us-south1-docker.pkg.dev/bankproject-486308/<ARTIFACT_REGISTRY_REPOSITORY_ID>/transaction-service:v1
Template: docker push us-central1-docker.pkg.dev/<YOUR_GCP_PROJECT_ID>/<REPO_NAME>/transaction-service:v1


Build and Deply to Cloud Run: 
Cd to BNKprojects/2/ and submit the build: #Already tested and it is running. 
gcloud builds submit --config container/cloudbuild.yaml .


Deploy Container to Cloud Run: 
gcloud run deploy transaction-service \
    --image us-south1-docker.pkg.dev/bankproject-486308/dev-mongodb-atlas-container/transaction-service:v1 \
    --region us-south1 \
    --no-allow-unauthenticated \
    --set-secrets MONGO_URI=transaction-service-db-connection-string:latest \
    --vpc-connector avechector \
    --vpc-egress all


Container Testing: 
Using the GCP`s Cloud Shell: 
Copy the Containers`s URL, output provided after completing previous step. Replace Placeholder "<YOUR_SERVICE_URL>" with it. 
Use curl to test the "transaction-service" container running in Cloud Run: 
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" <YOUR_SERVICE_URL>

Output should be: 
"Transaction Service is running. Use POST /transfer to initiate a transaction."

Set the folling variable replacing the place holder <YOUR_SERVICE_URL> with the Cloud Run URL: 
SERVICE_URL=$(gcloud run services describe transaction-service --region us-southl1 --format 'value(status.url)')

Or: 
SERVICE_URL=<YOUR_SERVICE_URL>


Test trasferfers system: 
# 2. Send the POST request with 'user_id'
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "1001",
    "toAccount": "2002",
    "amount": 50
  }' \
  "${SERVICE_URL}/transfer"

The transaction can also be see in: Mongodb Atlas website UI> Cluster > Browse Collections > transaction-db > journeys. 

Run query in mongo to find MFA verification status Failed: 
{
    "steps.step": "mfa_verification",
    "steps.status": "failed",
    "steps.error_code": "TIMEOUT"
}

or run this command from the mongodb terminal: 
1:
mongosh "mongodb+srv://<YOUR_CLUSTER_URL>/transaction-db" --username <YOUR_USER>

2:Switch to the database (if not already selected): 
use transaction-db

3: Run query: 
db.journeys.find({
    "steps.step": "mfa_verification",
    "steps.status": "failed",
    "steps.error_code": "TIMEOUT"
}).sort({ timestamp: -1 })