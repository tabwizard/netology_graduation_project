resource "yandex_compute_instance" "k8s-control-plane" {
  name     = "${terraform.workspace}-k8s-control-plane"
  hostname = "${terraform.workspace}-k8s-control-plane"
  zone     = var.zones[0]

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jekrp7jglcetucr2a"
      size     = 15
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet[0].id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}

resource "yandex_compute_instance" "k8s-node" {
  count    = 2
  name     = "${terraform.workspace}-k8s-node-${count.index + 1}"
  hostname = "${terraform.workspace}-k8s-node-${count.index + 1}"
  zone     = var.zones[count.index + 1]
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8jekrp7jglcetucr2a"
      // "fd8jekrp7jglcetucr2a" Ubuntu 20.04 LTS
      // "fd8p7vi5c5bbs2s5i67s"  centos7
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet[count.index + 1].id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}

