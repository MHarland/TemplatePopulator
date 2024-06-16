import os
from dotenv import load_dotenv

load_dotenv()

SOFFICE = os.getenv("SOFFICE", "soffice")
LOCAL_WORK_DIR = os.getenv("LOCAL_WORK_DIR", os.getcwd())
TEST_DIR = os.getenv("TEST_DIR", os.path.join(os.getcwd(), "test_out"))
