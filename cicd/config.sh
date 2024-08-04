#!/bin/bash

# Create a subscription in the Azure UI
export SUBSCRIPTION_ID="c272f1a1-2cef-4ad5-bca7-b2593df00dc7"
export PROJECT_NAME="tpop2"
export ENV_NAME="dev"

# The Terraform state is managed here
export TF_STATE_RESOURCE_GROUP_NAME="${PROJECT_NAME}${ENV_NAME}tfrg"
export TF_STATE_STORAGE_ACCOUNT_NAME="${PROJECT_NAME}${ENV_NAME}tfsta"

# Platform infrastructure
export TF_VAR_owners_entra_object_ids='["4c130760-602b-4a50-a5fd-6380775b9690"]' # owner object id's
export TF_VAR_project_name="${PROJECT_NAME}"
export TF_VAR_env_name="${ENV_NAME}"
export TF_VAR_rg_name="${TF_VAR_project_name}${TF_VAR_env_name}rg"
export TF_VAR_subscription_id="${SUBSCRIPTION_ID}"
export TF_VAR_devops_kvt="${PROJECT_NAME}${ENV_NAME}devopskvt"
export TF_VAR_devops_rg="${TF_STATE_RESOURCE_GROUP_NAME}"
export TF_VAR_func_app_name="${PROJECT_NAME}${ENV_NAME}app"
export TF_VAR_kvt_name="${PROJECT_NAME}${ENV_NAME}kvt"
export TF_VAR_appi_name="${PROJECT_NAME}${ENV_NAME}appi"
export TF_VAR_sta_name="${PROJECT_NAME}${ENV_NAME}sta"
export TF_VAR_acr_name="${PROJECT_NAME}${ENV_NAME}acr"
export TF_VAR_image_name="${PROJECT_NAME}${ENV_NAME}funcimg"
export TF_VAR_image_tag="latest"
export TF_VAR_vnet_name="${PROJECT_NAME}${ENV_NAME}vnet"
export TF_VAR_vhub_address_prefix="10.1.0.0/23"
export TF_VAR_vpn_client_address_pool_prefixes='["10.1.2.0/24"]'
export TF_VAR_vnet_address_space='["10.0.0.0/16"]'
export TF_VAR_vnet_subnet_prefixes='["10.0.0.0/24"]'
export TF_VAR_vnet_subnet_func_prefixes='["10.1.0.0/24"]'
