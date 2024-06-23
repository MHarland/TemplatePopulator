from .storage import Storage
from . import cfg
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import os
import pytest
from uuid import uuid4


@pytest.fixture
def test_template_path():
    credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        cfg.TEST_STORAGE_ENDPOINT, credential=credential
    )
    template_uuid = uuid4().hex
    test_template_blob_name = f"TestTemplate_{template_uuid}_{cfg.TEST_RUN_UUID}.docx"
    blob_client = blob_service_client.get_blob_client(
        container=cfg.TEST_STORAGE_TEMPLATE_CONTAINER, blob=test_template_blob_name
    )
    with open(
        os.path.join("template_populator", "test_data", "TestTemplate.docx"), "rb"
    ) as data:
        blob_client.upload_blob(data)
    template_path = "".join(
        [
            cfg.TEST_STORAGE_ENDPOINT,
            cfg.TEST_STORAGE_TEMPLATE_CONTAINER,
            "/",
            test_template_blob_name,
        ]
    )
    yield template_path
    blob_client.delete_blob()


def test_fetch_template(test_template_path):
    storage = Storage()
    target_path = f"TestTemplate{cfg.TEST_RUN_UUID}.docx"
    storage.fetch_template(test_template_path, target_path)
    full_target_path = os.path.join(cfg.WORK_DIR, target_path)
    assert os.path.exists(full_target_path)
    os.remove(full_target_path)


def test_post_document():
    storage = Storage()
    blob_name = f"TestDocument{cfg.TEST_RUN_UUID}.pdf"
    target_path = "".join(
        [
            cfg.TEST_STORAGE_ENDPOINT,
            cfg.TEST_STORAGE_DOCUMENT_CONTAINER,
            "/",
            blob_name,
        ]
    )
    local_source_path = os.path.join(
        "template_populator", "test_data", "TestDocument.pdf"
    )
    storage.post_document(local_source_path, target_path)
    credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        cfg.TEST_STORAGE_ENDPOINT, credential=credential
    )
    container_client = blob_service_client.get_container_client(
        cfg.TEST_STORAGE_DOCUMENT_CONTAINER
    )
    blob_names = list(container_client.list_blob_names())
    assert blob_name in blob_names
    blob_client = blob_service_client.get_blob_client(
        container=cfg.TEST_STORAGE_DOCUMENT_CONTAINER, blob=blob_name
    )
    blob_client.delete_blob()
