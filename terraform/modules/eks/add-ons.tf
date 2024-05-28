# # Instalación  Controllers

# resource "aws_eks_addon" "example" {
#   cluster_name = "${aws_eks_cluster.eks_adn.name}"
#   addon_name   = "vpc-cni"
# }

# resource "aws_eks_addon" "coredns" {
#   cluster_name = "${aws_eks_cluster.eks_adn.name}"
#   addon_name   = "coredns"
# }

# # Instalación del AWS Load Balancer Controller
# resource "helm_release" "alb_controller" {
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   name       = "alb-controller"
#   version    = "1.2.7"
#   timeout    = 300

#   set {
#     name  = "clusterName"
#     value = var.eks_name
#   }
# }
