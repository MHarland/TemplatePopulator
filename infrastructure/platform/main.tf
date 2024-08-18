terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.108.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.52.0"
    }
  }

  backend "azurerm" {
    container_name = "terraformstates"
    key            = "platform.tfstate"
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
