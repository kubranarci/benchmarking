//
// REPORT_BENCHMARK_STATISTICS: SUMMARIZE BENCHMARK REPORTS
//

params.options = [:]

include { MERGE_REPORTS  } from '../../modules/local/merge_reports'   addParams( options: params.options )
include { PLOTS          } from '../../modules/local/plots'           addParams( options: params.options )
include { DATAVZRD       } from '../modules/nf-core/datavzrd/main'    addParams( options: params.options )

workflow REPORT_BENCHMARK_STATISTICS {
    take:
    reports    // channel: [meta, report1, report2, ...]

    main:

    versions=Channel.empty()

    MERGE_REPORTS(
        reports
    )

    versions = versions.mix(MERGE_REPORTS.out.versions)

    PLOTS(
        MERGE_REPORTS.out.summary
    )

    versions = versions.mix(PLOTS.out.versions)

    DATAVZRD (

    )
    emit:
    versions
}
