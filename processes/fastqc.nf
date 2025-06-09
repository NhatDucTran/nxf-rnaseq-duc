params.publish_dir = "fastqc"

process fastqc {
    tag "$meta.name"
    publishDir "${params.publish_dir}", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    path "*.html"
    path "*.zip"

    script:
    """
    fastqc ${reads[0]}
    fastqc ${reads[1]}
    """
}