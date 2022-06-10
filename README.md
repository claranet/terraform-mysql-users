# MySQL user module

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "x.x.x"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

module "db_maria" {
  source  = "claranet/db-maria/azurerm"
  version = "x.x.x"

  client_name    = var.client_name
  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name

  tier     = "GeneralPurpose"
  capacity = 4

  authorized_cidrs = {
    rule1 = "10.0.0.0/24",
    rule2 = "12.34.56.78/32"
  }

  storage_mb                   = 5120
  backup_retention_days        = 10
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = false

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  force_ssl = true

  databases_names     = ["mydatabase"]
  databases_collation = { mydatabase = "utf8_general_ci" }
  databases_charset   = { mydatabase = "utf8" }

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]

  extra_tags = {
    foo = "bar"
  }
}

provider "mysql" {
  endpoint = format("%s:3306", module.db_maria.mariadb_fqdn)
  username = module.db_maria.mariadb_administrator_login
  password = module.db_maria.mariadb_administrator_password

  tls = true
}

module "mysql_users" {
  source = "git::ssh://git@git.fr.clara.net/claranet/projects/cloud/azure/terraform/mysql-users.git?ref=AZ-762_init_mysql_users"

  for_each = toset(module.db_maria.mariadb_databases_names)

  user_suffix_enabled = true
  user                = each.key
  database            = each.key
}
```

## Providers

| Name | Version |
|------|---------|
| mysql | ~> 1.12 |
| random | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mysql_grant.role](https://registry.terraform.io/providers/Paynetworx/mysql/latest/docs/resources/grant) | resource |
| [mysql_user.user](https://registry.terraform.io/providers/Paynetworx/mysql/latest/docs/resources/user) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| database | Database name | `string` | n/a | yes |
| host | User Host | `string` | `"%"` | no |
| password | Password if not generated | `string` | `null` | no |
| privileges | List of privileges | `list(any)` | <pre>[<br>  "ALL"<br>]</pre> | no |
| user | User name | `string` | n/a | yes |
| user\_suffix\_enabled | Append `_user` suffix | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| password | Password |
| user | User |
<!-- END_TF_DOCS -->