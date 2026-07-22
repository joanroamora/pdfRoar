/* ==========================================================================
   pdfRoar - Internationalization (i18n) Engine
   ========================================================================== */

const translations = {
  en: {
    title: "pdfRoar — Professional Cloud-Native PDF Platform",
    subtitle: "Ultra-fast PDF merging, splitting, clean text extraction, and Acrobat-style inline editing.",
    tab_merge: "Merge & Split Studio",
    tab_totext: "PDF to Text Converter",
    tab_editor: "Acrobat Coordinate Editor",
    dropzone_title: "Drag & Drop PDF files here",
    dropzone_sub: "or click to browse from your device (Max 100MB per file)",
    btn_merge: "Merge PDFs",
    btn_split: "Split PDF",
    btn_extract: "Extract Selected Pages",
    btn_totext: "Extract Clean Text",
    btn_copy: "Copy to Clipboard",
    btn_download_txt: "Download .TXT",
    btn_extract_blocks: "Inspect Coordinates & Blocks",
    btn_replace_text: "Apply Replace & Save PDF",
    worker_status: "PDF Worker Engine Status:",
    worker_idle: "On-Demand (Idle / Auto-Sleep Enabled)",
    worker_active: "Active & Processing",
    system_healthy: "All Systems Operational (Single-Region AWS)",
    start_page: "Start Page",
    end_page: "End Page",
    target_text: "Text to Find",
    replacement_text: "Replacement Text",
    page_numbers: "Page Numbers (e.g. 1, 3, 5)"
  },
  es: {
    title: "pdfRoar — Plataforma Profesional de PDFs en la Nube",
    subtitle: "Unión, separación ultra rápida de PDFs, extracción limpia de texto y edición inline estilo Acrobat.",
    tab_merge: "Estudio Unir y Separar",
    tab_totext: "Convertidor PDF a Texto",
    tab_editor: "Editor de Coordenadas Acrobat",
    dropzone_title: "Arrastra y suelta archivos PDF aquí",
    dropzone_sub: "o haz clic para explorar desde tu dispositivo (Máx 100MB por archivo)",
    btn_merge: "Unir PDFs",
    btn_split: "Separar PDF",
    btn_extract: "Extraer Páginas Seleccionadas",
    btn_totext: "Extraer Texto Limpio",
    btn_copy: "Copiar al Portapapeles",
    btn_download_txt: "Descargar .TXT",
    btn_extract_blocks: "Inspeccionar Coordenadas y Bloques",
    btn_replace_text: "Aplicar Reemplazo y Guardar PDF",
    worker_status: "Estado del Motor PDF Worker:",
    worker_idle: "Bajo Demanda (Inactivo / Auto-Apagado Activado)",
    worker_active: "Activo y Procesando",
    system_healthy: "Todos los Sistemas Operativos (AWS Single-Region)",
    start_page: "Página Inicial",
    end_page: "Página Final",
    target_text: "Texto a Buscar",
    replacement_text: "Texto de Reemplazo",
    page_numbers: "Números de Página (ej. 1, 3, 5)"
  },
  fr: {
    title: "pdfRoar — Plateforme PDF Professionnelle Cloud-Native",
    subtitle: "Fusion, division ultra-rapide de PDF, extraction de texte propre et édition style Acrobat.",
    tab_merge: "Studio Fusion & Division",
    tab_totext: "Convertisseur PDF en Texte",
    tab_editor: "Éditeur de Coordonnées Acrobat",
    dropzone_title: "Glissez & déposez vos fichiers PDF ici",
    dropzone_sub: "ou cliquez pour parcourir depuis votre appareil (Max 100MB)",
    btn_merge: "Fusionner les PDF",
    btn_split: "Diviser le PDF",
    btn_extract: "Extraire les Pages",
    btn_totext: "Extraire le Texte Propre",
    btn_copy: "Copier dans el presse-papiers",
    btn_download_txt: "Télécharger .TXT",
    btn_extract_blocks: "Inspecter les Coordonnées",
    btn_replace_text: "Appliquer et Enregistrer",
    worker_status: "Statut du Moteur Worker:",
    worker_idle: "À la demande (Inactif / En veille)",
    worker_active: "Actif & En traitement",
    system_healthy: "Tous les Systèmes Opérationnels",
    start_page: "Page de Début",
    end_page: "Page de Fin",
    target_text: "Texte à Rechercher",
    replacement_text: "Texte de Remplacement",
    page_numbers: "Numéros de Page (ex: 1, 3, 5)"
  },
  de: {
    title: "pdfRoar — Professionelle Cloud-Native PDF Platform",
    subtitle: "Zusammenfügen, Teilen von PDFs, saubere Textkonvertierung und Acrobat-Koordinaten-Editor.",
    tab_merge: "Zusammenfügen & Teilen",
    tab_totext: "PDF-zu-Text Konverter",
    tab_editor: "Acrobat Koordinaten-Editor",
    dropzone_title: "PDF-Dateien hierher ziehen",
    dropzone_sub: "oder klicken zum Durchsuchen (Max 100MB pro Datei)",
    btn_merge: "PDFs Zusammenfügen",
    btn_split: "PDF Teilen",
    btn_extract: "Seiten Extrahieren",
    btn_totext: "Sauberen Text Extrahieren",
    btn_copy: "In Zwischenablage Kopieren",
    btn_download_txt: ".TXT Herunterladen",
    btn_extract_blocks: "Koordinaten Überprüfen",
    btn_replace_text: "Ersetzen & PDF Speichern",
    worker_status: "PDF-Worker Status:",
    worker_idle: "Auf Anfrage (Inaktiv / Auto-Sleep)",
    worker_active: "Aktiv & Verarbeitet",
    system_healthy: "Alle Systeme Betriebsbereit",
    start_page: "Startseite",
    end_page: "Endseite",
    target_text: "Suchtext",
    replacement_text: "Ersatztext",
    page_numbers: "Seitenzahlen (z.B. 1, 3, 5)"
  }
};

let currentLang = 'en';

function setLanguage(lang) {
  if (!translations[lang]) return;
  currentLang = lang;
  
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (translations[lang][key]) {
      el.textContent = translations[lang][key];
    }
  });

  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (translations[lang][key]) {
      el.placeholder = translations[lang][key];
    }
  });
}
