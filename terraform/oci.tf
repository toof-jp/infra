# OCI always-free resources (ap-osaka-1, root compartment). The VCN and its
# defaults were hand-created in the console (2025-08) and are adopted here
# via import blocks; display names keep their console-generated values so
# the import is a no-op.

import {
  to = oci_core_vcn.k8s
  id = "ocid1.vcn.oc1.ap-osaka-1.amaaaaaalfc45kiajf44goeyv72cooo4m5g436l32uc5pqmpyy2vdcpofpya"
}

resource "oci_core_vcn" "k8s" {
  compartment_id = var.oci_tenancy_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "vcn-20250817-0330"
  dns_label      = "vcn08170335"
}

import {
  to = oci_core_internet_gateway.k8s
  id = "ocid1.internetgateway.oc1.ap-osaka-1.aaaaaaaai6obj7b4nnreibye3iegqb6f2ha5pjpyvxfxayq5dsvxi7mke2xq"
}

resource "oci_core_internet_gateway" "k8s" {
  compartment_id = var.oci_tenancy_ocid
  vcn_id         = oci_core_vcn.k8s.id
  display_name   = "Internet Gateway vcn-20250817-0330"
  enabled        = true
}

import {
  to = oci_core_default_route_table.k8s
  id = "ocid1.routetable.oc1.ap-osaka-1.aaaaaaaat7qrn5oynzlvklmxxwwkh3rcc64duuynvcfia7fqn3whfvjjqkba"
}

resource "oci_core_default_route_table" "k8s" {
  manage_default_resource_id = oci_core_vcn.k8s.default_route_table_id
  display_name               = "Default Route Table for vcn-20250817-0330"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k8s.id
  }
}

import {
  to = oci_core_default_security_list.k8s
  id = "ocid1.securitylist.oc1.ap-osaka-1.aaaaaaaah7xzf7mq53w4kyxe46gtv55eoodgutozyjsgtnxn33lwdx5lavsa"
}

resource "oci_core_default_security_list" "k8s" {
  manage_default_resource_id = oci_core_vcn.k8s.default_security_list_id
  display_name               = "Default Security List for vcn-20250817-0330"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # SSH is not exposed publicly; access is over Tailscale (same policy as
  # vultr-vps, see vultr.tf).

  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = "10.0.0.0/16"

    icmp_options {
      type = 3
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }
}

import {
  to = oci_core_subnet.k8s
  id = "ocid1.subnet.oc1.ap-osaka-1.aaaaaaaaajufxp6owv7x23o37w25wt5pnpgoackc6svpwxjkcxilztwgtnta"
}

resource "oci_core_subnet" "k8s" {
  compartment_id = var.oci_tenancy_ocid
  vcn_id         = oci_core_vcn.k8s.id
  cidr_block     = "10.0.0.0/24"
  display_name   = "subnet-20250817-0330"
  dns_label      = "subnet08170335"
}

# oci-vps: always-free E2.1.Micro intended to join the k8s cluster over
# Tailscale (same policy as vultr-vps). Launched via the OCI CLI on
# 2026-07-19 and adopted here.
import {
  to = oci_core_instance.oci_vps
  id = "ocid1.instance.oc1.ap-osaka-1.anvwsljrlfc45kicc74hfyeusg5ujhnl2rhdjfkrajbjb2qpph2laf7a545q"
}

resource "oci_core_instance" "oci_vps" {
  compartment_id      = var.oci_tenancy_ocid
  availability_domain = "yPbU:AP-OSAKA-1-AD-1"
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "oci-vps"

  source_details {
    source_type             = "image"
    source_id               = "ocid1.image.oc1.ap-osaka-1.aaaaaaaakkk2ftbt2ztpw3jdriwhadh4xi4rbdi4fspi2xcv27cx7xqj45pq"
    boot_volume_size_in_gbs = 100
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k8s.id
    assign_public_ip = true
    hostname_label   = "oci-vps"
  }

  metadata = {
    ssh_authorized_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIN8H2c3Qa2EsEh6RQG6nRoRFblH8fj5dHj9YyVD9tND toof@toof.jp"
  }

  lifecycle {
    # The workspace auto-applies; never let a drifted attribute replace the
    # always-free instance (capacity may be unrecoverable).
    prevent_destroy = true
  }
}

output "oci_vps_public_ip" {
  value = oci_core_instance.oci_vps.public_ip
}

output "oci_vps_private_ip" {
  value = oci_core_instance.oci_vps.private_ip
}
