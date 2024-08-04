#!/bin/bash
set -e

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Destroying ${PROJECT_NAME} - ${ENV_NAME} in subscription ${sub_name}"
sleep 5

# This resource is not recognized by Terraform (Bug) and implicitly created by Azure during the application insights deployment
# az resource delete -g "${TF_VAR_rg_name}" --name "$(az resource list --query "[?contains(name, 'Failure Anomalies')].name" -o tsv)" --resource-type "microsoft.alertsmanagement/smartDetectorAlertRules"

cd ${PROJECT_ROOT}/tf
terraform init \
    -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}"
terraform destroy
rm -rf .terraform
rm .terraform.lock.hcl
cd ${PROJECT_ROOT}

RESOURCE_GROUP_NAME="${TF_STATE_RESOURCE_GROUP_NAME}"
INFRASTRUCTURE_RESOURCE_GROUP_NAME="${TF_VAR_rg_name}"
STORAGE_ACCOUNT_NAME="${TF_STATE_STORAGE_ACCOUNT_NAME}"
CONTAINER_NAME=terraformstates
KEYVAULT_NAME="${PLATFORM_NAME}${ENV_NAME}devopskvt"
DEVOPS_SP_DISPLAY_NAME="${PLATFORM_NAME}${ENV_NAME}devopssp"

export DEVOPS_SERVICE_PRINCIPAL_APPID="$(az ad app list --display-name "${DEVOPS_SP_DISPLAY_NAME}" --query "[0].appId" | grep -o "[-a-z0-9]*")"
az ad app delete --id "${DEVOPS_SERVICE_PRINCIPAL_APPID}"

az storage account delete --yes --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME
az keyvault purge --location westeurope --name $KEYVAULT_NAME
az group delete --name $RESOURCE_GROUP_NAME
