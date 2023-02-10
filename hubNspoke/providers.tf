terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.90"
    }
  }
}

provider "azurerm" {
  features {}
}