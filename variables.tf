variable "user" {
  type        = string
  description = "User name"
}

variable "password" {
  type        = string
  default     = null
  description = "Password if not generated"
}

variable "databases" {
  type        = list(any)
  description = "Databases names"
}

variable "user_suffix_enabled" {
  type        = bool
  default     = false
  description = "Append `_user` suffix"
}

variable "host" {
  type        = string
  default     = "%"
  description = "User Host"
}

variable "privileges" {
  type        = list(any)
  default     = ["ALL PRIVILEGES"]
  description = "List of privileges"
}
