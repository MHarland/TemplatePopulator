#!/bin/bash
set -e

# Make sure to "az login"
echo "deploying infrastructure platform"

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh

cd ${PROJECT_ROOT}/infrastructure/platform
# sh
export ARM_CLIENT_ID=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_id.txt)
export ARM_CLIENT_SECRET=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_secret.txt)
export ARM_TENANT_ID=$(cat ${PROJECT_ROOT}/secrets/tenant_id.txt)
export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}

az account set -s ${SUBSCRIPTION_ID}
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Current tenant: ${TF_VAR_tenant_id}"
echo "Current subscription: ${sub_name}"
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

cd ${PROJECT_ROOT}