params.publish_dir = "original_fastqs"
params.deliver_fastqs = false

process deliver_fastqs {
    tag "${meta.name}"
    publishDir "${params.publish_dir}", mode: 'copy'

    //khi params là true 
    // when:
    //     params.deliver_fastqs

    input:
    tuple val(meta), path (reads)

    //includeInputs : Khi publish output files, cũng tự động publish (sao chép) các file input của process đó.
    output:
    path "${meta.name}_R*.fastq.gz", includeInputs: true, emit: downloads
    path "${meta.name}_fastq_md5sum.txt", emit: md5sum
    
    script:
    if (meta.single_end) {
        """
        [ ! -f ${meta.name}_R1.fastq.gz ] && ln -s $reads ${meta.name}_R1.fastq.gz
        md5sum ${meta.name}_R*.fastq.gz > ${meta.name}_fastq_md5sum.txt
        """
    } else {
        """
        [ ! -f ${meta.name}_R1.fastq.gz ] && ln -s ${reads[0]} ${meta.name}_R1.fastq.gz
        [ ! -f ${meta.name}_R2.fastq.gz ] && ln -s ${reads[1]} ${meta.name}_R2.fastq.gz
        md5sum ${meta.name}_R*.fastq.gz > ${meta.name}_fastq_md5sum.txt
        """
    }
    
}
