#!/bin/bash
set -e

echo "=== Installing Java ==="
sudo apt-get update
sudo apt-get install -y default-jre unzip wget tmux htop

echo "=== Installing Nextflow ==="
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

echo "=== Installing Trim Galore ==="
pip install cutadapt
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/0.6.10.tar.gz | tar xz
sudo mv TrimGalore-0.6.10/trim_galore /usr/local/bin/

echo "=== Installing FastQC ==="
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip
unzip fastqc_v0.12.1.zip
chmod +x FastQC/fastqc
sudo mv FastQC /opt/fastqc
sudo ln -s /opt/fastqc/fastqc /usr/local/bin/fastqc
rm fastqc_v0.12.1.zip

echo "=== Installing STAR ==="
wget https://github.com/alexdobin/STAR/releases/download/2.7.11b/STAR_2.7.11b.zip
unzip STAR_2.7.11b.zip
sudo mv STAR_2.7.11b/Linux_x86_64_static/STAR /usr/local/bin/
rm -rf STAR_2.7.11b.zip STAR_2.7.11b

echo "=== Installing featureCounts ==="
wget https://sourceforge.net/projects/subread/files/subread-2.0.6/subread-2.0.6-Linux-x86_64.tar.gz
tar xzf subread-2.0.6-Linux-x86_64.tar.gz
sudo mv subread-2.0.6-Linux-x86_64/bin/featureCounts /usr/local/bin/
rm -rf subread-2.0.6-Linux-x86_64.tar.gz subread-2.0.6-Linux-x86_64

echo "=== Verifying tools ==="
for tool in nextflow trim_galore fastqc STAR featureCounts; do
  echo -n "$tool: "; which $tool && $tool --version 2>&1 | head -1
done

echo "=== Setup complete ==="
