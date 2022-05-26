resource "yandex_lb_target_group" "k8s_lb_tg" {
  name = "${terraform.workspace}-k8s-target-group"

  dynamic "target" {
    for_each = [for s in yandex_compute_instance.k8s-node : {
      address   = s.network_interface.0.ip_address
      subnet_id = s.network_interface.0.subnet_id
    }]

    content {
      subnet_id = target.value.subnet_id
      address   = target.value.address
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s-load-balancer" {
  name = "${terraform.workspace}-k8s-load-balancer"

  listener {
    name        = "grafana-listener"
    port        = 80
    target_port = 30090
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.addr-k8s.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_lb_tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 30090
        path = "/login"
      }
    }
  }
}
