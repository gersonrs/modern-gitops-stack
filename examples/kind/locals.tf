resource "random_password" "airflow_fernetKey" {
  length  = 32
  special = false
}
locals {
  kubernetes_version = "v1.35.0"
  cluster_name       = "kind"
  base_domain        = format("%s.nip.io", replace(module.istio.external_ip, ".", "-"))
  subdomain          = "apps"
  cluster_issuer     = module.cert-manager.cluster_issuers.ca
  # The Prometheus Operator CRDs are installed by crds_bootstrap before every
  # other module, so ServiceMonitors can be enabled from the first apply
  # without breaking applications installed before kube-prometheus-stack.
  enable_service_monitor = true
  app_autosync           = { allow_empty = false, prune = true, self_heal = true }
}
