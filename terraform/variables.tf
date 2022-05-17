variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}

variable "cidr" {
  type    = list(string)
  default = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
}


