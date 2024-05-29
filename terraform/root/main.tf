#configure aws provider
provider "aws" {
  region = var.region
#  profile = "cloud_user"
}

provider "kubernetes" {
  // Configura tu proveedor de Kubernetes aquí
}

# Descomentar lineas 13 - 21 una vez realizada primera ejecucion

# terraform {
#   backend "s3" {
#     bucket         = "s3-tfstate-adrian-jimenez-s3" 
#     key            = "terraform.tfstate"  # Nombre del archivo de estado en el bucket
#     region         = "us-east-1"  # Reemplaza con tu región AWS
#    # dynamodb_table = "tf_state_lock"  # Opcional: Nombre de la tabla DynamoDB para el bloqueo del estado
#   }
#   #experiments = [module_variable_optional_attrs]
# }



module "vpc" {
  source = "../modules/vpc"
  region = var.region
  project_name = var.project_name
  vpc_cidr = var.vpc_cidr
  public_subnet_az1_cidr = var.public_subnet_az1_cidr
  public_subnet_az2_cidr = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

module "security_groups" {
  source = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id #hace referencia la modulo vpc, que tiene como OUTPUT el id de la vpc en la variable vpc_id
}


module "alb"{
    source = "../modules/alb"
    sg_alb_tls_id = module.security_groups.sg_alb_tls_id
    private_app_subnet_az1_id = module.vpc.private_app_subnet_az1_id
    private_app_subnet_az2_id = module.vpc.private_app_subnet_az2_id
    public_subnet_az2_id = module.vpc.public_subnet_az2_id
    public_subnet_az1_id = module.vpc.public_subnet_az1_id
    vpc_id = module.vpc.vpc_id
    instance_id_eks = module.eks.instance_id
}

module "s3" {
  source = "../modules/s3"
  bucket_wp_name = var.bucket_wp_name
}

module "eks" {
  source = "../modules/eks"
  eks_name = "eks-${var.project_name}"
  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id
  nodes_count_disered = "1"
  nodes_count_max = "2"
  nodes_count_min = "1"
}

module "ecr" {
  source = "../modules/ecr"
}

module "code_build" {
  source = "../modules/code_build"
}
