from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
from . import cfg
import re
from typing import Tuple
import os


class Storage:

    def __init__(self):
        self.credential = DefaultAzureCredential()

    def _dissect_path(self, path) -> Tuple[str, str, str]:
        match = re.match(r"^(https:\/\/[^/]*)\/([^/]*)\/(.*)$", path)
        if not match:
            raise Exception(f"Invalid path {path}")
        endpoint = match.group(1)
        container = match.group(2)
        blob = match.group(3)
        return endpoint, container, blob

    def fetch_template(self, storage_source_path: str, local_target_path: str):
        """Fetch Template

        Args:
            storage_source_path (str): Full URL of the blob
            local_target_path (str): Relative path in the working directory
        """
        endpoint, container, blob = self._dissect_path(storage_source_path)
        blob_service_client = BlobServiceClient(endpoint, credential=self.credential)
        blob_client = blob_service_client.get_blob_client(
            container=container, blob=blob
        )
        full_local_target_path = os.path.join(cfg.WORK_DIR, local_target_path)
        with open(file=full_local_target_path, mode="wb") as download_file:
            blob_client.download_blob().readinto(download_file)

    def post_document(self, local_source_path: str, storage_target_path: str):
        """Post document

        Args:
            local_source_path (str): Relative path in the working directory
            storage_target_path (str): Full URL of the blob
        """
        endpoint, container, blob = self._dissect_path(storage_target_path)
        blob_service_client = BlobServiceClient(endpoint, credential=self.credential)
        blob_client = blob_service_client.get_blob_client(
            container=container, blob=blob
        )
        with open(local_source_path, "rb") as data:
            blob_client.upload_blob(data)
