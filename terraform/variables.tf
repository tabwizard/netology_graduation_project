variable "cloud_id" {
  type    = string
  default = "b1gqrp1i6qksiv3fsd7p"
}

variable "folder_id" {
  type    = string
  default = "b1gtnhq0jsadaquuvpi6"
}

variable "dns_zone_id" {
  type    = string
  default = "dns2njvtqjticn9q5lf4"
}

variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}

variable "cidr" {
  type = map(list(string))
  default = {
    stage = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    prod  = ["192.168.110.0/24", "192.168.120.0/24", "192.168.130.0/24"]
  }
}
