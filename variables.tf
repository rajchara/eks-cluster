variable "region" {
  description = "AWS region"
  type        = string
  default     = "ca-central-1"
}

variable "cluster-suffix" {
  type    = string
  default = "Lab"
}

variable "node-prefix" {
  type    = string
  default = "EKS-Node"
}

variable "cluster-name" {
  type    = string
  default = ""
}

variable "namespaces" {
  type    = map(string)
  default = {
    "dev" = "",
    "interview" = ""
  }
}

variable "eks_users_auth" {
  type    = map(list(string))
  default = {
        "joce-test" = ["dev"] 
        "HarikaG" = ["interview"] 
  }
}
  


