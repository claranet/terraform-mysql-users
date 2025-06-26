terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    mysql = {
      source  = "Paynetworx/mysql"
      version = ">= 1.12"
    }
    azurecaf = {
      source  = "claranet/azurecaf"
      version = "1.2.28"
    }
  }
}

provider "azurerm" {
  features {}
}
