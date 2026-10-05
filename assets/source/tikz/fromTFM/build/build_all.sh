#!/usr/bin/env bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/exported/pdf"
for f in "$ROOT"/standalone/*_standalone.tex; do
  echo "[BUILD] $(basename "$f")"
  latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory="$ROOT/exported/pdf" "$f"
done
