#!/bin/bash
# ============================================================
#  check_tools.sh — Run this at the start of every Codespace
#  session to confirm your bioinformatics tools are ready.
# ============================================================

echo ""
echo "==============================="
echo "  Bioinformatics Tools Status  "
echo "==============================="
echo ""

check_tool() {
  local name="$1"
  local cmd="$2"
  local version_flag="${3:---version}"

  if command -v "$cmd" &>/dev/null; then
    VERSION=$("$cmd" $version_flag 2>&1 | head -n1 | grep -oP '[\d]+\.[\d]+[\.\d]*' | head -n1)
    printf "  %-12s ✅  %s\n" "$name" "${VERSION:-found}"
  else
    printf "  %-12s ❌  NOT FOUND\n" "$name"
    MISSING=1
  fi
}

MISSING=0

check_tool "FastQC"   "fastqc"   "--version"
check_tool "MultiQC"  "multiqc"  "--version"
check_tool "Nextflow" "nextflow" "-version"
check_tool "SPAdes"   "spades.py" "--version"
check_tool "Snippy"   "snippy"   "--version"
check_tool "IQ-TREE"  "iqtree2"  "--version"

echo ""

if [ "$MISSING" -eq 1 ]; then
  echo "  ⚠️  Some tools are missing."
  echo "  Run:  bash setup_bioinformatics.sh"
else
  echo "  🎉 All tools are ready to use!"
fi

echo ""
