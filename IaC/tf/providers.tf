terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.15.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {

}

resource "azurerm_resource_group" "rg" {
  name     = "auth-example"
  location = "North Europe"
}