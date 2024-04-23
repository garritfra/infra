terraform {
  cloud {
    organization = "garritfra"

    workspaces {
      name = "infra"
    }
  }
  required_providers {
    ansiblevault = {
      source  = "Tyron2k/ansiblevault"
      version = "3.0.12"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.35.1"
    }
    b2 = {
      source = "Backblaze/b2"
      version = "0.8.9"
    }
  }
}
