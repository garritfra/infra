# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = local.hcloud_token
}

locals {
  hcloud_token = sensitive(data.ansiblevault_path.hcloud_token.value)
}

data "hcloud_image" "valheim_image" {
  id = 78001274
}

# Create a new SSH key
resource "hcloud_ssh_key" "garrit" {
  name       = "9B68E6CA (garrit@slashdev.space)"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrjQEjtRrlQBEbABfR59mQKoHIkLD/JP5OEs9+NbCwDBKS14vCEaQ0NcgBpDRSZ7zQ2SsrR3Ei/R41nuA9jJo/SZ8vGDKjwKgCTrQ9aMx3F8hhTWFQV5aQM3RhIqZtZe7Mxh3L99BSySxVxx9Q3qJuevNa04T7aNwY4JneEZCvRJaMycapzA9eMVpeohmFFiyEwC0peXIMxruQRKIElEXpsEUXswC48dUdwOfiD4/a8y4WRjHUTdvuSeSA3QmfExVT5eFjDUbXS1oTWa0iXGrEJZTC73W/o1HGuAv+4puP7UBTrA9lkUmkLK9QvSPrHwMyOrhJmABe+Aks2BBpSTGYoe5+d50CyqZeiTfncr/5SJsfY8Mx5/eM1diZ3I3KEGO5bcs92yfyej+IDVvBYtn/JheBld/MtuC5wbKxvoP7CSKqcJnxhvPjzIAEToxJe5CfuQ3S4lYxcreHDTXNJiy1Iu5ILRkywoA1xLvCp6DAhznsCjKBwgrhj5HnG/0Y+zM= openpgp:0x9B68E6CA"
}

resource "hcloud_server" "k3s" {
  count = 0

  name        = "k3s-${count.index}"
  location    = "nbg1"
  image       = "ubuntu-22.04"
  server_type = "cpx11"
  ssh_keys    = [hcloud_ssh_key.garrit.id]
}

resource "hcloud_server" "valheim1" {
  name        = "valheim1"
  location    = "nbg1"
  image       = 78001274 # <-- Snapshot from before terraform migration. Previously "ubuntu-22.04"
  server_type = "cx11"
  ssh_keys    = [hcloud_ssh_key.garrit.id]
}

resource "hcloud_volume" "valheim1" {
  name      = "valheim1"
  automount = true
  size      = 10
  format    = "ext4"
  server_id = hcloud_server.valheim1.id
}

resource "hcloud_firewall" "valheim" {
  name = "valheim"
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

  rule {
    description     = "Wireguard"
    direction       = "in"
    protocol        = "udp"
    port            = "51820"
    destination_ips = ["10.0.0.0/16"]
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "k8s" {
  name = "k3s"
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

  rule {
    description = "K8s nodes public"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      for s in hcloud_server.k3s : "${s.ipv4_address}/32"
    ]
  }

  rule {
    description = "K8s nodes public"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      for s in hcloud_server.k3s : "${s.ipv4_address}/32"
    ]
  }

  rule {
    description = "K8s nodes public"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      for s in hcloud_server.k3s : "${s.ipv4_address}/32"
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

resource "hcloud_firewall_attachment" "valheim" {
  firewall_id = hcloud_firewall.valheim.id
  server_ids = [hcloud_server.valheim1.id]
}

/* resource "hcloud_firewall_attachment" "k8s" {
  firewall_id = hcloud_firewall.k8s.id
  server_ids  = [for s in hcloud_server.k3s : s.id]
} */

# TODO: This is based on the assumption that there's only one server in this
# infrastructure. It would be nice to integrate a dynamic inventory for ansible.
output "valheim_server_ip" {
  value = hcloud_server.valheim1.ipv4_address
}

output "valheim_volume_device" {
  value = hcloud_volume.valheim1.linux_device
}

output "valheim_volume_format" {
  value = hcloud_volume.valheim1.format
}
