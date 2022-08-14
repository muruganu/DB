output "public_sg" {
  value = aws_security_group.public_sg.id
}

output "rds_sg" {
  value = aws_security_group.rds_sg.id
}

output "lambda_sg" {
  value = aws_security_group.lambda_sg.id
}

output "asm_ep_sg" {
  value = aws_security_group.asm_ep_sg.id
}