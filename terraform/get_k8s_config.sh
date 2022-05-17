#!/bin/bash

set -e 
WS=$(terraform workspace show)
IPK8S=$(terraform output -json control_plane_public_ip | jq -j)

ssh -o "StrictHostKeyChecking no" wizard@$IPK8S -i ~/.ssh/yc/yc "sudo cp /root/.kube/config /home/wizard/config; sudo chown wizard /home/wizard/config"
rm -rf /home/wizard/.kube/config.$WS
scp -i ~/.ssh/yc/yc wizard@$IPK8S:/home/wizard/config "/home/wizard/.kube/config.${WS}"
sed -i "s/lb-apiserver.kubernetes.local/${IPK8S}/g" "/home/wizard/.kube/config.${WS}"
sed -i "s/cluster.local/${WS}.k8s.yc/g" "/home/wizard/.kube/config.${WS}"
export KUBECONFIG=$HOME/.kube/config.$WS
