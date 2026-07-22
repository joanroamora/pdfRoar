import os
import io
import fitz  # PyMuPDF
from typing import List
from fastapi import FastAPI, UploadFile, File, Form, HTTPException, status
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import Counter, Histogram, make_asgi_app

app = FastAPI(
    title="pdfRoar - PDF Merge & Split Service",
    description="High-performance PDF merging, splitting, and page extraction powered by PyMuPDF",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prometheus Metrics
REQUEST_COUNT = Counter("pdf_merge_split_requests_total", "Total requests", ["endpoint"])
REQUEST_LATENCY = Histogram("pdf_merge_split_request_duration_seconds", "Request latency", ["endpoint"])

# Add Prometheus metrics endpoint
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "pdf-merge-split"}


@app.post("/api/v1/pdf/merge", summary="Merge multiple PDF files into one")
async def merge_pdfs(files: List[UploadFile] = File(...)):
    REQUEST_COUNT.labels(endpoint="merge").inc()
    with REQUEST_LATENCY.labels(endpoint="merge").time():
        if len(files) < 2:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="At least 2 PDF files are required for merging."
            )

        merged_doc = fitz.open()

        try:
            for file in files:
                contents = await file.read()
                pdf_doc = fitz.open(stream=contents, filetype="pdf")
                merged_doc.insert_pdf(pdf_doc)
                pdf_doc.close()

            output_stream = io.BytesIO()
            merged_doc.save(output_stream)
            merged_doc.close()
            output_stream.seek(0)

            return StreamingResponse(
                output_stream,
                media_type="application/pdf",
                headers={"Content-Disposition": "attachment; filename=merged.pdf"}
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error merging PDFs: {str(e)}")


@app.post("/api/v1/pdf/split", summary="Split PDF file into individual pages or ranges")
async def split_pdf(
    file: UploadFile = File(...),
    start_page: int = Form(1),
    end_page: int = Form(None)
):
    REQUEST_COUNT.labels(endpoint="split").inc()
    with REQUEST_LATENCY.labels(endpoint="split").time():
        try:
            contents = await file.read()
            pdf_doc = fitz.open(stream=contents, filetype="pdf")
            total_pages = len(pdf_doc)

            if start_page < 1 or start_page > total_pages:
                raise HTTPException(
                    status_code=400,
                    detail=f"start_page must be between 1 and {total_pages}"
                )

            final_end_page = end_page if (end_page and end_page <= total_pages) else total_pages

            split_doc = fitz.open()
            # PyMuPDF uses 0-based page indexing
            split_doc.insert_pdf(pdf_doc, from_page=start_page - 1, to_page=final_end_page - 1)

            output_stream = io.BytesIO()
            split_doc.save(output_stream)
            split_doc.close()
            pdf_doc.close()
            output_stream.seek(0)

            return StreamingResponse(
                output_stream,
                media_type="application/pdf",
                headers={"Content-Disposition": f"attachment; filename=split_p{start_page}_p{final_end_page}.pdf"}
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error splitting PDF: {str(e)}")


@app.post("/api/v1/pdf/extract", summary="Extract specific page numbers from PDF")
async def extract_pages(
    file: UploadFile = File(...),
    pages: str = Form(..., description="Comma separated page numbers e.g. '1,3,5'")
):
    REQUEST_COUNT.labels(endpoint="extract").inc()
    with REQUEST_LATENCY.labels(endpoint="extract").time():
        try:
            page_numbers = [int(p.strip()) for p in pages.split(",") if p.strip().isdigit()]
            if not page_numbers:
                raise HTTPException(status_code=400, detail="Invalid page numbers provided.")

            contents = await file.read()
            pdf_doc = fitz.open(stream=contents, filetype="pdf")
            total_pages = len(pdf_doc)

            extract_doc = fitz.open()
            for p in page_numbers:
                if 1 <= p <= total_pages:
                    extract_doc.insert_pdf(pdf_doc, from_page=p - 1, to_page=p - 1)

            output_stream = io.BytesIO()
            extract_doc.save(output_stream)
            extract_doc.close()
            pdf_doc.close()
            output_stream.seek(0)

            return StreamingResponse(
                output_stream,
                media_type="application/pdf",
                headers={"Content-Disposition": "attachment; filename=extracted_pages.pdf"}
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error extracting PDF pages: {str(e)}")
