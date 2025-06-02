nextflow run main.nf \
    --design /mnt/d/PI/nextflow/nxf-rnaseq-duc/data/design.csv \
    --output /mnt/d/PI/nextflow/nxf-rnaseq-duc/output/check_design/ \
    --comparison /mnt/d/PI/nextflow/nxf-rnaseq-duc/data/comparison.csv \
    -resume

nextflow run main.nf \
    --design /mnt/d/PI/nextflow/nxf-rnaseq-duc/data/design_basic.csv \
    --output /mnt/d/PI/nextflow/nxf-rnaseq-duc/output/check_design/ \
    -resume


nextflow run main.nf \
    --design ./data/design.csv \
    --output ./output/check_design/ \
    --comparison ./data/comparison.csv \
    -resume

nextflow run main.nf \
    --design ./data/design_basic.csv \
    --output ./output/check_design/ \
    -resume