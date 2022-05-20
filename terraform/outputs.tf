output "control_plane_public_ip" {
  description = "Public IP addresses for control-plane"
  value       = yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address
}

output "control_plane_private_ip" {
  description = "Private IP addresses for control-plane"
  value       = yandex_compute_instance.k8s-control-plane.network_interface.0.ip_address
}

output "nodes_public_ips" {
  description = "Public IP addresses for worder-nodes"
  value       = yandex_compute_instance.k8s-node.*.network_interface.0.nat_ip_address
}

output "nodes_private_ips" {
  description = "Private IP addresses for worker-nodes"
  value       = yandex_compute_instance.k8s-node.*.network_interface.0.ip_address
}

output "balancer_ip_address" {
  value = [for s in yandex_lb_network_load_balancer.k8s-load-balancer.listener: s.external_address_spec.*.address if s.name == "web-listener"]
}