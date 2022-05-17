resource "yandex_vpc_network" "pirozhkov-netology-vpc" {
  name = "pirozhkov-netology-vpc"
}

resource "yandex_vpc_subnet" "subnet" {
  count          = 3
  name           = "subnet-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.pirozhkov-netology-vpc.id
  v4_cidr_blocks = [var.cidr[count.index]]
}
