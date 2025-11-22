#!/usr/bin/env nextflow

/*
 * Pipeline to build GEMs from genome FASTA files using gapseq and CarveMe
 * 
 * Author: Your Name
 * Date: 20 November 2025
 */

nextflow.enable.dsl=2

// Pipeline parameters
params.genome = null
params.outdir = "./results"
params.help = false

// Show help message
def helpMessage() {
    log.info"""
    Usage:
    nextflow run main.nf --genome <genome.fasta> [options]

    Required arguments:
      --genome          Path to genome FASTA file(s). Accepts glob patterns (e.g., "genomes/*.fasta")

    Optional arguments:
      --outdir          Output directory (default: ${params.outdir})
      --help            Show this help message
    """.stripIndent()
}

if (params.help) {
    helpMessage()
    exit 0
}

// Validate required parameters
if (!params.genome) {
    log.error "ERROR: --genome parameter is required"
    helpMessage()
    exit 1
}

/*
 * Process: Run gapseq on each genome
 */
process RUN_GAPSEQ {
	container 'quay.io/biocontainers/gapseq:1.4.0--h9ee0642_1'
    publishDir "${params.outdir}/gapseq", mode: 'copy'
	cpus = { 1 * task.attempt }
	memory = '8.GB'
	time = { 4.h * task.attempt }
	errorStrategy {  task.exitStatus in [143,137,104,134,139,255] ? 'retry' : 'finish' }
	maxRetries = 2
	maxForks 30

    input:
    path genome
    
    output:
    path "*", emit: gapseq_results
    
    script:
    """
    # Run gapseq on the genome
    gapseq doall ${genome} \
	 -K $task.cpus
    """
}

/*
 * Process: Predict genes with Prodigal
 */
process PREDICT_GENES { 
    container 'quay.io/biocontainers/prodigal:2.6.3--h031d066_9'
    cpus = 1
    memory = '6.GB'
    time = { 4.h * task.attempt }
	errorStrategy {  task.exitStatus in [143,137,104,134,139,255] ? 'retry' : 'finish' }
	maxRetries = 2
	maxForks 30


    input:
    path genome
    
    output:
    path "*.faa", emit: proteins
    
    script:
    def basename = genome.getBaseName()
    """
    prodigal -i ${genome} \
        -a ${basename}.faa \
        -f gff \
        -o ${basename}.gff
    """
}

/*
 * Process: Run CarveMe to build GEMs
 */
process RUN_CARVEME {
    container 'docker://ryanboobybiome/carveme:latest'
    publishDir "${params.outdir}/carveme", mode: 'copy'
    cpus = 2
    memory = '6.GB'
    errorStrategy {  task.exitStatus in [143,137,104,134,139,255] ? 'retry' : 'finish' }
    maxRetries = 2
    time = { 4.h * task.attempt }
	maxForks 10

    input:
    path proteins
    
    output:
    path "*.xml", emit: gem_models
    
    script:
    def basename = proteins.getBaseName()
    """
    carve ${proteins} \
        -o ${basename}.xml 
    """
}

/*
 * Workflow
 */
workflow {
    // Create channel from genome file(s)
    mags_ch = Channel.fromPath(params.genome, checkIfExists: true)
    
    // Run gapseq on each genome
    RUN_GAPSEQ(mags_ch)
    
    // Run CarveMe workflow: predict genes then build GEMs
    //PREDICT_GENES(mags_ch)
    //RUN_CARVEME(PREDICT_GENES.out.proteins)
    
    // Log completion
    RUN_GAPSEQ.out.gapseq_results.flatten().view { result ->
        log.info "Gapseq output: ${result}"
    }
    
    //RUN_CARVEME.out.gem_models.view { model ->
    //    log.info "CarveMe GEM model: ${model}"
    //}
}

workflow.onComplete {
    log.info "Pipeline completed at: ${workflow.complete}"
    log.info "Execution status: ${workflow.success ? 'Success' : 'Failed'}"
    log.info "Duration: ${workflow.duration}"
}

