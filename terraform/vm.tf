resource "yandex_compute_instance" "k8s-control-plane" {
  name     = "k8s-control-plane"
  hostname = "k8s-control-plane"
  zone     = var.zones[0]

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui"
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
  name     = "k8s-node-${count.index + 1}"
  hostname = "k8s-node-${count.index + 1}"
  zone     = var.zones[count.index + 1]
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui" // centos7
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
