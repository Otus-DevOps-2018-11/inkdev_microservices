provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

resource "google_container_cluster" "primary" {
  name               = "cluster-1"
  initial_node_count = "${var.count_node}"

  node_config {
    disk_size_gb = "${var.disk_size_gb}"
    machine_type = "${var.machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    metadata {
      disable-legacy-endpoints = "true"
    }
  }

  addons_config {
    kubernetes_dashboard {
      disabled = false
    }
  }

  timeouts {
    create = "30m"
    update = "40m"
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.id} --zone ${var.zone} --project ${var.project}"
  }

  provisioner "local-exec" {
    command = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_kubernetes" {
  name    = "allow-kubernetes"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}
