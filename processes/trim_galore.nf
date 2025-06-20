
params.publish_dir = "trim_galore"
params.protocol_setting = [ "clip_r1":0, "clip_r2":10, "three_prime_clip_r1":10, "three_prime_clip_r2":0,
                             "adapter":"AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC",
                             "adapter2":"AGATCGGAAGAGCGTCGTGTAGGGAAAGA", 
                             "strandedness":2, "ignore_R1":false, "umi":false, "trimming_2step":false ]
params.adapter_overlap = 1
params.min_read_length = 20
params.trim_nextseq = true
params.save_trimmed = false

process trim_galore {
    tag "${meta.name}"
    publishDir "${params.publish_dir}", mode: 'copy',
        saveAs: {filename ->
            if (filename.indexOf("_fastqc") > 0) "FastQC/$filename"
            else if (filename.indexOf("trimming_report.txt") > 0) "logs/$filename"
            else if (params.save_trimmed && filename.endsWith("fq.gz")) filename
            else null
        }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*fq.gz"), emit: reads
    path "*trimming_report.txt", emit: report
    path "*fastqc.{zip,html}"
    path "v_*.txt" , emit: version

    script:
    c_r1 = params.protocol_setting.clip_r1 > 0 ? "--clip_r1 ${params.protocol_setting.clip_r1}" : ''
    c_r2 = params.protocol_setting.clip_r2 > 0 ? "--clip_r2 ${params.protocol_setting.clip_r2}" : ''
    tpc_r1 = params.protocol_setting.three_prime_clip_r1 > 0 ? "--three_prime_clip_r1 ${params.protocol_setting.three_prime_clip_r1}" : ''
    tpc_r2 = params.protocol_setting.three_prime_clip_r2 > 0 ? "--three_prime_clip_r2 ${params.protocol_setting.three_prime_clip_r2}" : ''
    nextseq = params.trim_nextseq ? "--nextseq 20" : ''
    cutadapt_quality = params.trim_nextseq ? "--nextseq-trim 20": '-q 20'
    a1 = params.protocol_setting.adapter ? "-a ${params.protocol_setting.adapter}" : ''
    a2 = params.protocol_setting.adapter2 ? "-a2 ${params.protocol_setting.adapter2}" : ''
    
    if (params.protocol_setting.trimming_2step) {
        """
        cutadapt --version &> v_cutadapt.txt
        [ ! -f  ${meta.name}_R1.fastq.gz ] && ln -s $reads ${meta.name}_R1.fastq.gz
        cutadapt -j $task.cpus ${cutadapt_quality} -O ${params.adapter_overlap} $a1 -m ${params.min_read_length} -o ${meta.name}_trimmed_first.fastq.gz ${meta.name}_R1.fastq.gz > ${meta.name}_1st_adapter_trimming_report.txt
        cutadapt -j $task.cpus ${cutadapt_quality} -O ${params.adapter_overlap} -a \"A{100}\" -m ${params.min_read_length} -o ${meta.name}_trimmed.fq.gz ${meta.name}_trimmed_first.fastq.gz > ${meta.name}_2nd_polyA_trimming_report.txt
        fastqc --quiet --threads $task.cpus ${meta.name}_trimmed.fq.gz
        """
    } else if (meta.single_end) {
        """
        trim_galore --version &> v_trim_galore.txt
        [ ! -f ${meta.name}_R1.fastq.gz ] && ln -s $reads ${meta.name}_R1.fastq.gz
        trim_galore -j $task.cpus --fastqc --gzip $c_r1 $tpc_r1 --stringency ${params.adapter_overlap} --length ${params.min_read_length} $a1 $nextseq ${meta.name}_R1.fastq.gz
        """
    } else {
        """
        trim_galore --version &> v_trim_galore.txt
        [ ! -f ${meta.name}_R1.fastq.gz ] && ln -s ${reads[0]} ${meta.name}_R1.fastq.gz
        [ ! -f ${meta.name}_R2.fastq.gz ] && ln -s ${reads[1]} ${meta.name}_R2.fastq.gz
        trim_galore -j $task.cpus --paired --fastqc --gzip $c_r1 $c_r2 $tpc_r1 $tpc_r2 --stringency ${params.adapter_overlap} --length ${params.min_read_length} $a1 $a2 $nextseq ${meta.name}_R1.fastq.gz ${meta.name}_R2.fastq.gz
        """
    }
}