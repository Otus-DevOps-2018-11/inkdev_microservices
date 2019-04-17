provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source          = "./modules/app"
  public_key_path = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone            = "${var.zone}"
  app_disk_image  = "${var.app_disk_image}"
  node_count = "${var.node_count}"
}


#resource "google_compute_project_metadata_item" "default" {
#  key   = "ssh-keys"
#  value = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}appuser3:${file(var.public_key_path)}"
#}

