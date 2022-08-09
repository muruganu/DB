variable "vpc_cidr" {
  type = string
}

variable "private_cidr" {
  type = list(string)
}

variable "public_cidr" {
  type = list(string)
}
