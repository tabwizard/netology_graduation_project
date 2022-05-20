#!/bin/bash

## set -e 
WS=$(terraform workspace show)
IPK8S=$(terraform output -json control_plane_public_ip | jq -j)
IPBALANCER=$(terraform output -json balancer_ip_address | jq -j ".[0]"| jq -j ".[0]")

ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo cp /root/.kube/config /home/wizard/config; sudo chown wizard /home/wizard/config"
rm -rf /home/wizard/.kube/config.$WS
scp -i ~/.ssh/yc/yc wizard@$IPK8S:/home/wizard/config "/home/wizard/.kube/config.${WS}"
sed -i "s/lb-apiserver.kubernetes.local/${IPK8S}/g" "/home/wizard/.kube/config.${WS}"
sed -i "s/cluster.local/${WS}.k8s.yc/g" "/home/wizard/.kube/config.${WS}"
cp "/home/wizard/.kube/config.${WS}" "/home/wizard/.kube/config"
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config.$WS

ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo apt install nfs-common -y"
for num in 1 2
do
ssh -o "StrictHostKeyChecking no" wizard@$(terraform output -json nodes_public_ips | jq -j ".[$num-1]") -i ~/.ssh/yc/yc "sudo apt install nfs-common -y"
done

kubectl get pods --all-namespaces

cp "../template.yml" "../web.yml"
sed -i "s/  namespace:/  namespace: ${WS}/g" "../web.yml"
## sed -i "s/99.99.99.99/${IPK8S}/g" "../web.yml"
kubectl create ns $WS
kubectl apply -f "../web.yml"
sleep 5
kubectl get pods --namespace $WS

# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
kubectl apply --server-side -f ../kube-prometheus/manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f ../kube-prometheus/manifests/
kubectl apply -f ../kube-prometheus/grafana-svc.yaml -f ../kube-prometheus/grafana-NP.yaml

#   Install a Helm chart for Atlantis https://www.runatlantis.io
#kubectl apply -f ../atlantis/pv.yaml
#helm repo add runatlantis https://runatlantis.github.io/helm-charts
#helm install atlantis runatlantis/atlantis -f ../atlantis/values.yaml

echo -e "\n\nAccess to k8s test app - http://"$IPBALANCER
echo -e "\nAccess to k8s grafana - http://${IPBALANCER}:3000"
