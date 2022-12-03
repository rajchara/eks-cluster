output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "aws_auth_configmap_yaml" {
  description = "Kubernetes user map"
  value       = module.eks.aws_auth_configmap_yaml
}

output "aws_iam_group_policy" {
  description = "IAM group policy"
  value = aws_iam_group_policy.k8s_ns
}

