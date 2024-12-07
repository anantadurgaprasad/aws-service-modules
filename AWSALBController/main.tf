data "aws_caller_identity" "current" {}

module "irsa" {
  source        = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//IRSA"
  oidc_provider = replace(var.oidc_url, "https://", "")

  namespace       = var.namespace
  service_account = var.service_account
  role_name       = "${var.environment}-${var.app_name}-alb-controller-irsa"
  policy_arns     = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"]

}

resource "helm_release" "aws_alb_controller" {
  name = "aws-load-balancer-controller"

  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  create_namespace = var.namespace != "kube-system" ? true : false
  version          = var.controller_version
  namespace        = var.namespace

  cleanup_on_fail = true
  values          = var.helm_values


  dynamic "set" {
    for_each = local.mandatory_helm_chart_values
    iterator = helm_key_value
    content {
      name  = helm_key_value.key
      value = helm_key_value.value
    }
  }



}
