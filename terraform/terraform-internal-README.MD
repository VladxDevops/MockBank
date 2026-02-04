Internal README.md file. Internal use only. 
We will be working with terraform modules, one module per each bank project based on the the instructions from THE MAIN AGENTS.MD FILE. 

We will also be working with variables.tf dev.tfvars in order to use variables and keep the security to the highest. 

We are only using 1 and the same GCP project, thus the compute project id will be the same value for all 3 bank projects listed.



## Core Infrastructure



The following core infrastructure components are defined in the root of the `terraform` directory:



*   **GCP Services (`gcp_services.tf`):** Enables the necessary GCP APIs for the project.

*   **VPC Network (`network.tf`):** Creates a custom VPC, a subnet, and a Serverless VPC Access Connector.

*   **Artifact Registry (`artifact_registry.tf`):** Creates a Docker repository to store the container images.

*   **Secret Management (`secrets.tf`):** Creates empty secrets in GCP Secret Manager for the Atlas API keys. The values must be added manually.

*   **Remote State (`backend.tf`):** Configures a GCS bucket as the remote backend for Terraform state (commented by default).



## Project 2 Module



The `project2` module (`./modules/project2`) deploys the resources for Project 2, the Transaction Service. It includes:



*   A Cloud Run service for the Node.js application, connected to the VPC.

*   A Service Account for the Cloud Run service.

*   A MongoDB Atlas project and a free-tier cluster.



### MongoDB Atlas Provider







This project uses the `mongodbatlas` provider to manage MongoDB Atlas resources. The provider is configured in `terraform.tf` to read the Atlas API keys from GCP Secret Manager.







## Infrastructure Preservation







To prevent accidental data loss, some resources are configured with `prevent_destroy = true`. This means that you will not be able to destroy these resources with `terraform destroy` unless you remove the `lifecycle` block from the Terraform code.







The following resources are protected:







*   **Enabled GCP Services (`gcp_services.tf`):** The enabled GCP APIs will not be disabled.



*   **Artifact Registry Repository (`artifact_registry.tf`):** The Docker repository will not be deleted.



*   **Secrets in Secret Manager (`secrets.tf`):** The empty secrets for the Atlas API keys will not be deleted.







It is also highly recommended to protect your Terraform state GCS bucket from deletion by using bucket policies and IAM permissions.




Terraform: 

export GOOGLE_APPLICATION_CREDENTIALS="/home/pochitawork/Downloads/MockBankGCPproject/bankproject-486308-34dfd0dbef72.json"

terraform init -backend-config="bucket=terraform_state_bckup_bnk-project" && \
terraform plan -var-file="dev.tfvars" && \
terraform apply -auto-approve -var-file="dev.tfvars"

#unlock Terraform State: 

terraform force-unlock 1770119740925764