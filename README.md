
# jenkins-cloud-create
Jenkins infrastructure-as-code (IaC) for public cloud infrastructure.

1. AKS 
2. EKS (EKS support coming soon)

Sister project to containerize existing Jenkins server for use on the cloud: [Mu-Nirvana/jenkin-host-to-container](https://github.com/Mu-Nirvana/jenkins-host-to-container)

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
* `git clone https://github.com/Mu-Nirvana/jenkins-cloud-create.git`
* Navigate to azure directory `cd src/azure`

### Setup azure account
1. Login to azure by running `az login`
2. Copy the relevant subscription id from the output of the above. Ex. `"id": "35akss-subscription-id",`
3. Run `az account set --subscription "<SUBSCRIPTION_ID>"` to set the correct subscription
4. Create a service principal with: `az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/<SUBSCRIPTION_ID>"`
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

2. Run `terraform init` in [src/azure](src/azure) to initialize terraform
3. Run `terraform apply` and review infrastructure plan
4. Type `yes` to continue if plan is correct

After the resources are created, the configuration can be viewed on the [Azure portal](https://portal.azure.com/)

### Attach kubectl for localhost deployments

The AKS cluster can be attached with the following command

* Run `az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`

### Login with docker (optional)

If `acr_admin` is set true, an admin login will be created. You can login to the registry on docker with the following steps
1. Navigate to [Azure portal](https://portal.azure.com/) and locate the container registry resource
2. In the menu pane, select access keys under settings
3. Run the command `docker login <LOGIN_SERVER>` using the server address listed on the above page. When prompted enter either of the provided passwords
