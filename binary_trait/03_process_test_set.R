rm(list=ls())
library(plyr)
library(dplyr)
library(bigreadr)
library(stringr)
#load file
load('/public/home/biostat07/Five_binary_validation/temp_data/nosex_sort.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_EUR.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/temp_name.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/summary_adjust_name.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_female_sample.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_male_sample.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_nosex_sample.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_T1D_sample.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_T2D_sample.RData')
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_diabetes_sample.RData')
#get sample
binary_female<-binary_EUR[which(binary_EUR$sex==0),]
binary_male<-binary_EUR[which(binary_EUR$sex==1),]

set.seed(20230407)
female_sample<-sort(sample(nrow(binary_female),25000,replace = F))
set.seed(19110405)
male_sample<-sort(sample(nrow(binary_male),25000,replace = F))

binary_female_sample<-binary_female[-female_sample,]
female_sort<-rownames(binary_female_sample)
binary_male_sample<-binary_male[-male_sample,]
male_sort<-rownames(binary_male_sample)
binary_nosex_sample<-rbind(binary_female_sample,binary_male_sample)
nosex_sort<-rownames(binary_EUR)[which(rownames(binary_EUR) %in% rownames(binary_nosex_sample))]
binary_nosex_sample<-binary_nosex_sample[nosex_sort,]
binary_T1D_sample<-binary_nosex_sample[which(binary_nosex_sample[,141]==1),]
binary_T2D_sample<-binary_nosex_sample[which(binary_nosex_sample[,142]==1),]
binary_diabetes_sample<-binary_nosex_sample[which(binary_nosex_sample[,5]==1),]
T1D_sort<-rownames(binary_T1D_sample)
T2D_sort<-rownames(binary_T2D_sample)
diabetes_sort<-rownames(binary_diabetes_sample)
#get plink
plink_nosex<-data.frame(binary_nosex_sample$eid,binary_nosex_sample$eid)
plink_male<-data.frame(binary_male_sample$eid,binary_male_sample$eid)
plink_female<-data.frame(binary_female_sample$eid,binary_female_sample$eid)
plink_T1D<-data.frame(binary_T1D_sample$eid,binary_T1D_sample$eid)
plink_T2D<-data.frame(binary_T2D_sample$eid,binary_T2D_sample$eid)
plink_diabetes<-data.frame(binary_diabetes_sample$eid,binary_diabetes_sample$eid)
write.table(plink_nosex,file = '/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_nosex.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_male,file = '/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_male.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_female,file = '/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_female.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_T1D,file = '/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_T1D.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_T2D,file = '/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_T2D.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_diabetes,file = '/public/home/biostat07/Five_binary_test/mysample/get_plink/plink_diabetes.txt',
            col.names = F,row.names = F,quote = F)
##Read in covariate sqc file
total_var<-c('eid',paste0('PC',1:20))
total_list<-fread2('/public/home/Datasets/ukb/pheno/sqc.txt',select=total_var)
#Screening the European population and sorting the covariate files of the European population by fixed eid
EUR_list<-total_list[which(total_list$eid %in% EUR_eid),]
rownames(EUR_list)<-paste0('S',EUR_list$eid)
EUR_list<-EUR_list[paste0('S',EUR_eid),]
#Merge two files
last_binary<-cbind(binary_EUR,EUR_list)
binary_T1D<-last_binary[which(last_binary[,141]==1),]
binary_T2D<-last_binary[which(last_binary[,142]==1),]
binary_diabetes<-last_binary[which(last_binary[,5]==1),]
#preparation
varnames<-c(summary_adjust_name)
var_names<-c()
var_names<-as.vector(aaply(1:length(varnames),1,function(i){
  if (str_detect(varnames[i],' ')) {
    var_names[i]<-str_replace_all(varnames[i],' ','_')
  }else{
    var_names[i]<-varnames[i]
  }
}))
#Replace the spaces in the phenotype with '_'
var_names<-as.vector(aaply(1:length(var_names),1,function(i){
  if (str_detect(var_names[i],'/')){
    var_names[i]<-str_replace_all(var_names[i],'/','-')
  }else{
    var_names[i]<-var_names[i]
  }
}))
phenoname<-paste0(temp_name,'.txt')
filename<-paste0(paste0('residual_',temp_name),'.txt')
#Function 1 :get resid
get_resid <- function(dat,
                      dat_sample,
                      cov, 
                      xvar){
  if (cov == "none"){
    
    lm_model<-glm(dat[,xvar]~PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+
                    PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20,data=dat,family = 'binomial')
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 158:177)]), r_standard)
  }else if (cov == "BMI"){
    
    lm_model<-glm(dat[,xvar]~PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+
                    PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20+BMI,data=dat,family = 'binomial')
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 4, 158:177)]), r_standard)
  }else if (cov == "age,sex") {
    
    lm_model<-glm(dat[,xvar]~PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+
                    PC14+PC15+PC16+PC17+PC18+PC19+PC20+age+sex,data=dat,family = 'binomial')
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 158:177)]), r_standard)
  }else if (cov == "age") {
    
    lm_model<-glm(dat[,xvar]~PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+
                    PC14+PC15+PC16+PC17+PC18+PC19+PC20+age,data=dat,family = 'binomial')
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 158:177)]), r_standard)
  }
  extract_eid <- extract_eid[which(extract_eid$eid %in% dat_sample[,1]),]
  rownames(extract_eid)<-paste0('S',extract_eid$eid)
  pheno_eid <- extract_eid[nosex_sort, c(1, 2)]
  extract_eid <- extract_eid[nosex_sort, c(1, ncol(extract_eid))]
  extract_qqnorm<-data.frame(binary_nosex_sample[,1])
  extract_qqnorm <- cbind(extract_qqnorm, extract_eid[,2])
  write.table(extract_qqnorm[,2],
              file = paste0('/public/home/biostat07/Five_binary_test/validation/rstandard/',phenoname[xvar-5]), 
              row.names = F, col.names = F, quote = F)
  write.table(pheno_eid[,2],
              file = paste0('/public/home/biostat07/Five_binary_test/validation/pheno_value_eid/',phenoname[xvar-5]), 
              row.names = F, col.names = F, quote = F)
}
for (i in 1:length(var_names)+5) {
  if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='age,nosex)'){
    get_resid(last_binary,binary_nosex_sample,'age,sex',i)
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='age)'){
    get_resid(last_binary,binary_nosex_sample,'age',i)
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='type_1_diabetes)'){
    get_resid(binary_T1D,binary_T1D_sample,'none',i)
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='type_2_diabetes)'){
    get_resid(binary_T2D,binary_T2D_sample,'none',i)
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='diabetes_(ESRD_vs._no_ESRD))'){
    get_resid(binary_diabetes,binary_diabetes_sample,'none',i)
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='BMI)'){
    get_resid(last_binary,binary_nosex_sample,'BMI',i)
  } else {
    get_resid(last_binary,binary_nosex_sample,'none',i)
  }
}
binary_nosex_sample<-cbind(binary_nosex_sample,EUR_list[nosex_sort,])
#Function 2 : get cov's yhat
get_cov <- function(cov){
  beta<-fread2(paste0('/public/home/biostat07/Five_binary_validation/output_summary/',
                      temp_name[i],'.effect/Coef/',temp_name[i],'.txt'),header=F)[,1]
  beta.con<-beta[1]
  beta.cov<-beta[-1]
  if (cov == 'age,sex'){
    cov.yhat<-as.matrix(binary_nosex_sample[,c(158:177,3,2)]) %*% beta.cov + beta.con
  }else if (cov == 'age'){
    cov.yhat<-as.matrix(binary_nosex_sample[,c(158:177,3)]) %*% beta.cov + beta.con
  }else if (cov == 'BMI'){
    cov.yhat<-as.matrix(binary_nosex_sample[,c(158:177,4)]) %*% beta.cov + beta.con
  }else if (cov == 'none'){
    cov.yhat<-as.matrix(binary_nosex_sample[,c(158:177)]) %*% beta.cov + beta.con
  }
  cov.yhat<-cbind(binary_nosex_sample[,1],as.data.frame(cov.yhat))
  write.table(cov.yhat,
              file=paste0('/public/home/biostat07/Five_binary_test/cov_yhat/',temp_name[i],'.txt'),
              col.names = F,row.names = F,quote = F)
}
for (i in 1:length(var_names)+5) {
  if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='age,nosex)'){
    get_cov('age,sex')
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='age)'){
    get_cov('age')
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='type_1_diabetes)'){
    get_cov('none')
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='type_2_diabetes)'){
    get_cov('none')
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='diabetes_(ESRD_vs._no_ESRD))'){
    get_cov('none')
  } else if (str_split_fixed(var_names[i-5],'\\\(',n=2)[,2]=='BMI)'){
    get_cov('BMI')
  } else {
    get_cov('none')
  }
}
#Function 3 : get auc
get_auc_fun<-function(model,
                      type1,
                      type2,
                      file_name,
                      pheno_num,
                      sample_num){
  require(bigreadr)
  require(Metrics)
  pred_tot <- vector()
  for(chr in 1: 22){
    pred_chr_str <- paste0('/public/home/biostat07/Five_binary_test/prediction/',file_name,'.effect/',
                           model,'/geno/pred',type1,'_chr',chr,".profile.gz")
    if (file.exists(pred_chr_str)){
      pred_chr <- fread2(pred_chr_str, header = T)[, 6]
      pred_tot <- cbind(pred_tot, pred_chr)
    } else {
      cat (paste0("chr:", chr, " fail!\n"))
    }
  }
  if(length(pred_tot)==0){
    cat (paste0("fail!\n"))
  }else{
    if (ncol(pred_tot)==1){
      pheno_tot <- pred_tot[,1]
    }else{
      pheno_tot <- rowSums(pred_tot)
    }
    pheno_value<-fread2(paste0('/public/home/biostat07/Five_binary_test/cov_yhat/',file_name,'.txt'),header=F)
    predict_value<-pheno_tot+pheno_value[,2]
    pheno_value[,2]<-predict_value
    pheno_value[,3]<-fread2(paste0('/public/home/biostat07/Five_binary_test/validation/pheno_value_eid/',file_name,'.txt'),header=F)[,1]
    pheno_value<-na.omit(pheno_value)
    auc_sum<-as.vector(aaply(1:100,1,r2_fun <- function(xvar) {
      set.seed(20230508+xvar+pheno_num-3)
      if (sample_num == 100){
        mysample<-sort(sample(nrow(pheno_value),100,replace=F))
      }else{
        mysample<-sort(sample(nrow(pheno_value),5000,replace=F))
      }
      myvalue<-pheno_value[mysample,]
      myauc<-auc(myvalue[,3],myvalue[,2])
    }))
    low_index<-which(auc_sum<0.5)
    low_value<-1-auc_sum[low_index]
    auc_sum[low_index]<-low_value
    write.table(auc_sum,
                file=paste0('/public/home/biostat07/Five_binary_test/prediction/',file_name,
                            '.effect/',model,'/rsquare/',file_name,type2,".txt"),
                col.names = F,row.names = F,quote = F)
  }
}
for (i in 1:length(var_names)) {
  if (str_split_fixed(var_names[i],'\\\(',n=2)[,2]=='age,nosex)'){
    get_auc_fun('CT',NULL,NULL,temp_name[i],i,5000)
    get_auc_fun('SCT',NULL,NULL,temp_name[i],i,5000)
    get_auc_fun('LDpred2','_nosp','_nosp',temp_name[i],i,5000)
    get_auc_fun('LDpred2','_sp','_sp',temp_name[i],i,5000)
    get_auc_fun('LDpred2','_auto','_auto',temp_name[i],i,5000)
    get_auc_fun('LDpred2','_inf','_inf',temp_name[i],i,5000)
    get_auc_fun('DBSLMM','_dbslmm',NULL,temp_name[i],i,5000)
    get_auc_fun('DBSLMM','_auto','_auto',temp_name[i],i,5000)
    get_auc_fun('DBSLMM','_lmm','_lmm',temp_name[i],i,5000)
    get_auc_fun('PRScs','_prscs',NULL,temp_name[i],i,5000)
    get_auc_fun('SBLUP','_sblup',NULL,temp_name[i],i,5000)
  } else if (str_split_fixed(var_names[i],'\\\(',n=2)[,2]=='type_1_diabetes)'){
    get_auc_fun('CT',NULL,NULL,temp_name[i],i,100)
    get_auc_fun('SCT',NULL,NULL,temp_name[i],i,100)
    get_auc_fun('LDpred2','_nosp','_nosp',temp_name[i],i,100)
    get_auc_fun('LDpred2','_sp','_sp',temp_name[i],i,100)
    get_auc_fun('LDpred2','_auto','_auto',temp_name[i],i,100)
    get_auc_fun('LDpred2','_inf','_inf',temp_name[i],i,100)
    get_auc_fun('DBSLMM','_dbslmm',NULL,temp_name[i],i,100)
    get_auc_fun('DBSLMM','_auto','_auto',temp_name[i],i,100)
    get_auc_fun('DBSLMM','_lmm','_lmm',temp_name[i],i,100)
    get_auc_fun('PRScs','_prscs',NULL,temp_name[i],i,100)
    get_auc_fun('SBLUP','_sblup',NULL,temp_name[i],i,100)
  } else if (str_split_fixed(var_names[i],'\\\(',n=2)[,2]=='type_2_diabetes)'){
    get_auc_fun('CT',NULL,NULL,temp_name[i],i,100)
    get_auc_fun('SCT',NULL,NULL,temp_name[i],i,100)
    get_auc_fun('LDpred2','_nosp','_nosp',temp_name[i],i,100)
    get_auc_fun('LDpred2','_sp','_sp',temp_name[i],i,100)
    get_auc_fun('LDpred2','_auto','_auto',temp_name[i],i,100)
    get_auc_fun('LDpred2','_inf','_inf',temp_name[i],i,100)
    get_auc_fun('DBSLMM','_dbslmm',NULL,temp_name[i],i,100)
    get_auc_fun('DBSLMM','_auto','_auto',temp_name[i],i,100)
    get_auc_fun('DBSLMM','_lmm','_lmm',temp_name[i],i,100)
    get_auc_fun('PRScs','_prscs',NULL,temp_name[i],i,100)
    get_auc_fun('SBLUP','_sblup',NULL,temp_name[i],i,100)
  } else if (str_split_fixed(var_names[i],'\\\(',n=2)[,2]=='diabetes_(ESRD_vs._no_ESRD))'){
    get_auc_fun('CT',NULL,NULL,temp_name[i],i,100)
    get_auc_fun('SCT',NULL,NULL,temp_name[i],i,100)
    get_auc_fun('LDpred2','_nosp','_nosp',temp_name[i],i,100)
    get_auc_fun('LDpred2','_sp','_sp',temp_name[i],i,100)
    get_auc_fun('LDpred2','_auto','_auto',temp_name[i],i,100)
    get_auc_fun('LDpred2','_inf','_inf',temp_name[i],i,100)
    get_auc_fun('DBSLMM','_dbslmm',NULL,temp_name[i],i,100)
    get_auc_fun('DBSLMM','_auto','_auto',temp_name[i],i,100)
    get_auc_fun('DBSLMM','_lmm','_lmm',temp_name[i],i,100)
    get_auc_fun('PRScs','_prscs',NULL,temp_name[i],i,100)
    get_auc_fun('SBLUP','_sblup',NULL,temp_name[i],i,100)
  } else {
    get_auc_fun('CT',NULL,NULL,temp_name[i],i,5000)
    get_auc_fun('SCT',NULL,NULL,temp_name[i],i,5000)
    get_auc_fun('LDpred2','_nosp','_nosp',temp_name[i],i,5000)
    get_auc_fun('LDpred2','_sp','_sp',temp_name[i],i,5000)
    get_auc_fun('LDpred2','_auto','_auto',temp_name[i],i,5000)
    get_auc_fun('LDpred2','_inf','_inf',temp_name[i],i,5000)
    get_auc_fun('DBSLMM','_dbslmm',NULL,temp_name[i],i,5000)
    get_auc_fun('DBSLMM','_auto','_auto',temp_name[i],i,5000)
    get_auc_fun('DBSLMM','_lmm','_lmm',temp_name[i],i,5000)
    get_auc_fun('PRScs','_prscs',NULL,temp_name[i],i,5000)
    get_auc_fun('SBLUP','_sblup',NULL,temp_name[i],i,5000)
  }
}