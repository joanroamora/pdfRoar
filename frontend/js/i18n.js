/* ==========================================================================
   pdfRoar - Internationalization (i18n) Engine
   ========================================================================== */

const translations = {
  en: {
    title: "pdfRoar — Professional Cloud-Native PDF Platform",
    subtitle: "Ultra-fast PDF merging, splitting, page extraction, clean text converter, and Word/Acrobat-style WYSIWYG editor.",
    tab_merge: "Merge Studio",
    tab_split: "Split & Extract Studio",
    tab_totext: "PDF to Text Converter",
    tab_editor: "Word/Acrobat Interactive Editor",
    dropzone_merge_title: "Drag & Drop multiple PDF files to Merge",
    dropzone_split_title: "Drag & Drop PDF file to Split or Extract Pages",
    dropzone_sub: "or click to browse from your device (Max 100MB per file)",
    btn_merge: "Merge PDFs",
    btn_split: "Split PDF Range",
    btn_extract: "Extract Pages",
    btn_totext: "Extract Clean Text",
    btn_copy: "Copy to Clipboard",
    btn_download_txt: "Download .TXT",
    btn_export_pdf: "Save & Download Modified PDF",
    worker_status: "PDF Worker Engine Status:",
    worker_idle: "On-Demand (Idle / Auto-Sleep Enabled)",
    worker_active: "Active & Processing",
    system_healthy: "All Systems Operational (Single-Region AWS)",
    start_page: "Start Page",
    end_page: "End Page",
    target_text: "Text to Find",
    replacement_text: "Replacement Text",
    page_numbers: "Page Numbers (e.g. 1, 3, 5)",
    tool_font: "Font Family",
    tool_size: "Size",
    tool_add_text: "+ Add Text",
    tool_redact: "Redact Mask"
  },
  es: {
    title: "pdfRoar — Plataforma Profesional de PDFs en la Nube",
    subtitle: "Unión, separación de archivos, extracción de páginas, convertidor a texto y editor estilo Word/Acrobat.",
    tab_merge: "Estudio Unir PDFs",
    tab_split: "Estudio Separar y Extraer",
    tab_totext: "Convertidor PDF a Texto",
    tab_editor: "Editor Interactivo Estilo Word/Acrobat",
    dropzone_merge_title: "Arrastra y suelta varios archivos PDF para Unir",
    dropzone_split_title: "Arrastra y suelta un archivo PDF para Separar o Extraer",
    dropzone_sub: "o haz clic para explorar desde tu dispositivo (Máx 100MB por archivo)",
    btn_merge: "Unir PDFs",
    btn_split: "Separar Rango de PDF",
    btn_extract: "Extraer Páginas Seleccionadas",
    btn_totext: "Extraer Texto Limpio",
    btn_copy: "Copiar al Portapapeles",
    btn_download_txt: "Descargar .TXT",
    btn_export_pdf: "Guardar y Descargar PDF Modificado",
    worker_status: "Estado del Motor PDF Worker:",
    worker_idle: "Bajo Demanda (Inactivo / Auto-Apagado Activado)",
    worker_active: "Activo y Procesando",
    system_healthy: "Todos los Sistemas Operativos (AWS Single-Region)",
    start_page: "Página Inicial",
    end_page: "Página Final",
    target_text: "Texto a Buscar",
    replacement_text: "Texto de Reemplazo",
    page_numbers: "Números de Página (ej. 1, 3, 5)",
    tool_font: "Tipo de Letra",
    tool_size: "Tamaño",
    tool_add_text: "+ Añadir Texto",
    tool_redact: "Censurar/Redactar"
  },
  fr: {
    title: "pdfRoar — Plateforme PDF Professionnelle Cloud-Native",
    subtitle: "Fusion, division, extraction de pages, convertisseur texte et éditeur interactif style Word/Acrobat.",
    tab_merge: "Studio Fusion PDF",
    tab_split: "Studio Division & Extraction",
    tab_totext: "Convertisseur PDF en Texte",
    tab_editor: "Éditeur Interactif Word/Acrobat",
    dropzone_merge_title: "Glissez & déposez plusieurs fichiers PDF pour fusionner",
    dropzone_split_title: "Glissez & déposez un fichier PDF pour diviser",
    dropzone_sub: "ou cliquez pour parcourir depuis votre appareil (Max 100MB)",
    btn_merge: "Fusionner les PDF",
    btn_split: "Diviser par Plage",
    btn_extract: "Extraire les Pages",
    btn_totext: "Extraire le Texte Propre",
    btn_copy: "Copier dans le presse-papiers",
    btn_download_txt: "Télécharger .TXT",
    btn_export_pdf: "Enregistrer & Télécharger PDF Modifié",
    worker_status: "Statut du Moteur Worker:",
    worker_idle: "À la demande (Inactif / En veille)",
    worker_active: "Actif & En traitement",
    system_healthy: "Tous les Systèmes Opérationnels",
    start_page: "Page de Début",
    end_page: "Page de Fin",
    target_text: "Texte à Rechercher",
    replacement_text: "Texte de Remplacement",
    page_numbers: "Numéros de Page (ex: 1, 3, 5)",
    tool_font: "Police",
    tool_size: "Taille",
    tool_add_text: "+ Ajouter Texte",
    tool_redact: "Masquer/Censurer"
  },
  de: {
    title: "pdfRoar — Professionelle Cloud-Native PDF Platform",
    subtitle: "Zusammenfügen, Teilen, Seitenauswahl, Textkonvertierung und interaktiver Word/Acrobat-Editor.",
    tab_merge: "Zusammenfügen Studio",
    tab_split: "Teilen & Extrahieren Studio",
    tab_totext: "PDF-zu-Text Konverter",
    tab_editor: "Word/Acrobat Interaktiver Editor",
    dropzone_merge_title: "Mehrere PDF-Dateien zum Zusammenfügen hierher ziehen",
    dropzone_split_title: "PDF-Datei zum Teilen hierher ziehen",
    dropzone_sub: "oder klicken zum Durchsuchen (Max 100MB pro Datei)",
    btn_merge: "PDFs Zusammenfügen",
    btn_split: "Bereich Teilen",
    btn_extract: "Seiten Extrahieren",
    btn_totext: "Sauberen Text Extrahieren",
    btn_copy: "In Zwischenablage Kopieren",
    btn_download_txt: ".TXT Herunterladen",
    btn_export_pdf: "Geändertes PDF Speichern & Herunterladen",
    worker_status: "PDF-Worker Status:",
    worker_idle: "Auf Anfrage (Inaktiv / Auto-Sleep)",
    worker_active: "Aktiv & Verarbeitet",
    system_healthy: "Alle Systeme Betriebsbereit",
    start_page: "Startseite",
    end_page: "Endseite",
    target_text: "Suchtext",
    replacement_text: "Ersatztext",
    page_numbers: "Seitenzahlen (z.B. 1, 3, 5)",
    tool_font: "Schriftart",
    tool_size: "Größe",
    tool_add_text: "+ Text Hinzufügen",
    tool_redact: "Schwärzen"
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
