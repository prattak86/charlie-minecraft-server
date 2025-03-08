#!/bin/bash
# This script sets up the necessary Azure infrastructure for hosting a Minecraft server using Azure Container Instances (ACI).
# Ensure you have the Azure CLI installed and logged in before running this script.

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Variables
MINECRAFT_RG=${MINECRAFT_RG}
MINECRAFT_STORAGE_ACCT=${MINECRAFT_STORAGE_ACCT}
MINECRAFT_STORAGE_SKU=${MINECRAFT_STORAGE_SKU}
MINECRAFT_STORAGE_LOC=${MINECRAFT_STORAGE_LOC}
MINECRAFT_CONTAINER_NAME=${MINECRAFT_CONTAINER_NAME}
MINECRAFT_VNET_NAME=${MINECRAFT_VNET_NAME}
MINECRAFT_SUBNET_NAME=${MINECRAFT_SUBNET_NAME}
MINECRAFT_NSG_NAME=${MINECRAFT_NSG_NAME}
MINECRAFT_IMAGE="itzg/minecraft-server"
MINECRAFT_PORT=25565

# Register the Microsoft.ContainerInstance resource provider
az provider register --namespace Microsoft.ContainerInstance

# Create Resource Group
az group create --name $MINECRAFT_RG --location $MINECRAFT_STORAGE_LOC

# Create Virtual Network
az network vnet create \
    --resource-group $MINECRAFT_RG \
    --name $MINECRAFT_VNET_NAME \
    --address-prefix 10.0.0.0/16 \
    --subnet-name $MINECRAFT_SUBNET_NAME \
    --subnet-prefix 10.0.0.0/24

# Create Network Security Group
az network nsg create \
    --resource-group $MINECRAFT_RG \
    --name $MINECRAFT_NSG_NAME \
    --location $MINECRAFT_STORAGE_LOC

# Create NSG rule to allow Minecraft traffic
az network nsg rule create \
    --resource-group $MINECRAFT_RG \
    --nsg-name $MINECRAFT_NSG_NAME \
    --name AllowMinecraft \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range $MINECRAFT_PORT \
    --access Allow

# Associate NSG with Subnet
az network vnet subnet update \
    --resource-group $MINECRAFT_RG \
    --vnet-name $MINECRAFT_VNET_NAME \
    --name $MINECRAFT_SUBNET_NAME \
    --network-security-group $MINECRAFT_NSG_NAME

# Create Storage Account
az storage account create \
    --resource-group $MINECRAFT_RG \
    --name $MINECRAFT_STORAGE_ACCT \
    --sku $MINECRAFT_STORAGE_SKU \
    --location $MINECRAFT_STORAGE_LOC

# Create Azure Container Instance within the VNet
az container create \
    --resource-group $MINECRAFT_RG \
    --name $MINECRAFT_CONTAINER_NAME \
    --image $MINECRAFT_IMAGE \
    --ports $MINECRAFT_PORT \
    --environment-variables EULA=TRUE \
    --location $MINECRAFT_STORAGE_LOC \
    --restart-policy OnFailure \
    --vnet $MINECRAFT_VNET_NAME \
    --subnet $MINECRAFT_SUBNET_NAME \
    --os-type Linux \
    --cpu 2 \
    --memory 4 

# Output the FQDN of the container
az container show \
    --resource-group $MINECRAFT_RG \
    --name $MINECRAFT_CONTAINER_NAME \
    --query "{FQDN:ipAddress.fqdn}" \
    --output table