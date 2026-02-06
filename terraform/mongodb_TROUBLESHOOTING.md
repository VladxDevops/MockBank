# MongoDB Atlas Terraform Troubleshooting Guide

This guide will help you troubleshoot and resolve common errors when using the MongoDB Atlas provider for Terraform.

## Error: IP_ADDRESS_NOT_ON_ACCESS_LIST

This is the most common error and it means that the IP address of the machine running Terraform is not allowed to connect to your MongoDB Atlas project.

### 1. Find Your Public IP Address

To allow your machine to connect to MongoDB Atlas, you need to find its public IP address. You can do this by running the following command in your terminal:

```bash
curl -s ifconfig.me
```

This will return your public IP address.

### 2. Add Your IP Address to the MongoDB Atlas IP Access List

Now that you have your public IP address, you need to add it to the IP Access List in your MongoDB Atlas project.

1.  Log in to your MongoDB Atlas account.
2.  In the left-hand navigation pane, click on **Network Access** under the **Security** section.
3.  Click the **Add IP Address** button.
4.  In the dialog that appears, click the **Add Current IP Address** button if you are accessing the UI from the same machine that is running Terraform. Otherwise, enter your public IP address in the **Access List Entry** field.
5.  Click the **Confirm** button.

It may take a few minutes for the changes to take effect.

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
The atlas_org_id value listed in the dev.tfvars was wrong. 

Fix: 
If there is a terraform error stating that Mongo has issues with the IP: 
Go to: 
Mongodb atlas UI/website > Select project name > Security >  Project identity and Access > Applications > API Keys > Edit access List > "Add access list entry" > Add IP > Save > done. 

And import the mongodb atlas project to the terraform state. Command: 
terraform import -var-file="dev.tfvars" mongodbatlas_project.atlas_project 6981c8c8bcd3ea36dd09a4c4

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