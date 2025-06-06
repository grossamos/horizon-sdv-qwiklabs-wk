
variable "project_id" {
  description = "Define the project id"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the cluster node pool"
  type        = string
}

variable "build_node_pool_name" {
  description = "Name of the build node pool"
  type        = string
}

variable "build_node_pool_node_count" {
  description = "Number of nodes for the build node pool"
  type        = number
}

variable "build_node_pool_machine_type" {
  description = "Type fo the machine for the build node pool"
  type        = string
}

variable "build_node_pool_min_node_count" {
  description = "Number of minimum of nodes for the build node pool"
  type        = number
  default     = 0
}

variable "build_node_pool_max_node_count" {
  description = "Number of max of nodes for the build node pool"
  type        = number
  default     = 3
}

variable "network" {
  description = "Name of the network"
  type        = string
}

variable "subnetwork" {
  description = "Name of the subnetwork"
  type        = string
}


variable "location" {
  description = "Define the default location for the project"
  type        = string
}

variable "machine_type" {
  description = "Define the machine type of the node poll"
  type        = string
  default     = "e2-medium"
}

variable "service_account" {
  description = "Define the service account of the node poll"
  type        = string
}

variable "node_locations" {
  description = "Define the location of the nodes"
  type        = list(string)
  default = [
    "europe-west1-d",
  ]
}

variable "node_count" {
  description = "Define the number of node count"
  type        = number
  default     = 1
}


