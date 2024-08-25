#!/bin/bash
set -e

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Destroying platform of ${PROJECT_NAME} - ${ENV_NAME} in subscription ${sub_name}"
sleep 5

cd ${PROJECT_ROOT}/infrastructure/platform
export ARM_CLIENT_ID=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_id.txt)
export ARM_CLIENT_SECRET=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_secret.txt)
export ARM_TENANT_ID=$(cat ${PROJECT_ROOT}/secrets/tenant_id.txt)
export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
export TF_VAR_devops_vm_ip=$(cat ${PROJECT_ROOT}/secrets/devops_vm_ip.txt)

# az account set -s ${SUBSCRIPTION_ID}
export TF_VAR_tenant_id=$ARM_TENANT_ID
echo "Current tenant: ${TF_VAR_tenant_id}"
echo "Current subscription: ${ARM_SUBSCRIPTION_ID}"
echo "Current environment: ${ENV_NAME}"

cd ${PROJECT_ROOT}/infrastructure/platform
terraform init \
    -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}"
terraform destroy
rm -rf .terraform
rm .terraform.lock.hcl
cd ${PROJECT_ROOT}
