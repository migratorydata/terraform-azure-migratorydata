## terraform-azure-migratorydata

A Terraform module to deploy and run MigratoryData on Microsoft Azure using Ansible.

This guide provides a step-by-step process to create an infrastructure on Azure using Terraform, and deploy a MigratoryData Push Server cluster using Ansible. It also covers how to add a monitoring module, using Ansible, that installs Prometheus and Grafana for real-time statistics. Additionally, the guide includes instructions on how to update the MigratoryData Push Server across all instances.

## Prerequisites

Before deploying MigratoryData using Terraform, ensure that you have a Microsoft Azure account and have installed the following tools:

  - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  - [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

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
  - `enable_monitoring` - A boolean value to enable or disable monitoring and logging.

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

enable_monitoring = true
```

To update the version of MigratoryData Push server, update the `ansible/vars.yaml` file. The following variables are required:

  - `package_url` - The URL where the MigratoryData package can be downloaded.
  - `package_name` - The name of the MigratoryData package.

## SSH keys

In order to establish a secure connection to the virtual machines, Ansible requires both public and private SSH keys. These keys can be generated on your local machine using the ssh-keygen command. Once generated, the path to the private key can be specified in the `terraform.tfvars` file using the `ssh_private_key` variable. Follow the steps below to generate a new SSH key pair:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Executing this command will create a new RSA key pair with a key size of 4096 bits. The keys will be stored in the `.ssh` directory of your home folder. The public key will be saved as `~/.ssh/id_rsa.pub` and the private key as `~/.ssh/id_rsa`.


## Deploy the infrastructure

Before Terraform can manage any resources, it needs to be initialized. Initialization prepares Terraform for use by downloading the necessary provider plugins:
```bash
terraform init
```

It's always a good practice to check the deployment plan before applying it. This will give you an overview of the changes that will be made to your infrastructure:
```bash
terraform plan
```

Once you've reviewed and are satisfied with the deployment plan, you can apply it:
```bash
terraform apply
```

## Installing Ansible Collections

The provided commands are used to install necessary Ansible collections. Ansible collections are a distribution format for Ansible content that can include playbooks, roles, modules, and plugins.

```bash
# This command installs the community.general collection, which includes many of the most commonly used modules and other resources for Ansible.
ansible-galaxy collection install community.general

# This collection is designed to interact with Prometheus, a powerful open-source monitoring and alerting toolkit.
ansible-galaxy collection install prometheus.prometheus

# This collection provides modules to interact with Grafana, a popular open-source platform for visualizing metrics, which complements Prometheus.
ansible-galaxy collection install grafana.grafana
```

By running these commands, you ensure that your Ansible environment has the necessary collections to manage and monitor your infrastructure effectively.

## Install MigratoryData Push server

By running these commands, you initiate the installation of the MigratoryData Push Server on your infrastructure. The `ansible/install.yaml` playbook automates the installation process, ensuring a consistent setup across all your servers.

```bash
# used to disable SSH host key checking
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook ansible/install.yaml -i artifacts/hosts.ini
```

## Monitoring setup

If the `enable_monitoring` variable is set to true, then you can install grafana and prometheus on the monitor virtual machine using the following command:

```bash
# For mac you need tar and gnu-tar
brew install gnu-tar

# Fix for MAC OS error `ERROR! A worker was found in a dead state`
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
# used to disable SSH host key checking
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook ansible/monitor.yaml -i artifacts/hosts.ini
```

## Verify deployment

- You can access the MigratoryData cluster using the public IP address of the load balancer. You can find it running the following command, and find the value of `loadbalancer_ip` in the output:

```bash
terraform output 
```

- You can check the health of the cluster by accessing the load balancer public ip on port `80` with path `/health`.

```bash
http://${loadbalancer_public_ip}/health
```

- You can also verify the deployment by SSH-ing into the virtual machines. You can do this using the command `ssh admin@machine_public_ip` or `ssh -i ssh_private_key admin@machine_public_ip` if you need to specify a private key. Once logged in, you can check the status of the MigratoryData service and inspect the logs to ensure everything is running as expected.

```bash
sudo su
# Check the status of the MigratoryData service
systemctl status migratorydata

# Inspect the logs
nano /var/log/migratorydata/all/out.log
```

- To access the monitoring tools, you can use the public IP address of the monitor virtual machine. You can find it running the following command, and find the value of `monitor-public-ip-grafana-access` in the output. By default the username and password for Grafana are `admin` and `update_password` respectively:

```bash
terraform output 

# Access Grafana
http://${monitor-public-ip-grafana-access}:3000
```


## Update MigratoryData Push server

The `package_url` and `package_name` variables in the `ansible/vars.yaml` file should be updated to point to the new version of the MigratoryData Push Server. The `package_url` is the URL where the new version can be downloaded, and the `package_name` is the name of the package file.

Update MigratoryData Server running the following commands: 

```bash
# used to disable SSH host key checking
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook ansible/update.yaml -i artifacts/hosts.ini
```

The `ansible/update.yaml` playbook contains tasks that update the MigratoryData Push Server on the machines specified in the `hosts.ini` inventory file. The playbook is designed to sequentially update the MigratoryData Push Server on each server in your infrastructure. The playbook operates on one host to ensure service availability during the update process. The tasks executed on each host include stopping the MigratoryData service, downloading the new MigratoryData Push Server package, updating the package, and restarting the service. After updating each server, Ansible pauses for a period of time before moving to the next server, allowing the updated server to fully restart and rejoin the cluster before the next server is updated.

## Scale

To scale the deployment, update the `num_instances` variable in the `terraform.tfvars` file. For example, to scale the deployment to 5 instances, update the `num_instances` variable to 5 and run the following commands:

```bash
terraform plan
terraform apply
```

After the infrastructure is created and the new virtual machines are running, you can install the MigratoryData Push Server on the new virtual machines using the following command:

```bash
# used to disable SSH host key checking
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook ansible/install.yaml -i artifacts/hosts.ini
```

## Uninstall

To destroy the deployment run the following command:

```bash
terraform destroy
```

## Build realtime apps

Use any of the MigratoryData's [client APIs](/docs/client-api/) to develop real-time applications for communication with this MigratoryData cluster.
