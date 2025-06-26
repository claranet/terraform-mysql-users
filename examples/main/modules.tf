module "mysql_flexible" {
  source  = "claranet/db-mysql-flexible/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.name

  tier          = "GeneralPurpose"
  mysql_version = "8.0.21"

  allowed_cidrs = {
    "peered-vnet"     = "10.0.0.0/24"
    "customer-office" = "12.34.56.78/32"
  }

  backup_retention_days        = 10
  geo_redundant_backup_enabled = true

  administrator_login = "azureadmin"

  databases = {
    "documents" = {
      "charset"   = "utf8"
      "collation" = "utf8_general_ci"
    }
  }

  options = {
    interactive_timeout = "600"
    wait_timeout        = "260"
  }

  logs_destinations_ids = [
    module.logs.id,
    module.logs.storage_account_id,
  ]

  extra_tags = {
    foo = "bar"
  }
}

provider "mysql" {
  endpoint = "${module.mysql_flexible.fqdn}:3306"
  username = module.mysql_flexible.administrator_login
  password = module.mysql_flexible.administrator_password

  tls = true
}

module "mysql_users" {
  source  = "claranet/users/mysql"
  version = "x.x.x"

  user      = "claranet-db"
  databases = module.mysql_flexible.databases_names

  # user_suffix_enabled = true
}
