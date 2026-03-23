#!/bin/bash
# ============================================================
#  Bioinformatics Tool Installer for GitHub Codespaces
#  Tools: FastQC, MultiQC, Nextflow, SPAdes, Snippy, IQ-TREE
#  Run once. Re-running is safe — already-installed tools
#  are skipped automatically.
# ============================================================

set -e
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Add ~/.local/bin to PATH if not already there
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  export PATH="$INSTALL_DIR:$PATH"
fi

echo ""
echo "=============================="
echo "  Bioinformatics Setup Script"
echo "=============================="
echo ""

# ── Helper ──────────────────────────────────────────────────
check_installed() {
  command -v "$1" &>/dev/null
}

# ── 1. System packages (apt) ─────────────────────────────────
echo ">>> Updating apt and installing base dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  default-jdk \
  python3-pip \
  python3-venv \
  wget \
  curl \
  unzip \
  git \
  perl \
  cpanminus \
  libvcftools-perl \
  snp-sites \
  mafft \
  fastp \
  2>/dev/null || true

# ── 2. FastQC ────────────────────────────────────────────────
if check_installed fastqc; then
  echo ">>> FastQC already installed — skipping."
else
  echo ">>> Installing FastQC..."
  wget -q https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip -O /tmp/fastqc.zip
  unzip -q /tmp/fastqc.zip -d "$HOME/.local/"
  chmod +x "$HOME/.local/FastQC/fastqc"
  ln -sf "$HOME/.local/FastQC/fastqc" "$INSTALL_DIR/fastqc"
  echo "    FastQC installed ✓"
fi

# ── 3. MultiQC ───────────────────────────────────────────────
if check_installed multiqc; then
  echo ">>> MultiQC already installed — skipping."
else
  echo ">>> Installing MultiQC..."
  pip3 install --quiet multiqc
  echo "    MultiQC installed ✓"
fi

# ── 4. Nextflow ──────────────────────────────────────────────
if check_installed nextflow; then
  echo ">>> Nextflow already installed — skipping."
else
  echo ">>> Installing Nextflow..."
  wget -q https://get.nextflow.io -O "$INSTALL_DIR/nextflow"
  chmod +x "$INSTALL_DIR/nextflow"
  "$INSTALL_DIR/nextflow" self-update -quiet 2>/dev/null || true
  echo "    Nextflow installed ✓"
fi

# ── 5. SPAdes ────────────────────────────────────────────────
if check_installed spades.py; then
  echo ">>> SPAdes already installed — skipping."
else
  echo ">>> Installing SPAdes..."
  SPADES_VERSION="4.0.0"
  wget -q "https://github.com/ablab/spades/releases/download/v${SPADES_VERSION}/SPAdes-${SPADES_VERSION}-Linux.tar.gz" \
    -O /tmp/spades.tar.gz
  tar -xzf /tmp/spades.tar.gz -C "$HOME/.local/"
  ln -sf "$HOME/.local/SPAdes-${SPADES_VERSION}-Linux/bin/spades.py" "$INSTALL_DIR/spades.py"
  echo "    SPAdes installed ✓"
fi

# ── 6. Snippy ────────────────────────────────────────────────
if check_installed snippy; then
  echo ">>> Snippy already installed — skipping."
else
  echo ">>> Installing Snippy via conda (recommended)..."
  # Try conda/mamba first, fallback to direct install
  if check_installed conda; then
    conda install -y -c bioconda -c conda-forge snippy -q 2>/dev/null && echo "    Snippy installed via conda ✓"
  elif check_installed mamba; then
    mamba install -y -c bioconda -c conda-forge snippy -q 2>/dev/null && echo "    Snippy installed via mamba ✓"
  else
    echo "    conda not found. Installing Snippy dependencies manually..."
    sudo apt-get install -y -qq bwa samtools bcftools freebayes vcflib vt snpeff 2>/dev/null || true
    pip3 install --quiet snippy 2>/dev/null || \
      (git clone --quiet https://github.com/tseemann/snippy.git "$HOME/.local/snippy" && \
       ln -sf "$HOME/.local/snippy/bin/snippy" "$INSTALL_DIR/snippy" && \
       ln -sf "$HOME/.local/snippy/bin/snippy-core" "$INSTALL_DIR/snippy-core")
    echo "    Snippy installed ✓"
  fi
fi

# ── 7. IQ-TREE 2 ─────────────────────────────────────────────
if check_installed iqtree2 || check_installed iqtree; then
  echo ">>> IQ-TREE already installed — skipping."
else
  echo ">>> Installing IQ-TREE 2..."
  IQTREE_VERSION="2.3.6"
  wget -q "https://github.com/iqtree/iqtree2/releases/download/v${IQTREE_VERSION}/iqtree-${IQTREE_VERSION}-Linux-intel.tar.gz" \
    -O /tmp/iqtree.tar.gz
  tar -xzf /tmp/iqtree.tar.gz -C "$HOME/.local/"
  ln -sf "$HOME/.local/iqtree-${IQTREE_VERSION}-Linux-intel/bin/iqtree2" "$INSTALL_DIR/iqtree2"
  echo "    IQ-TREE 2 installed ✓"
fi

# ── Done ─────────────────────────────────────────────────────
echo ""
echo "=============================="
echo "  All tools installed!"
echo "=============================="
echo ""
echo "Reload your shell or run:  source ~/.bashrc"
echo "Then verify with:          bash check_tools.sh"
echo ""
