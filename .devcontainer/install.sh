#!/bin/bash
set -e
curl -s "https://get.sdkman.io" | bash
source ~/.sdkman/bin/sdkman-init.sh
sdk install java 17.0.10-tem
conda install -y -c bioconda -c conda-forge subread multiqc star fastqc
pip install cutadapt
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.10.tar.gz | tar xz
mv TrimGalore-0.6.10/trim_galore /usr/local/bin/
wget -qO- https://get.nextflow.io | bash
mv nextflow /usr/local/bin/
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
echo 'source ~/.sdkman/bin/sdkman-init.sh' >> ~/.bashrc
