data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "${terraform.workspace}"
      Managed-by  = "Terraform"
    }
  }
}


data "aws_availability_zones" "available" {}

resource "aws_resourcegroups_group" "lab" {

  name = "${terraform.workspace}-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "Environment",
      "Values": [ "${terraform.workspace}"]
    },
    {
      "Key": "Managed-by",
      "Values": [ "Terraform"]
    }
  ]
}
JSON
  }
}
