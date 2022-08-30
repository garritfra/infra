locals {
    vault_path = "../ansible/vars/vault.yml"
}

provider "ansiblevault" {
  root_folder = "../ansible/"
  vault_path  = "../ansible/.vault-password"
}

data "ansiblevault_path" "hcloud_token" {
  path = local.vault_path
  key  = "hcloud_token"
}

data "ansiblevault_path" "b2_application_key" {
  path = local.vault_path
  key  = "b2_application_key"
}

data "ansiblevault_path" "b2_application_key_id" {
  path = local.vault_path
  key  = "b2_application_key_id"
}