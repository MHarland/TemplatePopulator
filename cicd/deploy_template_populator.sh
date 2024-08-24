#!/bin/bash
set -e

echo "Deploying TemplatePopulator App"

export PROJECT_ROOT=$(pwd)
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
source ${PROJECT_ROOT}/cicd/config.sh

cd ${PROJECT_ROOT}/infrastructure/platform
export ARM_CLIENT_ID=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_id.txt)
export ARM_CLIENT_SECRET=$(cat ${PROJECT_ROOT}/secrets/devops_sp_client_secret.txt)
export ARM_TENANT_ID=$(cat ${PROJECT_ROOT}/secrets/tenant_id.txt)
export URL=${TF_VAR_acr_name}/${TF_VAR_image_name}:${TF_VAR_image_tag}

az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
az acr login --name ${TF_VAR_acr_name}
sudo docker login -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET ${TF_VAR_acr_name}
sudo docker build -t $URL -f ${PROJECT_ROOT}/az_func/Dockerfile ${PROJECT_ROOT}
sudo docker push $URL
#az acr build --registry ${TF_VAR_acr_name} --image ${TF_VAR_image_name}:${TF_VAR_image_tag} --file ${PROJECT_ROOT}/az_func/Dockerfile ${PROJECT_ROOT}
#az acr artifact-streaming update -n ${TF_VAR_acr_name} --repository ${TF_VAR_image_name} --enable-streaming True

cd ..
