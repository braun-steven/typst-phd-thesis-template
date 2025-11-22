#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
BURST_DIR="${BUILD_DIR}/thesis-burst"
MAIN_TYP="${ROOT_DIR}/main.typ"
MAIN_PDF="${ROOT_DIR}/main.pdf"
MAIN_TRIMMED="${BUILD_DIR}/main-without-appendices.pdf"
BOOKMARKS_FILE="${BUILD_DIR}/bookmarks.txt"
MERGED_PDF="${BUILD_DIR}/temp-merged.pdf"
FINAL_PDF="${ROOT_DIR}/dissertation.pdf"

mkdir -p "$BUILD_DIR" "$BURST_DIR"

echo "Using configured paper order (edit PAPERS array to change)..."
PAPERS=(
    # List paper basenames (without .pdf) in the desired order:
    1203.6902v1
    1603.09496v1
    1703.02528v1
    2103.17057v2
)
PAPER_COUNT=${#PAPERS[@]}

if (( PAPER_COUNT == 0 )); then
    echo "No papers configured in PAPERS array. Add entries and re-run." >&2
    exit 1
fi
echo "Found ${PAPER_COUNT} paper(s)."

echo "Compiling with typst..."
typst compile "$MAIN_TYP" "$MAIN_PDF"

# Save bookmarks before rearranging pages.
echo "Extracting bookmarks from main.pdf..."
pdftk "$MAIN_PDF" dump_data_utf8 output "$BOOKMARKS_FILE"

echo "Bursting main.pdf into individual pages..."
pdftk "$MAIN_PDF" burst output "${BURST_DIR}/page_%04d.pdf"
BURST_PAGE_COUNT=$(find "$BURST_DIR" -maxdepth 1 -type f -name 'page_*.pdf' -print | wc -l | tr -d '[:space:]')

if (( BURST_PAGE_COUNT < PAPER_COUNT )); then
    echo "main.pdf has ${BURST_PAGE_COUNT} pages, but ${PAPER_COUNT} paper placeholders are needed." >&2
    exit 1
fi

echo "Extracting last ${PAPER_COUNT} page(s) to pair with papers..."
last_pages=()
start_page=$((BURST_PAGE_COUNT - PAPER_COUNT + 1))
for ((page=start_page; page<=BURST_PAGE_COUNT; page++)); do
    last_pages+=("${BURST_DIR}/page_$(printf "%04d" "$page").pdf")
done

echo "Removing last ${PAPER_COUNT} page(s) from main.pdf..."
keep_until=$((start_page - 1))
if (( keep_until < 1 )); then
    echo "main.pdf does not have enough pages to remove ${PAPER_COUNT} placeholder page(s)." >&2
    exit 1
fi
pdftk "$MAIN_PDF" cat 1-"$keep_until" output "$MAIN_TRIMMED"

echo "Scaling original papers to A4..."
scaled_files=()
for paper_basename in "${PAPERS[@]}"; do
    paper_path="${ROOT_DIR}/paper/${paper_basename}.pdf"
    if [[ ! -f "$paper_path" ]]; then
        echo "Missing paper PDF: $paper_path" >&2
        exit 1
    fi
    scaled_output="${BUILD_DIR}/${paper_basename}-scaled.pdf"
    gs -o "$scaled_output" -sDEVICE=pdfwrite -sPAPERSIZE=a4 -dPDFFitPage "$paper_path"
    scaled_files+=("$scaled_output")
done

final_files=("$MAIN_TRIMMED")
for ((i=0; i<PAPER_COUNT; i++)); do
    final_files+=("${last_pages[i]}")
    final_files+=("${scaled_files[i]}")
done

echo "Merging papers..."
pdftk "${final_files[@]}" cat output "$MERGED_PDF"

echo "Restoring Table of Contents..."
pdftk "$MERGED_PDF" update_info_utf8 "$BOOKMARKS_FILE" output "$FINAL_PDF"

echo "Done! Build artifacts are in $BUILD_DIR and can be cleaned with make clean."
