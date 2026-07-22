import fitz  # PyMuPDF
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import JSONResponse, Response
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import Counter, Histogram, make_asgi_app

app = FastAPI(
    title="pdfRoar - PDF to Text Converter Service",
    description="Clean text extraction from PDF documents with layout awareness",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

REQUEST_COUNT = Counter("pdf_to_text_requests_total", "Total requests")
REQUEST_LATENCY = Histogram("pdf_to_text_request_duration_seconds", "Request duration")

app.mount("/metrics", make_asgi_app())


@app.get("/health")
def health_check():
    return {"status": "ok", "service": "pdf-to-text"}


@app.post("/api/v1/pdf/to-text", summary="Convert PDF pages to clean text")
async def pdf_to_text(
    file: UploadFile = File(...),
    format_output: str = Form("json", description="Output format: 'json' or 'txt'")
):
    REQUEST_COUNT.inc()
    with REQUEST_LATENCY.time():
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
