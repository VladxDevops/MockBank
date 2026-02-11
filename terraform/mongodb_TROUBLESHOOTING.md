# MongoDB Atlas Terraform Troubleshooting Guide

This guide will help you troubleshoot and resolve common errors when using the MongoDB Atlas provider for Terraform.

## Error during `apply`: `IP_ADDRESS_NOT_ON_ACCESS_LIST`

This error indicates that the public IP address of the machine running `terraform apply` is not authorized to make API calls to MongoDB Atlas. This is controlled by the **API Key's Access List** at the organization level.

This is different from the *Project IP Access List*, which controls which IPs can connect to the database cluster itself. The error during `terraform apply` is almost always related to the API Key.

### How to Fix

1.  Log in to your MongoDB Atlas account.
2.  In the top-left corner, click on your organization name to go to the organization view.
3.  In the left-hand navigation pane, click on **Access Manager**.
4.  Click on the **API Keys** tab.
5.  Find the API key you are using for Terraform and click **Edit**.
6.  Under the **API Access List** section, click **Add Access List Entry**.
7.  Add the IP address shown in the Terraform error message. For development, you can click **Add Current IP Address**.
8.  Click **Save**.

It may take a few minutes for the changes to take effect. After this, run `terraform apply` again.

---

## Allowing Database Connections from your IP

To connect to your database cluster directly (e.g., using `mongosh` from your local machine), you need to add your IP to the **Project's IP Access List**.

### 1. Find Your Public IP Address
```bash
curl -s ifconfig.me
```

### 2. Add Your IP to the Project's IP Access List
1.  Navigate to your Project in the Atlas UI.
2.  In the left-hand navigation pane, click on **Network Access** under the **Security** section.
3.  Click **Add IP Address**.
4.  In the dialog, click **Add Current IP Address**.
5.  Click **Confirm**.

### 3. (Optional but Recommended) Make the IP Address Dynamic

Hardcoding the IP address in your Terraform configuration is not ideal, as your IP address may change. A better approach is to use a data source to fetch the IP address dynamically.

You can add the following to your Terraform configuration to automatically fetch the public IP of the machine running Terraform:

```terraform
data "http" "my_ip" {
  url = "http://ifconfig.me"
}

resource "mongodbatlas_project_ip_access_list" "ip_access_list" {
  project_id = mongodbatlas_project.project.id
  ip_address = data.http.my_ip.response_body
  comment    = "IP address of the machine running Terraform"
}
```
*Note: You will need to add a terraform provider for http*
```
terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "3.4.2"
    }
 }
}

```

## Verifying the Project and Organization IDs

Ensure that the `atlas_org_id` you are using in your `dev.tfvars` file is correct.

1.  Log in to your MongoDB Atlas account.
2.  In the top-left corner, click on your organization name.
3.  Click on the **Settings** tab.
4.  Your **Organization ID** will be displayed on this page.

Similarly, to find your **Project ID**:

1.  Navigate to your project in the Atlas UI.
2.  Click on the **Settings** tab for the project.
3.  Your **Project ID** will be displayed on this page.


## Checking API Key Permissions

The MongoDB Atlas API key you are using must have the **Project Owner** role for the project you are trying to manage.

1.  In the left-hand navigation pane, click on **Access Manager** under the **Security** section.
2.  Click on the **API Keys** tab.
3.  Find the API key you are using and click on the **Edit** button.
4.  Under **Project Access**, ensure that the API key has the **Project Owner** role for your project.

Conclusion: 
The `atlas_org_id` value listed in the `dev.tfvars` might be incorrect. Double-check it in the Atlas UI under your Organization's settings.

If a resource was created in Atlas but not in the Terraform state, you may need to import it.

To import an existing project into state:
```bash
terraform import -var-file="dev.tfvars" mongodbatlas_project.atlas_project <your-atlas-project-id>
```

In case the resource needs to be removed from state (e.g. if the project was deleted manually), first find the exact resource name using `terraform state list`. Then remove it:
terraform state rm mongodbatlas_project.atlas_project

For example, if you see an error about an IP access list for a deleted project, find the access list resource:
terraform state list | grep access_list
terraform state rm mongodbatlas_project_ip_access_list.your_resource_name

## Error: User already exists / Error splitting database User info from ID

If Terraform fails with an error indicating that the database user already exists (e.g., `POST .../users: 409 (request "User already exists")`), it means the user was created manually or by a previous run but is missing from the state file.

To fix this, you must import the user into the Terraform state.

If you see `Error: error splitting database User info from ID`, it means the import ID you provided was not in the correct format.

The correct format is a single string with hyphens separating the parts: `{project_id}-{username}-{auth_database_name}`.

**Example Command:**

1.  Find your **Project ID** from the Atlas UI (e.g., `6981c8c8bcd3ea36dd09a4c4`).
2.  Identify the `username` (`user`) and `auth_database_name` (`admin`) from your `mongodb.tf` file.
3.  Combine them into the import ID: `6981c8c8bcd3ea36dd09a4c4-user-admin`.
4.  Run the import command:

```bash
# Example with a real project ID. Replace with your own.
terraform import -var-file="dev.tfvars" module.project2.mongodbatlas_database_user.user 6981c8c8bcd3ea36dd09a4c4-user-admin
```