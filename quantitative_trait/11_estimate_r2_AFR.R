library(plyr)
library(dplyr)
library(bigreadr)
library(stringr)
load('/public/home/biostat07/AFR/temp/AFR_frame.RData')
load('/public/home/biostat07/AFR/temp/nosex_sort.RData')
load('/public/home/biostat07/AFR/temp/last_nosex.RData')
load('/public/home/biostat07/AFR/temp/last_female.RData')
load('/public/home/biostat07/AFR/temp/last_male.RData')
load('/public/home/biostat07/AFR/temp/temp_name.RData')
load('/public/home/biostat07/AFR/temp/summary_adjust_name.RData')
#Read in covariate sqc file
total_var<-c('eid',paste0('PC',1:20))
total_list<-fread2('/public/home/Datasets/ukb/pheno/sqc.txt',select=total_var)

#Screening the AFR population and sorting the covariate files of the AFR population by fixed eid
AFR_eid <- fread2('/public/home/Datasets/ukb/pheno/eid_AFR.txt')[, 1]
AFR_list<-total_list[which(total_list$eid %in% AFR_eid),]
rownames(AFR_list)<-paste0('S',AFR_list$eid)
AFR_list<-AFR_list[paste0('S',AFR_eid),]
#Merge two files
last_AFR<-cbind(AFR_frame,AFR_list)
last_AFR_only_males<-last_AFR[which(last_AFR$sex==1),]
last_AFR_only_females<-last_AFR[which(last_AFR$sex==0),]
last_low50_males<-last_AFR[which(last_AFR$sex==1 & last_AFR$age<=50),]
last_over50_males<-last_AFR[which(last_AFR$sex==1 & last_AFR$age>50),]
last_low50_females<-last_AFR[which(last_AFR$sex==0 & last_AFR$age<=50),]
last_over50_females<-last_AFR[which(last_AFR$sex==0 & last_AFR$age>50),]
last_AFR_active<-last_AFR[which(last_AFR$activity>=5),]
last_AFR_inactive<-last_AFR[which(last_AFR$activity<5),]
write.table(last_AFR[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_nosex.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_AFR_only_females[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_female.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_AFR_only_males[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_male.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_low50_females[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_female_low50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_low50_males[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_male_low50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_over50_females[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_female_over50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_over50_males[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_male_over50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_AFR_active[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_active.txt", 
            row.names = F, col.names = F, quote = F)
write.table(last_AFR_inactive[,c(1,128)],
            file = "/public/home/biostat07/AFR/plink/plink_inactive.txt", 
            row.names = F, col.names = F, quote = F)
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
    extract_eid <- data.frame(na.omit(dat[,c(1, xvar, 129:148)]), r_standard)
  }
  extract_eid <- extract_eid[which(extract_eid$eid %in% dat_sample[,1]),]
  rownames(extract_eid)<-paste0('S',extract_eid$eid)
  pheno_eid <- extract_eid[nosex_sort, c(1, 2)]
  extract_eid <- extract_eid[nosex_sort, c(1, ncol(extract_eid))]
  extract_qqnorm<-data.frame(last_AFR[,1])
  extract_qqnorm <- cbind(extract_qqnorm, extract_eid[,2])
  write.table(extract_qqnorm[,2],
              file = paste0('/public/home/biostat07/AFR/liner_model/rstandard/',phenoname[xvar-6]), 
              row.names = F, col.names = F, quote = F)
  write.table(pheno_eid,
              file = paste0('/public/home/biostat07/AFR/liner_model/pheno_value_eid/',phenoname[xvar-6]), 
              row.names = F, col.names = F, quote = F)
}
for (i in 1:length(var_names)+6) {
  if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='age,nosex)'){
    get_resid(last_AFR,last_AFR,'age,sex',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='females)'){
    get_resid(last_AFR_only_females,AFR_female,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='males)'){
    get_resid(last_AFR_only_males,AFR_male,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI)'){
    get_resid(last_AFR,last_AFR,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='females,>_50_years_old)'){
    get_resid(last_over50_females,last_over50_females,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='females,<=_50_years_old)'){
    get_resid(last_low50_females,last_low50_females,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='males,>_50_years_old)'){
    get_resid(last_over50_males,last_over50_males,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='males,<=_50_years_old)'){
    get_resid(last_low50_males,last_low50_males,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,females,>_50_years_old)'){
    get_resid(last_over50_females,last_over50_females,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,females,<=_50_years_old)'){
    get_resid(last_low50_females,last_low50_females,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,males,>_50_years_old)'){
    get_resid(last_over50_males,last_over50_males,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='BMI,males,<=50_years_old)'){
    get_resid(last_low50_males,last_low50_males,'BMI',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='physically_active_indivdiuals)'){
    get_resid(last_AFR_active,last_AFR_active,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='physically_inactive_indivdiuals)'){
    get_resid(last_AFR_inactive,last_AFR_inactive,'none',i)
  } else if (str_split_fixed(var_names[i-6],'\\\(',n=2)[,2]=='physical_activity)'){
    get_resid(last_AFR,last_AFR,'acttype',i)
  } else {
    get_resid(last_AFR,last_AFR,'none',i)
  }
}
#Function 2 :get r2
get_r2_fun<-function(model,
                     type1,
                     type2,
                     file_name,
                     pheno_num){
  require(bigreadr)
  require(Metrics)
  pred_tot <- vector()
  for(chr in 1: 22){
    pred_chr_str <- paste0('/public/home/biostat07/AFR/output_summary/',file_name,'.effect/',
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
    pheno_value<-fread2(paste0('/public/home/biostat07/AFR/liner_model/rstandard/',file_name,'.txt'),header=F)[,1]
    pheno_sum<-data.frame(pheno_tot,pheno_value)
    pheno_sum<-na.omit(pheno_sum)
    r2_sum<-as.vector(aaply(1:100,1,r2_fun <- function(xvar) {
      set.seed(20230508+xvar+pheno_num-3)
      mysample<-sort(sample(nrow(pheno_sum),500,replace=F))
      myvalue<-pheno_sum[mysample,]
      r2<-cor(myvalue[,1],myvalue[,2])^2
    }))
    write.table(r2_sum,
                file=paste0('/public/home/biostat07/AFR/output_summary/',file_name,
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