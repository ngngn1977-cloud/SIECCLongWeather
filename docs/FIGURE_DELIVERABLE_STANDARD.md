# DEFAULT FIGURE DELIVERABLE RULE

Whenever an analytical figure, chart, plot, or multipanel scientific image is requested, provide BY DEFAULT:

1. IMAGE OUTPUT

   At least one publication-quality image format.

   Prefer as appropriate:

   - PNG
   - PDF
   - SVG

2. WORD DOCUMENT

   DOCX companion.

   For multipanel figures:

   - each panel must be a separate image;
   - each panel must occupy its own Word table cell;
   - the panel identifier/letter must occupy the separate cell directly below the corresponding image;
   - use a borderless table unless otherwise requested;
   - preserve editable/document-friendly layout;
   - do not flatten all panels into one image unless explicitly requested.

3. CSV COMPANION

   A CSV containing the exact numerical data used to draw the figure.

   It must include:

   - plotted observations;
   - x-axis variable;
   - each plotted series;
   - exact displayed fitted/trend values when present;
   - sufficient identifiers to reproduce panel membership.

4. TRACEABILITY

   Figure ↔ panel ↔ CSV columns ↔ numerical authority must be documented.

5. NO MANUAL NUMERICAL TRANSCRIPTION

   CSV and figure values must be generated programmatically from the same numerical authority.

This standard applies automatically unless the user explicitly asks for a different format.

For a purely decorative/non-data image for which no numerical data exist, record:

`CSV_NOT_APPLICABLE_NONDATA_IMAGE`

rather than inventing numerical data.

## Standardized file naming

For future analytical figures use, unless otherwise requested:

```text
<FIGURE_NAME>.png
<FIGURE_NAME>.pdf
<FIGURE_NAME>.svg
<FIGURE_NAME>.docx
<FIGURE_NAME>_DATA.csv
```

For multipanel figures, individual panel images should also be retained where practical:

```text
<FIGURE_NAME>_A.png
<FIGURE_NAME>_B.png
```
