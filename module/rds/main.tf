
resource "aws_db_subnet_group" "rds-subnet" {
  name = "rds-subnet"
  subnet_ids = var.rds_subnet
}

/* KMS Credetial creation: aws kms encrypt \
  --key-id <YOUR KMS KEY> \
  --region <AWS REGION> \
  --plaintext fileb://db-creds.yml \
  --output text \
  --query CiphertextBlob \
  > db-creds.yml.encrypted
  */

data "aws_kms_secrets" "rds_secret" {
  secret {
    name    = "db"
    payload = file("${path.module}/db-creds.yml.encrypted")
  }
}

locals {
  db_creds = yamldecode(data.aws_kms_secrets.rds_secret.plaintext["db"])
}

resource "aws_db_instance" "rds-mysql" {
  db_subnet_group_name = aws_db_subnet_group.rds-subnet.name
  allocated_storage    = var.rds_ds
  max_allocated_storage = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = local.db_creds.username
  password             = local.db_creds.password
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
