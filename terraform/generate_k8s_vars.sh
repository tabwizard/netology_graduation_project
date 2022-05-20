#!/bin/bash

## set -e 
K8VARS="/home/wizard/Ansible/kubespray/inventory/pirozhkov-k8s/group_vars/k8s_cluster/k8s-cluster.yml"
K8ALL="/home/wizard/Ansible/kubespray/inventory/pirozhkov-k8s/group_vars/all/all.yml"

# sed -i "s/# kube_webhook_token_auth: false/kube_webhook_token_auth: true/g" "${K8VARS}"
#sed -i "s/# kube_webhook_authorization: false/kube_webhook_authorization: true/g" "${K8VARS}"
sed -i "s/persistent_volumes_enabled: false/persistent_volumes_enabled: true/g" "${K8VARS}"
#sed -i "s/kube_webhook_token_auth: false/kube_webhook_token_auth: true/g" "${K8ALL}"
