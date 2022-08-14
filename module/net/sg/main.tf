#-----Public Secuity Group-------------

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Used for the elastic load balancer for public access"
  vpc_id      = var.vpc_id

  #HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Public SG"
  }
}


#-----Public Secuity Group-------------

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Used for the elastic load balancer for public access"
  vpc_id      = var.vpc_id

  #HTTP
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Rds SG"
  }
}

# Security group: allow only specific egress and deny all ingress.
resource "aws_security_group" "lambda_sg" {
  name   = "lambda_sg"
  vpc_id = var.vpc_id
  egress {
    description = "Secrets Manager via VPC endpoint"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    description = "MySQL password rotation"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    description = "RDS API via proxy"
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

#-----Public Secuity Group-------------

resource "aws_security_group" "asm_ep_sg" {
  name        = "asm_ep_sg"
  description = "Used for the elastic load balancer for public access"
  vpc_id      = var.vpc_id

  #HTTP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Rds SG"
  }
}