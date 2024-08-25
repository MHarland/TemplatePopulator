# Template Populator

This projects provides the code for an Azure function that receives 
1. the URL's of a `docx` template document
2. a map of how to fill in the template
3. an output path where the resulting pdf will be stored
The storage media are blob storages. The template populator applies the map to the document and saves it as a pdf.


# Requirements
- [Azure](https://azure.microsoft.com/en-us) account and subscription
- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
- [Libre Office](https://www.libreoffice.org/download/download-libreoffice/) (for local development)
- [Docker](https://docs.docker.com/engine/install/) (for local development)

# Setup

## Secrets
Create `secrets/config.sh` as such
```
export SUBSCRIPTION_ID="..."
export PROJECT_NAME="..."
export ENV_NAME="..."
# check your user's object ID in Azure Entra ID
export TF_VAR_owners_entra_object_ids='["..."]'
```

Generate an ssh key `ssh-keygen -t rsa`  for the login on the DevOps VM
at path: `secrets/id_devopsvm`

## Deployment
First, deploy the authorization, networking and CICD VM.
```
./cicd/deploy_infrastructure_core.sh apply
```

Then, load or update the code on the DevOps VM
```
./cicd/vm_load_code.sh
```

Upload secrets that were created during the core deployment (e.g. service principal)
```
./cicd/vm_load_secrets.sh
```

Login
```
./cicd/vm_login.sh
```

and deploy application layer infrastructure
```
cd ~/TemplatePopulator
./cicd/deploy_infrastructure_platform.sh apply
```
Probably, this command has to be run twice as the private endpoint configuration has an Azure-internal delay that Terraform doesn't take into account properly. There would be a `403` Error while reading the container states of the storage account.

Deploy the app
```
sudo ./cicd/deploy_template_populator.sh
```

# Example 
```
export STORAGE_ACCOUNT_NAME="..."
export FUNC_APP_NAME="..."
export FUNC_KEY="..."
```

## MacOs - ZShell
```
curl -v -G https://${FUNC_APP_NAME}.azurewebsites.net/api/healthcheck?code=${FUNC_KEY}

az storage blob upload -f template_populator/test_data/TestTemplate.docx --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n TestTemplate.docx

curl -X POST -v -H 'x-functions-key: ${FUNC_KEY}' -H 'Content-Type: application/json' -d '{"placeholder_map": {"PLACEHOLDER": "world"}, "template_docx_blob_path": "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/templates/TestTemplate.docx", "document_pdf_blob_path": "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/documents/test_document_123.pdf"}' 'https://${FUNC_APP_NAME}.azurewebsites.net/api/populated-document'

az storage blob download -f test_document_123.pdf --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf

az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf
az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n TestTemplate.docx
```

## Ubuntu - Bash
```
curl -v -G https://${FUNC_APP_NAME}.azurewebsites.net/api/healthcheck?code=${FUNC_KEY}

az storage blob upload -f template_populator/test_data/TestTemplate.docx --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n TestTemplate.docx

curl -X POST -v -H "x-functions-key: ${FUNC_KEY}" -H "Content-Type: application/json" -d "{\"placeholder_map\": {\"PLACEHOLDER\": \"world\"}, \"template_docx_blob_path\": \"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/templates/TestTemplate.docx\", \"document_pdf_blob_path\": \"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/documents/test_document_123.pdf\"}" https://${FUNC_APP_NAME}.azurewebsites.net/api/populated-document

az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf
az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n TestTemplate.docx
```

# Local development
1. conda create -p ./venv python=3.11
2. pip install -r requirements.txt
3. pip install -e .

If you have to modify the environment to run tests locally, create a dot-env file `.env`.

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

# Run container locally
```
export PROJECT_ROOT=$(pwd)
docker build -t  -f ${PROJECT_ROOT}/az_func/Dockerfile ${PROJECT_ROOT}
docker run --rm -it -p 7071:80 tpopdevacr.azurecr.io/tpopdevfuncimg:latest
Request `curl http://localhost:7071/api/healthcheck`
```

# Clean up
Login
```
./cicd/vm_login.sh
```
Destroy application layer
```
./cicd/destroy_infrastructure_platform.sh
```
`exit` the VM 
and destroy the core infrastructure
```
./cicd/destroy_infrastructure_core.sh
```

# ToDo
- Mange most secrets in a key vault
- DevOps VM authentication (maybe assign the service principal as a user assigned identity)

# Architecture

## Infrastructure
![Image](./docs/systems.png)

