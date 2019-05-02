variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable disk_size_gb {
  description = "Disk size"
  default     = "20"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}

variable count_node {
  description = "Count node"
  default     = "2"
}