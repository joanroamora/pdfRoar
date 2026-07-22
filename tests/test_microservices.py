import unittest
import sys
import os
import importlib.util
import fitz  # PyMuPDF
from fastapi.testclient import TestClient

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def load_module(module_name, file_path):
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

merge_split_module = load_module("merge_split", os.path.join(BASE_DIR, "services", "pdf-merge-split", "main.py"))
to_text_module = load_module("to_text", os.path.join(BASE_DIR, "services", "pdf-to-text", "main.py"))
editor_module = load_module("editor", os.path.join(BASE_DIR, "services", "pdf-editor", "main.py"))

def create_sample_pdf(text_content="Hello pdfRoar Cloud Test"):
    doc = fitz.open()
    page = doc.new_page()
    page.insert_text((50, 100), text_content, fontsize=12)
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes


class TestPDFMicroservices(unittest.TestCase):

    def setUp(self):
        self.pdf_file_1 = ("test1.pdf", create_sample_pdf("Page 1 Document Test"), "application/pdf")
        self.pdf_file_2 = ("test2.pdf", create_sample_pdf("Page 2 Document Test"), "application/pdf")
        self.client_merge = TestClient(merge_split_module.app)
        self.client_text = TestClient(to_text_module.app)
        self.client_editor = TestClient(editor_module.app)

    # 1. MERGE & SPLIT TESTS
    def test_pdf_merge_split_health(self):
        response = self.client_merge.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok", "service": "pdf-merge-split"})

    def test_pdf_merge(self):
        response = self.client_merge.post(
            "/api/v1/pdf/merge",
            files=[("files", self.pdf_file_1), ("files", self.pdf_file_2)]
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")
        
        merged_doc = fitz.open(stream=response.content, filetype="pdf")
        self.assertEqual(len(merged_doc), 2)
        merged_doc.close()

    def test_pdf_split(self):
        response = self.client_merge.post(
            "/api/v1/pdf/split",
            files={"file": self.pdf_file_1},
            data={"start_page": 1, "end_page": 1}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")

    # 2. PDF TO TEXT TESTS
    def test_pdf_to_text_health(self):
        response = self.client_text.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok", "service": "pdf-to-text"})

    def test_pdf_to_text_json(self):
        response = self.client_text.post(
            "/api/v1/pdf/to-text",
            files={"file": self.pdf_file_1},
            data={"format_output": "json"}
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["total_pages"], 1)
        self.assertIn("Page 1 Document Test", data["pages"][0]["text"])

    # 3. ACROBAT PDF EDITOR TESTS
    def test_pdf_editor_health(self):
        response = self.client_editor.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "ok")

    def test_pdf_editor_extract_blocks(self):
        response = self.client_editor.post(
            "/api/v1/editor/blocks",
            files={"file": self.pdf_file_1}
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(len(data["pages"]), 1)
        self.assertTrue(len(data["pages"][0]["blocks"]) > 0)

    def test_pdf_editor_replace_text(self):
        response = self.client_editor.post(
            "/api/v1/editor/replace-text",
            files={"file": self.pdf_file_1},
            data={"search_text": "Page 1 Document Test", "replace_text": "Replaced Acrobat Text"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")

if __name__ == "__main__":
    unittest.main()
