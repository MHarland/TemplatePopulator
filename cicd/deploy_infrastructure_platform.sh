#!/bin/bash
set -e

echo "Deploying infrastructure platform"

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh

cd ${PROJECT_ROOT}/infrastructure/platform
export ARM_CLIENT_ID=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_id.txt)
export ARM_CLIENT_SECRET=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_secret.txt)
export ARM_TENANT_ID=$(cat ${PROJECT_ROOT}/secrets/tenant_id.txt)
export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}

# az account set -s ${SUBSCRIPTION_ID}
export TF_VAR_tenant_id=$ARM_TENANT_ID
echo "Current tenant: ${TF_VAR_tenant_id}"
echo "Current subscription: ${ARM_SUBSCRIPTION_ID}"
echo "Current environment: ${ENV_NAME}"

terraform init \
    -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}"
terraform validate
# terraform plan
if [ ! -z $1 ]
then
    if [ $1 = "apply" ]
    then
        terraform apply -auto-approve
    fi
fi

terraform output -json > ${PROJECT_ROOT}/template_populator/infrastructure.json

az storage account update --name $TF_STATE_STORAGE_ACCOUNT_NAME --resource-group $TF_STATE_RESOURCE_GROUP_NAME --public-network-access Disabled

cd ${PROJECT_ROOT}