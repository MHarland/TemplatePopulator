#!/bin/bash

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

# Key vault for environment configuration accessible everywhere
az keyvault create --location westeurope --name $KEYVAULT_NAME --resource-group $RESOURCE_GROUP_NAME --enable-rbac-authorization true
az role assignment create --assignee $(az ad signed-in-user show --query id -o tsv) --role 00482a5a-887f-4fb3-b363-3b7fe8e74483 --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.KeyVault/vaults/${KEYVAULT_NAME}

# DevOps service principal
# Extract credentials to make them available for the DevOps pipelines (service connection)
SP_SECRETS="$(az ad sp create-for-rbac --name "${DEVOPS_SP_DISPLAY_NAME}")"
export DEVOPS_SERVICE_PRINCIPAL_APPID="$(echo $SP_SECRETS | grep -o "\"appId\": \"[^\"]*\"" | grep -o "[^\"]*" | tail -1)"
echo "DEVOPS_SERVICE_PRINCIPAL_APPID=${DEVOPS_SERVICE_PRINCIPAL_APPID}"
DEVOPS_SERVICE_PRINCIPAL_PASSWORD="$(echo $SP_SECRETS | grep -o "\"password\": \"[^\"]*\"" | grep -o "[^\"]*" | tail -1)"
DEVOPS_SERVICE_PRINCIPAL_OBJECT_ID="$(az ad sp show --id ${DEVOPS_SERVICE_PRINCIPAL_APPID} --query "id" -o tsv)"
az keyvault secret set --name "devops-sp-name" --vault-name $KEYVAULT_NAME --value $DEVOPS_SP_DISPLAY_NAME
az keyvault secret set --name "devops-sp-password" --vault-name $KEYVAULT_NAME --value $DEVOPS_SERVICE_PRINCIPAL_PASSWORD
az keyvault secret set --name "devops-sp-app-id" --vault-name $KEYVAULT_NAME --value $DEVOPS_SERVICE_PRINCIPAL_APPID
az keyvault secret set --name "devops-sp-object-id" --vault-name $KEYVAULT_NAME --value $DEVOPS_SERVICE_PRINCIPAL_OBJECT_ID
az keyvault secret set --name "tenant-id" --vault-name $KEYVAULT_NAME --value $TENANT_ID
az keyvault secret set --name "subscription-id" --vault-name $KEYVAULT_NAME --value $SUBSCRIPTION_ID

# Role assignments
echo "Role assignments"
az role assignment create --assignee-object-id $DEVOPS_SERVICE_PRINCIPAL_OBJECT_ID --role 4633458b-17de-408a-b874-0445c86b69e6 --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.KeyVault/vaults/${KEYVAULT_NAME} --assignee-principal-type "ServicePrincipal"
az role assignment create --assignee-object-id $DEVOPS_SERVICE_PRINCIPAL_OBJECT_ID --role b7e6dc6d-f1e8-4753-8033-0f276bb0955b --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME} --assignee-principal-type "ServicePrincipal"
az role assignment create --assignee-object-id $DEVOPS_SERVICE_PRINCIPAL_OBJECT_ID --role Owner --scope /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME} --assignee-principal-type "ServicePrincipal"
