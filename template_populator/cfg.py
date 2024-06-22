import os
from dotenv import load_dotenv
import json

load_dotenv()

SOFFICE = os.getenv("SOFFICE", "soffice")
LOCAL_WORK_DIR = os.getenv("LOCAL_WORK_DIR", os.getcwd())
TEMP_TEMPLATE_PATH = os.path.join(LOCAL_WORK_DIR, "template_tmp.docx")
TEMP_DOCUMENT_PATH = os.path.join(LOCAL_WORK_DIR, "document_tmp.pdf")
TEST_DIR = os.getenv("TEST_DIR", os.path.join(os.getcwd(), "test_out"))

with open("infrastructure.json", "r") as f:
    infrastructure = json.load(f)
TEST_STORAGE_ENDPOINT = infrastructure["test_storage_endpoint"]["value"]
TEST_STORAGE_TEMPLATE_CONTAINER = infrastructure["test_storage_template_container"][
    "value"
]
TEST_STORAGE_DOCUMENT_CONTAINER = infrastructure["test_storage_document_container"][
    "value"
]
