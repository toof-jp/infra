# vultr-vps: k8s node joining the zen2/sakura-vps cluster over Tailscale.
#
# The instance boots the custom NixOS installer ISO built from
# toof-jp/nix-sandbox (`make vultr-iso`), hosted at var.vultr_iso_url so
# Vultr can fetch it. Install flow:
#   1. make vultr-iso, upload result somewhere Vultr can reach, set
#      vultr_iso_url
#   2. apply — instance boots the installer; ssh root@<ip>, run
#      `vultr-install` (the firewall blocks public SSH, so reach the
#      installer via the Vultr web console or a temporary SSH rule)
#   3. set vultr_attach_iso = false, apply — detaches the ISO so the
#      instance boots NixOS from disk

resource "vultr_iso_private" "nixos_installer" {
  count = var.vultr_iso_url == "" ? 0 : 1
  url   = var.vultr_iso_url
}

resource "vultr_ssh_key" "toof" {
  name    = "toof@toof.jp"
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIN8H2c3Qa2EsEh6RQG6nRoRFblH8fj5dHj9YyVD9tND toof@toof.jp"
}

# Cluster traffic (apiserver, etcd, kubelet) and SSH flow over the Tailscale
# mesh, so only Tailscale's WireGuard port is exposed publicly. SSH reaches
# the node via its tailnet address, never the public IP.
resource "vultr_firewall_group" "k8s_node" {
  description = "k8s node: tailscale only"
}

resource "vultr_firewall_rule" "tailscale_v4" {
  firewall_group_id = vultr_firewall_group.k8s_node.id
  protocol          = "udp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = "41641"
}

resource "vultr_firewall_rule" "tailscale_v6" {
  firewall_group_id = vultr_firewall_group.k8s_node.id
  protocol          = "udp"
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = "41641"
}

resource "vultr_firewall_rule" "icmp_v4" {
  firewall_group_id = vultr_firewall_group.k8s_node.id
  protocol          = "icmp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
}

resource "vultr_instance" "vultr_vps" {
  label    = "vultr-vps"
  hostname = "vultr-vps"
  region   = var.vultr_region
  plan     = var.vultr_plan

  iso_id = var.vultr_attach_iso ? vultr_iso_private.nixos_installer[0].id : null

  ssh_key_ids       = [vultr_ssh_key.toof.id]
  firewall_group_id = vultr_firewall_group.k8s_node.id

  enable_ipv6      = true
  backups          = "disabled"
  ddos_protection  = false
  activation_email = false

  lifecycle {
    # The disk is managed by nixos-install, not Vultr images; never let a
    # drifted/computed os_id trigger a reinstall of a converted node.
    ignore_changes = [os_id]

    precondition {
      condition     = !var.vultr_attach_iso || var.vultr_iso_url != ""
      error_message = "vultr_attach_iso is true but vultr_iso_url is empty — build the ISO (make vultr-iso in nix-sandbox), host it, and set vultr_iso_url."
    }
  }
}

output "vultr_vps_ipv4" {
  value = vultr_instance.vultr_vps.main_ip
}

output "vultr_vps_ipv6" {
  value = vultr_instance.vultr_vps.v6_main_ip
}
