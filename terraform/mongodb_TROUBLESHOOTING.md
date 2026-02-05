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