output "user" {
  description = "User"
  value       = mysql_user.user.user
}

output "password" {
  description = "Password"
  value       = coalesce(var.password, random_password.password.result)
  sensitive   = true
}
