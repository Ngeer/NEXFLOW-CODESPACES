#!/bin/bash
set -e
conda install -y -c bioconda -c conda-forge subread multiqc openjdk=17
wget -qO- https://get.nextflow.io | bash
mv nextflow /usr/local/bin/
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
