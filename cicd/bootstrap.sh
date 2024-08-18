#!/bin/bash
set -e

source ${PROJECT_ROOT}/cicd/config.sh
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
TENANT_ID=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Bootstrapping ${PROJECT_NAME}${ENV_NAME} in subscription ${sub_name} of tenant ${TENANT_ID}"
sleep 5

RESOURCE_GROUP_NAME="${TF_STATE_RESOURCE_GROUP_NAME}"
STORAGE_ACCOUNT_NAME="${TF_STATE_STORAGE_ACCOUNT_NAME}"
CONTAINER_NAME=terraformstates
KEYVAULT_NAME="${TF_VAR_devops_kvt}"
DEVOPS_SP_DISPLAY_NAME="${PROJECT_NAME}${ENV_NAME}devopssp"

# Resource group for Terraform state
az group create --name $RESOURCE_GROUP_NAME --location westeurope

# Storage account for Terraform state
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
