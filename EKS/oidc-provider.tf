data "tls_certificate" "eks-cluster-tls-certificate" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-openid-connect" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks-cluster-tls-certificate.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks-cluster-tls-certificate.url
  depends_on      = [aws_eks_cluster.eks-cluster]
  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}