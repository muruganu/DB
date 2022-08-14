module "vpc" {
  source = "./module/net/vpc"
  vpc_cidr = var.vpc_cidr
  private_cidr = var.private_cidr
  public_cidr = var.public_cidr
}

module "sg" {
  source = "./module/net/sg"
  vpc_id = module.vpc.vpc_id
}


data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"] # insert values here
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"] # insert values here
  }
}

module "rds" {
  depends_on = [module.vpc,module.sg]
  source = "./module/rds"
  rds_subnet = data.aws_subnets.private.ids
  rds_sg = module.sg.rds_sg
  rds_ds = var.rds_ds
  engine_version = var.engine_version

}

module "asm" {
  depends_on = [module.vpc,module.sg,module.rds]
  source = "./module/asm"
  lambda_sg = module.sg.lambda_sg
  rds_endpoint = module.rds.rds_hostname
  subnet_ids = data.aws_subnets.private.ids
  asm_ep_sg = module.sg.asm_ep_sg
  vpc_id = module.vpc.vpc_id
  dbname = module.rds.dbname
  dbidentifier = module.rds.db_identifier
  dbusername = module.rds.db_username
  dbpass = module.rds.db_pass
}
