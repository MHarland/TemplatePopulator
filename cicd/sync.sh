#!/bin/bash
set -e

# This script synchronizes the platform deployment with your local code
# and loads your environment such, that you can run the tests

# Make sure to "az login"

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh

cd ${PROJECT_ROOT}/tf
az account set -s ${SUBSCRIPTION_ID}
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Current tenant: ${TF_VAR_tenant_id}"
echo "Current subscription: ${sub_name}"
echo "Current platform: ${PLATFORM_NAME}"
echo "Current environment: ${ENV_NAME}"

# bootstrap Terraform if Terraform-state resource group does not exist
if [ $(az group exists --name "${TF_STATE_RESOURCE_GROUP_NAME}") = false ];
then
    ${PROJECT_ROOT}/cicd/bootstrap.sh;
    while [ $(az group exists --name "${TF_STATE_RESOURCE_GROUP_NAME}") = false ];
    do
        echo "waiting for ${TF_STATE_RESOURCE_GROUP_NAME}";
        sleep 1;
    done
fi

# terraform
#DEVOPS_SERVICE_PRINCIPAL_APPID="$(echo $SP_SECRETS | grep -o "\"appId\": \"[^\"]*\"" | grep -o "[^\"]*" | tail -1)"
#ARM_CLIENT_ID=$DEVOPS_SERVICE_PRINCIPAL_APPID
#DEVOPS_SERVICE_PRINCIPAL_PASSWORD="$(echo $SP_SECRETS | grep -o "\"password\": \"[^\"]*\"" | grep -o "[^\"]*" | tail -1)"
#ARM_CLIENT_SECRET=$DEVOPS_SERVICE_PRINCIPAL_PASSWORD
#TENANT_ID=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
#ARM_TENANT_ID=$TENANT_ID
#ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
terraform init \
    -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}"
terraform validate
# terraform plan
if [ ! -z $1 ]
then
    if [ $1 = "deploy" ]
    then
        terraform apply -auto-approve
    fi
fi

terraform output -json > ${PROJECT_ROOT}/template_populator/infrastructure.json

cd ${PROJECT_ROOT}