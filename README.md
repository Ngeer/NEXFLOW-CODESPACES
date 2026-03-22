#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.reads  = "fastq/*_chrX_{1,2}.fastq.gz"
params.fasta  = "ref/chrX.fa"
params.gtf    = "ref/chrX.gtf"
params.outdir = "results"

process TRIM_READS {
    publishDir "${params.outdir}/trimmed", mode: 'copy'
    input:
    tuple val(sample), path(r1), path(r2)
    output:
    tuple val(sample), path("*_1_val_1.fq.gz"), path("*_2_val_2.fq.gz")
    script:
    """
    trim_galore --paired ${r1} ${r2}
    """
}

process FASTQC_TRIMMED {
    publishDir "${params.outdir}/fastqc_trimmed", mode: 'copy'
    input:
    tuple val(sample), path(r1), path(r2)
    output:
    path "*"
    script:
    """
    fastqc ${r1} ${r2}
    """
}

process STAR_INDEX {
    publishDir "${params.outdir}/star_index", mode: 'copy'
    memory '6 GB'
    cpus 2
    input:
    path fasta
    path gtf
    output:
    path "star_index"
    script:
    """
    mkdir -p star_index
    STAR \
      --runMode genomeGenerate \
      --genomeDir star_index \
      --genomeFastaFiles ${fasta} \
      --sjdbGTFfile ${gtf} \
      --runThreadN 2 \
      --genomeSAindexNbases 12 \
      --sjdbOverhang 99 \
      --limitGenomeGenerateRAM 6000000000
    """
}

process STAR_ALIGN {
    publishDir "${params.outdir}/aligned", mode: 'copy'
    cpus 1
    memory '6 GB'
    input:
    tuple val(sample), path(r1), path(r2), path(star_index)
    output:
    tuple val(sample), path("${sample}.sorted.bam")
    script:
    """
    STAR \
      --genomeDir ${star_index} \
      --readFilesIn ${r1} ${r2} \
      --readFilesCommand zcat \
      --runThreadN ${task.cpus} \
      --outFileNamePrefix ${sample}. \
      --outSAMtype BAM SortedByCoordinate
    mv ${sample}.Aligned.sortedByCoord.out.bam ${sample}.sorted.bam
    """
}

process FEATURECOUNTS {
    publishDir "${params.outdir}/counts", mode: 'copy'
    input:
    path gtf
    path bam_files
    output:
    path "gene_counts.txt"
    script:
    """
    featureCounts -p -a ${gtf} -o gene_counts.txt ${bam_files.join(' ')}
    """
}

workflow {
    reads_ch = Channel
        .fromFilePairs(params.reads)
        .map { sample, reads -> tuple(sample, reads[0], reads[1]) }

    trimmed_ch = TRIM_READS(reads_ch)
    FASTQC_TRIMMED(trimmed_ch)

    star_index_ch = STAR_INDEX(file(params.fasta), file(params.gtf))

    aligned_ch = trimmed_ch.combine(star_index_ch)
        .map { sample, r1, r2, index -> tuple(sample, r1, r2, index) }

    bam_ch = STAR_ALIGN(aligned_ch)

    bam_files_ch = bam_ch
        .map { sample, bam -> bam }
        .collect()

    FEATURECOUNTS(file(params.gtf), bam_files_ch)
}


# 1. Nextflow
curl -s https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/

# 2. Trim Galore
pip install cutadapt
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/refs/tags/0.6.10.tar.gz | tar xz
sudo mv TrimGalore-0.6.10/trim_galore /usr/local/bin/

# 3. FastQC
sudo apt-get install -y default-jre
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip
unzip fastqc_v0.12.1.zip
chmod +x FastQC/fastqc
sudo mv FastQC /opt/fastqc
sudo ln -s /opt/fastqc/fastqc /usr/local/bin/fastqc

# 4. STAR
wget https://github.com/alexdobin/STAR/releases/download/2.7.11b/STAR_2.7.11b.zip
unzip STAR_2.7.11b.zip
sudo mv STAR_2.7.11b/Linux_x86_64_static/STAR /usr/local/bin/

# 5. featureCounts
wget https://sourceforge.net/projects/subread/files/subread-2.0.6/subread-2.0.6-Linux-x86_64.tar.gz
tar xzf subread-2.0.6-Linux-x86_64.tar.gz
sudo mv subread-2.0.6-Linux-x86_64/bin/featureCounts /usr/local/bin/

# 6. tmux (prevent losing session on disconnect)
sudo apt-get install -y tmux

# 7. Verify all tools
for tool in nextflow trim_galore fastqc STAR featureCounts; do
  echo -n "$tool: "; which $tool && $tool --version 2>&1 | head -1
done


# Keep-alive (run in a separate terminal)
while true; do sleep 240 && echo "keeping awake..."; done

# Start tmux session and run pipeline
tmux new -s pipeline
mkdir -p fastq ref results
nextflow run pipeline.nf -resume


#Install FASTQC TRIM-GALORE STAR SUBREAD FEATURE COUNT
conda install -y -c bioconda -c conda-forge subread multiqc star fastqc && \
pip install cutadapt && \
curl -fsSL https://github.com/FelixKrueger/TrimGalore/archive/0.6.10.tar.gz | tar xz && \
sudo mv TrimGalore-0.6.10/trim_galore /usr/local/bin/ && \
wget -qO- https://get.nextflow.io | bash && \
sudo mv nextflow /usr/local/bin/

#NEXTFLOW
wget -qO- https://get.nextflow.io | bash
sudo mv nextflow /usr/local/bin/
