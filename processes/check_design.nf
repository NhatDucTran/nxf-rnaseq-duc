process check_design {
    tag "$design"
    
    input:
    path design
    path comparison

    output:
    path "checked_${design}", emit: checked_design
    // publishDir "output/check_design/", mode: 'copy'

    script:
    // comparison_file = comparison ? "-c $comparison" : ''
    comparison_file = comparison.name != 'NO_FILE' ? "-c $comparison" : ''
    """
    check_design.py $comparison_file $design
    """

}