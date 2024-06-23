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
```
export STORAGE_ACCOUNT_NAME=<storage account name>

az storage blob upload -f template_populator/test_data/TestTemplate.docx --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n test_template_123.docx

curl -X POST -v -H 'x-functions-key: <func-key>' -H 'Content-Type: application/json' -d '{"placeholder_map": {"PLACEHOLDER": "world"}, "template_docx_blob_path": "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/templates/test_template_123.docx", "document_pdf_blob_path": "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/documents/test_document_123.pdf"}' 'https://tpopdevapp.azurewebsites.net/api/populated-document'

az storage blob download -f test_document_123.pdf --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf

az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c documents -n test_document_123.pdf
az storage blob delete --account-name ${STORAGE_ACCOUNT_NAME} -c templates -n test_template_123.docx
```
