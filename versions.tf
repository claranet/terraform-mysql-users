terraform {
  required_version = ">= 1.3"
  required_providers {
    mysql = {
      source  = "Paynetworx/mysql"
      version = "~> 1.12"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
