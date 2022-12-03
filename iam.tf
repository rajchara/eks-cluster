data "aws_caller_identity" "aws_id" {}

resource "aws_iam_role" "k8s_admin" {
  name = "Kubernetes${terraform.workspace}Admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.aws_id.account_id}:root"
        }
      },
    ]
  })
}

resource "aws_iam_group" "k8s_admin" {
  name = "Kubernetes${terraform.workspace}Admin"
  path = "/eks/"
}

resource "aws_iam_group_policy" "k8s_admin" {
  name = "Kubernetes${terraform.workspace}Admin"
  group = aws_iam_group.k8s_admin.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AllowAssumeOrganizationAccountRole"
        Effect   = "Allow"
        Action = [ "sts:AssumeRole" ]
        Resource = "${aws_iam_role.k8s_admin.arn}"
      },
    ]
  })
}

#
# These roles are for namespace specific access control
#
resource "aws_iam_role" "k8s_ns_access" {
  for_each = var.namespaces
  name = "Kubernetes_${terraform.workspace}_${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.aws_id.account_id}:root"
        }
      },
    ]
  })
}

resource "aws_iam_group" "k8s_ns_access" {
  for_each = var.namespaces
  name = "Kubernetes_${terraform.workspace}_${each.key}"
  path = "/eks/"
}

resource "aws_iam_group_policy" "k8s_ns" {
  for_each = var.namespaces
  name = "Kubernetes_${terraform.workspace}_${each.key}"
  group = aws_iam_group.k8s_ns_access[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AllowAssumeOrganizationAccountRole"
        Effect   = "Allow"
        Action = [ "sts:AssumeRole" ]
        Resource = "${aws_iam_role.k8s_ns_access[each.key].arn}"
      },
    ]
  })
}

#
# Authorization part: give access to a cluster to a specific user
#
resource "aws_iam_user_group_membership" "eks_user" {
  for_each = var.eks_users_auth
  user = each.key 
  groups = [ for group in each.value : "Kubernetes_${terraform.workspace}_${group}" ]
  depends_on = [aws_iam_group.k8s_ns_access]
}
