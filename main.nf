#!/usr/bin/env nextflow

params.reads = 'sample_reads/*_R{1,2}.fastq.gz'
params.outdir = 'spades_results'
nextflow.enable.dsl = 2

process run_spades {
   container ' quay.io/biocontainers/shovill:1.1.0--hdfd78af_1'
   
    tag "${sample_id}"
    publishDir "${params.outdir}/${sample_id}", mode: 'copy'
    input:
        tuple val(sample_id), path(reads), path(reads2)
    output:
        path("spades.log")
        path("contigs.fasta")
        path("scaffolds.fasta")
        path("assembly_graph_after_simplification.gfa")
        path("assembly_graph_with_scaffolds.gfa")
    cpus 8
    memory '8GB'

    script:
    """
    shovill -R1 ${reads} -R2 ${reads2} -outdir . --cpus 8
    """
}

def get_sample_id(file) {
    def name = file.getBaseName()
    def m = name =~ /^(.+)_R[12]\.fastq\.gz$/
    return m ? m[0][1] : null
}


Channel
    .fromFilePairs(params.reads, flat: true)
    .set { read_pairs }


workflow {
    run_spades(read_pairs)

}
