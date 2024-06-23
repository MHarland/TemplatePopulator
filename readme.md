# Template Populator

This projects provides the code for an Azure function that receives 
1. the URL's of a `docx` template document
2. a map of how to fill in the template
3. an output path where the resulting pdf will be stored
The storage media shall be blob storages. The template populator applies the map to the document and saves it as a pdf.

# Todo
- discuss blocking vs. non-blocking, background task

# Local development
1. conda create -p ./venv python=3.11
2. pip install -r requirements.txt
3. pip install -e .

# Requirements
- Libre Office

# Config
This project uses `dotenv`. The configuration hierarchy is (highest to lowest)
1. Environment variables
2. `.env` file
3. default values in `cfg.py`, check this file to figure out what environment variables are relevant


# Build
`./cicd/build.sh`

# Run function locally
```
cd az_func
func start
```
Request `curl http://localhost:7071/api/healthcheck`

# Run container
docker run --rm -it -p 7071:80 tpopdevacr.azurecr.io/tpopdevfuncimg:latest

# Run
```
az storage blob upload -f template_populator/test_data/TestTemplate.docx --account-name tpopdevsta -c templates -n test_template_123.docx

curl -X POST -v -H 'x-functions-key: tVEVF_wmRrEQOXRTmTsMHWnZp-LqhA3zek1to2Jhp8ZkAzFuJGEhgg==' -H 'Content-Type: application/json' -d '{"placeholder_map": {"PLACEHOLDER": "world"}, "template_docx_blob_path": "https://tpopdevsta.blob.core.windows.net/templates/test_template_123.docx", "document_pdf_blob_path": "https://tpopdevsta.blob.core.windows.net/documents/test_document_123.pdf"}' 'https://tpopdevapp.azurewebsites.net/api/populated-document'

az storage blob download -f test_document_123.pdf --account-name tpopdevsta -c documents -n test_document_123.pdf
```