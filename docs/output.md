# nf-core/variantbenchmarking: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarizes results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Preprocesses ](#preprocesses)
- [Liftover of truth sets](#liftover)
- [Input vcf statistics](#stats)
- [Benchmarking](#benchmarks)
  - [Truvari](#truvari)
  - [SVanalyzer](#svanalyzer)
  - [Wittyer](#wittyer)
  - [RTG-tools](#rtgtools)
  - [Happy](#happy)
  - [Sompy](#sompy)
- [Summary statistics](#summary)
  - [Comparison of benchmarking results](#comparisons)
  - [Merged summary benchmark statistics](#tables)
  - [Plots](#plots)
  - [datavzrd HTML reports](#datavzrd)
- [MultiQC](#multiqc) - Aggregate report describing results and QC from the whole pipeline
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### Preprocesses

<details markdown="1">
<summary>Output files</summary>

- `preprocesses/`
  - `*.vcf.gz`: The standardized and normalized VCF files

</details>

Outputs from standardization, normalization and filtration processes saved. When any of `--sv_standardization`, `--preprocesses` or filtration applied to the input set of variants, the processed outputs will be saved into this directory.

### Liftover of truth sets

<details markdown="1">
<summary>Output files</summary>

- ## `liftover/`

- `liftover/`
  - `*.vcf.gz`: Lifted over variants
  - `*.bed`: Lifted over regions

</details>

If liftover applied to the truth set, the lifted over golden set variants (vcf.gz) and high confidence bed file saved here.

### Input VCF statistics

<details markdown="1">
<summary>Output files</summary>

- `stats/`
  - `bcftools/`
    - '\*.bcftools_stats.txt'
  - `survivor/`
    - '\*.stats'

</details>

bcftools stats applied into all variant types while survivor stats is only available for structural variants.

### Benchmarking

<details markdown="1">
<summary>Output files</summary>

- `truvari/`
  - `*.fn.vcf.gz` : False negative calls from comparison
  - `*.fn.vcf.gz.tbi` : False negative calls from comparison - index file
  - `*.fp.vcf.gz`: False positive calls from comparison
  - `*.fp.vcf.gz.tbi`: False positive calls from comparison - index file
  - `*.tp-comp.vcf.gz`: True positive calls from the comparison VCF
  - `*.tp-comp.vcf.gz.tbi`: True positive calls from the comparison VCF - index file
  - `*.tp-base.vcf.gz`: True positive calls form the base VCF
  - `*.tp-base.vcf.gz.tbi`: True positive calls form the base VCF - index file
  - `*.summary.json`: Json output of performance stats
- `svanalyzer/`
  - `*.distances`: Distances for comparisons
  - `*.falsenegatives.vcf.gz` : False negative calls from comparison
  - `*.falsepositives.vcf.gz`: False positive calls from comparison
  - `*.log`: Log of the run
  - `*.report`: Output report of performance stats
- `wittyer/`
  - `*.vcf.gz`: Calls from comparison
  - `*.vcf.gz.tbi`: Calls from comparison - index file
  - `*.json`: Json output of performance stats
- `rtgtools/`
  - `*.vcf.gz`: Calls from comparison
  - `*.vcf.gz.tbi`: Calls from comparison - index file
  - `*.fn.vcf.gz` : Contains variants from the baseline VCF which were not correctly called
  - `*.fn.vcf.gz.tbi` : Contains variants from the baseline VCF which were not correctly called - index file
  - `*.fp.vcf.gz`: Contains variants from the calls VCF which do not agree with baseline variants
  - `*.fp.vcf.gz.tbi`: Contains variants from the calls VCF which do not agree with baseline variants - index file
  - `*.tp.vcf.gz`: Contains those variants from the calls VCF which agree with variants in the baseline VCF
  - `*.tp.vcf.gz.tbi`: Contains those variants from the calls VCF which agree with variants in the baseline VCF - index file
  - `*.tp-baseline.vcf.gz`: Contains those variants from the baseline VCF which agree with variants in the calls VCF
  - `*.tp-baseline.vcf.gz.tbi`: Contains those variants from the baseline VCF which agree with variants in the calls VCF - index file
  - `*.non_snp_roc.tsv.gz`: Contains ROC data derived from those variants which were not represented as SNPs
  - `*.phasing.txt`: Contains phasing information
  - `*.snp_roc.tsv.gz`: Contains ROC data derived from only those variants which were represented as SNPs
  - `*.summary.txt`: Output summary of performance stats
  - `*.weighted_roc.tsv.gz`: Contains ROC data derived from all analyzed call variants, regardless of their representation
- `happy/`
  - `*.extended.csv`: Extended statistics
  - `*.metrics.json.gz`: JSON file containing all computed metrics and tables
  - `*.roc.all.csv.gz`: All precision / recall data points that were calculated
  - `*.roc.Locations.INDEL.csv.gz`: ROC for ALL indels only.
  - `*roc.Locations.INDEL.PASS.csv.gz`: ROC for PASSing indels only.
  - `*roc.Locations.SNP.csv.gz`: ROC for ALL SNPs only.
  - `*roc.Locations.SNP.PASS.csv.gz`: ROC for PASSing SNPs only.
  - `*.runinfo.json`: Log of the run
  - `*.summary.csv`: Output summary of performance stats
  - `*.vcf.gz`: Calls from comparison
  - `*.vcf.gz.tbi`: Calls from comparison - index file
- `sompy/`
  - `*.features.csv`: Calls from comparison
  - `*.metrics.json`: JSON file containing all computed metrics and tables
  - `*.stats.csv`: Output summary of performance stats

</details>

Benchmark results are created separately for each test vcf and for each method used.

### Summary statistics

<details markdown="1">
<summary>Output files</summary>

- `comparisons/`
  - `small/`
    - `rtgtools.small.FN.csv`: Summarizes and compares variants from the baseline VCF of rtgtools which were not correctly called
    - `rtgtools.small.FP.csv`: Summarizes and compares variants from the calls VCF of rtgtools which do not agree with baseline variant
    - `rtgtools.small.TP_base.csv`: Summarizes and compares variants from the baseline VCF of rtgtools which were correctly called
    - `rtgtools.small.TP_comp.csv`: Summarizes and compares variants from the calls VCF of rtgtools which do agree with baseline variant
  - `sv/`
    - `svbenchmark.sv.FN.csv`: Summarizes and compares variants from the baseline VCF of svbenchmark which were not correctly called
    - `svbenchmark.sv.FP.csv`: Summarizes and compares variants from the calls VCF of svbenchmark which do not agree with baseline variant
    - `truvari.sv.FN.csv`: Summarizes and compares variants from the baseline VCF of truvari which were not correctly called
    - `truvari.sv.FP.csv`: Summarizes and compares variants from the calls VCF of truvari which do not agree with baseline variant
    - `truvari.sv.TP_base.csv`: Summarizes and compares variants from the baseline VCF of truvari which were correctly called
    - `truvari.sv.TP_comp.csv`: Summarizes and compares variants from the calls VCF of truvari which do agree with baseline variant
- `plots/`
  - `cnv/`
    - `wittyer/`
      - `Base_metric_by_tool_wittyer.png`: Summary plot for callers on precision, recall and F1 per base in wittyer
      - `Base_variants_by_tool_wittyer.png`: Summary plot for callers on TP, FP and FN numbers per base in wittyer
      - `Event_metric_by_tool_wittyer.png`: Summary plot for callers on precision, recall and F1 per event in wittyer
      - `Event_variants_by_tool_wittyer.png`: Summary plot for callers on TP, FP and FN numbers per ecent in wittyer
  - `sv/`
    - `truvari/`
      - `metric_by_tool_truvari.png`: Summary plot for callers on precision, recall and F1 in truvari
      - `variants_by_tool_truvari.png`: Summary plot for callers on TP, FP and FN numbers in truvari
    - `svbenchmark/`
      - `metric_by_tool_svbenchmark.png`: Summary plot for callers on precision, recall and F1 in svbenchmark
      - `variants_by_tool_svbenchmark.png`: Summary plot for callers on TP, FP and FN numbers in svbenchmark
  - `small/`
    - `happy/`
      - `INDEL_ALL_metric_by_tool_happy.png`: Summary plot for callers on precision, recall and F1 of all INDELs in happy
      - `INDEL_ALL_variants_by_tool_happy.png`: Summary plot for callers on TP, FP and FN numbers of all INDELs in happy
      - `INDEL_PASS_metric_by_tool_happy.png`: Summary plot for callers on precision, recall and F1 of only PASSed INDELs in happy
      - `INDEL_PASS_variants_by_tool_happy.png`: Summary plot for callers on TP, FP and FN numbers of only PASSed INDELs in happy
      - `SNP_ALL_metric_by_tool_happy.png`: Summary plot for callers on precision, recall and F1 of all SNPs in happy
      - `SNP_ALL_variants_by_tool_happy.png`: Summary plot for callers on TP, FP and FN numbers of all SNPs in happy
      - `SNP_PASS_metric_by_tool_happy.png`: Summary plot for callers on precision, recall and F1 of only PASSed SNPs in happy
      - `SNP_PASS_variants_by_tool_happy.png`: Summary plot for callers on TP, FP and FN numbers of only PASSed SNPs in happy
    - `rtgtools/`
      - `metric_by_tool_rtgtools.png`: Summary plot for callers on precision, recall and F1 in rtgtools
      - `variants_by_tool_rtgtools.png`: Summary plot for callers on TP, FP and FN numbers in rtgtools
  - `indel/`
    - `sompy/`
      - `metric_by_tool_sompy.png`: Summary plot for callers on precision, recall and F1 of indels in sompy
      - `variants_by_tool_sompy.png`: Summary plot for callers on TP, FP and FN numbers of indels in sompy
  - `snv/`
    - `sompy/`
      - `metric_by_tool_sompy.png`: Summary plot for callers on precision, recall and F1 of SNVs in sompy
      - `variants_by_tool_sompy.png`: Summary plot for callers on TP, FP and FN numbers of SNVs in sompy
- `tables/`
  - `cnv/`
    - `wittyer.cnv.summary.csv`: Summary of performance stats from callers
  - `sv/`
    - `truvari.sv.summary.csv`: Summary of performance stats from callers
    - `svbenchmark.sv.summary.csv`: Summary of performance stats from callers
  - `small/`
    - `happy.sv.summary.csv`: Summary of performance stats from callers
    - `rtgtools.sv.summary.csv`: Summary of performance stats from callers
  - `indel/`
    - `sompy.indel.summary.csv`: Summary of performance stats from callers
    - `sompy.indel.regions.csv`: Summary of performance stats split by region bins from callers
  - `snv/`
    - `sompy.snv.summary.csv`: Summary of performance stats from callers
    - `sompy.snv.regions.csv`: Summary of performance stats split by region bins from callers
- ## `datavzrd/`

</details>
<summary>Output files</summary>

- benchmark tool
  - static
  - test
  - index.html: HTML file to open in the browser for datavzrd spedific tables and visualizations.

### References

<details markdown="1">
<summary>Output files</summary>

- `references/`
  - `dictionary`
    - `*.dict`: Dictionary file is the output of PICARD CREATESEQUENCEDICTIONARY. This file can be saved and reused further.
  - `sdf`
    - `*.sdf`: Sdf file is the output of RTGTOOLS FORMAT. This file can be saved and reused further.

</details>

Reusable reference files are saved in this directory.

### MultiQC

<details markdown="1">
<summary>Output files</summary>

- `multiqc/`
  - `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
  - `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
  - `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

[MultiQC](http://multiqc.info) is a visualization tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in the report data directory.

Results generated by MultiQC collate pipeline QC from supported tools e.g. FastQC. The pipeline has special steps which also allow the software versions to be reported in the MultiQC output for future traceability. For more information about how to use MultiQC reports, see <http://multiqc.info>.### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
