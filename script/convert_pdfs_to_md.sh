#!/usr/bin/env bash
set -euo pipefail

# Convert all PDFs under contexts/ to Markdown files with the same base name.
# Requires: pdftotext (poppler-utils)

shopt -s globstar nullglob

PDFS=(contexts/**/*.pdf)
if [ ${#PDFS[@]} -eq 0 ]; then
  echo "No PDF files found under contexts/. Skipping."
  exit 0
fi

for pdf in "${PDFS[@]}"; do
  base_no_ext="${pdf%.pdf}"
  md_out="${base_no_ext}.md"

  echo "Converting: $pdf -> $md_out"
  # -layout keeps text layout as close as possible
  pdftotext -layout -nopgbrk "$pdf" - | awk 'BEGIN{print "# Extracted from: '"$pdf"'\n"} {print}' > "$md_out.tmp"

  # Normalize line endings and trim trailing spaces; ensure UTF-8
  sed -e 's/[ \t]*$//' "$md_out.tmp" > "$md_out"
  rm -f "$md_out.tmp"

done

echo "Conversion finished. Generated Markdown files:"
ls -1 contexts/**/*.md || true
