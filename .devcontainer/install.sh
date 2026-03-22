#!/bin/bash
set -e
conda install -y -c bioconda -c conda-forge subread multiqc openjdk=17 star
pip install cutadapt
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.10.tar.gz | tar xz
mv TrimGalore-0.6.10/trim_galore /usr/local/bin/
wget -qO- https://get.nextflow.io | bash
mv nextflow /usr/local/bin/
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
