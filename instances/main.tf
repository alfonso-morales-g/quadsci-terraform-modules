resource "google_compute_instance" "instance" {
  for_each = var.instance_configuration

  name         = each.value.name
  machine_type = "e2-medium"
  tags         = each.value.tags
  zone         = "us-central1-a"
  hostname     = "${each.value.name}.internal"

  boot_disk {
    initialize_params {
      image = each.value.image
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = each.value.subnetwork
  }

  metadata = {
    enable-oslogin = each.value.enable_oslogin
  }

  metadata_startup_script = each.value.metadata_startup_script
}