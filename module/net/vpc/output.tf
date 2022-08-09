output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet" {
  value = aws_subnet.private_subnet.*.id
}

output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}

output "az1_subnet" {
  value = data.aws_availability_zones.available.names[0]
}

output "az2_subnet" {
  value = data.aws_availability_zones.available.names[1]
}