# --- Modules bases ---
module "kind" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-cluster-kind.git?ref=v3.0.0"

  cluster_name       = local.cluster_name
  kubernetes_version = local.kubernetes_version
}

module "metallb" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-metallb.git?ref=v3.0.0"

  subnet = module.kind.kind_subnet

  depends_on = [module.kind]
}

module "argocd_bootstrap" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-argocd.git//bootstrap?ref=v6.0.0"
  argocd_projects = {
    "${local.cluster_name}" = {
      destination_cluster = "in-cluster"
    }
  }

  ssh_private_key = var.ssh_private_key

  repositories = [
    "git@github.com:GersonRS/modern-gitops-stack-module-argocd.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-metrics-server.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-istio.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-kiali.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-cert-manager.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-keycloak.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-postgresql.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-minio.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-mlflow.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-strimzi.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-kafka.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-cp-schema-registry.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-kafka-ui.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-pinot.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-trino.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-zookeeper.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-nifi.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-loki-stack.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-thanos.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-kube-prometheus-stack.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-spark.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-hive-metastore.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-airflow.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-jupyterhub.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-qdrant.git",
    "git@github.com:GersonRS/modern-gitops-stack-module-ray.git",
  ]

  depends_on = [module.kind]
}

module "metrics-server" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-metrics-server.git?ref=v3.0.0"

  argocd_project = local.cluster_name

  app_autosync = local.app_autosync

  kubelet_insecure_tls = true

  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

# Prometheus Operator CRDs (ServiceMonitor, PodMonitor, PrometheusRule, ...)
# are installed before any other module so every application can enable its
# ServiceMonitor from the very first apply. Without this, enabling
# enable_service_monitor on the first run broke modules installed before
# kube-prometheus-stack (cert-manager) because the CRD did not exist yet.
# kube-prometheus-stack runs with crds.enabled=false, so this is the only
# owner of those objects.
module "crds_bootstrap" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-kube-prometheus-stack.git//crds_bootstrap?ref=v4.0.0"

  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

module "cert-manager" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-cert-manager.git//self-signed?ref=v3.0.0"

  argocd_project = local.cluster_name

  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor

  dependency_ids = {
    argocd         = module.argocd_bootstrap.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "istio" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-istio.git//kind?ref=v2.0.0"

  cluster_name           = local.cluster_name
  subdomain              = local.subdomain
  cluster_issuer         = local.cluster_issuer
  argocd_project         = local.cluster_name
  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor
  dependency_ids = {
    argocd         = module.argocd_bootstrap.id
    cert-manager   = module.cert-manager.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "postgresql" {
  source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-postgresql.git?ref=v4.0.0"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  subdomain              = local.subdomain
  cluster_issuer         = local.cluster_issuer
  argocd_project         = local.cluster_name
  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor

  dependency_ids = {
    argocd         = module.argocd_bootstrap.id
    istio          = module.istio.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "keycloak" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-keycloak.git?ref=v3.0.0"

  cluster_name   = local.cluster_name
  base_domain    = local.base_domain
  subdomain      = local.subdomain
  cluster_issuer = local.cluster_issuer
  argocd_project = local.cluster_name

  app_autosync = local.app_autosync
  database = {
    host     = module.postgresql.cluster_dns
    username = module.postgresql.credentials.username
    password = module.postgresql.credentials.password
  }

  dependency_ids = {
    istio          = module.istio.id
    cert-manager   = module.cert-manager.id
    postgresql     = module.postgresql.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "oidc" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-keycloak.git//oidc_bootstrap?ref=v3.1.0"

  cluster_name   = local.cluster_name
  base_domain    = local.base_domain
  subdomain      = local.subdomain
  cluster_issuer = local.cluster_issuer

  dependency_ids = {
    keycloak   = module.keycloak.id
    postgresql = module.postgresql.id
  }
}



module "minio" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-minio.git?ref=v3.0.0"

  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  subdomain              = local.subdomain
  cluster_issuer         = local.cluster_issuer
  argocd_project         = local.cluster_name
  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor
  config_minio           = local.minio_config
  oidc                   = module.oidc.oidc
  dependency_ids = {
    istio          = module.istio.id
    cert-manager   = module.cert-manager.id
    oidc           = module.oidc.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}



module "loki-stack" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-loki-stack.git//kind?ref=v4.0.0"

  argocd_project = local.cluster_name

  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor
  logs_storage = {
    bucket_name = local.minio_config.buckets.0.name
    endpoint    = module.minio.endpoint
    access_key  = local.minio_config.users.0.accessKey
    secret_key  = local.minio_config.users.0.secretKey
  }

  dependency_ids = {
    istio          = module.istio.id
    minio          = module.minio.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "thanos" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-thanos.git//kind?ref=v4.0.0"

  cluster_name   = local.cluster_name
  base_domain    = local.base_domain
  subdomain      = local.subdomain
  cluster_issuer = local.cluster_issuer
  argocd_project = local.cluster_name

  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor

  metrics_storage = {
    bucket_name = local.minio_config.buckets.1.name
    endpoint    = module.minio.endpoint
    access_key  = local.minio_config.users.1.accessKey
    secret_key  = local.minio_config.users.1.secretKey
  }

  thanos = {
    oidc = module.oidc.oidc
  }

  allowed_groups = [
    "modern-gitops-stack-admins",
    "modern-gitops-stack-editors",
    "modern-gitops-stack-data-engineers",
    "modern-gitops-stack-ml-engineers",
    "modern-gitops-stack-data-scientists",
  ]

  dependency_ids = {
    argocd         = module.argocd_bootstrap.id
    istio          = module.istio.id
    cert-manager   = module.cert-manager.id
    minio          = module.minio.id
    keycloak       = module.keycloak.id
    oidc           = module.oidc.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "kube-prometheus-stack" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-kube-prometheus-stack.git//kind?ref=v4.0.0"

  cluster_name   = local.cluster_name
  base_domain    = local.base_domain
  subdomain      = local.subdomain
  cluster_issuer = local.cluster_issuer
  argocd_project = local.cluster_name

  app_autosync = local.app_autosync

  metrics_storage = {
    bucket_name = local.minio_config.buckets.1.name
    endpoint    = module.minio.endpoint
    access_key  = local.minio_config.users.1.accessKey
    secret_key  = local.minio_config.users.1.secretKey
  }

  prometheus = {
    oidc = module.oidc.oidc
  }
  alertmanager = {
    oidc = module.oidc.oidc
  }
  grafana = {
    oidc = module.oidc.oidc
  }

  allowed_groups = [
    "modern-gitops-stack-admins",
    "modern-gitops-stack-viewers",
    "modern-gitops-stack-editors",
    "modern-gitops-stack-data-engineers",
    "modern-gitops-stack-ml-engineers",
    "modern-gitops-stack-data-scientists",
  ]

  dependency_ids = {
    istio          = module.istio.id
    cert-manager   = module.cert-manager.id
    minio          = module.minio.id
    oidc           = module.oidc.id
    crds_bootstrap = module.crds_bootstrap.id
  }
}

module "kiali" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-kiali.git?ref=v2.0.0"

  cluster_name           = local.cluster_name
  subdomain              = local.subdomain
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_project         = local.cluster_name
  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor
  grafana_admin_password = module.kube-prometheus-stack.grafana_admin_password
  oidc                   = module.oidc.oidc

  dependency_ids = {
    argocd                = module.argocd_bootstrap.id
    istio                 = module.istio.id
    kube-prometheus-stack = module.kube-prometheus-stack.id
    oidc                  = module.oidc.id
    crds_bootstrap        = module.crds_bootstrap.id
  }
}

module "argocd" {
  source = "git::https://github.com/GersonRS/modern-gitops-stack-module-argocd.git?ref=v6.0.0"

  base_domain              = local.base_domain
  cluster_name             = local.cluster_name
  subdomain                = local.subdomain
  cluster_issuer           = local.cluster_issuer
  server_secretkey         = module.argocd_bootstrap.argocd_server_secretkey
  accounts_pipeline_tokens = module.argocd_bootstrap.argocd_accounts_pipeline_tokens
  argocd_project           = local.cluster_name
  app_autosync             = local.app_autosync
  admin_enabled            = false
  exec_enabled             = true

  oidc = {
    name         = "OIDC"
    issuer       = module.oidc.oidc.issuer_url
    clientID     = module.oidc.oidc.client_id
    clientSecret = module.oidc.oidc.client_secret
    requestedIDTokenClaims = {
      groups = {
        essential = true
      }
    }
  }

  dependency_ids = {
    istio                 = module.istio.id
    cert-manager          = module.cert-manager.id
    oidc                  = module.oidc.id
    kube-prometheus-stack = module.kube-prometheus-stack.id
    kiali                 = module.kiali.id
  }
}
