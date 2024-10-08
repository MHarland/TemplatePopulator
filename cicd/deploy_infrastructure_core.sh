#!/bin/bash
set -e

echo "Deploying infrastructure core"

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh

cd ${PROJECT_ROOT}/infrastructure/core
az account set -s ${SUBSCRIPTION_ID}
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Current tenant: ${TF_VAR_tenant_id}"
echo "Current subscription: ${sub_name}"
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
else
    az storage account update --name $TF_STATE_STORAGE_ACCOUNT_NAME --resource-group $TF_STATE_RESOURCE_GROUP_NAME --public-network-access Enabled;
    echo "waiting for storage account to be public";
    sleep 3;
fi

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


terraform output -json > ${PROJECT_ROOT}/secrets/infrastructure_core.json
echo "$(terraform output devops_vm_ip | sed 's/\"//g')" > ${PROJECT_ROOT}/secrets/devops_vm_ip.txt
echo "$(terraform output devops_sp_client_id | sed 's/\"//g')" > ${PROJECT_ROOT}/secrets/devops_sp_client_id.txt
echo "$(terraform output devops_sp_client_secret | sed 's/\"//g')" > ${PROJECT_ROOT}/secrets/devops_sp_client_secret.txt
echo $TF_VAR_tenant_id > ${PROJECT_ROOT}/secrets/tenant_id.txt

cd ${PROJECT_ROOT}
