import time
import io
import fitz  # PyMuPDF
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File, Form, HTTPException, status
from fastapi.responses import StreamingResponse, JSONResponse, Response
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import Counter, Histogram, make_asgi_app

app = FastAPI(
    title="pdfRoar Consolidated Backend Engine",
    description="High-performance Cloud-Native PDF processing: Merge, Split, To-Text, and WYSIWYG Acrobat Editor",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Metrics
REQUEST_COUNT = Counter("pdfroar_api_requests_total", "Total requests", ["endpoint"])
REQUEST_LATENCY = Histogram("pdfroar_api_request_duration_seconds", "Request latency", ["endpoint"])

app.mount("/metrics", make_asgi_app())


def update_last_activity():
    try:
        with open("/tmp/last_pdf_request_timestamp", "w") as f:
            f.write(str(int(time.time())))
    except Exception:
        pass


@app.get("/health")
def health_check():
    update_last_activity()
    return {"status": "ok", "service": "pdfRoar-unified-backend"}


# 1. MERGE / SPLIT / EXTRACT
@app.post("/api/v1/pdf/merge", summary="Merge multiple PDF files into one")
async def merge_pdfs(files: List[UploadFile] = File(...)):
    update_last_activity()
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
                headers={"Content-Disposition": "attachment; filename=pdfRoar_merged.pdf"}
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error merging PDFs: {str(e)}")


@app.post("/api/v1/pdf/split", summary="Split PDF file into individual pages or ranges")
async def split_pdf(
    file: UploadFile = File(...),
    start_page: int = Form(1),
    end_page: Optional[int] = Form(None)
):
    update_last_activity()
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
            split_doc.insert_pdf(pdf_doc, from_page=start_page - 1, to_page=final_end_page - 1)

            output_stream = io.BytesIO()
            split_doc.save(output_stream)
            split_doc.close()
            pdf_doc.close()
            output_stream.seek(0)

            return StreamingResponse(
                output_stream,
                media_type="application/pdf",
                headers={"Content-Disposition": f"attachment; filename=pdfRoar_split_p{start_page}_p{final_end_page}.pdf"}
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
    update_last_activity()
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
                headers={"Content-Disposition": "attachment; filename=pdfRoar_extracted.pdf"}
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error extracting PDF pages: {str(e)}")


# 2. PDF TO TEXT
@app.post("/api/v1/pdf/to-text", summary="Convert PDF pages to clean text")
async def pdf_to_text(
    file: UploadFile = File(...),
    format_output: str = Form("json")
):
    update_last_activity()
    REQUEST_COUNT.labels(endpoint="to_text").inc()
    with REQUEST_LATENCY.labels(endpoint="to_text").time():
        try:
            contents = await file.read()
            pdf_doc = fitz.open(stream=contents, filetype="pdf")

            extracted_pages = []
            full_text = []

            for page_num in range(len(pdf_doc)):
                page = pdf_doc[page_num]
                text = page.get_text("text")
                extracted_pages.append({
                    "page": page_num + 1,
                    "text": text
                })
                full_text.append(f"--- Page {page_num + 1} ---\n{text}\n")

            pdf_doc.close()

            if format_output == "txt":
                combined_text = "\n".join(full_text)
                return Response(
                    content=combined_text,
                    media_type="text/plain; charset=utf-8",
                    headers={"Content-Disposition": f"attachment; filename={file.filename}.txt"}
                )

            return JSONResponse(content={
                "filename": file.filename,
                "total_pages": len(extracted_pages),
                "pages": extracted_pages
            })

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error converting PDF to text: {str(e)}")


# 3. WYSIWYG ACROBAT PDF EDITOR
@app.post("/api/v1/editor/blocks", summary="Extract text blocks with Acrobat-style coordinates")
async def extract_text_blocks(file: UploadFile = File(...)):
    update_last_activity()
    REQUEST_COUNT.labels(endpoint="editor_blocks").inc()
    with REQUEST_LATENCY.labels(endpoint="editor_blocks").time():
        try:
            contents = await file.read()
            pdf_doc = fitz.open(stream=contents, filetype="pdf")

            pages_data = []
            for page_num in range(len(pdf_doc)):
                page = pdf_doc[page_num]
                rect = page.rect
                blocks = page.get_text("blocks")

                block_list = []
                for b in blocks:
                    block_list.append({
                        "bbox": [b[0], b[1], b[2], b[3]],
                        "text": b[4].strip(),
                        "block_no": b[5],
                        "type": b[6]
                    })

                pages_data.append({
                    "page": page_num + 1,
                    "width": rect.width,
                    "height": rect.height,
                    "blocks": block_list
                })

            pdf_doc.close()
            return JSONResponse(content={"filename": file.filename, "pages": pages_data})
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error extracting PDF blocks: {str(e)}")


@app.post("/api/v1/editor/replace-text", summary="Replace text in PDF by string or bounding box")
async def replace_text(
    file: UploadFile = File(...),
    search_text: str = Form(...),
    replace_text: str = Form(...)
):
    update_last_activity()
    REQUEST_COUNT.labels(endpoint="editor_replace").inc()
    with REQUEST_LATENCY.labels(endpoint="editor_replace").time():
        try:
            contents = await file.read()
            pdf_doc = fitz.open(stream=contents, filetype="pdf")

            for page in pdf_doc:
                text_instances = page.search_for(search_text)
                for inst in text_instances:
                    # Redact old text
                    page.add_redact_annot(inst, fill=(1, 1, 1))
                    page.apply_redactions()
                    # Insert replacement text at origin coordinate
                    page.insert_text(
                        fitz.Point(inst.x0, inst.y1 - 2),
                        replace_text,
                        fontsize=11,
                        color=(0, 0, 0)
                    )

            output_stream = io.BytesIO()
            pdf_doc.save(output_stream)
            pdf_doc.close()
            output_stream.seek(0)

            return StreamingResponse(
                output_stream,
                media_type="application/pdf",
                headers={"Content-Disposition": "attachment; filename=pdfRoar_edited.pdf"}
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error replacing text in PDF: {str(e)}")
