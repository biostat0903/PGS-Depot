rm(list=ls())
library(plyr)
library(dplyr)
library(bigreadr)
library(stringr)

# Set paramters
PHENO_FILE <- "/public/home/Datasets/ukb/ukb47503.csv.gz"
SAMPLE_PATH <- '/public/home/biostat07/moment/meta_info_20220315.csv'
VAR_PATH <- "/public/home/biostat07/moment/moment_ukbb.csv"

# Extract summary and udi-code of variable
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

# Screen out the eid-code of the EUR population
EUR_eid <- fread2('/public/home/Datasets/ukb/pheno/eid_EUR.txt')[, 1]
var <- unique(c('eid',"31-0.0",'21022-0.0','884-0.0',
                '904-0.0','6164-0.0', var_list$UDI))
var <- na.omit(var)
pheno_list <- fread2(PHENO_FILE, select = var)
pheno_list[which(pheno_list[,4] %in% c(-3, -1)), 4] <- NA
pheno_list[which(pheno_list[,5] %in% c(-3, -1)), 5] <- NA
pheno_list <- pheno_list[which(pheno_list$eid %in% EUR_eid),]
rownames(pheno_list) <- paste0('S', pheno_list$eid)
EUR <- pheno_list[paste0('S', EUR_eid),]

#get the number of missing columns in each column
na_dat <- alply(EUR, 2, function(x){

  a = sum(is.na(x)) / nrow(EUR)
  return(a)
}) %>% do.call("rbind", .) %>% cbind(var, .)
colnames(na_dat)<-c('name','delete')
var_list1 <- merge(var_list, na_dat, by.x = "UDI", by.y = "name" ,all.x=T)
var_list2 <- var_list1[,match(colnames(var_list),colnames(var_list1))]
var_list2 <- cbind(var_list2,var_list1$delete)
var_list2 <- var_list2[match(var_list$ID,var_list2$ID),]
var_list <- var_list2
colnames(var_list)[ncol(var_list)]<-'miss_rate'
TD<-EUR[,38]/EUR[,39]
TD_delete<-sum(is.na(TD))/nrow(EUR)
for (i in 117:128){
  var_list$miss_rate[i]=TD_delete
}

# Delete phenotypes with missing numbers exceeding 0.5
na_names <- as.vector(na_dat[which(na_dat[,2] > 0.5),1])
var <- var[-which(var %in% na_names)]
EUR <- EUR[,-which(colnames(EUR) %in% na_names)]
var_list <- var_list[-which(var_list$UDI %in% na_names),]

# Add covariable information
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
EUR$'48-0.0/49-0.0'<-EUR$'48-0.0'/EUR$'49-0.0'
eur_last <- alply(var_list$UDI, 1, function(x)
  EUR[, colnames(EUR) == x]) %>% do.call("cbind", .)
colnames(eur_last) <- var_list$UDI

eur_last<-as.data.frame(eur_last)
eur_frame<-data.frame(EUR[,c(1:6)],eur_last)
colnames(eur_frame)<-c('eid','sex','age','activity1','activity2',
                       'act_type',summary_adjust_name)
eur_frame$activity<-eur_frame[,4]+eur_frame[,5]
#Select female EUR id and male EUR id
EUR_female <- eur_frame[which(eur_frame[,2] == 0),]
EUR_male <- eur_frame[which(eur_frame[,2] == 1),]

# Sample validation set
set.seed(20230407)
sample_female <- sort(sample(nrow(EUR_female), 25000, replace = F))
set.seed(19110405)
sample_male <- sort(sample(nrow(EUR_male), 25000, replace = F))
last_female<-EUR_female[sample_female,]
female_sort<-paste0('S',last_female$eid)
last_male<-EUR_male[sample_male,]
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

# make plink.txt to screen out genotype
plink_female<-data.frame(last_female$eid,last_female$eid)
plink_male<-data.frame(last_male$eid,last_male$eid)
plink_nosex<-data.frame(last_nosex$eid,last_nosex$eid)
plink_female_low50<-data.frame(last_female_low50$eid,last_female_low50$eid)
plink_female_over50<-data.frame(last_female_over50$eid,last_female_over50$eid)
plink_male_low50<-data.frame(last_male_low50$eid,last_male_low50$eid)
plink_male_over50<-data.frame(last_male_over50$eid,last_male_over50$eid)
plink_active<-data.frame(last_active$eid,last_active$eid)
plink_inactive<-data.frame(last_inactive$eid,last_inactive$eid)

# Output
write.table(last_female,
            file = "/public/home/biostat07/Five_people/mysample/get_eid/get_female_eid/last_female.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_male,
            file = "/public/home/biostat07/Five_people/mysample/get_eid/get_male_eid/last_male.txt", 
            row.names = F, col.names = T, quote = F)
write.table(last_nosex,
            file = "/public/home/biostat07/Five_people/mysample/get_eid/get_nosex_eid/last_nosex.txt", 
            row.names = F, col.names = T, quote = F)
write.table(plink_female,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_female.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_male,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_male.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_nosex,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_nosex.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_female_low50,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_female_low50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_male_low50,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_male_low50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_female_over50,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_female_over50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_male_over50,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_male_over50.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_active,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_active.txt", 
            row.names = F, col.names = F, quote = F)
write.table(plink_inactive,
            file = "/public/home/biostat07/Five_people/mysample/get_plink_eid/plink_inactive.txt", 
            row.names = F, col.names = F, quote = F)

# Save data
save(eur_frame, nosex_sort, last_nosex, last_female, last_male,
     last_male_low50, last_male_over50, last_female_low50,
     last_female_over50, last_active, last_inactive, temp_name, 
     summary_adjust_name, 
     file = '/public/home/biostat07/Five_people/tmp_data/RDATA/validation_dat.RData')
