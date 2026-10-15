Azure Infrastructure as Code (IaC) Using Terraform

!Terraform !Microsoft Azure !Linux !License
Overview

This project provisions cloud infrastructure on Microsoft Azure using Terraform. It deploys a Rocky Linux jumpbox and four regular Linux virtual machines inside a virtual network, with subnet segmentation, Network Security Groups (NSGs), and controlled SSH access.

The goal is to demonstrate Infrastructure as Code (IaC), cloud networking, virtual machine provisioning, and foundational Azure security practices.
Architecture

The infrastructure includes:

    Azure Resource Group: CloudX-CI
    Virtual Network: CloudX-network
    Jumpbox Subnet: 10.0.2.0/24
    Application Subnet: 10.0.3.0/24
    Jumpbox VM: cloudx-rocky-vm
    Application VMs: CloudX-spot-1, CloudX-spot-2, CloudX-spot-3, and CloudX-spot-4
    Operating System: Rocky Linux 9
    VM Size: Standard_D2as_v4
    Infrastructure Tool: Terraform
    Cloud Provider: Microsoft Azure
    Region: Central India (inherited from the existing resource group)

All five VMs are configured as regular, non-Spot virtual machines. The application VMs have private IP addresses and no directly assigned public IP addresses.
Architecture Diagram

Add your exported Azure architecture diagram to the repository as AzureExportedTemplateIaaC.jpg.

Display it in this README using:

!Azure Infrastructure Architecture
Infrastructure Components
Component	Description
Resource Group	Holds the Azure resources
Virtual Network	Provides private network connectivity
Jumpbox VM	Administrative entry point with a public IP
Application VMs	Four private Linux virtual machines
Public IP	Static Standard public IP for the jumpbox
Network Security Groups	Control inbound network traffic
Subnets	Separate administrative and application workloads
Terraform	Automates infrastructure provisioning
Prerequisites

Before deploying this project, ensure you have:

    An active Azure subscription.
    Azure CLI installed.
    Terraform installed.
    Access to an existing Azure resource group named CloudX-CI.
    Sufficient regional vCPU quota in Central India.
    Access to the Rocky Linux image specified in the Terraform configuration.
    Your public IP address and an administrator credential or SSH key.

Project Structure

terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── .gitignore
├── README.md
└── AzureExportedTemplateIaaC.jpg

The files variables.tf and outputs.tf can instead be combined into main.tf if the project is configured that way. Terraform loads all .tf files in the same directory as one module.
Configuration
1. Clone the repository

git clone <YOUR_GITHUB_REPOSITORY_URL>
cd <YOUR_REPOSITORY_DIRECTORY>

2. Authenticate with Azure

az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
az account show

3. Configure variables

Define the required variables in variables.tf:

variable "my_public_ip" {
  description = "Trusted administrator public IP in CIDR notation"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for Linux VMs"
  type        = string
  sensitive   = true
}

Create a local terraform.tfvars file:

my_public_ip   = "YOUR_PUBLIC_IP/32"
admin_password = "YOUR_STRONG_PASSWORD"

Use your actual public IP address and a strong password. Do not commit this file to GitHub.

    Security recommendation: Prefer SSH public-key authentication for Linux VMs instead of password-based SSH authentication.

Deployment
Initialize Terraform

terraform init

Format the configuration

terraform fmt -recursive

Validate the configuration

terraform validate

Review the execution plan

terraform plan

Review all proposed additions, modifications, and deletions before proceeding.
Deploy the infrastructure

terraform apply

Type yes when prompted after reviewing the plan.
Verify Deployment

Display the jumpbox public IP:

terraform output jumpbox_public_ip

Display the application VM private IP addresses:

terraform output spot_server_private_ips

The output name spot_server_private_ips is retained for compatibility with the existing Terraform configuration. Despite the name, these are regular, non-Spot VMs.
Connecting to the VMs

Connect to the jumpbox using SSH:

ssh vishnu@<JUMPBOX_PUBLIC_IP>

From the jumpbox, connect to an application VM using its private IP:

ssh vishnu@<APPLICATION_VM_PRIVATE_IP>

The application VM NSG allows SSH from the jumpbox private IP. Ensure that the SSH client and authentication method are configured appropriately.
Security Considerations

This project demonstrates basic network segmentation and access restrictions. Before using it in production, consider the following improvements:

    Replace password-based SSH with SSH key authentication.
    Consider Azure Bastion to avoid exposing the jumpbox through a public IP.
    Restrict SSH access to trusted sources.
    Review effective NSG rules and default network security rules.
    Implement controlled outbound connectivity through Azure NAT Gateway or Azure Firewall as appropriate.
    Store Terraform state in a secured Azure Storage backend.
    Restrict access to state files and secrets.
    Use managed identities where supported.
    Enable Azure Monitor and Defender for Cloud recommendations.
    Regularly update the operating system and review access permissions.

Cleanup

To delete the infrastructure managed by this Terraform configuration:

terraform plan -destroy
terraform destroy

Review the destruction plan carefully before confirming.

Warning: Destroying resources can permanently delete virtual machines, disks, networking components, and other managed resources. Back up any required data first. Resources not managed by this configuration, such as the pre-existing resource group, may remain.
Troubleshooting
LowPriorityCores quota exceeded

If you receive an Azure LowPriorityCores quota error, verify that your VMs are configured as regular VMs and do not contain Spot-specific arguments such as:

priority        = "Spot"
eviction_policy = "Deallocate"
max_bid_price   = -1

Regular VMs use the applicable regional standard vCPU quota, which must have sufficient capacity.
Duplicate variable declarations

Ensure that each Terraform variable is declared only once across the module's .tf files.
SSH connection failure

Verify the jumpbox public IP, administrator IP allowlist, NSG rules, VM status, routing, and SSH authentication settings.
Learning Outcomes

This project demonstrates:

    Infrastructure as Code using Terraform.
    Azure virtual network and subnet configuration.
    Linux VM provisioning.
    Network Security Group configuration.
    Jumpbox-based administration.
    Terraform variables, outputs, and deployment workflows.
    Basic cloud security and resource management.

License

This project is available under the MIT License. Add a LICENSE file if you intend to distribute it under that license.

Disclaimer: This is a learning and demonstration project. Review security, cost, quota, and operational requirements before deploying it in production.
Before you push to GitHub

Create a .gitignore file to prevent Terraform state and credentials from being committed:
gitignore

.terraform/
*.tfstate
*.tfstate.*
*.tfvars
!example.tfvars
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

Then commit your project:
bash

git add main.tf variables.tf outputs.tf README.md .gitignore AzureExportedTemplateIaaC.jpg
git commit -m "Add Azure Terraform infrastructure project"
git push

Make sure you have not already committed secrets or state files. A .gitignore does not remove files that are already tracked by Git.
