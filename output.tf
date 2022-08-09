#--VPC Outputs-------
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private1_subnet" {
  value = module.vpc.private_subnet
}

output "public1_subnet" {
  value = module.vpc.public_subnet
}

#---Security Group-----------

output "public_sg" {
  value = module.sg.public_sg
}


