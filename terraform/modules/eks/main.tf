resource "aws_eks_cluster" "eks_adn" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks_adn.arn

  vpc_config {
    subnet_ids = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  }


  depends_on = [
    aws_iam_role_policy_attachment.eks_adn_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_adn_AmazonEKSVPCResourceController,
  ]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_adn" {
  name               = "eks_cluster_adn"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_adn_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_adn.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security_groups_for_pods.html
resource "aws_iam_role_policy_attachment" "eks_adn_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_adn.name
}


#nodos

resource "aws_eks_node_group" "nodo-adn" {
  cluster_name    = aws_eks_cluster.eks_adn.name
  node_group_name = "nodo-${aws_eks_cluster.eks_adn.name}"
  node_role_arn   = aws_iam_role.role_node_eks_adn.arn
  subnet_ids      = [var.public_subnet_az1_id, var.public_subnet_az2_id]

  scaling_config {
    desired_size = "${var.nodes_count_disered}"
    max_size     = "${var.nodes_count_max}"
    min_size     = "${var.nodes_count_min}"
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.adn-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.adn-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.adn-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name = "apps"
  }
}


# iam role node gruop

resource "aws_iam_role" "role_node_eks_adn" {
  name = "${aws_eks_cluster.eks_adn.name}-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "adn-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.role_node_eks_adn.name
}

resource "aws_iam_role_policy_attachment" "adn-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.role_node_eks_adn.name
}

resource "aws_iam_role_policy_attachment" "adn-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_node_eks_adn.name
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.eks_adn.version}/amazon-linux-2/recommended/release_version"
}