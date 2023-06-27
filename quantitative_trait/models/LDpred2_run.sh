#!/usr/bin/bash
#PBS -N LDpred2
#PBS -l nodes=1:ppn=1,mem=30G
#PBS -l walltime=24:00:00
#PBS -p +1023
#PBS -t 1-528%30
#PBS -j oe
#PBS -o /public/home/biostat07/project/cluster_running_output/LDpred2.out
#PBS -q batch

bash
let k=0
PROJ_PATH=/public/home/biostat07/Five_people/
LDpred2=${PROJ_PATH}code/LDpred2.R
var_names=/public/home/biostat07/Five_people/validation/var_add.txt

for PHENONAME in $(cat ${var_names})
do
for CHR in `seq 1 22`
do

let k=${k}+1
if [ ${k} -eq ${PBS_ARRAYID} ]
then

SUMM=/public/home/biostat07/summary_data/summ_file/${PHENONAME}.assoc.txt
OUTPUT=${PROJ_PATH}output_summary/
DAT=c
THREAD=1
MODEL=grid
TIMELOG=${PROJ_PATH}output_summary/${PHENONAME}.effect/time_log/${PHENONAME}_${CHR}_LDpred2.txt
/usr/bin/time -v -o ${TIMELOG} \
Rscript ${LDpred2} --summ ${SUMM} --output ${OUTPUT} --thread ${THREAD} --phenoname ${PHENONAME} \
                   --chr ${CHR} --dat ${DAT} --model ${MODEL}
fi
done
done
