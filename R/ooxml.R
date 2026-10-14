.siecc_xml_escape <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x <- gsub('"', "&quot;", x, fixed = TRUE)
  x
}

.siecc_docx_shell <- function(document_xml, relationships = NULL, media = NULL, output) {
  .siecc_require("zip")
  dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
  output <- file.path(normalizePath(dirname(output), winslash = "/", mustWork = TRUE), basename(output))
  root <- tempfile("siecc-docx-"); dir.create(root)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  dir.create(file.path(root, "_rels")); dir.create(file.path(root, "word", "_rels"), recursive = TRUE)
  dir.create(file.path(root, "word", "media"), recursive = TRUE)
  writeLines('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Default Extension="png" ContentType="image/png"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>', file.path(root, "[Content_Types].xml"), useBytes = TRUE)
  writeLines('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>', file.path(root, "_rels", ".rels"), useBytes = TRUE)
  styles <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="300" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:pPr><w:spacing w:after="120" w:line="300" w:lineRule="auto"/></w:pPr><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="200"/></w:pPr><w:rPr><w:b/><w:color w:val="2E74B5"/><w:sz w:val="32"/></w:rPr></w:style></w:styles>'
  writeLines(styles, file.path(root, "word", "styles.xml"), useBytes = TRUE)
  writeLines(document_xml, file.path(root, "word", "document.xml"), useBytes = TRUE)
  rel <- c('<Relationship Id="rStyle" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>', relationships)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">', paste(rel, collapse = ""), '</Relationships>'), file.path(root, "word", "_rels", "document.xml.rels"), useBytes = TRUE)
  if (length(media)) for (i in seq_along(media)) file.copy(media[[i]], file.path(root, "word", "media", paste0("panel", i, ".png")), overwrite = TRUE)
  zip::zip(output, list.files(root, recursive = TRUE, all.files = TRUE, full.names = FALSE, include.dirs = FALSE), root = root, mode = "mirror")
  invisible(output)
}

.siecc_image_run <- function(rid, name, cx = 4040000L, cy = 2220000L, id = 1L) {
  paste0('<w:p><w:pPr><w:jc w:val="center"/><w:spacing w:after="0"/></w:pPr><w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"><wp:extent cx="', cx, '" cy="', cy, '"/><wp:docPr id="', id, '" name="', name, '"/><a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:nvPicPr><pic:cNvPr id="', id, '" name="', name, '"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" r:embed="', rid, '"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="', cx, '" cy="', cy, '"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>')
}

.siecc_write_figure_docx <- function(panel_paths, output, title) {
  stopifnot(length(panel_paths) == 4L, all(file.exists(panel_paths)))
  image_cells <- vapply(seq_along(panel_paths), function(i) paste0('<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/><w:tcMar><w:top w:w="40" w:type="dxa"/><w:start w:w="40" w:type="dxa"/><w:bottom w:w="40" w:type="dxa"/><w:end w:w="40" w:type="dxa"/></w:tcMar></w:tcPr>', .siecc_image_run(paste0("rId", i), paste0("Panel ", LETTERS[i]), id = i), '</w:tc>'), character(1))
  letter_cells <- vapply(seq_along(panel_paths), function(i) paste0('<w:tc><w:tcPr><w:tcW w:w="4680" w:type="dxa"/></w:tcPr><w:p><w:pPr><w:jc w:val="center"/><w:spacing w:before="0" w:after="80"/></w:pPr><w:r><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:t>', LETTERS[i], '</w:t></w:r></w:p></w:tc>'), character(1))
  table <- paste0('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders></w:tblPr><w:tblGrid><w:gridCol w:w="4680"/><w:gridCol w:w="4680"/></w:tblGrid>', '<w:tr>', paste(image_cells[1:2], collapse=""), '</w:tr><w:tr>', paste(letter_cells[1:2], collapse=""), '</w:tr><w:tr>', paste(image_cells[3:4], collapse=""), '</w:tr><w:tr>', paste(letter_cells[3:4], collapse=""), '</w:tr></w:tbl>')
  xml <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:p><w:pPr><w:pStyle w:val="Title"/><w:jc w:val="center"/></w:pPr><w:r><w:t>', .siecc_xml_escape(title), '</w:t></w:r></w:p>', table, '<w:p><w:r><w:rPr><w:sz w:val="16"/><w:color w:val="666666"/></w:rPr><w:t>Panels and CSV companion were generated from the same frozen numerical authority.</w:t></w:r></w:p><w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720" w:header="708" w:footer="708"/></w:sectPr></w:body></w:document>')
  rel <- vapply(seq_along(panel_paths), function(i) paste0('<Relationship Id="rId', i, '" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/panel', i, '.png"/>'), character(1))
  .siecc_docx_shell(xml, rel, panel_paths, output)
}

.siecc_write_results_docx <- function(results, contrasts, output, document_title="Final Long-Weather Descriptive and Results Table") {
  title <- paste0('<w:p><w:pPr><w:pStyle w:val="Title"/><w:jc w:val="center"/></w:pPr><w:r><w:t>',.siecc_xml_escape(document_title),'</w:t></w:r></w:p>')
  header <- c("Period", "Metric", "Descriptives", "HAC primary inference", "Contrasts and sensitivities")
  widths <- c(900, 1600, 1800, 2350, 3430)
  cell <- function(value, width, header = FALSE) paste0('<w:tc><w:tcPr><w:tcW w:w="', width, '" w:type="dxa"/>', if(header) '<w:shd w:fill="E8EEF5"/>' else '', '<w:tcMar><w:top w:w="80" w:type="dxa"/><w:start w:w="120" w:type="dxa"/><w:bottom w:w="80" w:type="dxa"/><w:end w:w="120" w:type="dxa"/></w:tcMar></w:tcPr><w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr><w:r><w:rPr>', if(header) '<w:b/>' else '', '<w:sz w:val="15"/></w:rPr><w:t xml:space="preserve">', .siecc_xml_escape(value), '</w:t></w:r></w:p></w:tc>')
  hrow <- paste0('<w:tr><w:trPr><w:tblHeader/></w:trPr>', paste(mapply(cell, header, widths, MoreArgs=list(header=TRUE)), collapse=""), '</w:tr>')
  rows <- vapply(seq_len(nrow(results)), function(i) {
    r <- results[i, ]; cc <- contrasts[contrasts$PERIOD == r$PERIOD & contrasts$METRIC == r$METRIC, , drop=FALSE]
    desc <- sprintf("Mean %.3f; SD %.3f; median %.3f; IQR %.3f; range %.3f-%.3f (%s-%s); N=%d", r$MEAN,r$SD,r$MEDIAN,r$IQR,r$MIN,r$MAX,r$MIN_YEAR,r$MAX_YEAR,r$N)
    hac <- sprintf("%.4g %s; 95%% CI %.4g to %.4g; SE %.4g; p=%.3g; period q=%.3g; global q=%.3g", r$HAC_SLOPE_PER_DECADE, if(r$UNIT=="mm") "mm/decade" else if(r$UNIT=="percent") "percentage points/decade" else "deg C/decade", r$HAC_CI_LOW,r$HAC_CI_HIGH,r$HAC_SE,r$HAC_P,r$PERIOD_BH_Q,r$GLOBAL_BH_Q)
    support <- sprintf("Normal-period change %.3f; first-recent decade change %.3f; fitted total change %.3f. GLS %.4g; Theil-Sen %.4g; modified MK p=%.3g; ordinary MK p=%.3g (legacy only); GAM %s; %s.", cc$NORMAL_DIFFERENCE,cc$FIRST_RECENT_DIFFERENCE,cc$TOTAL_FITTED_CHANGE,r$GLS_SLOPE_PER_DECADE,r$SEN_SLOPE_PER_DECADE,r$MODIFIED_MK_P,r$LEGACY_MK_P,r$GAM_CLASSIFICATION,r$ROBUSTNESS_CLASSIFICATION)
    vals <- c(r$PERIOD, gsub("_"," ",r$METRIC,fixed=TRUE), desc, hac, support)
    paste0('<w:tr><w:trPr><w:cantSplit/></w:trPr>', paste(mapply(cell, vals, widths, MoreArgs=list(header=FALSE)), collapse=""), '</w:tr>')
  }, character(1))
  table <- paste0('<w:tbl><w:tblPr><w:tblW w:w="10080" w:type="dxa"/><w:tblInd w:w="120" w:type="dxa"/><w:tblLayout w:type="fixed"/><w:tblBorders><w:top w:val="single" w:sz="4" w:color="B7C9DB"/><w:left w:val="single" w:sz="4" w:color="B7C9DB"/><w:bottom w:val="single" w:sz="4" w:color="B7C9DB"/><w:right w:val="single" w:sz="4" w:color="B7C9DB"/><w:insideH w:val="single" w:sz="3" w:color="D9E1E8"/><w:insideV w:val="single" w:sz="3" w:color="D9E1E8"/></w:tblBorders></w:tblPr><w:tblGrid>', paste0('<w:gridCol w:w="', widths, '"/>', collapse=""), '</w:tblGrid>', hrow, paste(rows,collapse=""), '</w:tbl>')
  note <- '<w:p><w:pPr><w:spacing w:before="80" w:after="80"/></w:pPr><w:r><w:rPr><w:sz w:val="16"/><w:color w:val="555555"/></w:rPr><w:t>Notes: HAC/Newey-West is primary. Modified Mann-Kendall is the autocorrelation-adjusted non-parametric sensitivity; ordinary Mann-Kendall is legacy/reference only. Celsius changes are never expressed as percentages. IMS daily mean is (TX+TN)/2. Rainfall calibration is study-specific.</w:t></w:r></w:p>'
  xml <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>', title, table, note, '<w:sectPr><w:pgSz w:w="15840" w:h="12240" w:orient="landscape"/><w:pgMar w:top="720" w:right="720" w:bottom="720" w:left="720" w:header="708" w:footer="708"/></w:sectPr></w:body></w:document>')
  .siecc_docx_shell(xml, output=output)
}
