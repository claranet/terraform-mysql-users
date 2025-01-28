resource "random_password" "password" {
  special = false
  length  = 32
}

resource "mysql_user" "user" {
  user               = var.user_suffix_enabled ? format("%s_user", var.user) : var.user
  plaintext_password = coalesce(var.password, random_password.password.result)
  host               = var.host
}

resource "mysql_grant" "role" {
  for_each   = toset(var.databases)
  user       = var.user_suffix_enabled ? format("%s_user", var.user) : var.user
  host       = var.host
  database   = each.key
  privileges = var.privileges
  depends_on = [mysql_user.user]
}
