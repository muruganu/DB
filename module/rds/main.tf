
resource "aws_db_subnet_group" "rds-subnet" {
  name = "rds-subnet"
  subnet_ids = var.rds_subnet
}

/*
locals {
  version_elements       = split(".", var.engine_version)
  major_version_elements = [local.version_elements[0], local.version_elements[1]]
  major_engine_version   = var.major_engine_version == "" ? join(".", local.major_version_elements) : var.major_engine_version
}
*/

resource "aws_db_instance" "rds-mysql" {
  db_subnet_group_name = aws_db_subnet_group.rds-subnet.name
  allocated_storage    = var.rds_ds
  max_allocated_storage = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately = true
  vpc_security_group_ids = ["${var.rds_sg}"]
  allow_major_version_upgrade = true
  auto_minor_version_upgrade = true
  multi_az = false
  tags = {
    Name = "MysqlDB"
  }
}
