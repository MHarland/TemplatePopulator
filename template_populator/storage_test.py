from .storage import Storage
from . import cfg
from azure.storage.blob import BlobServiceClient
from azure.core.exceptions import ResourceExistsError
from azure.identity import DefaultAzureCredential
import os
import pytest


@pytest.fixture
def use_template():
    credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        cfg.TEST_STORAGE_ENDPOINT, credential=credential
    )
    blob_client = blob_service_client.get_blob_client(
        container=cfg.TEST_STORAGE_TEMPLATE_CONTAINER, blob="TestTemplate.docx"
    )
    with open(
        os.path.join("template_populator", "test_data", "TestTemplate.docx"), "rb"
    ) as data:
        try:
            blob_client.upload_blob(data)
        except ResourceExistsError:
            pass
    yield
    os.remove(cfg.TEMP_TEMPLATE_PATH)
    blob_client.delete_blob()


def test_fetch_template(use_template):
    storage = Storage()
    path = "".join(
        [
            cfg.TEST_STORAGE_ENDPOINT,
            cfg.TEST_STORAGE_TEMPLATE_CONTAINER,
            "/TestTemplate.docx",
        ]
    )
    storage.fetch_template(path)
    assert os.path.exists(cfg.TEMP_TEMPLATE_PATH)


@pytest.fixture
def use_document():
    with (
        open(
            os.path.join("template_populator", "test_data", "TestDocument.pdf"), "rb"
        ) as test_data,
        open(cfg.TEMP_DOCUMENT_PATH, "wb") as tmp_data,
    ):
        tmp_data.write(test_data.read())
    yield
    os.remove(cfg.TEMP_DOCUMENT_PATH)
    credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        cfg.TEST_STORAGE_ENDPOINT, credential=credential
    )
    blob_client = blob_service_client.get_blob_client(
        container=cfg.TEST_STORAGE_DOCUMENT_CONTAINER, blob="TestDocument.pdf"
    )
    blob_client.delete_blob()


def test_post_document(use_document):
    storage = Storage()
    blob_name = "TestDocument.pdf"
    path = "".join(
        [
            cfg.TEST_STORAGE_ENDPOINT,
            cfg.TEST_STORAGE_DOCUMENT_CONTAINER,
            "/",
            blob_name,
        ]
    )
    storage.post_document(path)
    credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        cfg.TEST_STORAGE_ENDPOINT, credential=credential
    )
    container_client = blob_service_client.get_container_client(
        cfg.TEST_STORAGE_DOCUMENT_CONTAINER
    )
    blob_names = list(container_client.list_blob_names())
    assert blob_name in blob_names
