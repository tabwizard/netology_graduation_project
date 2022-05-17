variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b"]
}

variable "cidr" {
  type    = list(string)
  default = ["192.168.10.0/24", "192.168.11.0/24"]
}


