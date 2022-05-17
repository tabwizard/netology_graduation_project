#!/bin/bash

set -e 
KUBESPRAY=/home/wizard/Ansible/kubespray
PWD=$(pwd)
terraform apply -auto-approve

rm -rf "${KUBESPRAY}/inventory/pirozhkov-k8s"
cp -r "${KUBESPRAY}/inventory/sample" "${KUBESPRAY}/inventory/pirozhkov-k8s"

./generate_inventory.sh > "hosts.yaml"
cp "hosts.yaml" "${KUBESPRAY}/inventory/pirozhkov-k8s/"

cd "${KUBESPRAY}"

ansible-playbook -i inventory/pirozhkov-k8s/hosts.yaml --become --become-user=root cluster.yml

cd "${PWD}"

./get_k8s_config.sh

kg no
