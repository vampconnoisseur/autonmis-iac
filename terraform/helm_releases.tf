resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = true

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

  depends_on = [
    module.eks,
    aws_iam_role.alb_controller_role,
    aws_iam_policy.alb_controller_policy,
    kubernetes_service_account.alb_controller,
    aws_iam_role_policy_attachment.alb_controller_policy_attachment
  ]
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [file("../helm/values/nginx/nginx-values.yml")]

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }

  depends_on = [
    module.eks,
  ]
}

resource "helm_release" "autonmis" {
  name             = "autonmis"
  chart            = "../autonmis-charts"
  namespace        = "autonmis"
  version          = "1.0.0"
  create_namespace = true

  values = [
    file("../helm/values/autonmis/autonmis-values.yml")
  ]

  depends_on = [
    helm_release.nginx_ingress,
    kubernetes_manifest.letsencrypt_clusterissuer
  ]
}

resource "helm_release" "notebook" {
  name             = "notebook"
  chart            = "../notebook-charts"
  namespace        = "notebook"
  create_namespace = true

  values = [
    file("../helm/values/notebook/notebook-values.yml")
  ]

  depends_on = [
    helm_release.nginx_ingress,
    kubernetes_manifest.letsencrypt_clusterissuer
  ]
}

resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow-helm.github.io/charts"
  chart            = "airflow"
  version          = "8.9.0"
  namespace        = "airflow"
  create_namespace = true

  values = [
    file("../helm/values/airflow/airflow-values.yml")
  ]

  depends_on = [
    helm_release.nginx_ingress,
    kubernetes_storage_class.efs_sc,
    aws_efs_mount_target.efs_mount_target,
    kubernetes_manifest.letsencrypt_clusterissuer
  ]
}

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "kube-system"
  create_namespace = true

  depends_on = [
    module.eks
  ]
}
