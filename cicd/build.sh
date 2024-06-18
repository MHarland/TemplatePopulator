echo $(pwd)

cd tf
az login
az acr login -n ${terraform output -raw acr_server}
docker build -t ${terraform output -raw image_upload_url} .
docker push ${terraform output -raw image_upload_url}
cd ..
