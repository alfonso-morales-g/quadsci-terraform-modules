resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each = var.subnetworks

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "vpc_firewall" {
  for_each = var.firewall_rules

  name      = each.value.name
  network   = google_compute_network.vpc_network.name
  direction = each.value.direction

  dynamic "allow" {
    for_each = length(each.value.allow_rules) > 0 ? each.value.allow_rules : []
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = length(each.value.deny_rules) > 0 ? each.value.deny_rules : []
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  source_ranges      = each.value.source_ranges
  destination_ranges = each.value.destination_ranges
  source_tags        = each.value.source_tags  
  target_tags        = each.value.target_tags
  priority           = each.value.priority
}

resource "google_compute_router" "router" {
  name    = "nat-router"
  region  = var.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "webapp-nat-gateway"
  router                             = "nat-router"
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = var.nat_gateway_attach_instance == "webapp" ? google_compute_subnetwork.subnetwork["webapp-subnetwork"].name : google_compute_subnetwork.subnetwork["development-subnetwork"].name
    source_ip_ranges_to_nat = var.nat_gateway_attach_instance == "webapp" ? toset([google_compute_subnetwork.subnetwork["webapp-subnetwork"].ip_cidr_range]) : toset([google_compute_subnetwork.subnetwork["development-subnetwork"].ip_cidr_range])
  }
}