rm(list=ls())
library(plyr)
library(dplyr)
library(bigreadr)
library(stringr)
#load file
load('/public/home/biostat07/Five_people/tmp_data/RDATA/eur_frame.RData')
load('/public/home/biostat07/Five_people/tmp_data/RDATA/temp_name.RData')
load('/public/home/biostat07/Five_people/tmp_data/RDATA/summary_adjust_name.RData')
#Select female EUR id and male EUR id
EUR_female <- eur_frame[which(eur_frame[,2] == 0),]
EUR_male <- eur_frame[which(eur_frame[,2] == 1),]

#get sample
set.seed(20230407)
sample_female<-sort(sample(nrow(EUR_female),25000,replace = F))

set.seed(19110405)
sample_male<-sort(sample(nrow(EUR_male),25000,replace = F))

last_female<-EUR_female[-sample_female,]
female_sort<-paste0('S',last_female$eid)
last_male<-EUR_male[-sample_male,]
male_sort<-paste0('S',last_male$eid)
last_nosex<-rbind(last_female,last_male)
nosex_sort<-rownames(EUR)[which(rownames(EUR) %in% rownames(last_nosex))]
last_nosex<-last_nosex[nosex_sort,]

last_male_low50<-last_male[which(last_male$age<=50),]
male_low50_sort<-paste0('S',last_male_low50$eid)

last_male_over50<-last_male[which(last_male$age>50),]
male_over50_sort<-paste0('S',last_male_over50$eid)

last_female_low50<-last_female[which(last_female$age<=50),]
female_low50_sort<-paste0('S',last_female_low50$eid)

last_female_over50<-last_female[which(last_female$age>50),]
female_over50_sort<-paste0('S',last_female_over50$eid)

last_active<-last_nosex[which(last_nosex$activity>=5),]
active_sort<-paste0('S',last_active$eid)

last_inactive<-last_nosex[which(last_nosex$activity<5),]
inactive_sort<-paste0('S',last_inactive$eid)
#make plink.txt to screen out genotype
plink_female<-data.frame(last_female$eid,last_female$eid)
plink_male<-data.frame(last_male$eid,last_male$eid)
plink_nosex<-data.frame(last_nosex$eid,last_nosex$eid)
plink_female_low50<-data.frame(last_female_low50$eid,last_female_low50$eid)
plink_female_over50<-data.frame(last_female_over50$eid,last_female_over50$eid)
plink_male_low50<-data.frame(last_male_low50$eid,last_male_low50$eid)
plink_male_over50<-data.frame(last_male_over50$eid,last_male_over50$eid)
plink_active<-data.frame(last_active$eid,last_active$eid)
plink_inactive<-data.frame(last_inactive$eid,last_inactive$eid)
#write file
write.table(last_female,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_female_eid/last_female.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_female_low50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_female_eid/last_female_low50.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_female_over50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_female_eid/last_female_over50.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_male,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_male_eid/last_male.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_male_low50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_male_eid/last_male_low50.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_male_over50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_male_eid/last_male_over50.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_nosex,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_nosex_eid/last_nosex.txt", 
            row.names = F, col.names = T, quote = F)
write.table(plink_female,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_female.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_male,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_male.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_nosex,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_nosex.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_female_low50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_female_low50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_male_low50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_male_low50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_female_over50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_female_over50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_male_over50,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_male_over50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_active,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_active.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_inactive,
            file = "/public/home/biostat07/Five_people_test/mysample/get_eid/get_plink_eid/plink_inactive.txt", 
            row.names = F, col.names = F, quote = F)
#Read in covariate sqc file
total_var<-c('eid',paste0('PC',1:20))
total_list<-fread2('/public/home/Datasets/ukb/pheno/sqc.txt',select=total_var)

#Get European Population EID
EUR_eid<-fread2('/public/home/Datasets/ukb/pheno/eid_EUR.txt',col.names = c('eid','eid1'))
EUR_eid<-EUR_eid[,1]

#Screening the European population and sorting the covariate files of the European population by fixed eid
EUR_list<-total_list[which(total_list$eid %in% EUR_eid),]
rownames(EUR_list)<-paste0('S',EUR_list$eid)
EUR_list<-EUR_list[paste0('S',EUR_eid),]
#Merge two files
last_EUR<-cbind(eur_frame,EUR_list)
last_EUR_only_males<-last_EUR[which(last_EUR$sex==1),]
last_EUR_only_females<-last_EUR[which(last_EUR$sex==0),]
last_low50_males<-last_EUR[which(last_EUR$sex==1 & last_EUR$age<=50),]
last_over50_males<-last_EUR[which(last_EUR$sex==1 & last_EUR$age>50),]
last_low50_females<-last_EUR[which(last_EUR$sex==0 & last_EUR$age<=50),]
last_over50_females<-last_EUR[which(last_EUR$sex==0 & last_EUR$age>50),]
last_EUR_active<-last_EUR[which(last_EUR$activity>=5),]
last_EUR_inactive<-last_EUR[which(last_EUR$activity<5),]
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
# Function 1: obtain residuals
get_resid <- function(dat,
                      dat_sample,
                      cov, 
                      xvar){
  if (cov == "none"){
    
    lm_model<-lm(dat[,xvar]~PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+
                   PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20, data=dat)
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 129:148)]), r_standard)
  }else if (cov == "BMI"){
    
    lm_model<-lm(dat[,xvar]~dat[,26]+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+
                   PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20, data=dat)
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 26, 129:148)]), r_standard)
  }else if (cov == "acttype"){
    
    lm_model<-lm(dat[,xvar]~dat[,6]+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+
                   PC11+PC12+PC13+PC14+PC15+PC16+PC17+PC18+PC19+PC20, data=dat)
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 6, 129:148)]), r_standard)
  }else if (cov == "age,sex") {
    
    lm_model<-lm(dat[,xvar]~PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10+PC11+PC12+PC13+
                   PC14+PC15+PC16+PC17+PC18+PC19+PC20+age+sex, data=dat)
    r_standard <- qqnorm(resid(lm_model))$x
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 129:148, 2:3)]), r_standard)
  }
  extract_eid <- extract_eid[which(extract_eid$eid %in% dat_sample[,1]),]
  rownames(extract_eid)<-paste0('S',extract_eid$eid)
  pheno_eid <- extract_eid[nosex_sort, c(1, 2)]
  extract_eid <- extract_eid[nosex_sort, c(1, ncol(extract_eid))]
  extract_qqnorm<-data.frame(last_nosex[,1])
  extract_qqnorm <- cbind(extract_qqnorm, extract_eid[,2])
  write.table(extract_qqnorm[, 2],
              file = paste0('/public/home/biostat07/Five_people_test/validation/rstandard/',phenoname[xvar-6]), 
              row.names = F, col.names = F, quote = F)
  write.table(pheno_eid,
              file = paste0('/public/home/biostat07/Five_people_test/validation/pheno_value_eid/',phenoname[xvar-6]), 
              row.names = F, col.names = F, quote = F)
}

for (i in 1:length(var_names)+6) {
  if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='age,nosex)'){
    get_resid(last_EUR,last_nosex,'age,sex',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='females)'){
    get_resid(last_EUR_only_females,last_female,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='males)'){
    get_resid(last_EUR_only_males,last_male,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI)'){
    get_resid(last_EUR,last_nosex,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='females,>_50_years_old)'){
    get_resid(last_over50_females,last_female_over50,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='females,<=_50_years_old)'){
    get_resid(last_low50_females,last_female_low50,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='males,>_50_years_old)'){
    get_resid(last_over50_males,last_male_over50,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='males,<=_50_years_old)'){
    get_resid(last_low50_males,last_male_low50,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,females,>_50_years_old)'){
    get_resid(last_over50_females,last_female_over50,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,females,<=_50_years_old)'){
    get_resid(last_low50_females,last_female_low50,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,males,>_50_years_old)'){
    get_resid(last_over50_males,last_male_over50,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,males,<=50_years_old)'){
    get_resid(last_low50_males,last_male_low50,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='physically_active_indivdiuals)'){
    get_resid(last_EUR_active,last_active,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='physically_inactive_indivdiuals)'){
    get_resid(last_EUR_inactive,last_inactive,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='physical_activity)'){
    get_resid(last_EUR,last_nosex,'acttype',i)
  } else {
    get_resid(last_EUR,last_nosex,'none',i)
  }
}
#Function 2 : obtain r2
get_r2_fun<-function(model,
                     type1,
                     type2,
                     file_name,
                     pheno_num){
  require(bigreadr)
  require(Metrics)
  pred_tot <- vector()
  for(chr in 1: 22){
    pred_chr_str <- paste0('/public/home/biostat07/Five_people_test/prediction/',file_name,'.effect/',
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
    pheno_tot <- rowSums(pred_tot)
    pheno_value<-fread2(paste0('/public/home/biostat07/Five_people_test/validation/rstandard/',file_name,'.txt'),header=F)[,1]
    pheno_sum<-data.frame(pheno_tot,pheno_value)
    pheno_sum<-na.omit(pheno_sum)
    r2_sum<-as.vector(aaply(1:100,1,r2_fun <- function(xvar) {
      set.seed(20230508+xvar+pheno_num-3)
      mysample<-sort(sample(nrow(pheno_sum),5000,replace=F))
      myvalue<-pheno_sum[mysample,]
      r2<-cor(myvalue[,1],myvalue[,2])^2
    }))
    write.table(r2_sum,
                file=paste0('/public/home/biostat07/Five_people_test/prediction/',file_name,
                            '.effect/',model,'/rsquare/',file_name,type2,".txt"),
                col.names = F,row.names = F,quote = F)
  }
}
for (i in 1:length(var_names)) {
  get_r2_fun('CT',NULL,NULL,temp_name[i],i)
  get_r2_fun('SCT',NULL,NULL,temp_name[i],i)
  get_r2_fun('LDpred2','_nosp','_nosp',temp_name[i],i)
  get_r2_fun('LDpred2','_sp','_sp',temp_name[i],i)
  get_r2_fun('LDpred2','_auto','_auto',temp_name[i],i)
  get_r2_fun('LDpred2','_inf','_inf',temp_name[i],i)
  get_r2_fun('DBSLMM','_dbslmm',NULL,temp_name[i],i)
  get_r2_fun('DBSLMM','_auto','_auto',temp_name[i],i)
  get_r2_fun('DBSLMM','_lmm','_lmm',temp_name[i],i)
  get_r2_fun('PRScs','_prscs',NULL,temp_name[i],i)
  get_r2_fun('SBLUP','_sblup',NULL,temp_name[i],i)
}
