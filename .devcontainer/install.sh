#!/bin/bash
set -e

# Java
curl -s "https://get.sdkman.io" | bash
source ~/.sdkman/bin/sdkman-init.sh
sdk install java 17.0.10-tem

# All bioinformatics tools via conda
conda install -y -c bioconda -c conda-forge \
  fastqc multiqc star subread \
  snippy spades iqtree trimmomatic

# Cutadapt
pip install cutadapt

# TrimGalore
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.10.tar.gz | tar xz
mv TrimGalore-0.6.10/trim_galore /usr/local/bin/

# Nextflow
wget -qO- https://get.nextflow.io | bash
mv nextflow /usr/local/bin/

echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
echo 'source ~/.sdkman/bin/sdkman-init.sh' >> ~/.bashrc
