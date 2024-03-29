variable "lakehouse_name" {
  description = "The name of the lakehouse"
  type        = string
  default     = "delta_lakehouse"
}

variable "environment" {
  description = "The name of the current environment"
  type        = string
  default     = "sandbox"
}

variable "project_root" {
  description = "The root directory of the project"
  type        = string
  default     = "../.."
}
