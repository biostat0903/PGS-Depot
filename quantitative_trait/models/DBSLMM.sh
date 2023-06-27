#!/usr/bin/bash
#PBS -N dbslmm
#PBS -l nodes=1:ppn=1,mem=10G
#PBS -l walltime=10:00:00
#PBS -t 1-24%5
#PBS -j oe
#PBS -o /public/home/biostat07/project/cluster_running_output/dbslmm.out
#PBS -q batch

let k=0

PROJ_PATH=/public/home/biostat07/Five_people
DBSLMM_PATH=${PROJ_PATH}/code/
DBSLMM=${DBSLMM_PATH}DBSLMM_script.sh
PLINK=/public/home/biostat07/plink
BLOCK=/public/home/Datasets/genome_block/EUR/chr
THREAD=4
TYPE=t
var_names=/public/home/biostat07/Five_people/validation/var_add.txt

for PHENONAME in $(cat ${var_names})
do

let k=${k}+1
if [ ${k} -eq ${PBS_ARRAYID} ]
then

REF_GENOTYPE=/public/home/Datasets/1000GP/EUR/hm3/chr
VAL_GENOTYPE=${PROJ_PATH}/genotype/eid_nosex/xchr
VAL_PHENOTYPE=${PROJ_PATH}/validation/rstandard/${PHENONAME}.txt
INDEX=r2
HERIT=${PROJ_PATH}/herit_c/${PHENONAME}/h2.log
SUMM=/public/home/biostat07/summary_data/summ_file/${PHENONAME}
OUT_PATH=${PROJ_PATH}/output_summary/${PHENONAME}.effect/DBSLMM/
model=DBSLMM

# esttime=
# time /usr/bin/time -v -o ${esttime} 
sh ${DBSLMM} -D ${DBSLMM_PATH} -p ${PLINK} -B ${BLOCK} -s ${SUMM} -m ${model}\
             -H ${HERIT} -G ${VAL_GENOTYPE} -R ${REF_GENOTYPE} -P ${VAL_PHENOTYPE}\
             -l 1 -T ${TYPE} -i ${INDEX} -t ${THREAD} -o ${OUT_PATH} 
fi

done
