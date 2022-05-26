#!/bin/bash

set -e 
# Инициируем переменные
KUBESPRAY=/home/wizard/Ansible/kubespray
PWND=$(pwd)

echo -e "\n##################################################################"
echo -e "# Создаем инфраструктуру в Yandex.Cloud"
echo -e "####################################################################\n"
cd terraform
WS=$(terraform workspace show)
terraform apply -auto-approve

echo -e "\n##################################################################"
echo -e "# Подготавливаем инвентори для kubespray из шаблона"
echo -e "####################################################################\n"
rm -rf "${KUBESPRAY}/inventory/pirozhkov-k8s"
cp -r "${KUBESPRAY}/inventory/sample" "${KUBESPRAY}/inventory/pirozhkov-k8s"

echo -e "\n##################################################################"
echo -e "# Генерируем hosts.yaml из terraform outputs и копируем в созданный инвентори"
echo -e "####################################################################\n"
./generate_inventory.sh > "../kubespray/hosts.yaml"
cp "../kubespray/hosts.yaml" "${KUBESPRAY}/inventory/pirozhkov-k8s/"

echo -e "\n##################################################################"
echo -e "# Редактируем будущее имя кластера"
echo -e "####################################################################\n"
sed -i "s/cluster.local/${WS}.k8s.yc/g" "${KUBESPRAY}/inventory/pirozhkov-k8s/group_vars/k8s_cluster/k8s-cluster.yml"
cp "${KUBESPRAY}/inventory/pirozhkov-k8s/group_vars/k8s_cluster/k8s-cluster.yml" "../kubespray/k8s-cluster.yml"

echo -e "\n##################################################################"
echo -e "# Подключаем Ingress-controller"
echo -e "####################################################################\n"
sed -i "s/ingress_nginx_enabled: false/ingress_nginx_enabled: true/g" "${KUBESPRAY}/inventory/pirozhkov-k8s/group_vars/k8s_cluster/addons.yml"
sed -i "s/# ingress_nginx_host_network: false/ingress_nginx_host_network: true/g" "${KUBESPRAY}/inventory/pirozhkov-k8s/group_vars/k8s_cluster/addons.yml"
cp "${KUBESPRAY}/inventory/pirozhkov-k8s/group_vars/k8s_cluster/addons.yml" "../kubespray/addons.yml"

echo -e "\n##################################################################"
echo -e "# Создаем кластер K8S с помощью kubespray"
echo -e "####################################################################\n"
cd "${KUBESPRAY}"
ansible-playbook -i inventory/pirozhkov-k8s/hosts.yaml --become --become-user=root cluster.yml

echo -e "\n##################################################################"
echo -e "# Работаем с развернутым кластером K8S"
echo -e "####################################################################\n"
cd "${PWND}/terraform"
./get_k8s_config.sh
