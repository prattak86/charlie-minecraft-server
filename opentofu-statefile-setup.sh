# Variables
BACKEND_RESOURCE_GROUP_NAME="minecraft_tf_state_RG"
BACKEND_STORAGE_ACCOUNT_NAME="opentofutfstate"
BACKEND_STORAGE_CONTAINER_NAME="tfstate"
BACKEND_STORAGE_ACCOUNT_LOCATION="centralus"
BACKEND_STORAGE_ACCOUNT_SKU="Standard_LRS"

# Register the Microsoft.ContainerInstance resource provider
az provider register --namespace Microsoft.ContainerInstance

# Create resource group
az group create --name $BACKEND_RESOURCE_GROUP_NAME --location $BACKEND_STORAGE_ACCOUNT_LOCATION

# Create storage account
az storage account create --name $BACKEND_STORAGE_ACCOUNT_NAME --resource-group $BACKEND_RESOURCE_GROUP_NAME --location $BACKEND_STORAGE_ACCOUNT_LOCATION --sku $BACKEND_STORAGE_ACCOUNT_SKU

# Create blob container
az storage container create --name $BACKEND_STORAGE_CONTAINER_NAME --account-name $BACKEND_STORAGE_ACCOUNT_NAME