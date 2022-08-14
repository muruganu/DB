variable "lambda_sg" {}

variable "subnet_ids" {
  type = list(string)
}

variable "asm_ep_sg" {}

variable "vpc_id" {}

variable "rds_endpoint" {}
variable "dbname" {}
variable "dbidentifier" {}
variable "dbusername" {}
variable "dbpass" {}