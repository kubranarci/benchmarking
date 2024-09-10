//
// SMALL_GERMLINE_BENCHMARK: SUBWORKFLOW FOR SMALL GERMLINE VARIANTS
//

include { RTGTOOLS_FORMAT                                      } from '../../modules/nf-core/rtgtools/format/main'
include { RTGTOOLS_VCFEVAL                                     } from '../../modules/nf-core/rtgtools/vcfeval/main'
include { HAPPY_HAPPY                                          } from '../../modules/nf-core/happy/happy/main'
include { HAPPY_PREPY                                          } from '../../modules/nf-core/happy/prepy/main'
include { VCF_REHEADER_SAMPLENAME as VCF_REHEADER_SAMPLENAME_1 } from '../local/vcf_reheader_samplename'
include { VCF_REHEADER_SAMPLENAME as VCF_REHEADER_SAMPLENAME_2 } from '../local/vcf_reheader_samplename'
include { VCF_REHEADER_SAMPLENAME as VCF_REHEADER_SAMPLENAME_3 } from '../local/vcf_reheader_samplename'
include { VCF_REHEADER_SAMPLENAME as VCF_REHEADER_SAMPLENAME_4 } from '../local/vcf_reheader_samplename'

workflow SMALL_GERMLINE_BENCHMARK {
    take:
    input_ch  // channel: [val(meta),test_vcf,test_index,truth_vcf,truth_index, bed]
    fasta     // reference channel [val(meta), ref.fa]
    fai       // reference channel [val(meta), ref.fa.fai]
    sdf       // reference channel [val(meta), sdf]

    main:

    versions        = Channel.empty()
    summary_reports = Channel.empty()
    tagged_variants = Channel.empty()
    report_multiqc  = Channel.empty()

    if (params.method.contains('rtgtools')){

        if (!params.sdf){

            // Use rtgtools format to generate sdf file if necessary
            RTGTOOLS_FORMAT(
                fasta.map { meta, fasta -> [ meta, fasta, [], [] ] }
            )
            versions = versions.mix(RTGTOOLS_FORMAT.out.versions)
            sdf = RTGTOOLS_FORMAT.out.sdf

        }

        // apply rtgtools eval method
        RTGTOOLS_VCFEVAL(
            input_ch.map { meta, vcf, tbi, truth_vcf, truth_tbi, bed ->
                [ meta, vcf, tbi, truth_vcf, truth_tbi, bed, [] ]
            },
            sdf
        )
        versions = versions.mix(RTGTOOLS_VCFEVAL.out.versions.first())
        report_multiqc = report_multiqc.mix(RTGTOOLS_VCFEVAL.out.summary.collect{ meta, summary -> [ summary ] })

        // collect summary reports
        RTGTOOLS_VCFEVAL.out.summary
            .map { meta, file -> tuple([vartype: meta.vartype] + [benchmark_tool: "rtgtools"], file) }
            .groupTuple()
            .set{ report }

        summary_reports = summary_reports.mix(report)

        // reheader benchmarking results preperly and tag meta
        VCF_REHEADER_SAMPLENAME_1(
            RTGTOOLS_VCFEVAL.out.fn_vcf,
            fai
        )
        versions = versions.mix(VCF_REHEADER_SAMPLENAME_1.out.versions)

        VCF_REHEADER_SAMPLENAME_1.out.ch_vcf
            .map { meta, file, index -> tuple([vartype: meta.vartype] + [tag: "FN"] + [id: "rtgtools"], file, index) }
            .set { vcf_fn }

        VCF_REHEADER_SAMPLENAME_2(
            RTGTOOLS_VCFEVAL.out.fp_vcf,
            fai
        )
        versions = versions.mix(VCF_REHEADER_SAMPLENAME_2.out.versions)

        VCF_REHEADER_SAMPLENAME_2.out.ch_vcf
            .map { meta, file, index -> tuple([vartype: meta.vartype] + [tag: "FP"] + [id: "rtgtools"], file, index) }
            .set { vcf_fp }

        VCF_REHEADER_SAMPLENAME_3(
            RTGTOOLS_VCFEVAL.out.baseline_vcf,
            fai
        )
        versions = versions.mix(VCF_REHEADER_SAMPLENAME_3.out.versions)

        VCF_REHEADER_SAMPLENAME_3.out.ch_vcf
            .map { meta, file, index -> tuple([vartype: meta.vartype] + [tag: "TP_base"] + [id: "rtgtools"], file, index) }
            .set { vcf_tp_base }

        VCF_REHEADER_SAMPLENAME_4(
            RTGTOOLS_VCFEVAL.out.tp_vcf,
            fai
        )
        versions = versions.mix(VCF_REHEADER_SAMPLENAME_4.out.versions)

        VCF_REHEADER_SAMPLENAME_4.out.ch_vcf
            .map { meta, file, index -> tuple([vartype: meta.vartype] + [tag: "TP_comp"] + [id: "rtgtools"], file, index) }
            .set { vcf_tp_comp }

        tagged_variants = tagged_variants.mix(
            vcf_fn,
            vcf_fp,
            vcf_tp_base,
            vcf_tp_comp
        )
    }

    if (params.method.contains('happy')){

        input_ch
            .map{ meta, vcf, tbi, truth_vcf, truth_tbi, bed ->
                [ meta, vcf ]
            }
            .set { test_ch }

        input_ch
            .map{ meta, vcf, tbi, truth_vcf, truth_tbi, bed ->
                [ meta, truth_vcf, bed, [] ]
            }
            .set { truth_ch }

        if (params.preprocess.contains("prepy")){

            // apply prepy if required
            HAPPY_PREPY(
                input_ch.map{ meta, vcf, tbi, truth_vcf, truth_tbi, bed ->
                    [ meta, vcf, bed ]
                },
                fasta,
                fai
            )
            versions = versions.mix(HAPPY_PREPY.out.versions.first())
            // TODO: Check norm settings https://github.com/Illumina/hap.py/blob/master/doc/normalisation.md

            test_ch = HAPPY_PREPY.out.preprocessed_vcf
        }

        // apply happy method for benchmarking
        HAPPY_HAPPY(
            test_ch.join(truth_ch, failOnDuplicate:true, failOnMismatch:true),
            fasta,
            fai,
            [[],[]],
            [[],[]],
            [[],[]]
        )
        versions = versions.mix(HAPPY_HAPPY.out.versions.first())
        report_multiqc = report_multiqc.mix(HAPPY_HAPPY.out.summary_csv.collect{ meta, summary -> [ summary ] })

        // tag meta and collect summary reports
        HAPPY_HAPPY.out.summary_csv
            .map { meta, file -> tuple([vartype: meta.vartype] + [benchmark_tool: "happy"], file) }
            .groupTuple()
            .set{ report }
        summary_reports = summary_reports.mix(report)
    }
    emit:
    versions
    summary_reports
    tagged_variants
    report_multiqc

}
