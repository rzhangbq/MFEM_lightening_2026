#!/usr/bin/env bash
# Export MFEM_PIC_LIGHTNING_MARP.md to HTML and PDF.
# Usage: ./export_marp.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/MFEM_PIC_LIGHTNING_MARP.md"
HTML="$ROOT/MFEM_PIC_LIGHTNING_MARP.html"
PDF="$ROOT/MFEM_PIC_LIGHTNING_MARP.pdf"

if [[ ! -f "$SRC" ]]; then
  echo "error: missing $SRC" >&2
  exit 1
fi

if command -v marp >/dev/null 2>&1; then
  marp_cmd=(marp)
else
  marp_cmd=(npx --yes @marp-team/marp-cli)
fi

common=(--html --allow-local-files)

echo "HTML: $HTML"
"${marp_cmd[@]}" "${common[@]}" "$SRC" -o "$HTML"

echo "PDF:  $PDF"
"${marp_cmd[@]}" "${common[@]}" --pdf --pdf-outlines "$SRC" -o "$PDF"

echo "Done."
