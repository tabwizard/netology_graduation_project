#!/bin/bash

# Инициируем переменные
WS=$(terraform workspace show)
IPK8S=$(terraform output -json control_plane_public_ip | jq -j)
#IPBALANCER=$(terraform output -json balancer_ip_address | jq -j ".[0]"| jq -j ".[0]")

echo -e "\n##################################################################"
echo -e "# Копируем .kube/config с ControlPlane на локальную машину для использования с kubectl"
echo -e "####################################################################\n"
ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo cp /root/.kube/config /home/wizard/config; sudo chown wizard /home/wizard/config"
rm -rf /home/wizard/.kube/config.$WS
scp -i ~/.ssh/yc/yc wizard@$IPK8S:/home/wizard/config "/home/wizard/.kube/config.${WS}"
sed -i "s/lb-apiserver.kubernetes.local/${IPK8S}/g" "/home/wizard/.kube/config.${WS}"
#sed -i "s/cluster.local/${WS}.k8s.yc/g" "/home/wizard/.kube/config.${WS}"
cp "/home/wizard/.kube/config.${WS}" "/home/wizard/.kube/config"
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config.$WS

echo -e "\n##################################################################"
echo -e "# Копируем .kube/config с ControlPlane в gitlab для CI/CD      https://docs.gitlab.com/ee/api/project_level_variables.html"
echo -e "####################################################################\n"
curl --request PUT --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" \
    "https://gitlab.com/api/v4/projects/tabwizard%2Fnginxn/variables/CI_KUBE_CONFIG" \
    --form "value=$(cat $HOME/.kube/config)" -o /dev/null
curl --request PUT --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" \
    "https://gitlab.com/api/v4/projects/tabwizard%2Fnginxn/variables/CI_WORKSPACE" \
    --form "value=${WS}" -o /dev/null
echo -e "\n##################################################################"
echo -e "# Подключаемся к кластеру K8S, смотрим, что всё работает, поды есть"
echo -e "####################################################################\n"
kubectl get pods --all-namespaces

echo -e "\n##################################################################"
echo -e "# Устанавливаем kube-prometheus"
echo -e "####################################################################\n"
kubectl apply --server-side -f ../kube-prometheus/manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f ../kube-prometheus/manifests/
kubectl apply -f ../kube-prometheus/grafana-svc.yaml -f ../kube-prometheus/grafana-NP.yaml

echo -e "\n##################################################################"
echo -e "# Устанавливаем gitlab agent в кластер"
echo -e "####################################################################\n"
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install gitlab-agent gitlab/gitlab-agent \
    --namespace gitlab-agent \
    --create-namespace \
    --set config.token=$GITLAB_AGENT_TOKEN \
    --set config.kasAddress=wss://kas.gitlab.com

echo -e "\n##################################################################"
echo -e "# Создаем qbec манифест тестового приложения из шаблона"
echo -e "####################################################################\n"
  #cp "../k8s-test-app/template.yml" "../k8s-test-app/web.yml"
  #sed -i "s/  namespace:/  namespace: ${WS}/g" "../k8s-test-app/web.yml"
cp "../../nginxn/webtestapp/qbec.template" "../../nginxn/webtestapp/qbec.yaml"
sed -i "s/99.99.99.99/${IPK8S}/g" "../../nginxn/webtestapp/qbec.yaml"

echo -e "\n##################################################################"
echo -e "# Создаем namespace в K8S с тем же именем что и terraform workspace"
echo -e "####################################################################\n"
kubectl create ns $WS

echo -e "\n##################################################################"
echo -e "# Применяем манифест qbec в кластер K8S в соответствующее namespace"
echo -e "####################################################################\n"
  #kubectl apply -f "../k8s-test-app/web.yml"
cd ../../nginxn/webtestapp
qbec apply $WS --vm:ext-str image_tag="v1.0.0" --wait --yes
sleep 5

echo -e "\n##################################################################"
echo -e "# Смотрим, что под с тестовым приложением задеплоился"
echo -e "####################################################################\n"
kubectl get pods --namespace $WS

echo -e "\n##################################################################"
echo -e "# Финальный вывод адресов ресурсов кластера"
echo -e "####################################################################\n"
# echo -e "\n\nAccess to k8s test app - http://"$IPBALANCER
# echo -e "Access to k8s grafana - http://${IPBALANCER}:3000"
echo -e "\nAccess to k8s test app - http://pirozhkov-aa.ru"
echo -e "Access to k8s grafana - http://k8s.pirozhkov-aa.ru"
