import azure.functions as func
import json
import logging
from template_populator import populate

app = func.FunctionApp()


@app.route(route="healthcheck")
def healthcheck(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(status_code=200)


@app.route(route="populated-document")
def populated_document(req: func.HttpRequest) -> func.HttpResponse:
    parameters = req.get_json()
    populate(
        parameters["placeholder_map"],
        parameters["template_docx_blob_path"],
        parameters["document_pdf_blob_path"],
    )
    return func.HttpResponse(status_code=200)
