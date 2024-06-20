#!/bin/bash

export PROJECT_ROOT=$(pwd)

cd tf
# az login
az acr login -n $(terraform output -raw acr_server)
docker build -t $(terraform output -raw image_upload_url) -f ${PROJECT_ROOT}/az_func/Dockerfile ${PROJECT_ROOT}
docker push $(terraform output -raw image_upload_url)
cd ..
