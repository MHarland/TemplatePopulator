import azure.functions as func
from function_app import healthcheck, populated_document
from template_populator.populate_test import (
    check_blob_existence_and_clean_up,
    test_template_path,
)
from template_populator import cfg
import json


def test_healthcheck():
    req = func.HttpRequest(method="GET", body=None, url="/api/healthcheck", params=None)
    func_call = healthcheck.build().get_user_function()
    resp = func_call(req)


def test_populated_document(test_template_path):
    placeholder_map = {"PLACEHOLDER": "world"}
    document_blob_name = f"test_populate_{cfg.TEST_RUN_UUID}.pdf"
    document_path = "".join(
        [
            cfg.TEST_STORAGE_ENDPOINT,
            cfg.TEST_STORAGE_DOCUMENT_CONTAINER,
            "/",
            document_blob_name,
        ]
    )
    req = func.HttpRequest(
        method="POST",
        url="/api/populated-document",
        body=json.dumps(
            {
                "placeholder_map": {"PLACEHOLDER": "world"},
                "template_docx_blob_path": test_template_path,
                "document_pdf_blob_path": document_path,
            }
        ).encode(),
    )
    func_call = populated_document.build().get_user_function()
    resp = func_call(req)
    check_blob_existence_and_clean_up(document_blob_name)
