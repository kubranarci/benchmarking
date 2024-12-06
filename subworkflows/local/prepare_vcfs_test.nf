//
// PREPARE_VCFS: SUBWORKFLOW TO PREPARE INPUT VCFS
//

include { VCF_REHEADER_SAMPLENAME      } from '../local/vcf_reheader_samplename'
include { VCF_VARIANT_DEDUPLICATION    } from '../local/vcf_variant_deduplication'
include { VCF_VARIANT_FILTERING        } from '../local/vcf_variant_filtering'
include { SPLIT_SMALL_VARIANTS_TEST    } from '../local/split_small_variants_test'
include { BCFTOOLS_NORM                } from '../../modules/nf-core/bcftools/norm'
include { TABIX_BGZIPTABIX             } from '../../modules/nf-core/tabix/bgziptabix'
include { TABIX_TABIX                  } from '../../modules/nf-core/tabix/tabix'
include { LIFTOVER_VCFS                } from '../local/liftover_vcfs'
include { BCFTOOLS_VIEW as BCFTOOLS_VIEW_CONTIGS } from '../../modules/nf-core/bcftools/view'
include { FIX_VCF_PREFIX               } from '../../modules/local/custom/fix_vcf_prefix'


workflow PREPARE_VCFS_TEST {
    take:
    test_ch     // channel: [val(meta), vcf]
    fasta       // reference channel [val(meta), ref.fa]
    fai         // reference channel [val(meta), ref.fa.fai]
    chain       // reference channel [val(meta), chain.gz]
    rename_chr  // reference channel [val(meta), chrlist.txt]
    dictionary  // reference channel [val(meta), genome.dict]

    main:

    versions = Channel.empty()

    test_ch.branch{
        def meta = it[0]
        liftover: meta.liftover
        other: true}.set{vcf}

    vcf_ch = Channel.empty()

    if (params.liftover.contains("test")){
        LIFTOVER_VCFS(
            vcf.liftover,
            Channel.empty(),
            fasta,
            chain,
            rename_chr,
            dictionary
        )
        versions = versions.mix(LIFTOVER_VCFS.out.versions.first())
        vcf_ch = vcf_ch.mix(LIFTOVER_VCFS.out.vcf_ch,vcf.other)
    }
    vcf_ch = vcf_ch.mix(vcf.other)

    // if prefix of chromosomes needs to be fixed
    vcf_ch.branch{
        def meta = it[0]
        prefix: meta.fix_prefix
        other: true}.set{fix}

    vcf_ch = Channel.empty()

    fix.prefix.view()

    FIX_VCF_PREFIX(
        fix.prefix,
        rename_chr
    )
    versions = versions.mix(FIX_VCF_PREFIX.out.versions.first())
    vcf_ch = vcf_ch.mix(FIX_VCF_PREFIX.out.vcf,fix.other)


    // Add "query" to test sample
    VCF_REHEADER_SAMPLENAME(
        vcf_ch,
        fai
    )
    versions = versions.mix(VCF_REHEADER_SAMPLENAME.out.versions.first())
    vcf_ch   = VCF_REHEADER_SAMPLENAME.out.ch_vcf

    if (params.preprocess.contains("filter_contigs")){
        // filter out extra contigs!
        BCFTOOLS_VIEW_CONTIGS(
            vcf_ch,
            [],
            [],
            []
        )
        versions = versions.mix(BCFTOOLS_VIEW_CONTIGS.out.versions.first())

        TABIX_BGZIPTABIX(
            BCFTOOLS_VIEW_CONTIGS.out.vcf
        )
        versions = versions.mix(TABIX_BGZIPTABIX.out.versions.first())
        vcf_ch   = TABIX_BGZIPTABIX.out.gz_tbi
    }
    if (params.preprocess.contains("normalization")){

        // Split -any- multi-allelic variants
        BCFTOOLS_NORM(
            vcf_ch,
            fasta
        )
        versions = versions.mix(BCFTOOLS_NORM.out.versions.first())

        TABIX_TABIX(
            BCFTOOLS_NORM.out.vcf
        )
        versions = versions.mix(TABIX_TABIX.out.versions.first())
        BCFTOOLS_NORM.out.vcf.join(TABIX_TABIX.out.tbi, by:0)
                            .set{vcf_ch}
    }

    if (params.include_expression != null | params.exclude_expression != null | params.min_sv_size > 0 | params.max_sv_size != -1 | params.min_allele_freq != -1 | params.min_num_reads != -1 ){

        // Filters variants and SVs with given paramaters
        VCF_VARIANT_FILTERING(
            vcf_ch
        )
        vcf_ch = VCF_VARIANT_FILTERING.out.vcf_ch
        versions = versions.mix(VCF_VARIANT_FILTERING.out.versions.first())
    }

    if (params.preprocess.contains("deduplication")){

        // Deduplicate variants at the same position test
        VCF_VARIANT_DEDUPLICATION(
            vcf_ch,
            fasta
        )
        vcf_ch = VCF_VARIANT_DEDUPLICATION.out.ch_vcf
        versions = versions.mix(VCF_VARIANT_DEDUPLICATION.out.versions.first())

    }

    if (params.analysis.contains("somatic")){

        // somatic specific preparations
        if (params.variant_type == "small"){
            SPLIT_SMALL_VARIANTS_TEST(
                vcf_ch
            )
            versions = versions.mix(SPLIT_SMALL_VARIANTS_TEST.out.versions.first())
            vcf_ch = SPLIT_SMALL_VARIANTS_TEST.out.out_vcf_ch
        }

    }

    emit:
    vcf_ch   // channel: [val(meta), vcf.gz, tbi]
    versions // channel: [versions.yml]
}
