#!/bin/bash

set -e
WS=$(terraform workspace show)

echo ---
printf "all:\n"
printf "  hosts:\n"

for num in 1 2 3
do
printf "    ${WS}-k8s-node$num:\n      ansible_host: "
terraform output -json nodes_public_ips | jq -j ".[$num-1]"
printf "\n      ip: "
terraform output -json nodes_private_ips | jq -j ".[$num-1]"
printf "\n      etcd_member_name: etcd$num"
printf "\n"
done

cat << EOF
  children:
    kube_control_plane:
      hosts:
        ${WS}-k8s-node1:
        ${WS}-k8s-node2:
    kube_node:
      hosts:
        ${WS}-k8s-node1:
        ${WS}-k8s-node2:
        ${WS}-k8s-node3:
    etcd:
      hosts:
        ${WS}-k8s-node1:
        ${WS}-k8s-node2:
        ${WS}-k8s-node3:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF

printf "\n  vars:\n"
printf "    ansible_user: wizard\n"
printf "    ansible_ssh_private_key_file: /home/wizard/.ssh/yc/yc\n"
printf "    loadbalancer_apiserver:\n      address: "
terraform output -json control_plane_public_ip | jq -j
printf "\n      port: 6443"
