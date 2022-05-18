#!/bin/bash

## set -e 
WS=$(terraform workspace show)
IPK8S=$(terraform output -json control_plane_public_ip | jq -j)

ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo cp /root/.kube/config /home/wizard/config; sudo chown wizard /home/wizard/config"
rm -rf /home/wizard/.kube/config.$WS
scp -i ~/.ssh/yc/yc wizard@$IPK8S:/home/wizard/config "/home/wizard/.kube/config.${WS}"
sed -i "s/lb-apiserver.kubernetes.local/${IPK8S}/g" "/home/wizard/.kube/config.${WS}"
sed -i "s/cluster.local/${WS}.k8s.yc/g" "/home/wizard/.kube/config.${WS}"
cp "/home/wizard/.kube/config.${WS}" "/home/wizard/.kube/config"
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config.$WS

kubectl get pods --all-namespaces

cp "../template.yml" "../web.yml"
sed -i "s/  namespace:/  namespace: ${WS}/g" "../web.yml"
## sed -i "s/99.99.99.99/${IPK8S}/g" "../web.yml"
kubectl create ns $WS
kubectl apply -f "../web.yml"
sleep 5
kubectl get pods --namespace $WS
echo "Access to k8s app - http://"$(terraform output -json balancer_ip_address | jq -j ".[0]"| jq -j ".[0]")
