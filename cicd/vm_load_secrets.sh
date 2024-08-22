#!/bin/bash
set -e

export PROJECT_ROOT=$(pwd)
source cicd/config.sh
export DEVOPS_VM_IP=$(cat ${PROJECT_ROOT}/secrets/devops_vm_ip.txt)
scp -i ./secrets/id_devopsvm secrets/config.sh ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/config.sh
scp -i ./secrets/id_devopsvm secrets/tenant_id.txt ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/tenant_id.txt
scp -i ./secrets/id_devopsvm secrets/devops_sp_client_id.txt ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/devops_sp_client_id.txt
scp -i ./secrets/id_devopsvm secrets/devops_sp_client_secret.txt ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/devops_sp_client_secret.txt
