## terraform-azure-migratorydata

A Terraform module to deploy and run MigratoryData on Microsoft Azure.

## Prerequisites

Before deploying MigratoryData using Terraform, ensure that you have a Microsoft Azure account and have installed the following tools:

  - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Login to Azure

Login to Azure with the following command and follow the instructions on the screen to configure your Azure credentials:

```bash
az login
```

For other authentication methods, see [Terraform's Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) documentation.

## Configure the deployment

Clone the MigratoryData's repository with terraform configuration files:

```sh
git clone https://github.com/migratorydata/terraform-azure-migratorydata.git
cd terraform-azure-migratorydata/deploy
```

Update if necessary the configuration files from the `deploy/configs` directory. See the [Configuration](https://migratorydata.com/docs/server/configuration/) guide for more details. If you developed custom extensions, add them to the the `deploy/extensions` directory.


Update `deploy/terraform.tfvars` file to match your configuration. The following variables are required:

  - `region` - The Azure region where the resources will be deployed.
  - `namespace` - The namespace for the resources.
  - `address_space` - The address space for the virtual network.
  - `num_instances` - The number of nodes to start the MigratoryData cluster.
  - `max_num_instances` - The maximum number of instances of MigratoryData Nodes to scale the deployment when necessary.
  - `instance_type` - The type of the virtual machines to be deployed.
  - `ssh_private_key` - The path to the private key used to access the virtual machines.
  - `migratorydata_download_url` - The download URL for the MigratoryData package.

Your `terraform.tfvars` file should be similar to the following:

```bash
region          = "eastus"
namespace       = "migratorydata"
additional_tags = {}

address_space = "10.0.0.0/16"

num_instances     = 3
max_num_instances = 5
instance_type     = "Standard_F2s_v2"

ssh_private_key = "~/.ssh/id_rsa"

migratorydata_download_url = "https://migratorydata.com/releases/migratorydata-6.0.15/migratorydata-6.0.15-build20240209.x86_64.deb"
```

## Deploy MigratoryData

Initialize terraform:
```bash
terraform init
```

Check the deployment plan:
```bash
terraform plan
```

Apply the deployment plan:
```bash
terraform apply
```

## Verify deployment

You can access the MigratoryData cluster using the public IP address of the load balancer. You can find it running the following command, and find the value of `loadbalancer_ip` in the output:

```bash
terraform output 
```

You can check the health of the cluster by accessing the load balancer public ip on port `80` with path `/health`.

```bash
http://${loadbalancer_public_ip}/health
```

Also you can ssh into the virtual machines using the public ip of the virtual machines. You can find it under `cluster_ips` output and ssh into the virtual machines using the following command:

```bash
ssh azureuser@machine_public_ip
or
ssh -i ssh_private_key azureuser@machine_public_ip
```

## Scale

To scale the deployment, update the `num_instances` variable in the `terraform.tfvars` file and run the following commands:

```bash
terraform plan
terraform apply
```

## Uninstall

To destroy the deployment run the following command:

```bash
terraform destroy
```

## Build realtime apps

Use any of the MigratoryData's [client APIs](/docs/client-api/) to develop real-time applications for communication with this MigratoryData cluster.
