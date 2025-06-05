include { check_design } from './processes/check_design'
include { setup_channel } from './libs/setup_channel'
include { parse_design } from './libs/parse_design'
include { deliver_fastqs } from './processes/deliver_fastqs'

workflow {
    params.comparison = params.comparison ?: null
    
    design_ch = setup_channel( params.design, "Design file", true, "" )
    
    if (params.comparison) {
        comparison_ch = Channel.fromPath(params.comparison)
    } else {
        comparison_ch = Channel.of(file('NO_FILE'))
    }
    
    check_design(design_ch, comparison_ch)
    check_design.out.checked_design
        .splitCsv(header: true) //Chia từng dòng của CSV thành map với key là tên cột, [ group: "g1", sample: "s1", read_1: "fastq/s1_R1.fq.gz", read_2: "fastq/s1_R2.fq.gz" ]
        .map {parse_design(it)} // .map biến đổi không thay đổi số lượng phần tử, lặp qua từng phần tử trong parse_design, trả về như trong hàm parse design: [ [name: "s1", group: "g1", single_end: false], ["fastq/s1_R1.fq.gz", "fastq/s1_R2.fq.gz"] ]
        .groupTuple() // gom các sample name (meta) có trùng tên về 1 nhóm,  [ meta, [reads1, reads2, ...] ]
        .map { // Ghép tất cả các danh sách reads thành một list duy nhất per sample
            meta, reads -> [meta, reads.flatten()]
        }
        .branch { // Tách thành 2 nhánh: multiple: Nếu là single-end và có >1 file, hoặc paired-end có >2 file. single: Các trường hợp còn lại
            meta, reads ->
            multiple: ( meta.single_end && reads.size() > 1 ) || ( !meta.single_end && reads.size() > 2 )
            single: true
        }
        .set {reads} //Tạo 2 channel: reads.single, reads.multiple
        
    deliver_fastqs(reads.single)
}
