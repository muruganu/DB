variable "vpc_cidr" {
  type = string
}

variable "private_cidr" {
  type = list(string)
  default = []
}

variable "public_cidr" {
  type = list(string)
  default = []
}


variable "instance_type" {}
variable "rds_ds" {}
variable "engine_version" {}
