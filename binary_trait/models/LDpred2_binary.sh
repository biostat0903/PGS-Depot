#!/usr/bin/bash
#PBS -N LDpred2
#PBS -l nodes=1:ppn=1,mem=30G
#PBS -l walltime=24:00:00
#PBS -p +1023
#PBS -t 1-154%3
#PBS -j oe
#PBS -o /public/home/biostat07/project/cluster_running_output/LDpred2.out
#PBS -q batch

bash
let k=0
PROJ_PATH=/public/home/biostat07/Five_binary_validation/
LDpred2=${PROJ_PATH}code/LDpred2_binary.R
var_names=/public/home/biostat07/Five_binary_validation/LDpred2.txt

for PHENONAME in $(cat ${var_names})
do
for CHR in `seq 1 22`
do

let k=${k}+1
if [ ${k} -eq ${PBS_ARRAYID} ]
then

SUMM=/public/home/biostat07/Five_binary_validation/summ/gemma/${PHENONAME}.assoc.txt
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
