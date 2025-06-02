include { check_design } from './processes/check_design.nf'
include { setup_channel } from './libs/setup_channel.nf'

workflow {
    params.comparison = params.comparison ?: null
    
    design_ch = setup_channel( params.design, "Design file", true, "" )
    
    if (params.comparison) {
        comparison_ch = Channel.fromPath(params.comparison)
    } else {
        comparison_ch = Channel.of(file('NO_FILE'))
    }
    
    check_design(design_ch, comparison_ch)
}
