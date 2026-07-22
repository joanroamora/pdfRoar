/* ==========================================================================
   pdfRoar - Word/Acrobat-Style Interactive WYSIWYG PDF Editor Engine
   ========================================================================== */

let pdfDoc = null;
let currentPageNum = 1;
let totalPages = 1;
let scale = 1.25;
let activeTextNode = null;
let pageTextItems = [];

async function loadPdfPreview(fileOrUrl, wrapperId = 'canvas-wrapper') {
  const wrapper = document.getElementById(wrapperId);
  if (!wrapper) return;

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
    totalPages = pdfDoc.numPages;
    currentPageNum = 1;

    document.getElementById('page-indicator').textContent = `Page ${currentPageNum} / ${totalPages}`;
    renderInteractivePage(currentPageNum, wrapper);
  } catch (err) {
    console.error("PDF.js Editor Load Error:", err);
  }
}

async function renderInteractivePage(pageNum, wrapper) {
  wrapper.innerHTML = ''; // Clear previous canvas & text layer

  const page = await pdfDoc.getPage(pageNum);
  const viewport = page.getViewport({ scale: scale });

  // 1. Create Canvas Element
  const canvas = document.createElement('canvas');
  canvas.id = 'pdf-canvas';
  canvas.width = viewport.width;
  canvas.height = viewport.height;
  wrapper.appendChild(canvas);

  const ctx = canvas.getContext('2d');
  const renderContext = {
    canvasContext: ctx,
    viewport: viewport
  };
  await page.render(renderContext).promise;

  // 2. Create Interactive WYSIWYG Text Overlay Layer
  const textLayerDiv = document.createElement('div');
  textLayerDiv.className = 'pdf-text-layer';
  textLayerDiv.style.width = `${viewport.width}px`;
  textLayerDiv.style.height = `${viewport.height}px`;
  wrapper.appendChild(textLayerDiv);

  // 3. Extract Text Content & Create Editable Text Nodes
  const textContent = await page.getTextContent();
  pageTextItems = textContent.items;

  textContent.items.forEach((item, index) => {
    if (!item.str.trim()) return;

    const tx = pdfjsLib.Util.transform(viewport.transform, item.transform);
    const fontHeight = Math.sqrt(tx[2] * tx[2] + tx[3] * tx[3]);

    const node = document.createElement('div');
    node.className = 'editable-text-node';
    node.contentEditable = "true";
    node.setAttribute('data-index', index);
    node.setAttribute('data-original-text', item.str);
    
    // Position text node precisely over PDF canvas coordinates
    node.style.left = `${tx[4]}px`;
    node.style.top = `${tx[5] - fontHeight}px`;
    node.style.fontSize = `${fontHeight}px`;
    node.style.fontFamily = 'Plus Jakarta Sans, sans-serif';
    node.innerText = item.str;

    // Selection & Editing Event Listeners
    node.addEventListener('focus', () => selectTextNode(node));
    node.addEventListener('click', (e) => {
      e.stopPropagation();
      selectTextNode(node);
    });

    node.addEventListener('input', () => {
      node.setAttribute('data-modified', 'true');
    });

    textLayerDiv.appendChild(node);
  });
}

function selectTextNode(node) {
  if (activeTextNode) {
    activeTextNode.classList.remove('selected');
  }
  activeTextNode = node;
  activeTextNode.classList.add('selected');

  // Update Toolbar controls to match selected node's current styling
  const fontSelect = document.getElementById('tool-font-family');
  const sizeInput = document.getElementById('tool-font-size');
  const colorInput = document.getElementById('tool-text-color');

  if (fontSelect && node.style.fontFamily) {
    fontSelect.value = node.style.fontFamily.split(',')[0].replace(/['"]/g, '');
  }
  if (sizeInput && node.style.fontSize) {
    sizeInput.value = parseInt(node.style.fontSize);
  }
  if (colorInput && node.style.color) {
    colorInput.value = rgbToHex(node.style.color);
  }
}

// Add New Editable Text Frame anywhere on PDF page
function addNewTextNode() {
  const textLayer = document.querySelector('.pdf-text-layer');
  if (!textLayer) return;

  const node = document.createElement('div');
  node.className = 'editable-text-node selected';
  node.contentEditable = "true";
  node.style.left = '100px';
  node.style.top = '100px';
  node.style.fontSize = '16px';
  node.style.fontFamily = 'Outfit, sans-serif';
  node.style.color = '#3b82f6';
  node.innerText = 'New Edit Text Frame';
  node.setAttribute('data-new', 'true');

  node.addEventListener('focus', () => selectTextNode(node));
  node.addEventListener('click', (e) => {
    e.stopPropagation();
    selectTextNode(node);
  });

  textLayer.appendChild(node);
  selectTextNode(node);
  node.focus();
}

// Helper: Convert RGB to HEX for color input picker
function rgbToHex(rgb) {
  if (!rgb || rgb.startsWith('#')) return rgb || '#000000';
  const rgbValues = rgb.match(/\d+/g);
  if (!rgbValues) return '#000000';
  return "#" + ((1 << 24) + (parseInt(rgbValues[0]) << 16) + (parseInt(rgbValues[1]) << 8) + parseInt(rgbValues[2])).toString(16).slice(1);
}
