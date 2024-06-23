from .storage import Storage
from .document import Document
from . import cfg
from uuid import uuid4
import os


def populate(
    placeholder_map: dict[str, str],
    template_docx_blob_path: str,
    document_pdf_blob_path: str,
):
    run_id = uuid4().hex
    storage = Storage()
    tmp_docx = os.path.join(cfg.WORK_DIR, f"{run_id}.docx")
    storage.fetch_template(template_docx_blob_path, tmp_docx)
    document = Document(tmp_docx)
    document.map_placeholders(placeholder_map)
    tmp_pdf = os.path.join(cfg.WORK_DIR, f"{run_id}.pdf")
    document.save_as_pdf(tmp_pdf)
    storage.post_document(tmp_pdf, document_pdf_blob_path)
    for temporary_file in [tmp_docx, tmp_pdf]:
        os.remove(temporary_file)
