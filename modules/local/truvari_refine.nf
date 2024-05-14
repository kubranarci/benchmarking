process TRUVARI_REFINE {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://kubran/truvari:v4.3.0':
        'kubran/truvari:v4.3.0' }"

    input:
    tuple val(meta), path(bench)
    each path(bed)
    tuple val(meta2), path(fasta)
    tuple val(meta3), path(fai)

    output:
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    truvari refine \\
        --use-original-vcfs \\
        --reference $fasta \\
        --regions $bed \\
        $bench
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        truvari: \$(echo \$(truvari version 2>&1) | sed 's/^Truvari v//' ))
    END_VERSIONS
    """
}
