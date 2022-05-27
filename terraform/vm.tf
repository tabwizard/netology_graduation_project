resource "yandex_compute_instance" "k8s-node" {
  count    = 3
  name     = "${terraform.workspace}-k8s-node${count.index + 1}"
  hostname = "${terraform.workspace}-k8s-node${count.index + 1}"
  zone     = var.zones[count.index]
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.ubuntu-2004-lts.id}"
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet[count.index].id
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }
}

