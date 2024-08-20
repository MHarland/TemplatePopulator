# Template Populator

This projects provides the code for an Azure function that receives 
1. the URL's of a `docx` template document
2. a map of how to fill in the template
3. an output path where the resulting pdf will be stored
The storage media are blob storages. The template populator applies the map to the document and saves it as a pdf.

# Deployment
```
./cicd/deploy_infrastructure.sh apply
./cicd/deploy_template_populator.sh
```

# Local development
1. conda create -p ./venv python=3.11
2. pip install -r requirements.txt
3. pip install -e .

If you have to modify the environment to run tests locally, create a dot-env file `.env`.

# Requirements
- Azure account
- Libre Office
- Docker
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)

# Config
This project uses `dotenv`. The configuration hierarchy is (highest to lowest)
1. Environment variables
2. `.env` file
3. default values in `cfg.py`, check this file to figure out what environment variables are relevant

# Tests
```
pytest
```

# Run function locally
```
cd az_func
func start
```

# Run container
docker run --rm -it -p 7071:80 tpopdevacr.azurecr.io/tpopdevfuncimg:latest
Request `curl http://localhost:7071/api/healthcheck`

# Example 
## MacOs - ZShell
```
export STORAGE_ACCOUNT_NAME=<storage account name>
export FUNC_APP_NAME=<function app name>
export FUNC_KEY=<function key>

curl -v -G https://${FUNC_APP_NAME}.azurewebsites.net/api/healthcheck?code=${FUNC_KEY}

az storage blob upload -f template_populator/test_data/TestTemplate.docx --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n test_template_123.docx

curl -X POST -v -H 'x-functions-key: ${FUNC_KEY}' -H 'Content-Type: application/json' -d '{"placeholder_map": {"PLACEHOLDER": "world"}, "template_docx_blob_path": "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/templates/test_template_123.docx", "document_pdf_blob_path": "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/documents/test_document_123.pdf"}' 'https://${FUNC_APP_NAME}.azurewebsites.net/api/populated-document'

az storage blob download -f test_document_123.pdf --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf

az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf
az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n test_template_123.docx
```

## Ubuntu - Bash
```
curl -v -G https://${FUNC_APP_NAME}.azurewebsites.net/api/healthcheck?code=${FUNC_KEY}

curl -X POST -v -H "x-functions-key: ${FUNC_KEY}" -H "Content-Type: application/json" -d "{\"placeholder_map\": {\"PLACEHOLDER\": \"world\"}, \"template_docx_blob_path\": \"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/templates/TestTemplate.docx\", \"document_pdf_blob_path\": \"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/documents/test_document_123.pdf\"}" https://${FUNC_APP_NAME}.azurewebsites.net/api/populated-document
```

# Setup
Create `secrets/config.sh` as described in `cicd/config.sh`

`ssh-keygen -t rsa` with path: `./secrets/id_devopsvm`

```
./cicd/deploy_infrastructure_core.sh apply
```

Take the `devops_vm_ip` of `secrets/infrastructure_core.json`
and login
```
export PROJECT_ROOT=$(pwd)
source cicd/config.sh
export DEVOPS_VM_IP=$(cat ${PROJECT_ROOT}/secrets/devops_vm_ip.txt)
ssh -i secrets/id_devopsvm ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}
```

Install required software on VM (git, Azure CLI, Terraform)
```
sudo apt update
sudo apt install git-all
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```

Get code
```
git clone https://github.com/MHarland/TemplatePopulator.git
cd TemplatePopulator
```

Upload from different terminal session the secret config
```
export PROJECT_ROOT=$(pwd)
source cicd/config.sh
export DEVOPS_VM_IP=$(cat ${PROJECT_ROOT}/secrets/devops_vm_ip.txt)
scp -i ./secrets/id_devopsvm secrets/config.sh ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/config.sh
scp -i ./secrets/id_devopsvm secrets/tenant_id.txt ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/tenant_id.txt
scp -i ./secrets/id_devopsvm secrets/devops_sp_client_id.txt ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/devops_sp_client_id.txt
scp -i ./secrets/id_devopsvm secrets/devops_sp_client_secret.txt ${TF_VAR_devops_vm_username}@${DEVOPS_VM_IP}:~/TemplatePopulator/secrets/devops_sp_client_secret.txt
```

```
cd ~/TemplatePopulator
./cicd/deploy_infrastructure_platform.sh apply
```

# ToDo
Container (Storage) creation needs a `depends_on` for either permission or private endpoint
```
Error: checking for existing Container "documents" (Account "Account \"tpop3devsta\" (IsEdgeZone false / ZoneName \"\" / Subdomain Type \"blob\" / DomainSuffix \"core.windows.net\")"): executing request: unexpected status 403 (403 This request is not authorized to perform this operation.) with AuthorizationFailure: This request is not authorized to perform this operation.
```