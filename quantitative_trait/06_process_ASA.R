rm(list=ls())
library(plyr)
library(dplyr)
library(bigreadr)
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
## select specific columns
var_list <- var_list[, c(1:13,16,17,18)]
## select non-ukbb traits
var_list <- var_list[union(which(var_list$UKBB == 'N' & is.na(var_list$UDI) == FALSE), which(var_list$UKBB == 'N' & is.na(var_list$ratio) == FALSE)),]
## select sample size > 2000
var_list <- var_list[which(var_list$sample_size >= 2000),]
## delete traits with specific subgroup variables 
var_list <- var_list[-c(40:49,51:61),]
var_list <- var_list[order(var_list$UDI),]

# Screen out the eid-code of the ASA population
ASA_eid <- fread2('/public/home/Datasets/ukb/pheno/eid_ASA.txt')[, 1]
var <- unique(c('eid',"31-0.0",'21022-0.0','884-0.0',
                '904-0.0','6164-0.0', var_list$UDI))
var <- na.omit(var)
pheno_list <- fread2(PHENO_FILE, select = var)
pheno_list[which(pheno_list[,4] %in% c(-3, -1)), 4] <- NA
pheno_list[which(pheno_list[,5] %in% c(-3, -1)), 5] <- NA
pheno_list <- pheno_list[which(pheno_list$eid %in% ASA_eid),]
rownames(pheno_list) <- paste0('S', pheno_list$eid)
ASA <- pheno_list[paste0('S', ASA_eid),]

#get the number of missing columns in each column
na_dat <- alply(ASA, 2, function(x){
  
  a = sum(is.na(x)) / nrow(ASA)
  return(a)
}) %>% do.call("rbind", .) %>% cbind(var, .)

colnames(na_dat)<-c('name','delete')
var_list1 <- merge(var_list, na_dat, by.x = "UDI", by.y = "name" ,all.x=T)
var_list2 <- var_list1[,match(colnames(var_list),colnames(var_list1))]
var_list2 <- cbind(var_list2,var_list1$delete)
var_list2 <- var_list2[match(var_list$ID,var_list2$ID),]
var_list <- var_list2
colnames(var_list)[ncol(var_list)]<-'miss_rate'

TD<-ASA[,38]/ASA[,39]
TD_delete<-sum(is.na(TD))/nrow(ASA)
for (i in 117:128){
  var_list$miss_rate[i]=TD_delete
}
# Delete phenotypes with missing numbers exceeding 0.5
na_names <- as.vector(na_dat[which(na_dat[,2] > 0.5),1])
var <- var[-which(var %in% na_names)]
ASA <- ASA[,-which(colnames(ASA) %in% na_names)]
var_list <- var_list[-which(var_list$UDI %in% na_names),]

# Add covariate adjustment
temp_list <- var_list[,-c(2,3,15,16,17)]
temp_list$summary <- temp_list$ID
temp_list <- temp_list[, -c(12)]
temp_name <- temp_list$summary

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
var_list$UDI[is.na(var_list$UDI)] <- var_list$ratio[is.na(var_list$UDI)]
ASA$'48-0.0/49-0.0'<-ASA$'48-0.0'/ASA$'49-0.0'
ASA_last <- alply(var_list$UDI, 1, function(x)
  ASA[, colnames(AFR) == x]) %>% do.call("cbind", .)
colnames(ASA_last) <- var_list$UDI

ASA_last<-as.data.frame(ASA_last)
ASA_frame<-data.frame(ASA[,c(1:6)],ASA_last)
colnames(AFR_frame)<-c('eid','sex','age','activity1','activity2',
                       'act_type',summary_adjust_name)
ASA_frame$activity<-ASA_frame[,4]+ASA_frame[,5]
#Select female EUR id and male EUR id
ASA_female <- ASA_frame[which(ASA_frame[,2] == 0),]
ASA_male <- ASA_frame[which(ASA_frame[,2] == 1),]
ASA_nosex <- ASA_frame
female_sort<-paste0('S',ASA_female$eid)
male_sort<-paste0('S',ASA_male$eid)
nosex_sort<-paste0('S',ASA_nosex$eid)
save(ASA_frame,file = '/public/home/biostat07/ASA/temp/ASA_frame.RData')
save(nosex_sort,file = '/public/home/biostat07/ASA/temp/nosex_sort.RData')
save(ASA_nosex,file = '/public/home/biostat07/ASA/temp/last_nosex.RData')
save(ASA_female,file = '/public/home/biostat07/ASA/temp/last_female.RData')
save(ASA_male,file = '/public/home/biostat07/ASA/temp/last_male.RData')
save(temp_name,file = '/public/home/biostat07/ASA/temp/temp_name.RData')
save(summary_adjust_name,file = '/public/home/biostat07/ASA/temp/summary_adjust_name.RData')