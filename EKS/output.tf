output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}


output "eks_cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "eks_cluster_cert_authority" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}
output "eks_cluster_oidc_issuer" {
  value = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}
output "eks-node-iam-role-arn" {
  value = aws_iam_role.eks-node-role.arn
}

output "oidc_url" {
  value = aws_iam_openid_connect_provider.eks-openid-connect.url
}
output "oidc_arn" {
  value = aws_iam_openid_connect_provider.eks-openid-connect.arn
}