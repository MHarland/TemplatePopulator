from .document import Document
from template_populator import cfg
import os


def test_docx_to_pdf():
    doc = Document("template_populator/test_data/TestTemplate.docx")
    test_out = os.path.join(cfg.TEST_DIR, "test_docx_to_pdf.pdf")
    doc.save_as_pdf(test_out)
    assert os.path.exists(test_out)
    os.remove(test_out)
    os.removedirs(cfg.TEST_DIR)


def test_map_placeholders():
    doc = Document("template_populator/test_data/TestTemplate.docx")
    placeholder_map = {"PLACEHOLDER": "world"}
    doc.map_placeholders(placeholder_map)
    whole_text = doc.get_whole_text()
    assert "world" in whole_text
