# nf_gems - Nextflow Gapseq Pipeline

A Nextflow pipeline to run gapseq on genome FASTA files for metabolic network reconstruction.

## Overview

This pipeline takes one or more genome FASTA files and runs gapseq on each genome to predict metabolic pathways and reconstruct genome-scale metabolic models.

## Requirements

- Nextflow >= 22.10.0
- One of the following:
  - gapseq installed locally
  - Docker
  - Singularity
  - Conda/Mamba

## Quick Start

### Using Docker (recommended)

```bash
# Single genome
nextflow run main.nf \
    --genome genome.fasta \
    --outdir results \
    -profile docker

# Multiple genomes using glob pattern
nextflow run main.nf \
    --genome "genomes/*.fasta" \
    --outdir results \
    -profile docker
```

### Using Conda

```bash
nextflow run main.nf \
    --genome genome.fasta \
    --outdir results \
    -profile conda
```

### Using Singularity

```bash
nextflow run main.nf \
    --genome genome.fasta \
    --outdir results \
    -profile singularity
```

### Local execution (requires gapseq pre-installed)

```bash
nextflow run main.nf \
    --genome genome.fasta \
    --outdir results
```

## Parameters

### Required

- `--genome`: Path to genome FASTA file(s). Supports glob patterns (e.g., `"genomes/*.fasta"`)

### Optional

- `--outdir`: Output directory (default: `./results`)
- `--help`: Display help message

## Profiles

- `standard`: Local execution (default)
- `docker`: Run using Docker containers
- `singularity`: Run using Singularity containers
- `conda`: Use Conda environment
- `slurm`: Submit jobs to SLURM cluster
- `sge`: Submit jobs to SGE cluster

## Output

The pipeline generates:

- All gapseq output files for each genome (pathways, reactions, metabolic models, etc.)
- `pipeline_info/`: Directory containing execution reports and timeline

## Example

```bash
# Run gapseq on a single genome
nextflow run main.nf \
    --genome my_genome.fasta \
    --outdir gapseq_results \
    -profile docker

# Run gapseq on multiple genomes
nextflow run main.nf \
    --genome "genomes/*.fasta" \
    --outdir gapseq_results \
    -profile docker
```

## Resource Configuration

Default resources can be adjusted in `nextflow.config` or overridden on the command line:

```bash
nextflow run main.nf \
    --genome reference.fasta \
    --max_cpus 16 \
    --max_memory 32.GB
```

## Citation

If you use this pipeline, please cite:

- Nextflow: https://doi.org/10.1038/nbt.3820
- gapseq: Zimmermann J, Kaleta C, Waschina S. gapseq: informed prediction of bacterial metabolic pathways and reconstruction of accurate metabolic models. Genome Biol. 2021;22(1):81.

## License

MIT License
