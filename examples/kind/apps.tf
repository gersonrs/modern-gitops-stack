# module "mlflow" {
#   source = "git::https://github.com/GersonRS/modern-gitops-stack-module-mlflow.git?ref=v1.5.0"
#
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   oidc = module.oidc.oidc
#   allowed_groups = [
#     "modern-gitops-stack-admins",
#     "modern-gitops-stack-data-scientists",
#     "modern-gitops-stack-ml-engineers",
#   ]
#
#   storage = {
#     bucket_name       = "mlflow"
#     endpoint          = module.minio.endpoint
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.username
#     password = module.postgresql.credentials.password
#     database = "mlflow"
#     service  = module.postgresql.cluster_dns
#   }
#   dependency_ids = {
#     argocd     = module.argocd_bootstrap.id
#     istio      = module.istio.id
#     minio      = module.minio.id
#     postgresql = module.postgresql.id
#     oidc       = module.oidc.id
#   }
# }

# module "strimzi" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-strimzi.git?ref=v1.6.0"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   dependency_ids = {
#     argocd = module.argocd_bootstrap.id
#   }
# }

# module "kafka" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-kafka.git?ref=v2.13.0"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   dependency_ids = {
#     argocd  = module.argocd_bootstrap.id
#     strimzi = module.strimzi.id
#   }
# }

# module "cp-schema-registry" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-cp-schema-registry.git?ref=v1.6.0"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   kafka_broker_name      = module.kafka.broker_name
#   gateway_name           = module.istio.gateway_name
#   gateway_namespace      = module.istio.gateway_namespace
#   oidc                   = module.oidc.oidc
#   allowed_groups = [
#     "modern-gitops-stack-admins",
#     "modern-gitops-stack-data-engineers",
#   ]
#   dependency_ids = {
#     argocd = module.argocd_bootstrap.id
#     kafka  = module.kafka.id
#   }
# }

# module "kafka-ui" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-kafka-ui.git?ref=v1.6.0"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   kafka_broker_name      = module.kafka.broker_name
#   gateway_name           = module.istio.gateway_name
#   gateway_namespace      = module.istio.gateway_namespace
#   oidc                   = module.oidc.oidc
#   allowed_groups = [
#     "modern-gitops-stack-admins",
#     "modern-gitops-stack-data-engineers",
#   ]
#   dependency_ids = {
#     argocd             = module.argocd_bootstrap.id
#     kafka              = module.kafka.id
#     cp-schema-registry = module.cp-schema-registry.id
#   }
# }

# module "trino" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-trino.git?ref=v1.1.1"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   pinot_dns              = module.pinot.cluster_dns
#   storage = {
#     bucket_name       = "trino"
#     endpoint          = module.minio.endpoint
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.user
#     password = module.postgresql.credentials.password
#     database = "curated"
#     service  = module.postgresql.cluster_dns
#   }
#   dependency_ids = {
#     argocd     = module.argocd_bootstrap.id
#     traefik    = module.traefik.id
#     oidc       = module.oidc.id
#     minio      = module.minio.id
#     postgresql = module.postgresql.id
#     pinot      = module.pinot.id
#   }
# }


# module "pinot" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-pinot.git?ref=v1.1.1"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   storage = {
#     bucket_name       = "pinot"
#     endpoint          = module.minio.endpoint
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   dependency_ids = {
#     argocd  = module.argocd_bootstrap.id
#     traefik = module.traefik.id
#     minio   = module.minio.id
#   }
# }

# module "zookeeper" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-zookeeper.git?ref=v2.0.0"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   dependency_ids = {
#     argocd = module.argocd_bootstrap.id
#   }
# }

# module "nifi" {
#   source                 = "git::https://github.com/GersonRS/modern-gitops-stack-module-nifi.git?ref=v1.5.0"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor
#   oidc                   = module.oidc.oidc
#   dependency_ids = {
#     zookeeper = module.zookeeper.id
#   }
# }

# module "spark" {
#   source = "git::https://github.com/GersonRS/modern-gitops-stack-module-spark.git?ref=v1.5.1"

#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor

#   storage = {
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }

#   dependency_ids = {
#     argocd       = module.argocd_bootstrap.id
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     minio        = module.minio.id
#   }
# }

# module "hive-metastore" {
#   source = "git::https://github.com/GersonRS/modern-gitops-stack-module-hive-metastore.git?ref=v1.2.0"

#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor

#   storage = {
#     bucket_name       = "warehouse"
#     endpoint          = module.minio.endpoint
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.user
#     password = module.postgresql.credentials.password
#     database = "metastore"
#     service  = module.postgresql.cluster_dns
#   }

#   dependency_ids = {
#     argocd       = module.argocd_bootstrap.id
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#     spark        = module.spark.id
#   }
# }

# module "jupyterhub" {
#   source          = "git::https://github.com/GersonRS/modern-gitops-stack-module-jupyterhub.git?ref=v1.3.0"
#   cluster_name    = local.cluster_name
#   base_domain     = local.base_domain
#   subdomain       = local.subdomain
#   cluster_issuer  = local.cluster_issuer
#   argocd_project  = local.cluster_name
#   app_autosync    = local.app_autosync
#   oidc            = module.oidc.oidc
#   storage = {
#     bucket_name       = "mlflow"
#     endpoint          = module.minio.endpoint
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     database = "jupyterhub"
#     user     = module.postgresql.credentials.username
#     password = module.postgresql.credentials.password
#     endpoint = module.postgresql.cluster_dns
#   }
#   mlflow = {
#     endpoint = module.mlflow.cluster_dns
#   }
#   # ray = {
#   #   endpoint = module.ray.cluster_dns
#   # }
#   dependency_ids = {
#     argocd     = module.argocd_bootstrap.id
#     traefik    = module.traefik.id
#     oidc       = module.oidc.id
#     minio      = module.minio.id
#     postgresql = module.postgresql.id
#     mlflow     = module.mlflow.id
#   }
# }

# module "qdrant" {
#   source = "git::https://github.com/GersonRS/modern-gitops-stack-module-qdrant.git?ref=v1.2.0"

#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   subdomain              = local.subdomain
#   cluster_issuer         = local.cluster_issuer
#   argocd_project         = local.cluster_name
#   app_autosync           = local.app_autosync
#   enable_service_monitor = local.enable_service_monitor

#   dependency_ids = {
#     argocd       = module.argocd_bootstrap.id
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#   }
# }

module "airflow" {
  source                 = "../../../modern-gitops-stack-module-airflow"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  subdomain              = local.subdomain
  cluster_issuer         = local.cluster_issuer
  argocd_project         = local.cluster_name
  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor
  oidc                   = module.oidc.oidc
  target_revision        = "develop"
  fernetKey              = base64encode(resource.random_password.airflow_fernetKey.result)
  storage = {
    bucket_name       = local.minio_config.buckets.3.name
    endpoint          = module.minio.endpoint
    access_key        = local.minio_config.users.3.accessKey
    secret_access_key = local.minio_config.users.3.secretKey
  }
  database = {
    database = "airflow"
    user     = module.postgresql.credentials.username
    password = module.postgresql.credentials.password
    endpoint = module.postgresql.cluster_dns
  }
  dependency_ids = {
    argocd     = module.argocd.id
    istio      = module.istio.id
    oidc       = module.oidc.id
    minio      = module.minio.id
    postgresql = module.postgresql.id
  }
}
