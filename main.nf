include { check_design } from './processes/check_design.nf'
include { setup_channel } from './libs/setup_channel.nf'

workflow {
    design_ch = setup_channel( params.design, "Design file", true, "" )
    if (params.comparison) {
        comparison_ch = Channel.fromPath(params.comparison)
        check_design(design_ch, comparison_ch)
    } else {
        comparison_ch = Channel.empty()
        check_design(design_ch, comparison_ch)
    }
}
