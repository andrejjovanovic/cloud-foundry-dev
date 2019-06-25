
# Account variables
variable "project_id" {}
variable "region_id" {}
variable "credentials_path" {}

# Resource variables

variable "network_name" {
  default     = "cf-dev-network"
  type        = "string"
  description = "Network for Bosh lite dev playground"
}

variable "cidr_range" {
  default     = "10.0.0.0/24"
  type        = "string"
  description = "IP CIDR range for Google VPC"
}

variable "subnet_name" {
  default = "cf-dev-subnet"
}
