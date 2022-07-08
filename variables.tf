variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west2"
}

variable "london_subnet_cidr" {
  type    = string
  default = "10.0.0.0/20"
}

variable "composer_pod_cidr" {
  type    = string
  default = "10.32.0.0/14"
}

variable "composer_service_cidr" {
  type    = string
  default = "10.36.0.0/20"
}

variable "composer_master_cidr" {
  type    = string
  default = "10.40.0.0/28"
}

variable "composer_vpc_access_subnet" {
  type    = string
  default = "10.41.0.0/28"
}