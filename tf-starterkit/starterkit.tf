
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "my-rg" {
  name     = "starterkitRG"
  location = "eastus2"
}

resource "azurerm_storage_account" "starterkitstorage" {
  name                     = "starterkitstorage"
  resource_group_name      = "${azurerm_resource_group.my-rg.name}"
  location                 = "eastus2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "null_resource" "inspec" {
    provisioner "local-exec" {
#        command = "inspec exec https://github.com/anniehedgpeth/inspec-azure-demo.git -t azure://${var.subscription_id}"
        command = "inspec exec ../inspec-starterkit -t azure://${var.subscription_id}"

    }
}