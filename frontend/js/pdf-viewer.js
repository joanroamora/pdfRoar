/* ==========================================================================
   pdfRoar - Fast Canvas PDF.js Previewer & Coordinate Overlay Engine
   ========================================================================== */

let pdfDoc = null;
let currentPageNum = 1;
let pageRendering = false;
let pageNumPending = null;
let scale = 1.2;
let currentBlocks = [];

async function loadPdfPreview(fileOrUrl, canvasId = 'pdf-canvas') {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;

  const ctx = canvas.getContext('2d');

  try {
    let arrayBuffer;
    if (fileOrUrl instanceof File) {
      arrayBuffer = await fileOrUrl.arrayBuffer();
    } else {
      const resp = await fetch(fileOrUrl);
      arrayBuffer = await resp.arrayBuffer();
    }

    const loadingTask = pdfjsLib.getDocument({ data: arrayBuffer });
    pdfDoc = await loadingTask.promise;
    currentPageNum = 1;
    renderPage(currentPageNum, canvas, ctx);
  } catch (err) {
    console.error("PDF.js Render Error:", err);
  }
}

async function renderPage(num, canvas, ctx) {
  pageRendering = true;
  const page = await pdfDoc.getPage(num);

  const viewport = page.getViewport({ scale: scale });
  canvas.height = viewport.height;
  canvas.width = viewport.width;

  const renderContext = {
    canvasContext: ctx,
    viewport: viewport
  };

  const renderTask = page.render(renderContext);
  await renderTask.promise;

  pageRendering = false;
  if (pageNumPending !== null) {
    renderPage(pageNumPending, canvas, ctx);
    pageNumPending = null;
  }

  // If bounding box block coordinates exist for this page, overlay them
  drawCoordinateOverlays(canvas, ctx, viewport);
}

function drawCoordinateOverlays(canvas, ctx, viewport) {
  if (!currentBlocks || currentBlocks.length === 0) return;

  const pageBlocks = currentBlocks.find(p => p.page === currentPageNum);
  if (!pageBlocks || !pageBlocks.blocks) return;

  ctx.save();
  ctx.strokeStyle = 'rgba(6, 182, 212, 0.8)';
  ctx.lineWidth = 1.5;
  ctx.fillStyle = 'rgba(6, 182, 212, 0.15)';

  pageBlocks.blocks.forEach(b => {
    // bbox: [x0, y0, x1, y1]
    const [x0, y0, x1, y1] = b.bbox;
    // Scale coordinates to canvas viewport
    const scaledX0 = x0 * scale;
    const scaledY0 = y0 * scale;
    const width = (x1 - x0) * scale;
    const height = (y1 - y0) * scale;

    ctx.fillRect(scaledX0, scaledY0, width, height);
    ctx.strokeRect(scaledX0, scaledY0, width, height);
  });

  ctx.restore();
}

function setCoordinateBlocks(blocksData) {
  currentBlocks = blocksData;
  if (pdfDoc && document.getElementById('pdf-canvas')) {
    const canvas = document.getElementById('pdf-canvas');
    const ctx = canvas.getContext('2d');
    renderPage(currentPageNum, canvas, ctx);
  }
}
