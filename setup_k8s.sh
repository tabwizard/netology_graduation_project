#!/bin/bash

set -e 

KUBESPRAY=/home/wizard/Ansible/kubespray
PWND=$(pwd)

# Создаем инфраструктуру в Yandex.Cloud
cd terraform
terraform apply -auto-approve

# Подготавливаем инвентори для kubespray из шаблона
rm -rf "${KUBESPRAY}/inventory/pirozhkov-k8s"
cp -r "${KUBESPRAY}/inventory/sample" "${KUBESPRAY}/inventory/pirozhkov-k8s"

# Генерируем hosts.yaml из terraform outputs и копируем в созданный инвентори
./generate_inventory.sh > "hosts.yaml"
cp "hosts.yaml" "${KUBESPRAY}/inventory/pirozhkov-k8s/"

# Создаем кластер K8S с помощью kubespray
cd "${KUBESPRAY}"
ansible-playbook -i inventory/pirozhkov-k8s/hosts.yaml --become --become-user=root cluster.yml

# Работаем с развернутым кластером K8S
cd "${PWND}/terraform"
./get_k8s_config.sh
