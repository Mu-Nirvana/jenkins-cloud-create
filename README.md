
# jenkins-cloud-create
Jenkins infrastructure-as-code (IaC) for public cloud infrastructure.

1. AKS 
2. EKS (EKS support coming soon)

Sister project to containerize existing Jenkins server for use on the cloud: `jenkin-host-to-container`.

## Project structure
* [src](src) Contains the source terraform
* [src/azure](src/azure) Azure Terraform
* [examples](examples) Contains example files for terraform variable inputs

## Infrastructure overview
The Terraform projects in this repository configure a basic kubernetes cluster on the cloud, along with a container registry to privately host container images. This is designed to support the creation or migration of any source Jenkins server to AKS/EKS.

## Getting started (AKS)
Setup project and create Azure infrastructure

### Prerequisites
* Azure account with a valid subscription
* Installed [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Clone the repository
* `git clone https://${YOUR_REPO}/jenkins-cloud-create.git`
* Navigate to azure directory `cd src/azure`

### Setup azure account

1. Onetime set az Azure Gov `az cloud set --name AzureUSGovernment`
2. Login to azure by running `az login`
3. Copy the relevant subscription id from the output of the above. Ex. `"id": "35akss-subscription-id",`
4. Run `az account set --subscription "<SUBSCRIPTION_ID>"` to set the correct subscription
5. Optionally if using Service Principal (required for CI/CD, not localhost), create a service principal with: `az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/<SUBSCRIPTION_ID>"`
    The output should look something like: 
```
Creating 'Contributor' role assignment under scope '/subscriptions/35akss-subscription-id'
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "appId": "xxxxxx-xxx-xxxx-xxxx-xxxxxxxxxx",
  "displayName": "azure-cli-2022-xxxx",
  "password": "xxxxxx~xxxxxx~xxxxx",
  "tenant": "xxxxx-xxxx-xxxxx-xxxx-xxxxx"
}
```
### Configure terraform and create infrastrcture
1. Create a file named terraform.tfvars in [src/azure](src/azure) and add the following:

For localhost:

``` tf
subscription_id = "<SUBSCRIPTION_ID>"
location        = "<CLOUD_REGION>"
app_name        = "<APPLICATION_NAME>"
acr_admin       = true
```

For SP from CI/CD:
``` tf
client_id       = "<APPID_VALUE>"
client_secret   = "<PASSWORD_VALUE>"
tenant_id       = "<TENANT_VALUE>"
subscription_id = "<SUBSCRIPTION_ID>"
location        = "<CLOUD_REGION>"
app_name        = "<APPLICATION_NAME>"
```

Note: *.tfvars are .gitignore'd

Optional: `acr_admin = true` can be added to create an admin account for the container registry

Note: `app_name` will be used as the prefix for Azure cloud resources

2. Install Terraform if required [here](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. Run `terraform init` in [src/azure](src/azure) to initialize terraform
4. Run `terraform apply` and review infrastructure plan
5. Type `yes` to continue if plan is correct

After the resources are created, the configuration can be viewed on the [Azure portal](https://portal.azure.com/)

### Attach kubectl for localhost deployments

The AKS cluster can be attached with the following command

* Run `az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`, 
e.g., `az aks get-credentials --resource-group NDFS-Innovation-LabRG-c4d4ace3 --name NDFS-Innovation-LabAKS-c4d4ace3`

### Login with docker (optional)

If `acr_admin` is set true, an admin login will be created. You can login to the registry on docker with the following steps
1. Navigate to [Azure portal](https://portal.azure.com/) and locate the container registry resource
2. In the menu pane, select access keys under settings
3. Run the command `docker login <LOGIN_SERVER>` using the server address listed on the above page. When prompted enter either of the provided passwords
