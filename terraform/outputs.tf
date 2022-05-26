output "control_plane_public_ip" {
  description = "Public IP addresses for control-plane"
  value       = yandex_compute_instance.k8s-node[0].network_interface.0.nat_ip_address
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
  value = yandex_vpc_address.addr-k8s.external_ipv4_address[0].address
}

output "balancer_web_ip_address" {
  value = yandex_vpc_address.addr-web.external_ipv4_address[0].address
}
