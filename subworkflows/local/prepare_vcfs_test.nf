//
// PREPARE_VCFS: SUBWORKFLOW TO PREPARE INPUT VCFS
//

params.options = [:]
include { VCF_VARIANT_DEDUPLICATION } from '../local/vcf_variant_deduplication'     addParams( options: params.options )
include { VCF_VARIANT_FILTERING     } from '../local/vcf_variant_filtering'         addParams( options: params.options )
include { BGZIP_TABIX               } from '../../modules/local/bgzip_tabix'        addParams( options: params.options )
include { BCFTOOLS_VIEW             } from '../../modules/local/bcftools_view'      addParams( options: params.options )
include { BCFTOOLS_SORT             } from '../../modules/nf-core/bcftools/sort'    addParams( options: params.options )
include { HAPPY_PREPY               } from '../../modules/nf-core/happy/prepy/main' addParams( options: params.options )
include { BCFTOOLS_NORM             } from '../../modules/nf-core/bcftools/norm'    addParams( options: params.options )
include { TABIX_TABIX   as TABIX_TABIX_1         } from '../../modules/nf-core/tabix/tabix'       addParams( options: params.options )
include { TABIX_TABIX   as TABIX_TABIX_3         } from '../../modules/nf-core/tabix/tabix'       addParams( options: params.options )
include { TABIX_BGZIPTABIX as TABIX_BGZIPTABIX_1 } from '../../modules/nf-core/tabix/bgziptabix'  addParams( options: params.options )
include { TABIX_BGZIPTABIX as TABIX_BGZIPTABIX_2 } from '../../modules/nf-core/tabix/bgziptabix'  addParams( options: params.options )
include { BCFTOOLS_REHEADER as BCFTOOLS_REHEADER_TEST } from '../../modules/nf-core/bcftools/reheader'  addParams( options: params.options )


workflow PREPARE_VCFS_TEST {
    take:
    input_ch    // channel: [val(meta),vcf]
    fasta       // reference channel [val(meta), ref.fa]
    fai         // reference channel [val(meta), ref.fa.fai]

    main:

    versions=Channel.empty()

    //
    // MODULE: BGZIP_TABIX
    //
    // zip and index input test files
    BGZIP_TABIX(
        input_ch
    )
    versions = versions.mix(BGZIP_TABIX.out.versions)
    vcf_ch = BGZIP_TABIX.out.gz_tbi

    //
    // PREPARE_VCFS
    //
    // Reheader needed to standardize sample names
    ch_samples = Channel.of(["samples.txt", params.sample,"query"])
                    .collectFile(newLine:false)

    vcf_ch.combine(ch_samples)
            .map{it -> tuple( it[0], it[1],[],it[3])}
            .set{input_ch}

    //
    // BCFTOOLS_REHEADER
    //
    // Add "query" to test sample
    BCFTOOLS_REHEADER_TEST(
        input_ch,
        fai
        )
    versions = versions.mix(BCFTOOLS_REHEADER_TEST.out.versions)

    TABIX_BGZIPTABIX_1(
        BCFTOOLS_REHEADER_TEST.out.vcf
    )
    versions = versions.mix(TABIX_BGZIPTABIX_1.out.versions)
    vcf_ch = TABIX_BGZIPTABIX_1.out.gz_tbi

    if (params.preprocess.contains("filter_contigs")){
        //
        // BCFTOOLS_VIEW
        //
        // To filter out contigs!
        BCFTOOLS_VIEW(
            vcf_ch
        )
        versions = versions.mix(BCFTOOLS_VIEW.out.versions)

        TABIX_BGZIPTABIX_2(
            BCFTOOLS_VIEW.out.vcf
        )
        versions = versions.mix(TABIX_BGZIPTABIX_2.out.versions)
        vcf_ch   = TABIX_BGZIPTABIX_2.out.gz_tbi
    }

    if (params.preprocess.contains("normalization")){
        //
        // BCFTOOLS_NORM
        //
        // Breaks down -any- multi-allelic variants
        BCFTOOLS_NORM(
            vcf_ch,
            fasta
        )
        versions = versions.mix(BCFTOOLS_NORM.out.versions)

        TABIX_TABIX_1(
            BCFTOOLS_NORM.out.vcf
        )
        versions = versions.mix(TABIX_TABIX_1.out.versions)
        BCFTOOLS_NORM.out.vcf.join(TABIX_TABIX_1.out.tbi, by:0)
                            .set{vcf_ch}
    }


    if (params.variant_filtering != null | params.min_sv_size > 0 | params.max_sv_size != -1 | params.min_allele_freq != -1 | params.min_num_reads != -1 ){
        //
        // SUBWORKFLOW: VCF_VARIANT_FILTERING
        //
        // Filters SVs with given paramaters
        VCF_VARIANT_FILTERING(
            vcf_ch
        )
        vcf_ch = VCF_VARIANT_FILTERING.out.vcf_ch
        versions = versions.mix(VCF_VARIANT_FILTERING.out.versions)
    }

    if (params.preprocess.contains("deduplication")){
        //
        // SUBWORKFLOW: VCF_VARIANT_DEDUPLICATION
        //
        // Deduplicates variants at the same position test
        VCF_VARIANT_DEDUPLICATION(
            vcf_ch,
            fasta
        )
        vcf_ch = VCF_VARIANT_DEDUPLICATION.out.ch_vcf
        versions = versions.mix(VCF_VARIANT_DEDUPLICATION.out.versions)

    }
    vcf_ch.branch{
            sv:  it[0].vartype == "sv"
            small:  it[0].vartype == "small"
            cnv:  it[0].vartype == "cnv"
            other: false}
            .set{vcf}

    out_vcf_ch = Channel.empty()

    // only for small variant benchmarking
    if (params.preprocess.contains("prepy")){
        HAPPY_PREPY(
            vcf.small.map{it -> tuple( it[0], it[1],[])},
            fasta,
            fai
        )
        // TODO: Check norm settings https://github.com/Illumina/hap.py/blob/master/doc/normalisation.md

        TABIX_TABIX_3(
            HAPPY_PREPY.out.preprocessed_vcf
        )

        HAPPY_PREPY.out.preprocessed_vcf.join(TABIX_TABIX_3.out.tbi, by:0)
                            .set{vcf_ch}

        out_vcf_ch = out_vcf_ch.mix(vcf_ch)
        out_vcf_ch = out_vcf_ch.mix(vcf.sv)
        out_vcf_ch = out_vcf_ch.mix(vcf.cnv)
        vcf_ch = out_vcf_ch
    }


    emit:
    vcf_ch
    versions
}
