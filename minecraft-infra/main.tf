resource "azurerm_resource_group" "minecraft" {
  name     = var.minecraft_rg
  location = var.minecraft_storage_loc
}

resource "azurerm_virtual_network" "minecraft" {
  name                = var.minecraft_vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.minecraft_storage_loc
  resource_group_name = azurerm_resource_group.minecraft.name
}

resource "azurerm_subnet" "minecraft" {
  name                 = var.minecraft_subnet_name
  resource_group_name  = azurerm_resource_group.minecraft.name
  virtual_network_name = azurerm_virtual_network.minecraft.name
  address_prefixes     = ["10.0.0.0/24"]

  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "aci-delegation"
    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "minecraft" {
  name                = var.minecraft_nsg_name
  location            = var.minecraft_storage_loc
  resource_group_name = azurerm_resource_group.minecraft.name
}

resource "azurerm_network_security_rule" "allow_minecraft" {
  name                        = "AllowMinecraft"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "25565"
  source_address_prefix       = "45.24.176.182"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.minecraft.name
  network_security_group_name = azurerm_network_security_group.minecraft.name
}

resource "azurerm_subnet_network_security_group_association" "minecraft" {
  subnet_id                 = azurerm_subnet.minecraft.id
  network_security_group_id = azurerm_network_security_group.minecraft.id
}

# New Resources for NAT Gateway
resource "azurerm_public_ip" "minecraft_nat_ip" {
  name                = "minecraft-nat-ip"
  location            = azurerm_resource_group.minecraft.location
  resource_group_name = azurerm_resource_group.minecraft.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "minecraft_nat" {
  name                = "minecraft-nat"
  location            = azurerm_resource_group.minecraft.location
  resource_group_name = azurerm_resource_group.minecraft.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.minecraft_nat.id
  public_ip_address_id = azurerm_public_ip.minecraft_nat_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet_nat_assoc" {
  subnet_id      = azurerm_subnet.minecraft.id
  nat_gateway_id = azurerm_nat_gateway.minecraft_nat.id
}

resource "azurerm_storage_account" "minecraft" {
  name                     = var.minecraft_storage_acct
  resource_group_name      = azurerm_resource_group.minecraft.name
  location                 = var.minecraft_storage_loc
  account_tier             = "Standard"
  account_replication_type = var.minecraft_storage_sku
}

resource "azurerm_storage_share" "minecraft" {
  name                 = "minecraftfiles"
  storage_account_id   = azurerm_storage_account.minecraft.id
  quota                = 50
}

resource "azurerm_storage_account_network_rules" "minecraft_network_rules" {
  storage_account_id = azurerm_storage_account.minecraft.id

  default_action             = "Allow"
  bypass                     = ["AzureServices"]
  ip_rules                   = []
  virtual_network_subnet_ids = [azurerm_subnet.minecraft.id]
}

resource "azurerm_container_group" "minecraft" {
  name                = var.minecraft_container_name
  location            = var.minecraft_storage_loc
  resource_group_name = azurerm_resource_group.minecraft.name
  ip_address_type     = "Private"
  os_type             = "Linux"

  container {
    name   = "minecraft"
    image  = "itzg/minecraft-server:latest"
    cpu    = "2"
    memory = "4"

    ports {
      port     = 25565
      protocol = "TCP"
    }

    environment_variables = {
      EULA = "TRUE"
    }

    volume {
      name = "minecraftfiles"
      mount_path = "/data"
      read_only = false
      share_name          = azurerm_storage_share.minecraft.name
      storage_account_name = azurerm_storage_account.minecraft.name
      storage_account_key  = azurerm_storage_account.minecraft.primary_access_key
    }   
  }

  subnet_ids = [azurerm_subnet.minecraft.id]
}

output "minecraft_public_ip" {
  value = azurerm_public_ip.minecraft_nat_ip.ip_address
}