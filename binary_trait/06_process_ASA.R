library(bigreadr)
library(plyr)
library(dplyr)
library(stringr)

# set paramters
PHENO_FILE <- "/public/home/Datasets/ukb/ukb47503.csv.gz"
SAMPLE_PATH <- '/public/home/biostat07/moment/meta_info_20220315.csv'
VAR_PATH <- "/public/home/biostat07/moment/moment_ukbb.csv"

#extract summary and udi-code of variable
sample_list <- fread2(SAMPLE_PATH)
var_list <- fread2(VAR_PATH) 
var_list <- alply(var_list, 2, function(xx) {
  xx[xx==""] <- NA
  return(xx)
}) %>% do.call("cbind", .)
var_list$sample_size <- as.numeric(sample_list$sample_size)
## select non-ukbb traits
var_list <- var_list[which(var_list$UKBB == 'N' & is.na(var_list$case.control) == FALSE),]
## select sample size > 2000
var_list <- var_list[-which(var_list$sample_size<2000),]
## delete traits with specific subgroup variables 
var_list <- var_list[order(var_list$summary),]
var_list <- var_list[-c(31,32,34,40,71,76,80:83,87,94,97,98,102,103,106,107,110,111,117,
                        118,130,155,156,157,158,164,165,181,182),]

ICD10_main <- paste0("41202-0.", 0:74)
df_eid <- fread2(PHENO_FILE, select = c("eid","31-0.0",'21022-0.0','21001-0.0'))
df_ICD10 <- fread2(PHENO_FILE, select = ICD10_main)
#load file
load('/public/home/biostat07/Five_binary_validation/temp_data/binary_pheno.RData')
colnames(binary_pheno)<-var_list$ID
binary_all<-as.data.frame(cbind(df_eid,Diabetes,binary_pheno))
rownames(binary_all)<-paste0('S',binary_all$eid)
#Screen out the eid-code of the ASA population
ASA_eid<-fread2('/public/home/Datasets/ukb/pheno/eid_ASA.txt',col.names=c('eid','eid1'))
ASA_eid<-ASA_eid[,1]
#ASA Sorted by fixed number
binary_ASA<-binary_all[paste0('S',ASA_eid),]
colnames(binary_ASA)[2:4]<-c('sex','age','BMI')

##Add covariate adjustment
temp_list<-var_list[,-c(2,3,14,15,17,18)]
temp_list$summary=temp_list$ID
temp_list<-temp_list[,-c(12)]
temp_name<-c(temp_list$summary)
summary_adjust_name <- aaply(c(1: nrow(temp_list)), 1, function(x){
  
  tmp <- unlist(temp_list[x,])
  if(sum(is.na(tmp)) == 10){
    
    tmp_name <- temp_list$summary[x]
  } else {
    
    tmp_name1 <- paste0(tmp[1],'(')
    tmp_name2 <- paste0(tmp[-1][which(!is.na(tmp[-1]))], collapse = ',')
    tmp_name <- paste0(tmp_name1, tmp_name2, ")")
  }
  return(tmp_name)
}) 
summary_adjust_name<-as.vector(summary_adjust_name)
#get sample
binary_female_sample<-binary_ASA[which(binary_ASA$sex==0),]
binary_male_sample<-binary_ASA[which(binary_ASA$sex==1),]
female_sort<-rownames(binary_female_sample)
male_sort<-rownames(binary_male_sample)
binary_nosex_sample<-binary_ASA
nosex_sort<-rownames(binary_ASA)
binary_T1D_sample<-binary_nosex_sample[which(binary_nosex_sample[,141]==1),]
binary_T2D_sample<-binary_nosex_sample[which(binary_nosex_sample[,142]==1),]
binary_diabetes_sample<-binary_nosex_sample[which(binary_nosex_sample[,5]==1),]
T1D_sort<-rownames(binary_T1D_sample)
T2D_sort<-rownames(binary_T2D_sample)
diabetes_sort<-rownames(binary_diabetes_sample)

save(nosex_sort,file = '/public/home/biostat07/ASA_binary/temp/nosex_sort.RData')
save(summary_adjust_name,file = '/public/home/biostat07/ASA_binary/temp/summary_adjust_name.RData')
save(binary_female_sample,file = '/public/home/biostat07/ASA_binary/temp/binary_female_sample.RData')
save(binary_male_sample,file = '/public/home/biostat07/ASA_binary/temp/binary_male_sample.RData')
save(binary_nosex_sample,file = '/public/home/biostat07/ASA_binary/temp/binary_nosex_sample.RData')
save(binary_T1D_sample,file = '/public/home/biostat07/ASA_binary/temp/binary_T1D_sample.RData')
save(binary_T2D_sample,file = '/public/home/biostat07/ASA_binary/temp/binary_T2D_sample.RData')
save(binary_diabetes_sample,file = '/public/home/biostat07/ASA_binary/temp/binary_diabetes_sample.RData')
save(binary_ASA,file = '/public/home/biostat07/ASA_binary/temp/binary_ASA.RData')
save(temp_name,file = '/public/home/biostat07/ASA_binary/temp/temp_name.RData')