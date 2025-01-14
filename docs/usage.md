# nf-core/variantbenchmarking: Usage

## :warning: Please read this documentation on the nf-core website: [https://nf-co.re/variantbenchmarking/usage](https://nf-co.re/variantbenchmarking/usage)

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction

<!-- TODO nf-core: Add documentation about anything specific to running your pipeline. For general topics, please point to (and add to) the main nf-core website. -->

Given test vcfs in samplesheet.csv, this pipelines compares them to truth vcf provided with params.truth_vcf.

params.variant*type can be "small" or "structural" for params.analysis of "germline" or params.variant_type can be "snv", "indel" or "structural" for params.analysis of "somatic". Please be aware that \_only one type of varian_analysis is possible for each run*.

## Samplesheet input

You will need to create a samplesheet with information about the test vcf you would like to analyze before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 3 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

### Full samplesheet

The samplesheet can have as many columns as you desire, however, there is a strict requirement for the first 3 columns to match those defined in the table below.

```csv title="samplesheet.csv"
id,test_vcf,caller
test1,test1.vcf.gz,delly
test2,test2.vcf,gatk
test3,test3.vcf.gz,cnvkit
```

| Column     | Description                                                                                                                                     |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`       | Custom id name per test vcf. This entry will be identical.                                                                                      |
| `test_vcf` | The VCF file to use as benchmarking test input. The same file can be used in more than one row. File can be either vcf or vcf.gz.               |
| `caller`   | Variant caller method used to generate test VCF file. There can be more than one test vcf for the same caller. For unknown caller use 'unknown' |

An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline.

## Truth samples

Please find the detailed information about truth samples [here](../docs/truth.md).

## Lifting over truth sets

This workflow comes with a liftover option for truth sets. In order to activate liftover use `--liftover "truth"`.

- `--chain`: This workflow uses picard tools for lifting over and a chain file has to be provided specific to the input truth vcf. Some examples can be found [here](https://genome.ucsc.edu/goldenPath/help/chain.html)
- `--rename_chr`: Renaming chromosomes is required after liftover process. Some examples can be found under `assets/rename_contigs` directory.
- `--dictionary`: .dict file is required to run liftover process. If dictionary file is not provided, picard createsequencedictionary will create and use the file.

## Lifting over test sets

Lifting over test samples is also possible through this pipeline, if you want to liftover at least one of the samples first use `--liftover "test"` and add liftover option to samplesheet:

```csv title="samplesheet.csv"
id,test_vcf,caller,liftover
test1,test1.vcf.gz,delly,true
test2,test2.vcf,gatk,false
test3,test3.vcf.gz,cnvkit,true
```

Please note that you should still provide chain and reame_chr files, and lifting over truth and test samples simultaneously is not possible.

## Standardization and normalization parameters

Consistent formatting and alignment of variants in test and truth VCF files for accurate comparison is controlled by _sv_standardization_ and _preprocesses_.

- `--sv_standardization`: The standardization methods to perform on the input files. Should be a comma-separated list of one or more of the following options: `homogenize,svync`.

  - `homogenize`: makes use of [variant-extractor](https://github.com/EUCANCan/variant-extractor)
  - `svync`: makes use of [svync](https://github.com/nvnieuwk/svync)

- `--preprocesses`: The preprocessing steps to perform on the input files. Should be a comma-separated list of one or more of the following options: `normalization,deduplication,prepy,filter_contigs`
  - `normalization`: Splits multi-allelic variants in test and truth VCF files ([bcftools norm](https://samtools.github.io/bcftools/bcftools.html#norm))
  - `deduplication`: Deduplicates variants in test and truth VCF files ([bcftools norm](https://samtools.github.io/bcftools/bcftools.html#norm))
  - `prepy`: Uses prepy in order to normalize test files. This option is only applicable for happy benchmarking of germline analysis ([prepy](https://github.com/Illumina/hap.py/tree/master))
  - `filter_contigs`: Filter out extra contigs. It is common for truth files not to include extra contigs.

## Using multi-sample vcf inputs

If the input test vcf contains more than one sample, then user has to define which sample name to use. `subsample` will added to the samplesheet as an additional column as follows:

```csv title="samplesheet.csv"
id,test_vcf,caller,subsample
test1,test1.vcf.gz,delly,"TUMOR"
test2,test2.vcf,gatk,"NA128120"
test3,test3.vcf.gz,cnvkit,
```

Note that, this option can be inevitable for somatic analysis since most of the callers reports both normal and tumor genotypes in the same vcf file.

## Optional benchmarking parameters

Benchmarking parameters may vary between the tools and for callers. In order to use the same parameters for all callers be sure to write the same value for all. If noting provided, deafault values will be used.

_SVbenchmark_

```csv title="samplesheet.csv"
id,test_vcf,caller,normshift,normdist,normsizediff,maxdist
test1,test1.vcf.gz,delly,0.7,0.7,0.7,100000
test2,test2.vcf,gatk,0.6,0.5,0.7,110000
```

- `normshift`: Has to be between 0-1. Disallow matches if alignments between alternate alleles have normalized shift greater than normshift (default 0.2)
- `normdist`: Has to be between 0-1. Disallow matches if alternate alleles have normalized edit distance greater than normdist (default 0.2)
- `normsizediff`: Has to be between 0-1. Disallow matches if alternate alleles have normalized size difference greater than normsizediff (default 0.2)
- `maxdist`: Disallow matches if positions of two variants are more than maxdist bases from each other (default 100,000)

_Truvari_

```csv title="samplesheet.csv"
id,test_vcf,caller,pctsize,pctseq,pctovl,refdist,chunksize,dup_to_ins,typeignore
test1,test1.vcf.gz,delly,0.7,0.7,0.7,100000,50000,true,true
test2,test2.vcf,gatk,0.6,0.5,0.7,110000,40000,false,true
```

- `pctsize`: Has to be between 0-1. Ratio of min(base_size, comp_size)/max(base_size, comp_size)
- `pctseq`: Has to be between 0-1. Edit distance ratio between the REF/ALT haplotype sequences of base and comparison call. Turn it off (0) for no sequence comparison.
- `pctovl`: Has to be between 0-1. Ratio of two calls' (overlapping bases)/(longest span)
- `refdist`: Maximum distance comparison calls must be within from base call's start/end
- `chunksize`: Create chunks of all calls overlapping within ±chunksize basepairs
- `dup_to_ins`: Converts DUP to INS type (boolean)
- `typeignore`: Ignore SVTYPE matching (boolean)

_Wittyer_

```csv title="samplesheet.csv"
id,test_vcf,caller,vartype,bpDistance,percentThreshold,absoluteThreshold,maxMatches,evaluationmode
test1,test1.vcf.gz,delly,sv,200,0.5,17000,100,sc
test2,test2.vcf,gatk,sv,100,0.5,11000,-1,cts
```

- `bpDistance`: Upper bound of boundary distance when comparing truth and query. By default it is 500bp for all types except for Insertions, which are 100bp.Please note that if you set this value in the command line, it overrides all the defaults, so Insertions and other types will have the same bpd.
- `percentThreshold`: This is used for percentage thresholding. For CopyNumberTandemRepeats, this determines how large of a RepeatUnitCount (RUC) threshold to use for large tandem repeats. For all other SVs, in order to match between query and truth, the distance between boundaries should be within a number thats proportional to total SV (default 0.25)
- `absoluteThreshold`: This is used for absolute thresholding. For CopyNumberTandemRepeats, this determines how large of a RepeatUnitCount (RUC) threshold to use. For all other SVs, this is the upper bound of boundary distance when comparing truth and query. (default 10000)
- `maxMatches`: axMatches is a wittyer parameter. This is used for matching behaviour. Negative value means to match any number (for large SVs it is not recommended).
- `evaluationmode`: It is by default requires genotype matching. simpleCounting:sc, CrossTypeAndSimpleCounting:cts, genotypematch:d

## Filtering parameters

- `--exclude_expression`: Use [bcftools expressions](https://samtools.github.io/bcftools/bcftools.html#expressions) to exclude variants. Default:null
- `--include_expression`: Use [bcftools expressions](https://samtools.github.io/bcftools/bcftools.html#expressions) to include variants. Default:null

_Parameters applicable only to Structural Variants_

- `--min_sv_size`: Minimum SV size of variants to benchmark, 0 to disable , Default:30
- `--max_sv_size`: Maximum SV size of variants to benchmark, -1 to disable , Default:-1
- `--min_allele_freq`: Minimum Alele Frequency of variants to benchmark, Use -1 to disable , Default:-1
- `--min_num_reads`: Minimum number of read supporting variants to benchmark, Use, -1 to disable , Default:-1

## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run nf-core/variantbenchmarking --input ./samplesheet.csv --outdir ./results -profile docker --genome GRCh37 --sample HG002 --analysis germline --variant_type small
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run nf-core/variantbenchmarking -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: './samplesheet.csv'
outdir: './results/'
genome: 'GRCh37'
sample: 'HG002'
analysis: 'germline'
<...>
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull nf-core/variantbenchmarking
```

### Reproducibility

It is a good idea to specify the pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [nf-core/variantbenchmarking releases page](https://github.com/nf-core/variantbenchmarking/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, at the bottom of the MultiQC reports.

To further assist in reproducibility, you can use share and reuse [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

> [!TIP]
> If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to check if your system is supported, please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `test_full`
  - A profile with a complete configuration for full size of sample testing
  - Includes links to test data so needs no other parameters
- `liftover_test`
  - A profile with a complete configuration for using liftover of HG002 hg38 test set to hg37
  - Includes links to test data so needs no other parameters
- `liftover_truth`
  - A profile with a complete configuration for using liftover of HG002 hg37 truth set to hg38
  - Includes links to test data so needs no other parameters
- `germline_small`
  - A profile with a complete configuration for germline analysis with small variat type of data
  - Includes links to test data so needs no other parameters
- `germline_structural`
  - A profile with a complete configuration for germline analysis with structural variat type of data
  - Includes links to test data so needs no other parameters
- `somatic_structural`
  - A profile with a complete configuration for somatic analysis with structural variat type of data
  - Includes links to test data so needs no other parameters
- `somatic_snv`
  - A profile with a complete configuration for somatic analysis with snv variat type of data
  - Includes links to test data so needs no other parameters
- `somatic_indel`
  - A profile with a complete configuration for somatic analysis with indel variat type of data
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

### nf-core/configs

In most cases, you will only need to create a custom config as a one-off but if you and others within your organisation are likely to be running nf-core pipelines regularly and need to use the same settings regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter. You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

See the main [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for more information about creating your own configuration files.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack) on the [`#configs` channel](https://nfcore.slack.com/channels/configs).

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
