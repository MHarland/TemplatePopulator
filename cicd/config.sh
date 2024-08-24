#!/bin/bash

source ${PROJECT_ROOT}/secrets/config.sh

# The Terraform state is managed here
export TF_STATE_RESOURCE_GROUP_NAME="${PROJECT_NAME}${ENV_NAME}tfrg"
export TF_STATE_STORAGE_ACCOUNT_NAME="${PROJECT_NAME}${ENV_NAME}tfsta"

# Platform infrastructure
export TF_VAR_rg_tf_state_name="${TF_STATE_RESOURCE_GROUP_NAME}"
export TF_VAR_sta_tf_state_name="${TF_STATE_STORAGE_ACCOUNT_NAME}"
export TF_VAR_project_name="${PROJECT_NAME}"
export TF_VAR_env_name="${ENV_NAME}"
export TF_VAR_rg_name="${TF_VAR_project_name}${TF_VAR_env_name}rg"
export TF_VAR_subscription_id="${SUBSCRIPTION_ID}"
export TF_VAR_devops_rg="${TF_STATE_RESOURCE_GROUP_NAME}"
export TF_VAR_func_app_name="${PROJECT_NAME}${ENV_NAME}app"
export TF_VAR_kvt_name="${PROJECT_NAME}${ENV_NAME}kvt"
export TF_VAR_appi_name="${PROJECT_NAME}${ENV_NAME}appi"
export TF_VAR_sta_name="${PROJECT_NAME}${ENV_NAME}sta"
export TF_VAR_acr_name="${PROJECT_NAME}${ENV_NAME}acr"
export TF_VAR_image_name="${PROJECT_NAME}${ENV_NAME}funcimg"
export TF_VAR_image_tag="latest"
export TF_VAR_vnet_name="${PROJECT_NAME}${ENV_NAME}vnet"
export TF_VAR_vnet_address_space='["10.0.0.0/16"]'
export TF_VAR_vnet_subnet_prefixes='["10.0.0.0/24"]'
export TF_VAR_vnet_subnet_name="${PROJECT_NAME}${ENV_NAME}vnetsub"
export TF_VAR_vnet_subnet_gate_prefixes='["10.0.3.0/24"]'
export TF_VAR_vnet_subnet_func_prefixes='["10.0.1.0/24"]'
export TF_VAR_devops_vm_name="${PROJECT_NAME}${ENV_NAME}devopsvm"
export TF_VAR_devops_vm_computer_name="${PROJECT_NAME}${ENV_NAME}devopsvm"
export TF_VAR_devops_vm_username="jim"
export TF_VAR_devops_vm_ssh_pub_key_path="${PROJECT_ROOT}/secrets/id_devopsvm.pub"
export TF_VAR_devops_sp_app_name="${PROJECT_NAME}${ENV_NAME}devopssp"
export TF_VAR_dns_zone1_name="privatelink.blob.core.windows.net"
