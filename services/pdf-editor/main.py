import time
import io
import fitz  # PyMuPDF
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Body
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from prometheus_client import Counter, Histogram, make_asgi_app

app = FastAPI(
    title="pdfRoar - Heavy PDF Advanced Coordinate Editor Engine",
    description="Acrobat-style inline text block coordinate extraction, text replacement, and redaction engine",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

REQUEST_COUNT = Counter("pdf_editor_requests_total", "Total editor requests")
REQUEST_LATENCY = Histogram("pdf_editor_request_duration_seconds", "Request latency")

app.mount("/metrics", make_asgi_app())


def update_last_activity():
    """Update timestamp file to reset idle shutdown timer on EC2 PDF Worker"""
    try:
        with open("/tmp/last_pdf_request_timestamp", "w") as f:
            f.write(str(int(time.time())))
    except Exception:
        pass


@app.get("/health")
def health_check():
    update_last_activity()
    return {"status": "ok", "service": "pdf-editor", "mode": "on-demand-worker"}


@app.post("/api/v1/editor/blocks", summary="Extract text blocks with Acrobat-style coordinates")
async def extract_text_blocks(file: UploadFile = File(...)):
    update_last_activity()
    REQUEST_COUNT.inc()
    with REQUEST_LATENCY.time():
        try:
            contents = await file.read()
            pdf_doc = fitz.open(stream=contents, filetype="pdf")

            pages_data = []
            for page_num in range(len(pdf_doc)):
                page = pdf_doc[page_num]
                rect = page.rect
                blocks = page.get_text("blocks")  # (x0, y0, x1, y1, text, block_no, block_type)

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
    REQUEST_COUNT.inc()
    with REQUEST_LATENCY.time():
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
                headers={"Content-Disposition": "attachment; filename=edited.pdf"}
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error replacing text in PDF: {str(e)}")
