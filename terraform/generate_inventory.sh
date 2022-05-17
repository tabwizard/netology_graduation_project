#!/bin/bash

set -e

echo ---
printf "all:\n"
printf "  hosts:\n"
printf "    k8s-control-plane:\n      ansible_host: "
terraform output -json control_plane_public_ip | jq -j
printf "\n      ip: "
terraform output -json control_plane_private_ip | jq -j
printf "\n"

for num in 1 2
do
printf "    k8s-node-$num:\n      ansible_host: "
terraform output -json nodes_public_ips | jq -j ".[$num-1]"
printf "\n      ip: "
terraform output -json nodes_private_ips | jq -j ".[$num-1]"
printf "\n"
done

printf "\n  vars:\n"
printf "    ansible_user: wizard\n"
printf "    ansible_ssh_private_key_file: /home/wizard/.ssh/yc/yc\n"
printf "    loadbalancer_apiserver:\n      address: "
terraform output -json control_plane_public_ip | jq -j
printf "\n      port: 6443\n\n"

cat << EOF
  children:
    kube_control_plane:
      hosts:
        k8s-control-plane:
    kube_node:
      hosts:
        k8s-node-1:
        k8s-node-2:
    etcd:
      hosts:
        k8s-control-plane:
        k8s-node-1:
        k8s-node-2:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF

