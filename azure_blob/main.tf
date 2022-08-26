
variable subnet_id {}
variable vault_id {}
variable user_id {}


terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "akBlob" {
  name = "akBlob"
  location = "eastus2"
}

resource "azurerm_storage_account" "akBlob728" {
  name                     = "akblob728"
  resource_group_name      = azurerm_resource_group.akBlob.name
  location                 = azurerm_resource_group.akBlob.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  #allow_blob_public_access = false
   identity {
    type = "UserAssigned"
    identity_ids = [var.user_id]
  }
   #network_rules {
   # default_action             = "Deny"
   # ip_rules                   = ["18.117.137.175","3.133.30.37","20.85.76.160","68.32.152.0/24","20.22.83.191","20.22.83.0/24","75.2.98.97/30","99.83.150.238/30","52.86.200.106/30","52.86.201.227/30","52.70.186.109/30","44.236.246.186/30","54.185.161.84/30","44.238.78.236/30"]
   # virtual_network_subnet_ids = [var.subnet_id]
   # bypass                     = ["AzureServices"]
 # }
  customer_managed_key {
   key_vault_key_id = var.vault_id
   user_assigned_identity_id = var.user_id
  }
  tags = {
    environment = "staging3"
  }
}

resource "azurerm_storage_account_network_rules" "example" {
  storage_account_id = azurerm_storage_account.akBlob728.id

 default_action             = "Deny"
 ip_rules                   = ["44.238.78.236/30"]
 virtual_network_subnet_ids = [var.subnet_id]
 bypass                     = ["AzureServices"]
  depends_on = [
    azurerm_storage_container.akblob, azurerm_storage_queue.akqueue
  ]
}

resource "azurerm_storage_container" "akblob" {
  name                  = "akblob2"
  storage_account_name  = azurerm_storage_account.akBlob728.name

  container_access_type = "private"
}

resource "azurerm_storage_queue" "akqueue" {
  name                 = "akqueue3"
  storage_account_name = azurerm_storage_account.akBlob728.name
}

data "external" "curlip" {
program = ["sh", "-c", "echo '{ \"extip\": \"'$(curl -s https://ifconfig.me)'\" }'"]
}

output "curlip" {
  value = data.external.curlip
}