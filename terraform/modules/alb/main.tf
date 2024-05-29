# Si bien, se creo un alb por tf, la AMI usada para el eks contiene la instalado el alb ingress controller, por lo que al final como alternativa se puede crear el alb desde el ingress.yml
resource "aws_lb_target_group" "alb_tg_app_eks" {
  name     = "alb-tg-app-eks"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled = true
    healthy_threshold = 3
    matcher = 200
    path = "/"
    timeout = 3
    unhealthy_threshold = 2
  }

}



resource "aws_lb_target_group_attachment" "attach_app_eks" {
  target_group_arn = aws_lb_target_group.alb_tg_app_eks.arn
  target_id        = var.instance_id_eks
  port             = 80
}


resource "aws_lb" "alb_app_eks" {
  name               = "alb-app-eks"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_tls_id]
  subnets            = ["${var.public_subnet_az1_id}", "${var.public_subnet_az2_id}"]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}
resource "aws_lb_listener" "listener_app"{ 
  load_balancer_arn = aws_lb.alb_app_eks.arn
  port              = "80"
  protocol          = "HTTP"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_app_eks.arn
  }
}
