terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.63.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }

  backend "azurerm" {
    container_name = "terraformstates"
    key            = "template_populator.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  storage_use_azuread = true
  features {}
}

provider "azuread" {
  tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = "westeurope"
}

data "azurerm_key_vault" "devops_kvt" {
  name                = var.devops_kvt
  resource_group_name = var.devops_rg
}

data "azurerm_key_vault_secret" "devops_sp_object_id" {
  name         = "devops-sp-object-id"
  key_vault_id = data.azurerm_key_vault.devops_kvt.id
}
