terraform {
  required_version = ">= 1.3.2"

 required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    aws = ">= 3.0, <= 4.67.0"
  }
}