resource "yandex_vpc_network" "pirozhkov-netology-vpc" {
  name = "${terraform.workspace}-pirozhkov-netology-vpc"
}

resource "yandex_vpc_subnet" "subnet" {
  count          = 3
  name           = "${terraform.workspace}-subnet-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.pirozhkov-netology-vpc.id
  v4_cidr_blocks = [var.cidr[terraform.workspace][count.index]]
}

resource "yandex_vpc_address" "addr-web" {
  name = "webtestappAddress"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_address" "addr-k8s" {
  name = "k8sAddress"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}
