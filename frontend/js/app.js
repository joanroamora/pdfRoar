/* ==========================================================================
   pdfRoar - Main Application Controller & PDF4QT Stream Binder
   ========================================================================== */

let selectedFilesMerge = [];
let selectedFileSplit = null;
let selectedFileText = null;
let selectedFileEditor = null;

document.addEventListener('DOMContentLoaded', () => {
  setupNavigationTabs();
  setupLanguageSelector();
  setupMergeDropzone();
  setupSplitDropzone();
  setupTextDropzone();
  setupEditorDropzone();
  setupEditorToolbar();
  setupActionListeners();
  setupPdf4QtFrame();
});

/* Tab Navigation */
function setupNavigationTabs() {
  const tabs = document.querySelectorAll('.tab-btn');
  const contents = document.querySelectorAll('.tab-content');

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      contents.forEach(c => c.classList.remove('active'));

      tab.classList.add('active');
      const targetId = tab.getAttribute('data-tab');
      document.getElementById(targetId).classList.add('active');

      if (targetId === 'tab-pdf4qt') {
        setupPdf4QtFrame();
      }
    });
  });
}

/* Dynamic Hostname Resolution for PDF4QT noVNC Stream */
function setupPdf4QtFrame() {
  const iframe = document.getElementById('pdf4qt-frame');
  if (!iframe) return;

  const currentHost = window.location.hostname;
  const noVncUrl = `http://${currentHost}:6080/vnc.html?autoconnect=true&resize=scale`;

  if (!iframe.src || iframe.src === 'about:blank' || iframe.src.includes('127.0.0.1')) {
    iframe.src = noVncUrl;
  }
}

/* Language Selection */
function setupLanguageSelector() {
  const langSelect = document.getElementById('lang-select');
  if (langSelect) {
    langSelect.addEventListener('change', (e) => {
      setLanguage(e.target.value);
    });
  }
}

/* Toast Notifications */
function showToast(message, type = 'info') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="12" y1="16" x2="12" y2="12"></line>
      <line x1="12" y1="8" x2="12.01" y2="8"></line>
    </svg>
    <span>${message}</span>
  `;

  container.appendChild(toast);
  setTimeout(() => {
    toast.remove();
  }, 4000);
}

/* Download Helper */
function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

/* Word/Acrobat-Style Editor Toolbar Controls */
function setupEditorToolbar() {
  const fontSelect = document.getElementById('tool-font-family');
  const sizeInput = document.getElementById('tool-font-size');
  const colorInput = document.getElementById('tool-text-color');
  const btnBold = document.getElementById('tool-btn-bold');
  const btnItalic = document.getElementById('tool-btn-italic');
  const btnAddText = document.getElementById('tool-btn-add-text');
  const btnRedact = document.getElementById('tool-btn-redact');

  fontSelect?.addEventListener('change', (e) => {
    if (activeTextNode) activeTextNode.style.fontFamily = e.target.value;
  });

  sizeInput?.addEventListener('input', (e) => {
    if (activeTextNode) activeTextNode.style.fontSize = `${e.target.value}px`;
  });

  colorInput?.addEventListener('input', (e) => {
    if (activeTextNode) activeTextNode.style.color = e.target.value;
  });

  btnBold?.addEventListener('click', () => {
    if (activeTextNode) {
      const isBold = activeTextNode.style.fontWeight === 'bold';
      activeTextNode.style.fontWeight = isBold ? 'normal' : 'bold';
      btnBold.classList.toggle('active', !isBold);
    }
  });

  btnItalic?.addEventListener('click', () => {
    if (activeTextNode) {
      const isItalic = activeTextNode.style.fontStyle === 'italic';
      activeTextNode.style.fontStyle = isItalic ? 'normal' : 'italic';
      btnItalic.classList.toggle('active', !isItalic);
    }
  });

  btnAddText?.addEventListener('click', () => {
    addNewTextNode();
    showToast('New editable text frame inserted on PDF page!', 'info');
  });

  btnRedact?.addEventListener('click', () => {
    if (activeTextNode) {
      activeTextNode.style.background = '#000000';
      activeTextNode.style.color = '#000000';
      showToast('Selected text redacted (masked)', 'info');
    }
  });
}

/* 1. Dedicated Merge Studio Dropzone */
function setupMergeDropzone() {
  const dropzone = document.getElementById('dropzone-merge');
  const fileInput = document.getElementById('input-merge-files');
  const fileListContainer = document.getElementById('file-list-merge');

  if (!dropzone || !fileInput) return;

  dropzone.addEventListener('click', () => fileInput.click());
  dropzone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropzone.classList.add('dragover');
  });

  dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));

  dropzone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropzone.classList.remove('dragover');
    if (e.dataTransfer.files.length > 0) {
      handleMergeFiles(Array.from(e.dataTransfer.files));
    }
  });

  fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
      handleMergeFiles(Array.from(e.target.files));
    }
  });

  function handleMergeFiles(files) {
    const pdfFiles = files.filter(f => f.type === 'application/pdf' || f.name.endsWith('.pdf'));
    if (pdfFiles.length === 0) {
      showToast('Please select valid PDF files.', 'error');
      return;
    }
    selectedFilesMerge = [...selectedFilesMerge, ...pdfFiles];
    renderFileList();
  }

  function renderFileList() {
    fileListContainer.innerHTML = '';
    selectedFilesMerge.forEach((file, index) => {
      const item = document.createElement('div');
      item.className = 'file-item';
      item.innerHTML = `
        <div class="file-info">
          <span class="file-name">${file.name}</span>
          <span class="file-size">(${(file.size / 1024 / 1024).toFixed(2)} MB)</span>
        </div>
        <button class="btn-remove" onclick="removeMergeFile(${index})">✕</button>
      `;
      fileListContainer.appendChild(item);
    });
  }

  window.removeMergeFile = (index) => {
    selectedFilesMerge.splice(index, 1);
    renderFileList();
  };
}

/* 2. Dedicated Split & Extract Studio Dropzone */
function setupSplitDropzone() {
  const dropzone = document.getElementById('dropzone-split');
  const fileInput = document.getElementById('input-split-file');
  const nameLabel = document.getElementById('selected-split-filename');

  if (!dropzone || !fileInput) return;

  dropzone.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
      selectedFileSplit = e.target.files[0];
      nameLabel.textContent = `Selected: ${selectedFileSplit.name}`;
    }
  });
}

/* 3. PDF to Text Dropzone */
function setupTextDropzone() {
  const dropzone = document.getElementById('dropzone-text');
  const fileInput = document.getElementById('input-text-file');
  const nameLabel = document.getElementById('selected-text-filename');

  if (!dropzone) return;

  dropzone.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
      selectedFileText = e.target.files[0];
      nameLabel.textContent = `Selected: ${selectedFileText.name}`;
    }
  });
}

/* 4. Acrobat/Word Editor Dropzone */
function setupEditorDropzone() {
  const dropzone = document.getElementById('dropzone-editor');
  const fileInput = document.getElementById('input-editor-file');
  const nameLabel = document.getElementById('selected-editor-filename');

  if (!dropzone) return;

  dropzone.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', async (e) => {
    if (e.target.files.length > 0) {
      selectedFileEditor = e.target.files[0];
      nameLabel.textContent = `Selected: ${selectedFileEditor.name}`;
      showToast('Loading interactive PDF canvas editor...', 'info');
      await loadPdfPreview(selectedFileEditor, 'canvas-wrapper');
    }
  });
}

/* Action Listeners */
function setupActionListeners() {
  /* Merge Action */
  document.getElementById('btn-merge-action')?.addEventListener('click', async () => {
    if (selectedFilesMerge.length < 2) {
      showToast('Please select at least 2 PDF files to merge.', 'error');
      return;
    }
    try {
      showToast('Merging PDFs on AWS Gateway...', 'info');
      const blob = await mergePdfsApi(selectedFilesMerge);
      downloadBlob(blob, 'pdfRoar_merged.pdf');
      showToast('PDFs merged successfully!', 'success');
    } catch (err) {
      showToast(err.message, 'error');
    }
  });

  /* Split Action */
  document.getElementById('btn-split-action')?.addEventListener('click', async () => {
    if (!selectedFileSplit) {
      showToast('Please select a PDF file to split in the Split Studio.', 'error');
      return;
    }
    const startPage = parseInt(document.getElementById('split-start-page').value) || 1;
    const endPage = parseInt(document.getElementById('split-end-page').value) || null;

    try {
      showToast('Splitting PDF...', 'info');
      const blob = await splitPdfApi(selectedFileSplit, startPage, endPage);
      downloadBlob(blob, `split_p${startPage}_p${endPage || 'end'}.pdf`);
      showToast('PDF split successfully!', 'success');
    } catch (err) {
      showToast(err.message, 'error');
    }
  });

  /* Extract Pages Action */
  document.getElementById('btn-extract-action')?.addEventListener('click', async () => {
    if (!selectedFileSplit) {
      showToast('Please select a PDF file in the Split & Extract Studio.', 'error');
      return;
    }
    const pagesStr = document.getElementById('extract-pages-input').value;
    if (!pagesStr) {
      showToast('Please enter page numbers e.g. 1, 3, 5', 'error');
      return;
    }

    try {
      showToast('Extracting pages...', 'info');
      const blob = await extractPagesApi(selectedFileSplit, pagesStr);
      downloadBlob(blob, 'extracted_pages.pdf');
      showToast('Pages extracted successfully!', 'success');
    } catch (err) {
      showToast(err.message, 'error');
    }
  });

  /* PDF to Text Action */
  document.getElementById('btn-totext-action')?.addEventListener('click', async () => {
    if (!selectedFileText) {
      showToast('Please select a PDF file first.', 'error');
      return;
    }

    try {
      showToast('Extracting clean text...', 'info');
      const data = await pdfToTextApi(selectedFileText, 'json');
      const textOutputBox = document.getElementById('text-output-display');
      
      let textContent = `=== ${data.filename} (${data.total_pages} Pages) ===\n\n`;
      data.pages.forEach(p => {
        textContent += `--- Page ${p.page} ---\n${p.text}\n\n`;
      });
      
      textOutputBox.textContent = textContent;
      showToast('Text extracted successfully!', 'success');
    } catch (err) {
      showToast(err.message, 'error');
    }
  });

  /* Copy Text Action */
  document.getElementById('btn-copy-text')?.addEventListener('click', () => {
    const textOutputBox = document.getElementById('text-output-display');
    if (textOutputBox && textOutputBox.textContent) {
      navigator.clipboard.writeText(textOutputBox.textContent);
      showToast('Copied to clipboard!', 'success');
    }
  });

  /* Export & Save Modified PDF Action */
  document.getElementById('btn-export-edited-pdf')?.addEventListener('click', async () => {
    if (!selectedFileEditor) {
      showToast('Please load a PDF to edit first.', 'error');
      return;
    }

    const modifiedNodes = document.querySelectorAll('.editable-text-node[data-modified="true"], .editable-text-node[data-new="true"]');
    if (modifiedNodes.length === 0) {
      showToast('No text modifications detected yet. Edit text on the canvas to save!', 'info');
      return;
    }

    try {
      const firstModified = modifiedNodes[0];
      const origText = firstModified.getAttribute('data-original-text') || firstModified.innerText;
      const newText = firstModified.innerText;

      showToast('Waking PDF Worker Engine & compiling modified PDF...', 'info');
      const blob = await replaceTextInPdfApi(selectedFileEditor, origText, newText);
      downloadBlob(blob, 'pdfRoar_edited.pdf');
      showToast('Modified PDF compiled and saved successfully!', 'success');
    } catch (err) {
      showToast(err.message, 'error');
    }
  });
}
