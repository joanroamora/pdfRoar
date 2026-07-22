/* ==========================================================================
   pdfRoar - API Gateway Client Wrapper (With Safe Response Parsing)
   ========================================================================== */

const API_BASE = '/api/v1';

async function handleApiResponse(response, defaultErrorMsg) {
  if (!response.ok) {
    let errorDetail = defaultErrorMsg;
    try {
      const contentType = response.headers.get('content-type') || '';
      if (contentType.includes('application/json')) {
        const json = await response.json();
        errorDetail = json.detail || defaultErrorMsg;
      } else {
        const text = await response.text();
        errorDetail = text.substring(0, 100) || defaultErrorMsg;
      }
    } catch (e) {
      errorDetail = `Server Error (${response.status})`;
    }
    throw new Error(errorDetail);
  }
}

async function mergePdfsApi(files) {
  const formData = new FormData();
  files.forEach(file => formData.append('files', file));

  const response = await fetch(`${API_BASE}/pdf/merge`, {
    method: 'POST',
    body: formData
  });

  await handleApiResponse(response, 'Failed to merge PDFs');
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

  await handleApiResponse(response, 'Failed to split PDF');
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

  await handleApiResponse(response, 'Failed to extract pages');
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

  await handleApiResponse(response, 'Failed to extract text');

  if (formatOutput === 'txt') {
    return await response.text();
  }
  return await response.json();
}

async function pdfToDocxApi(file) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch(`${API_BASE}/pdf/to-docx`, {
    method: 'POST',
    body: formData
  });

  await handleApiResponse(response, 'Failed to convert PDF to DOCX');
  return await response.blob();
}

async function extractEditorBlocksApi(file) {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch(`${API_BASE}/editor/blocks`, {
    method: 'POST',
    body: formData
  });

  await handleApiResponse(response, 'Failed to extract Acrobat coordinate blocks');
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

  await handleApiResponse(response, 'Failed to replace text in PDF');
  return await response.blob();
}
