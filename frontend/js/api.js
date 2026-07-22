/* ==========================================================================
   pdfRoar - API Gateway Client Wrapper
   ========================================================================== */

const API_BASE = '/api/v1';

async function mergePdfsApi(files) {
  const formData = new FormData();
  files.forEach(file => formData.append('files', file));

  const response = await fetch(`${API_BASE}/pdf/merge`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.detail || 'Failed to merge PDFs');
  }

  return await response.blob();
}

async function splitPdfApi(file, startPage, endPage) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('start_page', startPage);
  if (endPage) formData.append('end_page', endPage);

  const response = await fetch(`${API_BASE}/pdf/split`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.detail || 'Failed to split PDF');
  }

  return await response.blob();
}

async function extractPagesApi(file, pagesStr) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('pages', pagesStr);

  const response = await fetch(`${API_BASE}/pdf/extract`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.detail || 'Failed to extract pages');
  }

  return await response.blob();
}

async function pdfToTextApi(file, formatOutput = 'json') {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('format_output', formatOutput);

  const response = await fetch(`${API_BASE}/pdf/to-text`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.detail || 'Failed to extract text');
  }

  if (formatOutput === 'txt') {
    return await response.text();
  }
  return await response.json();
}

async function extractEditorBlocksApi(file) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch(`${API_BASE}/editor/blocks`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.detail || 'Failed to extract Acrobat coordinate blocks');
  }

  return await response.json();
}

async function replaceTextInPdfApi(file, searchText, replaceText) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('search_text', searchText);
  formData.append('replace_text', replaceText);

  const response = await fetch(`${API_BASE}/editor/replace-text`, {
    method: 'POST',
    body: formData
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(err.detail || 'Failed to replace text in PDF');
  }

  return await response.blob();
}
