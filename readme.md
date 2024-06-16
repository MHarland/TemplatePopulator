# Template Populator

This projects provides the code for an Azure function that receives the URL's of a `docx` template document and a `csv` files that contains the map of how to fill in the template. Both are located in a blob storage. The template populator applies the map to the document,  saves it as a pdf and returns a link to the exported pdf.

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
