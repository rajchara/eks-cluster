terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "ca-central-1"
    bucket         = "aws-lab-eks-cluster-dev-terraform-states"
    key            = "lab.tfstate"
    dynamodb_table = "aws-lab-eks-cluster-dev-terraform-states-lock"
    profile        = "cofomo"
    role_arn       = ""
    encrypt        = "true"
  }
}



