#!/bin/bash

SEND_THREAD_NUM=2
tmp_fifofile="/tmp/$$.fifo"
mkfifo "$tmp_fifofile"
exec 6<>"$tmp_fifofile"

for ((i=0;i<$SEND_THREAD_NUM;i++));do
echo
done >&6

for chr in `seq 1 1`;do
read -u6
{
#for sex in nosex T1D T2D diabetes
#do
var_names=/public/home/biostat07/Five_binary_validation/binary_name.txt
PLINK=/public/home/biostat07/plink
compstr=/public/home/biostat07/Five_binary_test/
idxtest=/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_nosex.txt

for phenoname in $(cat ${var_names}); do

# bfile
bfile=/public/home/biostat07/Five_people_test/genotype/eid_nosex/xchr${chr}

esteffCT=/public/home/biostat07/Five_binary_validation/output_summary/${phenoname}.effect/CT/${phenoname}.txt
esteffSCT=/public/home/biostat07/Five_binary_validation/output_summary/${phenoname}.effect/SCT/${phenoname}.txt
predCT=${compstr}prediction/${phenoname}.effect/CT/geno/pred_chr${chr}
predSCT=${compstr}prediction/${phenoname}.effect/SCT/geno/pred_chr${chr}
esteffLDpred2=/public/home/biostat07/Five_binary_validation/output_summary/${phenoname}.effect/LDpred2/effect_chr${chr}.txt
predLDpred2sp=${compstr}prediction/${phenoname}.effect/LDpred2/geno/pred_sp_chr${chr}
predLDpred2nosp=${compstr}prediction/${phenoname}.effect/LDpred2/geno/pred_nosp_chr${chr}
esteffbestdbslmm=/public/home/biostat07/Five_binary_validation/output_summary/${phenoname}.effect/DBSLMM/${phenoname}_chr${chr}_best.dbslmm.txt
predbestdbslmm=${compstr}prediction/${phenoname}.effect/DBSLMM/geno/pred_dbslmm_chr${chr}
esteffsblup=/public/home/biostat07/Five_binary_timi/${phenoname}/esteff_SBLUP.txt
predsblup=${compstr}prediction/${phenoname}.effect/SBLUP/geno/pred_sblup_chr${chr}
esteffPRScs=/public/home/biostat07/Five_binary_timi/${phenoname}/esteff_PRScs.txt
predPRScs=${compstr}prediction/${phenoname}.effect/PRScs/geno/pred_prscs_chr${chr}
esteffLDpred2inf=/public/home/biostat07/Five_binary_timi/${phenoname}/esteff_LDpred2_inf.txt
esteffLDpred2auto=/public/home/biostat07/Five_binary_timi/${phenoname}/esteff_LDpred2_auto.txt
predLDpred2inf=${compstr}prediction/${phenoname}.effect/LDpred2/geno/pred_inf_chr${chr}
predLDpred2auto=${compstr}prediction/${phenoname}.effect/LDpred2/geno/pred_auto_chr${chr}
esteffdbslmmauto=/public/home/biostat07/Five_binary_timi/${phenoname}/esteff_DBSLMM_auto_DBSLMM.txt
esteffdbslmmlmm=/public/home/biostat07/Five_binary_timi/${phenoname}/esteff_DBSLMM_auto_LMM.txt
preddbslmmauto=${compstr}prediction/${phenoname}.effect/DBSLMM/geno/pred_auto_chr${chr}
preddbslmmlmm=${compstr}prediction/${phenoname}.effect/DBSLMM/geno/pred_lmm_chr${chr}
gunzip ${esteffsblup}.gz
gunzip ${esteffPRScs}.gz
gunzip ${esteffLDpred2inf}.gz
gunzip ${esteffLDpred2auto}.gz
gunzip ${esteffdbslmmauto}.gz
gunzip ${esteffdbslmmlmm}.gz
${PLINK} --bfile ${bfile} --silent --score ${esteffCT} 1 2 3 sum --keep ${idxtest} --out ${predCT}
${PLINK} --bfile ${bfile} --silent --score ${esteffSCT} 1 2 3 sum --keep ${idxtest} --out ${predSCT}
${PLINK} --bfile ${bfile} --silent --score ${esteffLDpred2} 1 2 4 sum --keep ${idxtest} --out ${predLDpred2sp}
${PLINK} --bfile ${bfile} --silent --score ${esteffLDpred2} 1 2 3 sum --keep ${idxtest} --out ${predLDpred2nosp}
${PLINK} --bfile ${bfile} --silent --score ${esteffbestdbslmm} 1 2 4 sum --keep ${idxtest} --out ${predbestdbslmm}
${PLINK} --bfile ${bfile} --silent --score ${esteffsblup} 1 2 4 sum --keep ${idxtest} --out ${predsblup}
${PLINK} --bfile ${bfile} --silent --score ${esteffPRScs} 2 4 6 sum --keep ${idxtest} --out ${predPRScs}
${PLINK} --bfile ${bfile} --silent --score ${esteffLDpred2inf} 1 2 3 sum --keep ${idxtest} --out ${predLDpred2inf}
${PLINK} --bfile ${bfile} --silent --score ${esteffLDpred2auto} 1 2 3 sum --keep ${idxtest} --out ${predLDpred2auto}
${PLINK} --bfile ${bfile} --silent --score ${esteffdbslmmauto} 1 2 4 sum --keep ${idxtest} --out ${preddbslmmauto}
${PLINK} --bfile ${bfile} --silent --score ${esteffdbslmmlmm} 1 2 4 sum --keep ${idxtest} --out ${preddbslmmlmm}
gzip -f ${predCT}.profile
gzip -f ${predSCT}.profile
gzip -f ${predLDpred2sp}.profile
gzip -f ${predLDpred2nosp}.profile
gzip -f ${predbestdbslmm}.profile
gzip -f ${predsblup}.profile
gzip -f ${predPRScs}.profile
gzip -f ${predLDpred2inf}.profile
gzip -f ${predLDpred2auto}.profile
gzip -f ${preddbslmmauto}.profile
gzip -f ${preddbslmmlmm}.profile
rm ${predCT}.log
rm ${predCT}.nopred
rm ${predSCT}.log
rm ${predSCT}.nopred
rm ${predLDpred2sp}.log
rm ${predLDpred2nosp}.log
rm ${predLDpred2sp}.nopred
rm ${predLDpred2nosp}.nopred
rm ${predbestdbslmm}.log
rm ${predbestdbslmm}.nopred
rm ${predsblup}.log
rm ${predsblup}.nopred
rm ${predPRScs}.log
rm ${predPRScs}.nopred
rm ${predLDpred2inf}.log
rm ${predLDpred2auto}.log
rm ${predLDpred2inf}.nopred
rm ${predLDpred2auto}.nopred
rm ${preddbslmmauto}.log
rm ${preddbslmmauto}.nopred
rm ${preddbslmmlmm}.log
rm ${preddbslmmlmm}.nopred


done
} &
pid=$!
echo $pid
done

wait

exec 6>&-

exit 0

