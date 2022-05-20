variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}

variable "cidr" {
  type    = map(list(string))
  default = {
    stage = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    prod  = ["192.168.110.0/24", "192.168.120.0/24", "192.168.130.0/24"]
  }
}

variable "lb_address" {
  type    = string
  default = "51.250.42.246"
}