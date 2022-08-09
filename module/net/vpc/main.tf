#-------VPC------------------

resource "aws_vpc" "vpc" {
  enable_dns_hostnames = true
  enable_dns_support = true
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my_vpc"
  }
}

#Availability zones

data "aws_availability_zones" "available" {
  state = "available"
}


# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.public_route_association
  ]
  vpc = true
}


#-------Private and Public Subnets------------------

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count = "${length(var.private_cidr)}"
  cidr_block              = var.private_cidr[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_subnet"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count = "${length(var.public_cidr)}"
  cidr_block              = var.public_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public_subnet"
  }
}


#---Internet Gateway------------

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

#-----Route Table------------

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id
  route {
    gateway_id = aws_internet_gateway.ig.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_default_route_table" "default_route" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name = "Default Route table"
  }
}

resource "aws_route_table_association" "public_route_association" {
  route_table_id = aws_route_table.public_route.id
  count = "${length(var.public_cidr)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id,count.index)}"

}


# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id

  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public_subnet[0].id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }

}

# Creating an Route Table Association of the NAT Gateway route
# table with the Private Subnet!
resource "aws_route_table_association" "private_rt_assoc" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  count = "${length(var.private_cidr)}"
  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id  = "${element(aws_subnet.private_subnet.*.id,count.index)}"
  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}
