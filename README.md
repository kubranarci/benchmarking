<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/images/nf-core-variantbenchmarking_logo_dark.png">
    <img alt="nf-core/variantbenchmarking" src="docs/images/nf-core-variantbenchmarking_logo_light.png">
  </picture>
</h1>[![GitHub Actions CI Status](https://github.com/nf-core/variantbenchmarking/actions/workflows/ci.yml/badge.svg)](https://github.com/nf-core/variantbenchmarking/actions/workflows/ci.yml)
[![GitHub Actions Linting Status](https://github.com/nf-core/variantbenchmarking/actions/workflows/linting.yml/badge.svg)](https://github.com/nf-core/variantbenchmarking/actions/workflows/linting.yml)[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/variantbenchmarking/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A524.04.2-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/nf-core/variantbenchmarking)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23benchmark-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/variantbenchmarking)[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/nf_core)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**nf-core/variantbenchmarking** is designed to evaluate and validate the accuracy of variant calling methods in genomic research. Initially, the pipeline is tuned well for available gold standard truth sets (for example, Genome in a Bottle and SEQC2 samples) but it can be used to compare any two variant calling results. The workflow provides benchmarking tools for small variants including SNVs and INDELs, Structural Variants (SVs) and Copy Number Variations (CNVs) for germline and somatic analysis.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

<p align="center">
    <img title="variantbenchmarking metro map" src="docs/images/variantbenchmarking_metromap.png" width=50%>
</p>

The workflow involves several key processes to ensure reliable and reproducible results as follows:

### Standardization and normalization of variants:

This initial step ensures consistent formatting and alignment of variants in test and truth VCF files for accurate comparison.

1. Subsample if input test vcf is multisample ([bcftools view](https://samtools.github.io/bcftools/bcftools.html#view))
2. Homogenization of multi-allelic variants, MNPs and SVs (including imprecise paired breakends and single breakends) ([variant-extractor](https://github.com/EUCANCan/variant-extractor))
3. Reformatting test VCF files from different SV callers ([svync](https://github.com/nvnieuwk/svync))
4. Rename sample names in test and truth VCF files ([bcftools reheader](https://samtools.github.io/bcftools/bcftools.html#reheader))
5. Splitting multi-allelic variants in test and truth VCF files ([bcftools norm](https://samtools.github.io/bcftools/bcftools.html#norm))
6. Deduplication of variants in test and truth VCF files ([bcftools norm](https://samtools.github.io/bcftools/bcftools.html#norm))
7. Use prepy in order to normalize test files. This option is only applicable for happy benchmarking of germline analysis ([prepy](https://github.com/Illumina/hap.py/tree/master))
8. Split SNVs and indels if the given test VCF contains both. This is only applicable for somatic analysis ([bcftools view](https://samtools.github.io/bcftools/bcftools.html#view))

### Filtering options:

Applying filtering on the process of benchmarking itself might makes it impossible to compare different benchmarking strategies. Therefore, for whom like to compare benchmarking methods this subworkflow aims to provide filtering options for variants.

9. Filtration of contigs ([bcftools view](https://samtools.github.io/bcftools/bcftools.html#view))
10. Include or exclude SNVs and INDELs ([bcftools filter](https://samtools.github.io/bcftools/bcftools.html#filter))
11. Size and quality filtering for SVs ([SURVIVOR filter](https://github.com/fritzsedlazeck/SURVIVOR/wiki))

### Liftover of vcfs:

This sub-workflow provides option to convert genome coordinates of truth VCF and high confidence BED file to a new assembly. Golden standard truth files are build upon specific reference genomes which makes the necessity of lifting over depending on the test VCF in query. Lifting over one or more test vcfs is also possible.

12. Create sequence dictionary for the reference ([picard CreateSequenceDictionary](https://gatk.broadinstitute.org/hc/en-us/articles/360037068312-CreateSequenceDictionary-Picard)). This file can be saved and reused.
13. Lifting over truth variants ([picard LiftoverVcf](https://gatk.broadinstitute.org/hc/en-us/articles/360037060932-LiftoverVcf-Picard))
14. Lifting over high confidence coordinates ([UCSC liftover](http://hgdownload.cse.ucsc.edu/admin/exe))

### Statistical inference of input test and truth variants:

This step provides insights into the distribution of variants before benchmarking.

15. Get statistics of SNVs, INDELs and complex variants ([bcftools stats](https://samtools.github.io/bcftools/bcftools.html#stats))
16. Get statistics of SVs by type ([SURVIVOR stats](https://github.com/fritzsedlazeck/SURVIVOR/wiki))

### Benchmarking of variants:

Actual benchmarking of variants are split between SVs and small variants:

Available methods for SVs:

17. Germline and somatic variant benchmarking using Truvari ([truvari bench](https://github.com/acenglish/truvari/wiki/bench))
18. Germline and somatic variant benchmarking using SVanalyzer ([svanalyzer benchmark](https://github.com/nhansen/SVanalyzer/blob/master/docs/svbenchmark.rst))

Available methods for CNVs:

19. Germline and somatic variant benchmarking using Wittyer ([witty.er](https://github.com/Illumina/witty.er/tree/master))

Available methods for SNVs and INDELs:

20. Germline variant benchmarking using RTG-tools ([rtg vcfeval](https://realtimegenomics.com/products/rtg-tools))
21. Germline variant benchmarking using Happy tools ([hap.py](https://github.com/Illumina/hap.py/blob/master/doc/happy.md))
22. Somatic variant benchmarking using Sompy ([som.py](https://github.com/Illumina/hap.py/tree/master?tab=readme-ov-file#sompy))

### Comparison of benchmarking results per TP, FP and FN files

It is essential to compare benchmarking results in order to infer uniquely or commonly seen TPs, FPs and FNs.

23. Merging TP, FP and FN results for happy, rtgtools and sompy ([bcftools merge](https://samtools.github.io/bcftools/bcftools.html#merge))
24. Merging TP, FP and FN results for Truvari and SVanalyzer ([SURVIVOR merge](https://github.com/fritzsedlazeck/SURVIVOR/wiki))
25. Conversion of VCF files to CSV to infer common and unique variants per caller (python script)

### Reporting of benchmark results

The generation of comprehensive report that consolidates all benchmarking results.

26. Merging summary statistics per benchmarking tool (python script)
27. Plotting benchmark metrics per benchmarking tool (R script)
28. Create visual HTML report for the integration of NCBENCH ([datavzrd](https://datavzrd.github.io/docs/index.html))

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow.Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
id,test_vcf,caller
test1,test1.vcf.gz,delly
test2,test2.vcf,gatk
test3,test3.vcf.gz,cnvkit
```

Each row represents a vcf file (test-query file). For each vcf file and variant calling method (caller) have to be defined.

User has to define or provide truth vcf in config files. There are readily available vcf files for benchmarking from Genome in a bottle and SEQC2 studies which can be used readily. Please find detailed information about truth files [here](https://nf-co.re/variantbenchmarking/truth)

For more details and further functionality, please refer to the [usage documentation](https://nf-co.re/variantbenchmarking/usage) and the [parameter documentation](https://nf-co.re/variantbenchmarking/parameters).

Now, you can run the pipeline using:

```bash
nextflow run nf-core/variantbenchmarking \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR> \
   --genome GRCh37 \
   --sample HG002
   --analysis germline
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/usage/getting_started/configuration#custom-configuration-files).

## Pipeline output

To see the results of an example test run with a full size dataset refer to the [results](https://nf-co.re/variantbenchmarking/results) tab on the nf-core website pipeline page.
For more details about the output files and reports, please refer to the
[output documentation](https://nf-co.re/variantbenchmarking/output).

This pipeline outputs benchmarking results per method besides to the inferred and compared statistics.

## Credits

nf-core/variantbenchmarking was originally written by Kübra Narcı ([@kubranarci](https://github.com/kubranarci)) as a part of benchmarking studies in German Human Genome Phenome Archieve Project ([GHGA](https://www.ghga.de/)).

We thank the following people for their extensive assistance in the development of this pipeline:

- Nicolas Vannieuwkerke ([@nvnienwk](https://github.com/nvnieuwk)),
- Maxime Garcia ([@maxulysse](https://github.com/maxulysse))

## Acknowledgements

<a href="https://www.ghga.de/">
  <img src="docs/images/GHGA_short_Logo_orange.png" alt="GHGA" width="200"/>
</a>

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#variantbenchmarking` channel](https://nfcore.slack.com/channels/variantbenchmarking) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use nf-core/variantbenchmarking for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) --><!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
