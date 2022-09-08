# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = local.hcloud_token
}

locals {
  hcloud_token = sensitive(data.ansiblevault_path.hcloud_token.value)
  locations = [
    "nbg1",
    "fsn1"
  ]
}

# Create a new SSH key
resource "hcloud_ssh_key" "garrit" {
  name       = "9B68E6CA (garrit@slashdev.space)"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrjQEjtRrlQBEbABfR59mQKoHIkLD/JP5OEs9+NbCwDBKS14vCEaQ0NcgBpDRSZ7zQ2SsrR3Ei/R41nuA9jJo/SZ8vGDKjwKgCTrQ9aMx3F8hhTWFQV5aQM3RhIqZtZe7Mxh3L99BSySxVxx9Q3qJuevNa04T7aNwY4JneEZCvRJaMycapzA9eMVpeohmFFiyEwC0peXIMxruQRKIElEXpsEUXswC48dUdwOfiD4/a8y4WRjHUTdvuSeSA3QmfExVT5eFjDUbXS1oTWa0iXGrEJZTC73W/o1HGuAv+4puP7UBTrA9lkUmkLK9QvSPrHwMyOrhJmABe+Aks2BBpSTGYoe5+d50CyqZeiTfncr/5SJsfY8Mx5/eM1diZ3I3KEGO5bcs92yfyej+IDVvBYtn/JheBld/MtuC5wbKxvoP7CSKqcJnxhvPjzIAEToxJe5CfuQ3S4lYxcreHDTXNJiy1Iu5ILRkywoA1xLvCp6DAhznsCjKBwgrhj5HnG/0Y+zM= openpgp:0x9B68E6CA"
}

resource "hcloud_server" "k8s" {
  count = 3

  name        = "htz-${local.locations[count.index % length(local.locations)]}-${floor(count.index / length(local.locations))}"
  location    = local.locations[count.index % length(local.locations)]
  image       = "ubuntu-22.04"
  server_type = "cpx11"
  keep_disk = false
  ssh_keys    = [hcloud_ssh_key.garrit.id]
}

resource "hcloud_firewall" "k8s" {
  # Only create if there is a server. Otherwise it would crash
  count = length(hcloud_server.k8s) > 0 ? 1 : 0

  name = "k8s"
  rule {
    description = "HTTP"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "HTTPS"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # TODO: ONLY FOR TESTING PURPOSES
  rule {
    description = "k8s control plane"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "K8s nodes public"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      for s in hcloud_server.k8s : "${s.ipv4_address}/32"
    ]
  }

  rule {
    description = "K8s nodes public"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      for s in hcloud_server.k8s : "${s.ipv4_address}/32"
    ]
  }

  rule {
    description = "K8s nodes public"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      for s in hcloud_server.k8s : "${s.ipv4_address}/32"
    ]
  }

  rule {
    description = "K8s nodes internal"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      "10.0.0.0/16"
    ]
  }

  rule {
    description = "K8s nodes internal"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      "10.0.0.0/16"
    ]
  }

  rule {
    description = "K8s nodes internal"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "10.0.0.0/16"
    ]
  }
}

resource "hcloud_firewall_attachment" "k8s" {
  # Only create if there is a server. Otherwise it would crash
  count = length(hcloud_server.k8s) > 0 ? 1 : 0

  firewall_id = one(hcloud_firewall.k8s).id
  server_ids  = [for s in hcloud_server.k8s : s.id]
}

output "hetzner_ips" {
  value = [
    for s in hcloud_server.k8s : {
      hostname = s.name
      ip = s.ipv4_address
    }
  ]
}
