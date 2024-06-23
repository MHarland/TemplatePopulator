import os
from dotenv import load_dotenv
import json
from uuid import uuid4

load_dotenv()

SOFFICE = os.getenv("SOFFICE", "soffice")
WORK_DIR = os.getenv("WORK_DIR", os.getcwd())

TEST_RUN_UUID = uuid4().hex
cfg_path = os.path.dirname(os.path.abspath(__file__))
infrastructure_path = os.path.join(cfg_path, "infrastructure.json")
with open(infrastructure_path, "r") as f:
    infrastructure = json.load(f)
TEST_STORAGE_ENDPOINT = infrastructure["test_storage_endpoint"]["value"]
TEST_STORAGE_TEMPLATE_CONTAINER = infrastructure["test_storage_template_container"][
    "value"
]
TEST_STORAGE_DOCUMENT_CONTAINER = infrastructure["test_storage_document_container"][
    "value"
]
