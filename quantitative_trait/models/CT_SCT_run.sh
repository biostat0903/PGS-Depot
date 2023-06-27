#!/usr/bin/bash
#PBS -N CT_SCT
#PBS -l nodes=1:ppn=1,mem=60G
#PBS -l walltime=24:00:00
#PBS -p +1023
#PBS -t 3-9%7
#PBS -j oe
#PBS -o /public/home/biostat07/project/cluster_running_output/CT_SCT.out
#PBS -q batch

bash
let k=0
PROJ_PATH=/public/home/biostat07/Five_people/
LDpred2=${PROJ_PATH}code/CT_SCT.R
var_names=/public/home/biostat07/Five_people/validation/pheno_CT.txt

for phenoname in $(cat ${var_names})
do

let k=${k}+1
if [ ${k} -eq ${PBS_ARRAYID} ]
then

SUMM=/public/home/biostat07/summary_data/summ_file/${phenoname}.assoc.txt
path=${PROJ_PATH}SCT_CT/SCT
thread=4
phenofile=${phenoname}
pheno=${PROJ_PATH}validation/rstandard/${phenoname}.txt
cross=1
dat=continuous
reftype=/public/home/biostat07/project/reference_panel/mergeout
TIMELOG=${PROJ_PATH}output_summary/${phenoname}.effect/time_log/${phenoname}.txt
/usr/bin/time -v -o ${TIMELOG} \
Rscript ${LDpred2} --summ ${SUMM} --path ${path} --thread ${thread} --phenofile ${phenofile} \
                   --cross ${cross} --dat ${dat} --reftype ${reftype} --pheno ${pheno}
fi
done