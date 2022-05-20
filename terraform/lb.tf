resource "yandex_lb_target_group" "k8s_lb_tg" {
  name      = "k8s-target-group"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet[0].id}"
    address   = "${yandex_compute_instance.k8s-control-plane.network_interface.0.ip_address}"
  }
  
  target {
    subnet_id = "${yandex_vpc_subnet.subnet[1].id}"
    address   = "${yandex_compute_instance.k8s-node[0].network_interface.0.ip_address}"
  }
  
  target {
    subnet_id = "${yandex_vpc_subnet.subnet[2].id}"
    address   = "${yandex_compute_instance.k8s-node[1].network_interface.0.ip_address}"
  }
}

resource "yandex_lb_network_load_balancer" "k8s-load-balancer" {
  name = "k8s-load-balancer"

  listener {
    name = "web-listener"
    port = 80
    target_port = 30080
    external_address_spec {
      ip_version = "ipv4"
      address = var.lb_address
    }
  }
  
  listener {
    name = "grafana-listener"
    port = 3000
    target_port = 30090
    external_address_spec {
      ip_version = "ipv4"
      address = var.lb_address
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.k8s_lb_tg.id}"

    healthcheck {
      name = "http"
      http_options {
        port = 30080
        path = "/index.html"
      }
    }
  }
}
