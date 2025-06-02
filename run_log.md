nextflow run main.nf \
    --design /mnt/d/PI/nextflow/nxf-rnaseq-duc/data/design.csv \
    --output /mnt/d/PI/nextflow/nxf-rnaseq-duc/output/check_design/ \
    --comparison /mnt/d/PI/nextflow/nxf-rnaseq-duc/data/comparison.csv \
    -resume

nextflow run main.nf \
    --design /mnt/d/PI/nextflow/nxf-rnaseq-duc/data/design_basic.csv \
    --output /mnt/d/PI/nextflow/nxf-rnaseq-duc/output/check_design/ \
    -resume