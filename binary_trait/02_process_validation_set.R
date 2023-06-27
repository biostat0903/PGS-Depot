library(bigreadr)
library(plyr)
library(dplyr)
library(stringr)

#load file
load('/public/home/biostat07/Five_binary_validation/temp_data/validation_dat.RData')

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
  
  coef <- coef(lm_model)
  write.table(coef,
              file=paste0('/public/home/biostat07/Five_binary_validation/output_summary/',
                          temp_name[xvar-5],'.effect/Coef/',
                          temp_name[xvar-5],'.txt'),
              row.names = F, col.names = F, quote = F)
  extract_eid <- extract_eid[which(extract_eid$eid %in% dat_sample[,1]),]
  rownames(extract_eid)<-paste0('S',extract_eid$eid)
  pheno_eid <- extract_eid[nosex_sort, c(1, 2)]
  extract_eid <- extract_eid[nosex_sort, c(1, ncol(extract_eid))]
  extract_qqnorm<-data.frame(binary_nosex_sample[,1])
  extract_qqnorm <- cbind(extract_qqnorm, extract_eid[,2])
  write.table(extract_qqnorm[,2],
              file = paste0('/public/home/biostat07/Five_binary_validation/validation/rstandard/',phenoname[xvar-5]), 
              row.names = F, col.names = F, quote = F)
  write.table(pheno_eid[,2],
              file = paste0('/public/home/biostat07/Five_binary_validation/validation/pheno_value_eid/',phenoname[xvar-5]), 
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