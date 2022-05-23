#!/bin/bash

# Инициируем переменные
WS=$(terraform workspace show)
IPK8S=$(terraform output -json control_plane_public_ip | jq -j)
IPBALANCER=$(terraform output -json balancer_ip_address | jq -j ".[0]"| jq -j ".[0]")

# Копируем .kube/config с ControlPlane на локальную машину для использования с kubectl
ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo cp /root/.kube/config /home/wizard/config; sudo chown wizard /home/wizard/config"
rm -rf /home/wizard/.kube/config.$WS
scp -i ~/.ssh/yc/yc wizard@$IPK8S:/home/wizard/config "/home/wizard/.kube/config.${WS}"
sed -i "s/lb-apiserver.kubernetes.local/${IPK8S}/g" "/home/wizard/.kube/config.${WS}"
sed -i "s/cluster.local/${WS}.k8s.yc/g" "/home/wizard/.kube/config.${WS}"
cp "/home/wizard/.kube/config.${WS}" "/home/wizard/.kube/config"
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config.$WS

# Устанавливаем пакеты для работы с NFS в кластер
  # ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo apt install nfs-common -y"
  # for num in 1 2
  # do
  # ssh -o "StrictHostKeyChecking no" wizard@$(terraform output -json nodes_public_ips | jq -j ".[$num-1]") -i ~/.ssh/yc/yc "sudo apt install nfs-common -y"
  # done

# Подключаемся к кластеру K8S, смотрим, что всё работает, поды есть
kubectl get pods --all-namespaces

# Устанавливаем kube-prometheus
kubectl apply --server-side -f ../kube-prometheus/manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f ../kube-prometheus/manifests/
kubectl apply -f ../kube-prometheus/grafana-svc.yaml -f ../kube-prometheus/grafana-NP.yaml

# Создаем qbec манифест тестового приложения из шаблона
  #cp "../template.yml" "../web.yml"
  #sed -i "s/  namespace:/  namespace: ${WS}/g" "../web.yml"
cp "../webtestapp/qbec.template" "../webtestapp/qbec.yaml"
sed -i "s/99.99.99.99/${IPK8S}/g" "../webtestapp/qbec.yaml"

# Создаем namespace в K8S с тем же именем что и terraform workspace
kubectl create ns $WS

# Применяем манифест qbec в кластер K8S в соответствующее namespace
  #kubectl apply -f "../web.yml"
cd ../webtestapp
qbec apply $WS --yes
sleep 5

# Смотрим, что под с тестовым приложением задеплоился
kubectl get pods --namespace $WS

# Финальный вывод адресов ресурсов кластера
echo -e "\n\nAccess to k8s test app - http://"$IPBALANCER
echo -e "Access to k8s grafana - http://${IPBALANCER}:3000"
echo -e "\n\nAccess to k8s test app - http://pirozhkov-aa.ru"
echo -e "Access to k8s grafana - http://pirozhkov-aa.ru:3000"
