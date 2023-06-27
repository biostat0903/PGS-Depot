rm(list=ls())
library(plyr)
library(dplyr)
library(bigreadr)
library(stringr)

# load file
load('/public/home/biostat07/Five_people/tmp_data/RDATA/validation_dat.RData')

# Read in covariate sqc file
total_var<-c('eid',paste0('PC',1:20))
total_list<-fread2('/public/home/Datasets/ukb/pheno/sqc.txt',select=total_var)

# Get European Population EID
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
  
  coef <- coef(lm_model)
  write.table(coef,
              file=paste0('/public/home/biostat07/Five_people/output_summary/',
                          temp_name[xvar - 6], '.effect/Coef/',
                          temp_name[xvar - 6],'.txt'),
              row.names = F, col.names = F, quote = F)
  extract_eid <- extract_eid[which(extract_eid$eid %in% dat_sample[,1]),]
  rownames(extract_eid)<-paste0('S',extract_eid$eid)
  pheno_eid <- extract_eid[nosex_sort, c(1, 2)]
  extract_eid <- extract_eid[nosex_sort, c(1, ncol(extract_eid))]
  extract_qqnorm<-data.frame(last_nosex[,1])
  extract_qqnorm <- cbind(extract_qqnorm, extract_eid[,2])
  write.table(extract_qqnorm[, 2],
              file = paste0('/public/home/biostat07/Five_people/validation/rstandard/',phenoname[xvar-6]), 
              row.names = F, col.names = F, quote = F)
  write.table(pheno_eid,
              file = paste0('/public/home/biostat07/Five_people/validation/pheno_value_eid/',phenoname[xvar-6]), 
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



