# Project 0: Foundational Infrastructure (Networking & APIs)

## Overview
Project 0 establishes the "Zero Trust" foundation for the Altmtrk2026 Bank Platform. It centralizes networking, API management, and global identity federation to ensure security and consistency across all application-specific projects.

## Core Components
- **Global VPC & Subnets**: Standardized networking for all services.
- **Serverless VPC Access**: Connectivity for Cloud Run services.
- **Cloud NAT & Router**: Secure, static egress for external API calls (e.g., MongoDB Atlas).
- **Artifact Registry**: Centralized Docker repository for all microservices.
- **Workload Identity Federation (WIF)**: Keyless authentication for GitHub Actions.
- **GCP Service APIs**: Centralized enablement of 16+ required services.
- **Memory Store (GCP Memorystore for Redis)** [PENDING]: Caching and session store infrastructure.
  - **Status**: Planning / Not Implemented / Pending


## Getting Started

### 1. Initial Bootstrap (IAM Setup)
Before running Terraform, ensure the execution service account has the necessary permissions. Use the provided script:

```bash
# From the root of the repo
cd BNKprojects/zero
chmod +x project0firstrun.sh
./project0firstrun.sh
```

### 2. Deploy Foundation via Terraform
Navigate to the `terraform` directory and apply the Project 0 module:

```bash
cd ../../terraform

# Initialize and select workspace
terraform init
terraform workspace select projectZERO || terraform workspace new projectZERO

# Bootstrap APIs and Networking
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.project0
```

### 3. Shared Secrets Management
Once the foundation is live, provision the secret placeholders:

```bash
terraform apply -var="bootstrap=true" -var-file="dev.tfvars" -target=module.atlas_public_key_secret -target=module.atlas_private_key_secret
```
*Note: After creation, manually populate the secret values in the GCP Secret Manager console.*

## Documentation
- **[Detailed Planning](PROJECT0DETAILS.MD)**: Implementation rationale and architecture.
- **[Troubleshooting](../../Documentation/internal/TROUBLESHOOTING_PROJECT0.md)**: Known issues and resolutions.
