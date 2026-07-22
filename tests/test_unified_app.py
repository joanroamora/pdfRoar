import unittest
import sys
import os
import fitz  # PyMuPDF
from fastapi.testclient import TestClient

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BASE_DIR)

import app_main

def create_sample_pdf(text_content="Hello pdfRoar Unified App Test"):
    doc = fitz.open()
    page = doc.new_page()
    page.insert_text((50, 100), text_content, fontsize=12)
    pdf_bytes = doc.tobytes()
    doc.close()
    return pdf_bytes

class TestUnifiedApp(unittest.TestCase):

    def setUp(self):
        self.client = TestClient(app_main.app)
        self.pdf_1 = ("test1.pdf", create_sample_pdf("Sample PDF Page 1 Content"), "application/pdf")
        self.pdf_2 = ("test2.pdf", create_sample_pdf("Sample PDF Page 2 Content"), "application/pdf")

    def test_health_endpoints(self):
        r1 = self.client.get("/health")
        self.assertEqual(r1.status_code, 200)
        self.assertEqual(r1.json()["status"], "ok")

        r2 = self.client.get("/api/health")
        self.assertEqual(r2.status_code, 200)
        self.assertEqual(r2.json()["status"], "ok")

    def test_merge_pdfs(self):
        response = self.client.post(
            "/api/v1/pdf/merge",
            files=[("files", self.pdf_1), ("files", self.pdf_2)]
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")

    def test_split_pdf(self):
        response = self.client.post(
            "/api/v1/pdf/split",
            files={"file": self.pdf_1},
            data={"start_page": 1, "end_page": 1}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")

    def test_extract_pages(self):
        response = self.client.post(
            "/api/v1/pdf/extract",
            files={"file": self.pdf_1},
            data={"pages": "1"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")

    def test_pdf_to_text(self):
        response = self.client.post(
            "/api/v1/pdf/to-text",
            files={"file": self.pdf_1},
            data={"format_output": "json"}
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["total_pages"], 1)
        self.assertIn("Sample PDF Page 1 Content", data["pages"][0]["text"])

    def test_pdf_to_docx(self):
        response = self.client.post(
            "/api/v1/pdf/to-docx",
            files={"file": self.pdf_1}
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue("wordprocessingml" in response.headers["content-type"])

    def test_editor_blocks(self):
        response = self.client.post(
            "/api/v1/editor/blocks",
            files={"file": self.pdf_1}
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(len(data["pages"]), 1)

    def test_editor_replace_text(self):
        response = self.client.post(
            "/api/v1/editor/replace-text",
            files={"file": self.pdf_1},
            data={"search_text": "Sample PDF Page 1 Content", "replace_text": "Replaced Text Content"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "application/pdf")

    def test_metrics_endpoint(self):
        response = self.client.get("/metrics")
        self.assertEqual(response.status_code, 200)
        self.assertIn("pdfroar_api_requests_total", response.text)

if __name__ == "__main__":
    unittest.main()
