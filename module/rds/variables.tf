variable "rds_subnet" {
  type = list(string)
}

variable "rds_sg" {}

variable "rds_ds" {}

variable "engine_version" {}

variable "major_engine_version" {
  default     = ""
  type        = string
  description = "Specifies the major version of the engine that this option group should be associated with."
}