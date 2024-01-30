
process SVANALYZER_SVBENCHMARK {
    tag "$meta.id $meta2.caller"
    label 'process_medium'

    conda "bioconda::svanalyzer=0.35"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/svanalyzer:0.35--pl526_0':
        'quay.io/biocontainers/svanalyzer:0.35--pl526_0' }"

    input:
    tuple val(meta),val(meta2), path(test), path(test_index), path(truth), path(truth_index)
    tuple path(fasta), path(fai)
    path(bed)

    output:
    tuple val(meta), path("*.falsenegatives.vcf"), emit: fns
    tuple val(meta), path("*.falsepositives.vcf"), emit: fps
    tuple val(meta), path("*.distances")         , emit: distances
    tuple val(meta), path("*.log")               , emit: log
    tuple val(meta), path("*.report")            , emit: report
    path "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def bed = bed ? "-includebed $bed" : ""
    def VERSION = '0.35' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    svanalyzer \\
        benchmark \\
        $args \\
        --ref $fasta \\
        --test $test \\
        --truth $truth \\
        --prefix $prefix \\
        $bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        svanalyzer: ${VERSION}
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = '0.35' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    touch ${prefix}.falsenegatives.vcf
    touch ${prefix}.falsepositives.vcf
    touch ${prefix}.distances
    touch ${prefix}.log
    touch ${prefix}.report

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        svanalyzer: ${VERSION}
    END_VERSIONS
    """
}
