locals {
  ns_auth_roles = [ 
    for key,value in var.namespaces : { 
      rolearn = aws_iam_role.k8s_ns_access[key].arn 
      username = "k8s-${key}-user"
      groups = []
    }
  ]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_roles = concat([
    {
      rolearn  = aws_iam_role.k8s_admin.arn
      username = "k8s-admin-user"
      groups   = []
    }], 
    local.ns_auth_roles
  )

  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    attach_cluster_primary_security_group = true
    create_security_group = false
  }

  eks_managed_node_groups = {
    one = {
      name = "${local.cluster_name}-1"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }

    two = {
      name = "${local.cluster_name}-2"
      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]
    }
  }
}


resource "kubernetes_cluster_role_v1" "k8s_admin" {
  metadata {
    name = "k8s-admin-role"
  }

  rule {
    api_groups     = ["", "apps", "batch", "extensions"]
    resources      = [
       "configmaps",
       "cronjobs",
       "deployments",
       "events",
       "ingresses",
       "jobs",
       "pods",
       "pods/attach",
       "pods/exec",
       "pods/log",
       "pods/portforward",
       "secrets",
       "services",
       "replicasets",
    ]
    verbs          = [
       "create",
       "delete",
       "describe",
       "get",
       "list",
       "patch",
       "update"
    ]
  }
}

resource "kubernetes_cluster_role_binding_v1" "k8s_admin" {
  metadata {
    name      = "k8s-admin-rolebinding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "k8s-admin-role"
  }

  subject {
    kind      = "User"
    name      = "k8s-admin-user"
    api_group = "rbac.authorization.k8s.io"
  }
}

# 
# Build the namespace and the user role allowing access through a corresponding IAM group
#
resource "kubernetes_namespace_v1" "envs" {
  for_each = var.namespaces
  metadata {
    annotations = {
      name = each.key
    }

    labels = {
      created-by = "terraform"
    }

    name = each.key 
  }
}

resource "kubernetes_role_v1" "ns_access" {
  for_each = var.namespaces
  metadata {
    name = "k8s-${each.key}-role"
    namespace = each.key 
  }

  rule {
    api_groups     = ["", "apps", "batch", "extensions"]
    resources      = [
       "configmaps",
       "cronjobs",
       "deployments",
       "events",
       "ingresses",
       "jobs",
       "pods",
       "pods/attach",
       "pods/exec",
       "pods/log",
       "pods/portforward",
       "secrets",
       "services",
       "replicasets",
    ]
    verbs          = [
       "create",
       "delete",
       "describe",
       "get",
       "list",
       "patch",
       "update"
    ]
  }
}

resource "kubernetes_role_binding_v1" "ns_access" {
  for_each = var.namespaces
  metadata {
    name      = "k8s-${each.key}-rolebinding"
    namespace = each.key 
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "k8s-${each.key}-role"
  }

  subject {
    kind      = "User"
    name      = "k8s-${each.key}-user"
    api_group = "rbac.authorization.k8s.io"
  }
}

