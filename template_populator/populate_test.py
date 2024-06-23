from .storage_test import test_template_path
from .populate import populate
from . import cfg
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential


def test_populate(test_template_path):
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
    populate(placeholder_map, test_template_path, document_path)

    credential = DefaultAzureCredential()
    blob_service_client = BlobServiceClient(
        cfg.TEST_STORAGE_ENDPOINT, credential=credential
    )
    container_client = blob_service_client.get_container_client(
        cfg.TEST_STORAGE_DOCUMENT_CONTAINER
    )
    blob_names = list(container_client.list_blob_names())
    assert document_blob_name in blob_names
    blob_client = blob_service_client.get_blob_client(
        container=cfg.TEST_STORAGE_DOCUMENT_CONTAINER, blob=document_blob_name
    )
    blob_client.delete_blob()
