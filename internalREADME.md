##Terraform: 

Use the following command to import cradentials: 

Cloud Shell: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/arisvargas/bankdir/Bank/bankproject-486308-34dfd0dbef72.json"

From Local: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"


Init: 
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project"

Enable GCP services: 
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=google_project_service.gcp_services
The Service account will need to have the necessary roles to enable the services. 

To deploy the empty Secrets: 
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.atlas_public_key_secret -target=module.atlas_private_key_secret



Start of the day: Local + Init + Plan + Apply:
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"&& \
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \
terraform plan -var-file="dev.tfvars" && \
terraform apply -auto-approve -var-file="dev.tfvars"


Then, PLAN + APPLY:
terraform plan -var-file="dev.tfvars" && \
terraform apply -auto-approve -var-file="dev.tfvars"


#Retrieve IP, use: 
curl -s ifconfig.me

Then: 
Add output IP to mongoDB Atlas, go to: 
Mongodb atlas UI/website > Select project name > Security >  Project identity and Access > Applications > API Keys > Actions > Edit access List > "Add access list entry" > Add IP > Save > done. 



#unlock Terraform State: 

terraform force-unlock 1770119740925764

If there is a terraform error stating that Mongo has issues with the IP: 
Go to: 
Mongodb atlas UI/website > Select project name > Security >  Project identity and Access > Applications > API Keys > Actions > Edit access List > "Add access list entry" > Add IP > Save > done. 


#Get MongoDB Atlas Public and private Keys: 
NEXT: 
Have terraform pull the private and public keys from the secret manager whe trying apply dev.tfvars. It is currently asking for them. Steps: 

Log in to the Mongodb Atlas account > on the left pane/menu click: Security > Public Identity and Access > Applications > API Keys> Copy the "public Key". May need to creater new API key to see the private kwy since it can only be seen at creation time. Click > Create API Key, Grant Project Owner Role/Permission, Copy keys, aadd them to Secret manager. Add IP. > Click on Done. 



Fix terraform Drifts: 
terraform apply -refresh-only
or
terraform apply -auto-approve -var-file="dev.tfvars" -refresh-only



#  Project 2: 
Build Docker Application: Using the GCP Cloud Shell: 
gcloud auth configure-docker us-south1-docker.pkg.dev

cd to the directory where the Dockerfile is located:
cd /home/arisvargas/bankdir/Bank/BNKprojects/2/container

Build Docker Container: 
Build Image: 
docker build -t us-south1-docker.pkg.dev/bankproject-486308/main-repository/transaction-service:v1 .
Template: docker build -t us-south1-docker.pkg.dev/bankproject-486308/main-repository/transaction-service:v1 .

## Format: LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:TAG
docker tag bank-transaction-service:v1 us-south1-docker.pkg.dev/bankproject-486308/main-repository/transaction-service:v1


Push Docker Image using Docker push: 
docker push us-south1-docker.pkg.dev/bankproject-486308/main-repository/transaction-service:v1
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



##  Project1: 

Declare Artifact registry repo where the KeyCloak container will be deployed/stored. Status: DONE. 

(The following 2 steps should be performed automatically by the pipeline in the future: 
reading the files from the repository(source of thrut: Github or Gitlab) build the container using cloud build, storing the container in artifact registry and deploying the container to Cloud Run)

First time Deploying: 
Mirror keycloak Image to Artifact registry using Cloud Build: Run the following commands: #Do this before terraform apply. 
# Assuming you are in the root directory of the project: Change directory to 1/container
gcloud builds submit . --config=mirror-keycloak.yaml \
  --substitutions=_REGION=us-south1,_REPOSITORY=project1-repo

Mirror keycloak Image to Artifact registry using Cloud Build:
new command with v1 tag, use this one: (Change directory to 1/container)
PROJECT_ID=$(gcloud config get-value project)
REPO_NAME="project1-repo" 
gcloud builds submit --tag us-south1-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/keycloak:v1 .


Start of the day: Local + Init + Plan + Apply:
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"&& \
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \
terraform plan -target=module.project1 -var-file="dev.tfvars" && \
terraform apply -auto-approve -target=module.project1 -var-file="dev.tfvars"


##Use the Python script with venv: 

Update the KEYCLOAK_URL in the .env file locate ad the src dir with the url provided by Cloud Run. 

Run in a sepparate terminal (before starting your Python script): 
gcloud run services proxy keycloak-service --region us-south1 --port 8888

#In a second separate terminal run: 
pip-sync requirements.txt

cd /Bank/BNKprojects/1/
python src/app.py

2
### Troubleshooting Project 1 State
If you manually delete the Cloud SQL instance and get 403 errors during deployment, follow these steps to clean up the state:
1. Navigate to the `terraform` directory.
2. Select the correct workspace: `terraform workspace select projectZERO`.
3. Run the cleanup commands:
   ```bash
   terraform state rm module.project1.google_sql_database.keycloak_schema
   terraform state rm module.project1.google_sql_user.keycloak_user
   terraform state rm module.project1.google_sql_database_instance.keycloak_db
   terraform taint module.project1.random_id.database_name_suffix
   ```
4. Re-run your deployment pipeline.


## Project3: 

#Very first time deploying: 
## Create terraform workspace: 

Change to terraform dir: 
cd terraform

#Create new terraform workspace: 
terraform workspace new project3

#Change to terraform workspace project3
terraform workspace select project3


#terraform apply: Double check terraform workspace is project3
Start of the day: Local + Init + Plan + Apply: Use the other one. 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"&& \
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \
terraform plan -var-file="dev.tfvars" && \
terraform apply -auto-approve -var-file="dev.tfvars"


#With -target=module.project3: This is the good one: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"&& \
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \
terraform plan -target=module.project3 -var-file="dev.tfvars" && \
terraform apply -auto-approve -target=module.project3 -var-file="dev.tfvars"


#REQUIRED: Local Terraform + Keycloak Provider (403 Forbidden Workaround)

**ERROR:** When running `terraform plan -target=module.project3` locally, you will encounter:
```
Error: error initializing keycloak provider
failed to perform initial login to Keycloak: error sending POST request to
https://keycloak-service-[PROJECT].us-south1.run.app/realms/master/protocol/openid-connect/token: 403 Forbidden
```

**WHY:** The Keycloak Cloud Run service is intentionally **private** (secure-by-default). Unauthenticated or unauthorized Terraform calls cannot reach the admin API.

**REQUIRED WORKAROUND (Every time you run terraform plan/apply targeting project3):**

**Step 1:** In Terminal 1, create a local authenticated proxy tunnel:
```bash
gcloud run services proxy keycloak-service --region us-south1 --port 8080 &
```
Wait for: `Proxy is successfully tunnelled to keycloak-service on http://127.0.0.1:8080`

**Step 2:** In Terminal 2, run terraform with the local proxy URL override:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"&& \
cd terraform && \
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \
terraform plan \
  -var-file="dev.tfvars" \
  -var="keycloak_url=http://127.0.0.1:8080" \
  -var="bootstrap=false" \
  -target=module.project3 && \
terraform apply -auto-approve \
  -var-file="dev.tfvars" \
  -var="keycloak_url=http://127.0.0.1:8080" \
  -var="bootstrap=false" \
  -target=module.project3
```

**Key Args:**
- `-var="keycloak_url=http://127.0.0.1:8080"` - Overrides the public HTTPS URL from dev.tfvars to use the local proxy.
- `-var="bootstrap=false"` - Disables bootstrap mode (use real credentials, not bootstrap creds).

**Note:** This workaround is **architectural and cannot be eliminated**. The alternative is to use GitHub Actions (`cd.yaml`), which handles the proxy setup automatically in the `configure-identity` job.

For full details, see: [ERROR_403_EXPLANATION.md](./ERROR_403_EXPLANATION.md) → "Known Unsolved Issue: Persistent 403 Forbidden in Local Development"

### Running Keycloak Identity Configuration via Cloud Build

If you want to apply the Identity Configuration (`module.project3`) using Google Cloud Build without building or pushing the Keycloak container, use the [cloudbuild-keycloak.yaml](file:///home/pochitawork/InterviewCloud%20Projects/Altmtrk2026/Bank/BNKprojects/1/container/cloudbuild-keycloak.yaml) configuration. 

This build pipeline:
1. Installs the required tools (`curl`, `unzip`, `jq`, and the `terraform` CLI) inside the build step.
2. Configures and launches the `gcloud run services proxy` component.
3. Authenticates to Cloud Run to create a secure tunnel on port `8080`.
4. Loops and waits for `/health/live` to return a `200` with `"UP"`.
5. Authenticates and applies the Project 3 identity modules targeting the local proxy endpoint.

To run this build pipeline, execute the following command from the root of the repository:
```bash
gcloud builds submit --config=BNKprojects/1/container/cloudbuild-keycloak.yaml \
  --substitutions=_SERVICE_NAME="keycloak-service",_REGION="us-south1",_STATE_BUCKET="terraform_state_bckup_bnk-project",_TERRAFORM_VERSION="1.5.7" \
  .
```

#pending: 
When trying plain: 
terraform plan -target=module.project3 -var-file="dev.tfvars" && terraform apply -auto-approve -target=module.project3 -var-file="dev.tfvars"

while in terraform workspace project3: 

terraform wont deploy: 
"Apply complete! Resources: 0 added, 0 changed, 0 destroyed."

Fix: 
Import resources: 
# Import Network
terraform import -var-file="dev.tfvars" google_compute_network.vpc main-vpc

# Import Static IP
terraform import -var-file="dev.tfvars" google_compute_address.nat_ip projects/bankproject-486308/regions/us-south1/addresses/nat-static-ip

# Import Service Account from Project 2
terraform import -var-file="dev.tfvars" module.project2.google_service_account.service_account projects/bankproject-486308/serviceAccounts/transaction-service-sa@bankproject-486308.iam.gserviceaccount.com

# Import Secrets
terraform import -var-file="dev.tfvars" module.project2.google_secret_manager_secret.db_password_secret projects/466592165334/secrets/transaction-service-db-password
terraform import -var-file="dev.tfvars" module.project2.google_secret_manager_secret.db_connection_secret projects/466592165334/secrets/transaction-service-db-connection-string



# For project3 Github secrets: 

## How to get the "YOUR_PROVIDER_ID":

### Steps 1:

gcloud command: 
gcloud iam workload-identity-pools list --location=global

This will output a list of pools. Note the name (which is YOUR_POOL_ID) of the relevant pool.


Step 2:

Use gcloud command:

gcloud iam workload-identity-pools providers list
--workload-identity-pool="YOUR_POOL_ID"
--location=global

*Replace 
YOUR_POOL_ID 
with the ID you found in the previous step. The output will list providers. The ID column (or the last segment of the NAME column after /providers/) is YOUR_PROVIDER_ID.

Example output: 
projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/YOUR_POOL_ID/providers/YOUR_PROVIDER_ID


Steps 3:

Once you have:

YOUR_PROJECT_NUMBER (You can find this on the Google Cloud Console dashboard for your project) YOUR_POOL_ID YOUR_PROVIDER_ID

Combine them into the string: 
projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/YOUR_POOL_ID/providers/YOUR_PROVIDER_ID 
This full string is what you'll use as the value for the GCP_WIF_PROVIDER GitHub secret.

Add string to github secret, env DEV: 
gh secret set WIF_PROVIDER --env DEV --body "your-DEV-provider-string"

Continue with Keycloak image Build, check errors in Cloud Build... (pending)




# ProjectZERO: 

### Very firs time seting up project zero:
Use script to give IAM roles to terraform service account: 

Before that: Can use this commd to retrive roles from the other GCP project: 
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:[SERVICE_ACCOUNT_EMAIL]" \
    --format="value(bindings.role)"

*Replace placeholder: SERVICE_ACCOUNT_EMAIL with actual service account email. 

After that: 
give execute permission to script: 
chmod +x project0firstrun.sh

Run script: 
cd BNKprojects/0
./project0firstrun.sh



Terraform: 

Since this is the very first time deploying this project ZERO: Cretate a new Terraform workspace, use command: 
terraform workspace new projectZERO



terraform init: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \

INIT: Still using same bucket. 
terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \

### Cross-Project Initialization
When the target infrastructure project differs from the state project, use the following initialization pattern:
```bash
terraform init \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json"
```

If asked use: "terraform init -migrate-state". This applies when there is already infrastructure deployed. 
terraform init -migrate-state \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json" && \

Or: 
If not accepting the "project="
terraform init -migrate-state \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"





terraform plan: 

terraform plan \
  -var-file="dev.tfvars" \
  -target=google_project_service.gcp_services

OR: 

terraform plan \
  -target=google_project_service.gcp_services \
  -target=data.google_secret_manager_secret_version.atlas_public_key \
  -target=data.google_secret_manager_secret_version.atlas_private_key \
  -var-file="dev.tfvars"


Working? Plan with bootstrap and empty secrets first: Use this if secrets are empty: 
terraform plan \
  -var="bootstrap=true" \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services \
  -target=module.atlas_public_key_secret \
  -target=module.atlas_private_key_secret


terraform apply \
  -var="bootstrap=true" \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services \
  -target=module.atlas_public_key_secret \
  -target=module.atlas_private_key_secret



Terraform init to plan: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform validate && \
terraform init \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform plan \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services



Terraform init to plan: With AUTO-APROVE: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform validate && \
terraform init \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform plan \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services && \
terraform apply -auto-approve \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services


Once the Private and Public Keys from MongoDB Atlas were added to the Secret Manager: 



#Very first time Deploying stages: 
Providers: 
Enable WorkLoad Identity Federation GCP service
Deploy WorkLoad Identity Federation service
Enable GCP services

Deploy terraform with empty secrets: 
Terraform init to plan: With AUTO-APROVE: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform validate && \
terraform init \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform plan \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services && \
terraform apply -auto-approve \
  -var-file="dev.tfvars" \
  -target=module.project0 \
  -target=google_project_service.gcp_services

Get MongoDB Atlas Public and Private Keys: 
Log in to the Mongodb Atlas account > on the left pane/menu click: Security > Public Identity and Access > Applications > API Keys> Copy the "public Key". May need to creater new API key to see the private kwy since it can only be seen at creation time. Click > Create API Key, Grant Project Owner Role/Permission, Copy keys, aadd them to Secret manager. Add IP. > Click on Done. 

Add Public and Private Keys to the Secret Manager. 

Run the remote_terraform_state_enabler.sh script in the centralized remote terraform state GCP project to add IAm roles to Environment (DEV, ) Deployer Service Accounts (Github actions from DEV, for example)

Once the Private and Public Keys from MongoDB Atlas were added to the Secret Manager: 



Terraform init to plan: With AUTO-APROVE: 
export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/ZERO/DEV/dev-mockbank-29dfceaf4da1.json" && \
terraform validate && \
terraform init \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="credentials=/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json" && \
terraform plan \
  -var-file="dev.tfvars" \
  -target=module.project0 && \
terraform apply -auto-approve \
  -var-file="dev.tfvars" \
  -target=module.project0



*No longer in use: 
  -backend-config="project=bankproject-486308" \


start deploying terraform using github actions

###Push local terraform state if necessary: 
In case github actions`teraform are trying to create already existing GCP resources, push the local terraform state to remote state using the following command: 
terraform init -migrate-state \
  -backend-config="bucket=terraform_state_bckup_bnk-project" \
  -backend-config="project=bankproject-486308"

Then: 
terraform state push terraform.tfstate.d/projectZERO/terraform.tfstate


###Use this command in case secrets need to be imported: 
terraform import -var-file="dev.tfvars" \
  module.project0.google_secret_manager_secret.keycloak_database_password \
  projects/$(gcloud config get-value project)/secrets/SECRETNAME



###Pendings/debuggiing: 
Errors: 
Github actions errors, 

Declare terraform to populate the secret called: 
keycloak-administrator-usernam. DONE.  



Run workflow first since changes were made...
Ask gemini: Prompt: 
please run: 
terraform plan \
    -var-file="dev.tfvars" \
    -target=module.project3 retrieve the errors and fix them, retry if necessary until errors are fixed. 
    Once errors are fixed document to relevant .md files. 

Pending: 
add the run to github actions for the cloudbuild-keycloak and the rest ofthe code in order to work


## After the very first time deployment: 