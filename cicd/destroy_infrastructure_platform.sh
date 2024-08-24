#!/bin/bash
set -e

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh
sub_name="$(az account list --query "[?isDefault].name" -o tsv)"
export TF_VAR_tenant_id=$(az account list --query "[?name == '${sub_name}'].tenantId" -o tsv)
echo "Destroying platform of ${PROJECT_NAME} - ${ENV_NAME} in subscription ${sub_name}"
sleep 5

# This resource is not recognized by Terraform (Bug) and implicitly created by Azure during the application insights deployment
az resource delete --yes -g "${TF_VAR_rg_name}" --name "$(az resource list --query "[?contains(name, 'Failure Anomalies')].name" -o tsv)" --resource-type "microsoft.alertsmanagement/smartDetectorAlertRules"

cd ${PROJECT_ROOT}/infrastructure/platform
terraform init \
    -backend-config="resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}" \
    -backend-config="storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}"
terraform destroy
rm -rf .terraform
rm .terraform.lock.hcl
cd ${PROJECT_ROOT}
