from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
from . import cfg
import re
from typing import Tuple


class Storage:

    def __init__(self):
        self.credential = DefaultAzureCredential()

    def _dissect_path(self, path) -> Tuple[str, str, str]:
        match = re.match(r"^(https:\/\/[^/]*)\/([^/]*)\/(.*)$", path)
        if not match:
            raise Exception("Invalid path")
        endpoint = match.group(1)
        container = match.group(2)
        blob = match.group(3)
        return endpoint, container, blob

    def fetch_template(self, path: str):
        endpoint, container, blob = self._dissect_path(path)
        blob_service_client = BlobServiceClient(endpoint, credential=self.credential)
        blob_client = blob_service_client.get_blob_client(
            container=container, blob=blob
        )
        with open(file=cfg.TEMP_TEMPLATE_PATH, mode="wb") as download_file:
            blob_client.download_blob().readinto(download_file)

    def post_document(self, path: str):
        endpoint, container, blob = self._dissect_path(path)
        blob_service_client = BlobServiceClient(endpoint, credential=self.credential)
        blob_client = blob_service_client.get_blob_client(
            container=container, blob=blob
        )
        with open(cfg.TEMP_DOCUMENT_PATH, "rb") as data:
            blob_client.upload_blob(data)
