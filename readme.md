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
Request `curl http://localhost:7071/api/req`

# Run container
docker run --rm -it -p 7071:80 tpopdevacr.azurecr.io/tpopdevfuncimg:latest

# Azure runs
docker run -d --expose=80 --name tpopdevapp_0_feab2ccc -e WEBSITE_USE_DIAGNOSTIC_SERVER=false -e WEBSITE_SITE_NAME=tpopdevapp -e WEBSITE_AUTH_ENABLED=False -e PORT=80 -e WEBSITE_ROLE_INSTANCE_ID=0 -e WEBSITE_HOSTNAME=tpopdevapp.azurewebsites.net -e WEBSITE_INSTANCE_ID=5e0fe6be2d0acc7128080b409166ad9fab444029edca97ce3162c99626039516 -e HTTP_LOGGING_ENABLED=1 tpopdevacr.azurecr.io/tpopdevfuncimg:latest

# Curl
```
curl -X GET -v -H 'x-functions-key: <key>' -H 'Content-Type: application/json' 'https://tpopdevapp.azurewebsites.net/api/healthcheck'
```

 TODO
https://tpopdevsta.blob.core.windows.net/templates/TestTemplate2.docx
```
curl -X GET -v -H 'x-functions-key: <key>' -H 'Content-Type: application/json' 'https://tpopdevapp.azurewebsites.net/api/healthcheck'
```


curl -X GET -v -H 'x-functions-key: tVEVF_wmRrEQOXRTmTsMHWnZp-LqhA3zek1to2Jhp8ZkAzFuJGEhgg==' -H 'Content-Type: application/json' 'https://tpopdevapp.azurewebsites.net/api/healthcheck'