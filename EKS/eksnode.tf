/*=========
IAM role for aws-node ( VPC CNI pods) 
This is role will be used by service account aws-node associated to aws-node pods which 
needs IAM permissions to spin up eks node 
===========*/
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}



resource "aws_eks_node_group" "eks-node" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.environment}-${var.app_name}-eks-node"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = var.subnet_ids
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-eks-nodegroup"
  })

  scaling_config {
    desired_size = var.eks_desired_size
    max_size     = var.eks_max_size
    min_size     = var.eks_min_size
  }

  capacity_type  = "ON_DEMAND"
  instance_types = [var.eks_instance_type]

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role.eks-node-role
  ]
}

data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}


data "aws_iam_policy_document" "eks-node-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-nodegroup.amazonaws.com", "eks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks-node-role" {
  name               = "${var.environment}-${var.app_name}-eks-node-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eks-node-role-policy.json
  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-eks-iam-role"
  })
  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}


resource "aws_iam_role_policy_attachment" "eks-node-role-policy-attach" {
  role       = aws_iam_role.eks-node-role.name
  count      = length(compact(concat(var.node_policies, local.node_policies)))
  policy_arn = compact(concat(var.node_policies, local.node_policies))[count.index]
}