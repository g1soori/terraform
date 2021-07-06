# Create Azure Kubernetes Cluster

## Overview
This plan will create a AKS cluster with advanced network configuration. It does
- Create dependent services required for AKS (vnet, subnet, resource group, )
- Create Kubernetes cluster
- Enable http application routing for AKS to enable ingress traffic from public ip
- Deploy ingress controller using a Helm chart

**Important**
- Make sure ssh key pair is generated in your PC and added the path inside the linux profile section
- By default, Azure creates additional resource group for underline infrastructure. This reource group normally name with "MC_<rg><aks>"
- This additional resource group is called "node resource group"
- Microsoft recommends CNI networking model due to these reasons
    - Greater flexibility when connecting to peered network and on-premise networks in enterprise environments
    - Kubenet network might degrade performance due to UDR and IP forwarding

## Create the AKS cluster
- Create `terraform.tfvars` file with these variables `client_id`, `client_secret`
- Run the `terraform plan` and verify the resource settings
- Run the `terraform apply` to create resources

## Connect to new AKS cluster
Connect to the new cluster using below command. Make sure you are logged in with azure cli before run this.
```
az aks get-credentials --resource-group "tf-k8s-resources" --name "tf-k8s"
```