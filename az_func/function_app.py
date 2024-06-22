import azure.functions as func
import datetime
import json
import logging
from template_populator import Storage, Document, cfg

app = func.FunctionApp()


@app.function_name(name="Healthcheck")
@app.route(route="healthcheck")
def main(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(status_code=200)


@app.function_name(name="TemplatePopulator")
@app.route(route="document")
def main(req: func.HttpRequest) -> str:
    parameters = json.loads(req.body.decode())
    template_docx_blob_path = parameters["template_docx_blob_path"]
    document_pdf_blob_path = parameters["document_pdf_blob_path"]
    placeholder_map = parameters["placeholder_map"]

    storage = Storage()
    storage.fetch_template(template_docx_blob_path)
    document = Document(cfg.TEMP_TEMPLATE_PATH)
    document.map_placeholders(placeholder_map)
    document.save_as_pdf(cfg.TEMP_DOCUMENT_PATH)
    storage.post_document(document_pdf_blob_path)

    return func.HttpResponse(status_code=200)
