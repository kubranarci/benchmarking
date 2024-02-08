// UNTESTED
process GRIDSS_ANNOTATION {
    tag "$meta.id $meta2.caller"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gridss:2.13.2--h270b39a_0':
        'quay.io/biocontainers/gridss:2.13.2--h270b39a_0' }"

    input:
    tuple val(meta),val(meta2), path(vcf), path(index)
    tuple path(fasta), path(fasta_fai)

    output:
    tuple val(meta),val(meta2), path("*.vcf.gz"),path("*.vcf.gz.tbi")   , emit: vcf
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def genome = params.genome.contains("38") ? "hg38": "hg19" 
    def VERSION = '2.13.2' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    if (meta2.caller == "gridss"){
        """
        bgzip -d $vcf -c > unzziped.vcf
        simple_event-annotator.R \\
            unzziped.vcf \\
            ${prefix}.vcf \\
            ${genome}

        bgzip --threads ${task.cpus} -c ${prefix}.vcf > ${prefix}.anno.vcf.gz
        tabix -p vcf ${prefix}.anno.vcf.gz

        rm unzziped.vcf

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            gridss: ${VERSION}
        END_VERSIONS
        """
    }
    else{
        """
        cp $vcf ${prefix}.vcf.gz
        cp $index ${prefix}.vcf.gz.tbi

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            gridss: ${VERSION}
        END_VERSIONS
        """    

    }

}
