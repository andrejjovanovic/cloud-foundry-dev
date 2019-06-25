resource "google_compute_network" "cf-dev-network" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dev-subnet" {
  ip_cidr_range = "${var.cidr_range}"
  name          = "${var.network_name}"
  network       = "${google_compute_network.cf-dev-network.self_link}"
  region        = "${var.region_id}"
}

resource "google_compute_global_address" "cf-dev-ip" {
  name = "global-cf-dev-ip"
}

output "global_ip" {
  value = "${google_compute_global_address.cf-dev-ip.address}"
}