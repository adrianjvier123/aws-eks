output "endpoint" {
  value = aws_eks_cluster.eks_adn.endpoint
}
output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.eks_adn.certificate_authority[0].data
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_name
}

data "aws_instance" "eks_node" {
  depends_on = [aws_eks_node_group.nodo-adn ]
  # Filtras las instancias EC2 por su etiqueta o cualquier otro atributo único que identifique tu nodo
  filter {
    name   = "tag:eks:cluster-name"
    values = ["eks-adn"]  # Reemplaza con el nombre de tu nodo
  }
}

output "instance_id" {
  value = data.aws_instance.eks_node.id  # Obtén el primer ID de instancia encontrado
}