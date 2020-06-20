# Create Azure Kubernetes Cluster

## Overview
This plan will create a AKS cluster with basic network configuration.

**Important**
- Make sure ssh key pair is generated in your PC and added the path inside the linux profile section
- By default, Azure creates additional resource group for underline infrastructure. This reource group normally name with "MC_<rg><aks>"
- This additional resource group is called "node resource group"
- Microsoft recommends CNI networking model due to these reasons
    - Greater flexibility when connecting to peered network and on-premise networks in enterprise environments
    - Kubenet network might degrade performance due to UDR and IP forwarding

## Create the AKS cluster
Run the "terraform plan" and verify the resource settings
Run the "terraform apply" to create resources

## Connect to new AKS cluster
Connect to the Auzre powershell using "Connect-AzAccount"
Then connect to the new k8s cluster using "Import-AzAksCredential -ResourceGroupName aks-k8s-resources -Name aks-k8s"
Ensure current context is the new k8s cluster using "kubectl config view"