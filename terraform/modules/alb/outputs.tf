output "aws_lb_target_group_app_arn_suffix" {
  value = aws_lb_target_group.alb_tg_app_eks.arn_suffix
}
output "alb_app_web1_arn_suffix" {
  value = aws_lb.alb_app_eks.arn_suffix
}