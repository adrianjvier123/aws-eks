data "aws_caller_identity" "current" {}
#desomentar lineas 9-15 depues de la primera ejecucion
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
    #   { 
    #     Effect = "Allow",
    #     Principal = {
    #       AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/codebuild-role"
    #     },
    #     Action = "sts:AssumeRole"
    #   },
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_common" {
  name = "eks-glue"
  path = "/"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${aws_iam_role.codebuild_role.arn}"
    }
  ]
})
}

resource "aws_iam_policy_attachment" "codebuild_s3_accesssss" {
  name       = "codebuild-s3-access"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "${aws_iam_policy.glue_common.arn}"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-policy-adn"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      },
    {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Resource  = "${aws_iam_role.codebuild_role.arn}"
      }
      // Otros permisos necesarios
    ]
  })
}


resource "aws_iam_policy_attachment" "codebuild_s3_access" {
  name       = "codebuild-s3-access"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "codebuild_ecr_access" {
  name       = "codebuild-ecr-access"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


resource "aws_codebuild_project" "python_build" {
  name          = "python-build-project"
  description   = "Compiles a Python application"
  build_timeout = 5

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_REGION"
      value = "us-east-1"
    }
    environment_variable {
      name  = "AWS_ECR_REPOSITORY_NAME"
      value = "python-app-repo"
    }
    environment_variable {
      name  = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.codebuild_role.arn #(hacer que use el otro rol el de code buil pero con mas permisos o agregar los permisos del otro del eks al de codebuild)
    }
    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = "eks-adn"
    }
  }

  source {
    buildspec = "buildspec.yml"
    type      = "GITHUB"
    location  = "https://github.com/adrianjvier123/aws-eks.git"
    git_clone_depth = 1
  }
}




data "aws_iam_policy" "eks_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # Política integrada de Amazon EKS para el control del clúster
}


resource "aws_iam_role_policy_attachment" "eks_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = data.aws_iam_policy.eks_policy.arn
}


