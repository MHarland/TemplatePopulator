#!/bin/bash
set -e

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Destroying core of ${PROJECT_NAME} - ${ENV_NAME} in subscription ${sub_name}"
sleep 5

cd ${PROJECT_ROOT}/infrastructure/core
terraform init \
    -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}"
terraform destroy
rm -rf .terraform
rm .terraform.lock.hcl
cd ${PROJECT_ROOT}

az storage account delete --yes --resource-group $TF_STATE_RESOURCE_GROUP_NAME --name $TF_STATE_STORAGE_ACCOUNT_NAME
az group delete --yes --name $TF_STATE_RESOURCE_GROUP_NAME
