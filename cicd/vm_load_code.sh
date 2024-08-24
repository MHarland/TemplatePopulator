#!/bin/bash
set -e

export PROJECT_ROOT=$(pwd)
source cicd/config.sh
export DEVOPS_VM_IP=$(cat ${PROJECT_ROOT}/secrets/devops_vm_ip.txt)
ssh -i ${PROJECT_ROOT}/secrets/id_devopsvm ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP} "if [ ! -d TemplatePopulator ]; then git clone https://github.com/MHarland/TemplatePopulator.git; else cd TemplatePopulator; git pull; fi"
