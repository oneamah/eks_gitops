resource "aws_alb" "main" {
  name            = "main-alb"
  internal        = false
  security_groups = [var.alb_security_group_id]
  subnets         = var.subnet_ids
}

