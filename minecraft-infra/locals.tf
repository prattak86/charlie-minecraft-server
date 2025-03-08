locals {
    # The name of the backend resource group to use
    # This is the resource group that will be used to store the Terraform state
    backend_resource_group_name = "minecraft_tf_state_RG"
    
    # The name of the backend storage account to use
    # This is the storage account that will be used to store the Terraform state
    backend_storage_account_name = "opentofutfstate"
    
    # The name of the backend storage container to use
    # This is the storage container that will be used to store the Terraform state
    backend_storage_container_name = "tfstate"
    
    # # The name of the key vault to create
    # key_vault_name = "${var.key_vault_name}-${var.environment}"
    
    # # The name of the app service plan to create
    # app_service_plan_name = "${var.app_service_plan_name}-${var.environment}"
    
    # # The name of the app service to create
    # app_service_name = "${var.app_service_name}-${var.environment}"
}