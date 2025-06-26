# MySQL Users module
[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/claranet/users/mysql/)

Terraform module using `MySQL` provider to create users and manage their roles on an existing Database.
This module will be used in combination with others MySQL modules (like [`azure-db-mysql`](https://registry.terraform.io/modules/claranet/db-mysql/azurerm/) for example).

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | OpenTofu version | AzureRM version |
| -------------- | ----------------- | ---------------- | --------------- |
| >= 8.x.x       | **Unverified**    | 1.8.x            | >= 4.0          |
| >= 7.x.x       | 1.3.x             |                  | >= 3.0          |
| >= 6.x.x       | 1.x               |                  | >= 3.0          |
| >= 5.x.x       | 0.15.x            |                  | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   |                  | >= 2.0          |
| >= 3.x.x       | 0.12.x            |                  | >= 2.0          |
| >= 2.x.x       | 0.12.x            |                  | < 2.0           |
| <  2.x.x       | 0.11.x            |                  | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

⚠️ Since modules version v8.0.0, we do not maintain/check anymore the compatibility with
[Hashicorp Terraform](https://github.com/hashicorp/terraform/). Instead, we recommend to use [OpenTofu](https://github.com/opentofu/opentofu/).

```hcl
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
| databases | Databases names | `list(any)` | n/a | yes |
| host | User Host | `string` | `"%"` | no |
| password | Password if not generated | `string` | `null` | no |
| privileges | List of privileges | `list(any)` | <pre>[<br/>  "ALL PRIVILEGES"<br/>]</pre> | no |
| user | User name | `string` | n/a | yes |
| user\_suffix\_enabled | Append `_user` suffix | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| password | Password |
| user | User |
<!-- END_TF_DOCS -->
