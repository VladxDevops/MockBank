resource "google_compute_instance" "default" {
  project      = var.project_id
  zone         = var.zone
  name         = var.instance_name
  machine_type = var.machine_type
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
  }
}
