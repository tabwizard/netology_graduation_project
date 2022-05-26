resource "yandex_alb_target_group" "k8s-alb-tg" {
  name = "${terraform.workspace}-k8s-alb-target-group"

  dynamic "target" {
    for_each = [for s in yandex_compute_instance.k8s-node : {
      address   = s.network_interface.0.ip_address
      subnet_id = s.network_interface.0.subnet_id
    }]

    content {
      subnet_id  = target.value.subnet_id
      ip_address = target.value.address
    }
  }
}

resource "yandex_alb_backend_group" "k8s-backend-group" {
  name = "${terraform.workspace}-k8s-backend-group"

  http_backend {
    name             = "${terraform.workspace}-k8s-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.k8s-alb-tg.id}"]
    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout             = "1s"
      interval            = "1s"
      healthy_threshold   = 1
      unhealthy_threshold = 3
      healthcheck_port    = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "k8s-tf-router" {
  name = "${terraform.workspace}-k8s-http-router"
}

resource "yandex_alb_virtual_host" "k8s-virtual-host" {
  name           = "${terraform.workspace}-k8s-virtual-host"
  http_router_id = yandex_alb_http_router.k8s-tf-router.id
  route {
    name = "${terraform.workspace}-k8s-http-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.k8s-backend-group.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "k8s-alb-balancer" {
  name = "${terraform.workspace}-k8s-load-balancer"

  network_id = yandex_vpc_network.pirozhkov-netology-vpc.id

  allocation_policy {
    dynamic "location" {
      for_each = [for s in yandex_vpc_subnet.subnet : {
        zone_id   = s.zone
        subnet_id = s.id
      }]

      content {
        subnet_id = location.value.subnet_id
        zone_id   = location.value.zone_id
      }
    }
  }

  listener {
    name = "${terraform.workspace}-k8s-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = yandex_vpc_address.addr-web.external_ipv4_address[0].address
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.k8s-tf-router.id
      }
    }
  }
}
