variable "ssh_private_key" {
  description = <<-EOT
    Chave privada SSH no formato PEM utilizada para:
    - acesso a repositórios Git privados (deploy keys);
    - acesso SSH a nós do cluster quando necessário.

    Guarde essa chave como secret no provedor CI/CD e nunca a comite em texto claro no repositório.
  EOT
  type        = string
  sensitive   = true
  nullable    = false
}

variable "corporate_sso_client_secret" {
  description = <<-EOT
    Client secret do client registrado no Keycloak corporativo (SSO da Magalu)
    usado para Identity Brokering. Defina via terraform.tfvars (git-ignorado)
    ou variável de ambiente TF_VAR_corporate_sso_client_secret. Nunca comite em
    texto claro no repositório.
  EOT
  type        = string
  sensitive   = true
  default     = "7IfEV2od8LxYmMKqrXUicCcwlZEJHVab"
}
