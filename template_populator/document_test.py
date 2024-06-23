from .document import Document
from template_populator import cfg
import os


def test_docx_to_pdf():
    doc = Document("template_populator/test_data/TestTemplate.docx")
    test_out_path = os.path.join(
        cfg.WORK_DIR, f"test_docx_to_pdf_{cfg.TEST_RUN_UUID}.pdf"
    )
    doc.save_as_pdf(test_out_path)
    assert os.path.exists(test_out_path)
    os.remove(test_out_path)


def test_map_placeholders():
    doc = Document("template_populator/test_data/TestTemplate.docx")
    placeholder_map = {"PLACEHOLDER": "world"}
    doc.map_placeholders(placeholder_map)
    whole_text = doc.get_whole_text()
    assert "world" in whole_text
