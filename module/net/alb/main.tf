resource "aws_lb" "ec2-alb" {
  name = "ec2-alb"
  load_balancer_type = "application"
  security_groups = ["${var.alb_sg}"]
  enable_cross_zone_load_balancing = true
  subnets = var.subnets
  tags = {
    Name = "ec2-alb"
  }
}

# Target group for the web servers
resource "aws_lb_target_group" "web_servers" {
  name     = "ec2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ec2-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }
}
/*
resource "aws_lb_target_group_attachment" "asg_attach" {
  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id        = "${var.asg_id}"
}
*/
resource "aws_autoscaling_attachment" "alb_autoscale" {
  lb_target_group_arn = aws_lb_target_group.web_servers.arn
  autoscaling_group_name = "${var.asg_id}"
}