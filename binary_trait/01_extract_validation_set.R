library(xlsx)
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

#1 Artial fibrillation
ind_AF <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('I48',c(0:2,9)))
})))))
AF <- rep(0, nrow(df_eid))
AF[ind_AF] <- 1

#2 T2D
ind_T2D <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'E11')
})))))
T2D <- rep(0, nrow(df_eid))
T2D[ind_T2D] <- 1

#3 diabetes incidence
ind_Diabetes <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('E',10:14))
})))))
Diabetes <- rep(0, nrow(df_eid))
Diabetes[ind_Diabetes] <- 1

#4 Cardiovascular disease
ind_Cardiovascular <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% c(paste0('I0',5:9),'I11',paste0('I2',0:7),paste0('I',30:52)))
})))))
Cardiovascular  <- rep(0, nrow(df_eid))
Cardiovascular[ind_Cardiovascular] <- 1

#5 Coronary heart disease
ind_CHD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('I2',0:5))
})))))
CHD  <- rep(0, nrow(df_eid))
CHD[ind_CHD] <- 1

#6 Heart failure
ind_HF <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'I50')
})))))
HF  <- rep(0, nrow(df_eid))
HF[ind_HF] <- 1

#7 Breast cancer
ind_BC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C50')
})))))
BC  <- rep(0, nrow(df_eid))
BC[ind_BC] <- 1

#8 Cancer
ind_Cancer <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0("C", 0:97))
})))))
Cancer  <- rep(0, nrow(df_eid))
Cancer[ind_Cancer] <- 1

#9 Prostate cancer
ind_PC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C61')
})))))
PC  <- rep(0, nrow(df_eid))
PC[ind_PC] <- 1

#10 Celiac disease
ind_Celia <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% c(paste0("R", c(10,18,19)),paste0('K4',c(0,3,5,6)),'C48'))
})))))
Celia  <- rep(0, nrow(df_eid))
Celia[ind_Celia] <- 1

#11 Rheumatoid arthritis
ind_RA <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0("M0", 5:6))
})))))
RA  <- rep(0, nrow(df_eid))
RA[ind_RA] <- 1

#12 Asthma
ind_Asthma <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'J45')
})))))
Asthma  <- rep(0, nrow(df_eid))
Asthma[ind_Asthma] <- 1

#13 Ulcerative colitis
ind_UC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'K51')
})))))
UC  <- rep(0, nrow(df_eid))
UC[ind_UC] <- 1

#14 Coronary artery disease
ind_CAD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('I2',0:5))
})))))
CAD  <- rep(0, nrow(df_eid))
CAD[ind_CAD] <- 1

#15 Multiple sclerosis
ind_MS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'G35')
})))))
MS  <- rep(0, nrow(df_eid))
MS[ind_MS] <- 1

#16 Bipolar disorder
ind_BD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'F31')
})))))
BD  <- rep(0, nrow(df_eid))
BD[ind_BD] <- 1

#17 Schizophrenia
ind_Schizophrenia <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'F20')
})))))
Schizophrenia  <- rep(0, nrow(df_eid))
Schizophrenia[ind_Schizophrenia] <- 1

#18 Major depressive disorder
ind_MDS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('F32',2:3))
})))))
MDS  <- rep(0, nrow(df_eid))
MDS[ind_MDS] <- 1

#19 obesity
ind_obesity <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('E',65:68))
})))))
obesity  <- rep(0, nrow(df_eid))
obesity[ind_obesity] <- 1

#20 Hip or knee osteoarthritis
ind_HKO <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('M',c(16,17)))
})))))
HKO  <- rep(0, nrow(df_eid))
HKO[ind_HKO] <- 1

#21 Hip osteoarthritis
ind_HO <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'M16')
})))))
HO  <- rep(0, nrow(df_eid))
HO[ind_HO] <- 1

#22 Primary biliary cholangitis
ind_PBCS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K743')
})))))
PBCS  <- rep(0, nrow(df_eid))
PBCS[ind_PBCS] <- 1

#23 Ischemic stroke
ind_stroke <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'I63')
})))))
stroke  <- rep(0, nrow(df_eid))
stroke[ind_PBC] <- 1

#24 Cardioembolic ischemic stroke
ind_CIS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('I63',c(1,4)))
})))))
CIS  <- rep(0, nrow(df_eid))
CIS[ind_CIS] <- 1

#25 Large-vessel disease ischemic stroke

#26 Small-vessel disease ischemic stroke

#27 Gout
ind_Gout <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'M10')
})))))
Gout  <- rep(0, nrow(df_eid))
Gout[ind_Gout] <- 1

#28 Autism spectrum disorders
ind_ASD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('F84',0:1))
})))))
ASD  <- rep(0, nrow(df_eid))
ASD[ind_ASD] <- 1

#29 Attention deficit-hyperactivity disorder
ind_ADHD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'F90')
})))))
ADHD  <- rep(0, nrow(df_eid))
ADHD[ind_ADHD] <- 1

#30 Narcolepsy
ind_Narcolepsy <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c('F511','G471'))
})))))
Narcolepsy  <- rep(0, nrow(df_eid))
Narcolepsy[ind_Narcolepsy] <- 1

#31 Obesity
ind_Obesity <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'E66')
})))))
Obesity  <- rep(0, nrow(df_eid))
Obesity[ind_Obesity] <- 1

#32 Overweight

#33 Juvenile idiopathic arthritis
ind_JIA <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('M08',c(0,4)))
})))))
JIA  <- rep(0, nrow(df_eid))
JIA[ind_JIA] <- 1

#34 Ankylosing spondylitis
ind_Ankylosing <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'M45')
})))))
Ankylosing  <- rep(0, nrow(df_eid))
Ankylosing[ind_Ankylosing] <- 1

#35 Alzheimer
ind_Alzheimer <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'G30')
})))))
Alzheimer  <- rep(0, nrow(df_eid))
Alzheimer[ind_Alzheimer] <- 1

#36 Anorexia nervosa
ind_Anorexia <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('F50',0:1))
})))))
Anorexia  <- rep(0, nrow(df_eid))
Anorexia[ind_Anorexia] <- 1

#37 Deep intracerebral hemorrhage stroke
ind_DIHS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('I6',0:2))
})))))
DIHS  <- rep(0, nrow(df_eid))
DIHS[ind_DIHS] <- 1

#38 Intracerebral hemorrhage stroke

#39 Lobar intracerebral hemorrhage stroke

#40 Clozapine-Induced Agranulocytosis/Granulocytopenia
ind_Granulocytopenia <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'D720')
})))))
Granulocytopenia  <- rep(0, nrow(df_eid))
Granulocytopenia[ind_Granulocytopenia] <- 1

#41 Longevity(living up to 90)

#42 T1D
ind_T1D <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'E10')
})))))
T1D  <- rep(0, nrow(df_eid))
T1D[ind_T1D] <- 1

#43 Neuroticism
ind_Neuroticism <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('F4',0:8))
})))))
Neuroticism  <- rep(0, nrow(df_eid))
Neuroticism[ind_Neuroticism] <- 1

#44 Crohn's disease
ind_Crohn <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'K50')
})))))
Crohn  <- rep(0, nrow(df_eid))
Crohn[ind_Crohn] <- 1

#45 Inflammatory bowel disease
ind_IFBD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('K5',c(0:2,8)))
})))))
IFBD  <- rep(0, nrow(df_eid))
IFBD[ind_IFBD] <- 1

#46 Myocardial infarction
ind_MI <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('I2',1:3))
})))))
MI  <- rep(0, nrow(df_eid))
MI[ind_MI] <- 1

#47 Primary biliary cirrhosis
ind_PBCH <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K743')
})))))
PBCH  <- rep(0, nrow(df_eid))
PBCH[ind_PBCH] <- 1

#48 Systemic lupus erythematosus
ind_SLET <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'M32')
})))))
SLET  <- rep(0, nrow(df_eid))
SLET[ind_SLET] <- 1

#49 Sarcoidosis (lofgren's syndrome)
ind_Sarcoidosis <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'D86')
})))))
Sarcoidosis  <- rep(0, nrow(df_eid))
Sarcoidosis[ind_Sarcoidosis] <- 1

#50 Chronic kidney disease
ind_CKD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'N18')
})))))
CKD  <- rep(0, nrow(df_eid))
CKD[ind_CKD] <- 1

#51 Small vessel disease ischemic stroke

#52 Periodontal complex trait 1
ind_PCT1 <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K052')
})))))
PCT1  <- rep(0, nrow(df_eid))
PCT1[ind_PCT1] <- 1

#53 Periodontal complex trait 2
ind_PCT2 <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K053')
})))))
PCT2  <- rep(0, nrow(df_eid))
PCT2[ind_PCT2] <- 1

#54 Periodontal complex trait 3
ind_PCT3 <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K054')
})))))
PCT3  <- rep(0, nrow(df_eid))
PCT3[ind_PCT3] <- 1

#55 Periodontal complex trait 4
ind_PCT4 <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K055')
})))))
PCT4  <- rep(0, nrow(df_eid))
PCT4[ind_PCT4] <- 1

#56 Periodontal complex trait 5
ind_PCT5 <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K056')
})))))
PCT5  <- rep(0, nrow(df_eid))
PCT5[ind_PCT5] <- 1

#57 Amyotrophic lateral sclerosis
ind_ALS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G122')
})))))
ALS  <- rep(0, nrow(df_eid))
ALS[ind_ALS] <- 1

#56 Vitiligo
ind_Vitiligo <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'L80')
})))))
Vitiligo  <- rep(0, nrow(df_eid))
Vitiligo[ind_Vitiligo] <- 1

#57 IgA deficiency
ind_IgA <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'D802')
})))))
IgA  <- rep(0, nrow(df_eid))
IgA[ind_IgA] <- 1

#58 Sciatica
ind_Sciatica <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% paste0('M54',3:4))
})))))
Sciatica  <- rep(0, nrow(df_eid))
Sciatica[ind_Sciatica] <- 1

#59 Cluster headache
ind_Cheadache <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G440')
})))))
Cheadache  <- rep(0, nrow(df_eid))
Cheadache[ind_Cheadache] <- 1

#60 Primary sclerosing cholangitis
ind_PSCT <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K830')
})))))
PSCT  <- rep(0, nrow(df_eid))
PSCT[ind_PSCT] <- 1

#61 Serous boarderline ovarian cancer
ind_SBOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'D391')
})))))
SBOC  <- rep(0, nrow(df_eid))
SBOC[ind_SBOC] <- 1

#62 Clear cell ovarian cancer
ind_CCOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
CCOC  <- rep(0, nrow(df_eid))
CCOC[ind_CCOC] <- 1

#63 Epithelial ovarian cancer
ind_EOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
EOC  <- rep(0, nrow(df_eid))
EOC[ind_EOC] <- 1

#64 High grade serous ovarian cancer
ind_HGSOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
HGSOC  <- rep(0, nrow(df_eid))
HGSOC[ind_HGSOC] <- 1

#65 Invasive ovarian cancer
ind_IOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
IOC  <- rep(0, nrow(df_eid))
IOC[ind_IOC] <- 1

#66 Low grade and borderline serous ovarian cancer
ind_LGBSOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'D391')
})))))
LGBSOC  <- rep(0, nrow(df_eid))
LGBSOC[ind_LGBSOC] <- 1

#67 Low grade serous ovarian cancer
ind_LGSOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
LGSOC  <- rep(0, nrow(df_eid))
LGSOC[ind_LGSOC] <- 1

#68 Mucinous ovarian cancer
ind_MOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
MOC  <- rep(0, nrow(df_eid))
MOC[ind_MOC] <- 1

#69 Serous invasive ovarian cancer
ind_SIOC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C56')
})))))
SIOC  <- rep(0, nrow(df_eid))
SIOC[ind_SIOC] <- 1

#70 Cervical cancer
ind_Cervical <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C53')
})))))
Cervical  <- rep(0, nrow(df_eid))
Cervical[ind_Cervical] <- 1

#71 Neuroblastoma_rep(11q deletion)
ind_Neuroblastoma <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'C749')
})))))
Neuroblastoma  <- rep(0, nrow(df_eid))
Neuroblastoma[ind_Neuroblastoma] <- 1

#72 Sporadic amyotrophic lateral sclerosis
ind_SALS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G122')
})))))
SALS  <- rep(0, nrow(df_eid))
SALS[ind_SALS] <- 1

#73 Rotator cuff injury
ind_RCI <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c('S460','M751'))
})))))
RCI  <- rep(0, nrow(df_eid))
RCI[ind_RCI] <- 1

#74 Open-angle glaucoma
ind_OAG <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'H401')
})))))
OAG  <- rep(0, nrow(df_eid))
OAG[ind_OAG] <- 1

#75 Colorectal cancer
ind_Colorectal <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'C20')
})))))
Colorectal  <- rep(0, nrow(df_eid))
Colorectal[ind_Colorectal] <- 1

#76 Juvenile idiopathic arthritis with vs without uveitis
ind_JIAU <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'M080')
})))))
JIAU  <- rep(0, nrow(df_eid))
JIAU[ind_JIAU] <- 1

#79 Plantar fasciitis
ind_PF <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'M722')
})))))
PF  <- rep(0, nrow(df_eid))
PF[ind_PF] <- 1

#80 Neuromyelitis optica
ind_NO <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G360')
})))))
NO <- rep(0, nrow(df_eid))
NO[ind_NO] <- 1

#81 Schizophrenia/Bipolar disorder
ind_BSchizophrenia <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'F250')
})))))
BSchizophrenia <- rep(0, nrow(df_eid))
BSchizophrenia[ind_BSchizophrenia] <- 1

#82 Anti-epstein-barr virus early antigen (ea) IgG seropositivity
ind_epstein <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'B279')
})))))
epstein <- rep(0, nrow(df_eid))
epstein[ind_epstein] <- 1

#83 Anti-cytomegalovirus IgG seropositivity
ind_cytomegalovirus <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'B259')
})))))
cytomegalovirus <- rep(0, nrow(df_eid))
cytomegalovirus[ind_cytomegalovirus] <- 1

#84 Anti-herpes simplex virus 1 IgG seropositivity
ind_AHSV <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'B009')
})))))
AHSV <- rep(0, nrow(df_eid))
AHSV[ind_AHSV] <- 1

#85 Anti-varicella zoster virus IgG seropositivity
ind_AVZV <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'B018')
})))))
AVZV <- rep(0, nrow(df_eid))
AVZV[ind_AVZV] <- 1

#86 Anti-helicobacter pylori IgG seropositivity
ind_AHP <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'B968')
})))))
AHP <- rep(0, nrow(df_eid))
AHP[ind_AHP] <- 1

#87 Anti-mumps virus IgG seropositivity
ind_AMV <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'B26')
})))))
AMV <- rep(0, nrow(df_eid))
AMV[ind_AMV] <- 1

#88 Anti-rubella virus IgG seropositivity
ind_ARV <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'B069')
})))))
ARV <- rep(0, nrow(df_eid))
ARV[ind_ARV] <- 1

#89 Biliary atresia
ind_BA <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'Q44')
})))))
BA <- rep(0, nrow(df_eid))
BA[ind_BA] <- 1

#90 Insomnia
ind_Insomnia <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c('G470','F510'))
})))))
Insomnia <- rep(0, nrow(df_eid))
Insomnia[ind_Insomnia] <- 1

#91 Childhood steroid-sensitive nephrotic syndrome
ind_CSSNS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c('G470','F510'))
})))))
CSSNS <- rep(0, nrow(df_eid))
CSSNS[ind_CSSNS] <- 1

#92 Early progression to active pulmonary tuberculosis in Mycobacterium tuberculosis-infected individuals
ind_MTII <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c('R761','Z111'))
})))))
MTII <- rep(0, nrow(df_eid))
MTII[ind_MTII] <- 1

#93 Eosinophilic granulomatosis with polyangiitis
ind_EGPA <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'M301')
})))))
EGPA <- rep(0, nrow(df_eid))
EGPA[ind_EGPA] <- 1

#94 COVID-19
ind_COVID19 <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'U071')
})))))
COVID19 <- rep(0, nrow(df_eid))
COVID19[ind_COVID19] <- 1

#95 Pancreatic cancer
ind_Pancreatic <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c(paste0('C25',0:9),paste0('D13',6:7)))
})))))
Pancreatic <- rep(0, nrow(df_eid))
Pancreatic[ind_Pancreatic] <- 1

#96 Addison's disease
ind_Addison <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c(paste0('E27',1:2)))
})))))
Addison <- rep(0, nrow(df_eid))
Addison[ind_Addison] <- 1

#97 HTLV-1 associated myelopathy
ind_HAM <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G041')
})))))
HAM <- rep(0, nrow(df_eid))
HAM[ind_HAM] <- 1

#99 Psoriasis
ind_Psoriasis <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'L40')
})))))
Psoriasis <- rep(0, nrow(df_eid))
Psoriasis[ind_Psoriasis] <- 1

#100 Hirschsprung disease
ind_Hirschsprung <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'Q431')
})))))
Hirschsprung <- rep(0, nrow(df_eid))
Hirschsprung[ind_Hirschsprung] <- 1

#101 Diabetic kidney disease in diabetes (ESRD vs. no ESRD)
ind_DKD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) %in% c('E102','E112'))
})))))
DKD <- rep(0, nrow(df_eid))
DKD[ind_DKD] <- 1

#102 End-stage renal disease in type 2 diabetes
ind_ESRD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'E112')
})))))
ESRD <- rep(0, nrow(df_eid))
ESRD[ind_ESRD] <- 1

#103 Childhood absence epilepsy
ind_CAE <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G408')
})))))
CAE <- rep(0, nrow(df_eid))
CAE[ind_CAE] <- 1

#104 Focal epilepsy (with hippocampal sclerosis)
ind_FE <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G401')
})))))
FE <- rep(0, nrow(df_eid))
FE[ind_FE] <- 1

#105 Polycystic ovary syndrome
ind_POS <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'E282')
})))))
POS <- rep(0, nrow(df_eid))
POS[ind_POS] <- 1

#106 Adult asthma
ind_asthma <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'J45')
})))))
asthma <- rep(0, nrow(df_eid))
asthma[ind_asthma] <- 1

#107 Renal cell carcinoma
ind_RCC <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) %in% paste0('C6',4:8))
})))))
RCC <- rep(0, nrow(df_eid))
RCC[ind_RCC] <- 1

#108 	Nonalcoholic fatty liver disease
ind_NAFL <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'K760')
})))))
NAFL <- rep(0, nrow(df_eid))
NAFL[ind_NAFL] <- 1

#109 Retinitis pigmentosa
ind_pigmentosa <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'H355')
})))))
pigmentosa <- rep(0, nrow(df_eid))
pigmentosa[ind_pigmentosa] <- 1

#110 Dementia with Lewy bodies
ind_DLB <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G318')
})))))
DLB <- rep(0, nrow(df_eid))
DLB[ind_DLB] <- 1

#111 Kawasaki disease
ind_Kawasaki <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'M303')
})))))
Kawasaki <- rep(0, nrow(df_eid))
Kawasaki[ind_Kawasaki] <- 1

#112 Lacunar stroke
ind_Lacunar <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'I638')
})))))
Lacunar <- rep(0, nrow(df_eid))
Lacunar[ind_Lacunar] <- 1

#113 latent autoimmune diabetes in adults
ind_LADA <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,3) == 'E13')
})))))
LADA <- rep(0, nrow(df_eid))
LADA[ind_LADA] <- 1

#114 cystic fibrosis associated meconium ileus
ind_CFAMI <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'E841')
})))))
CFAMI <- rep(0, nrow(df_eid))
CFAMI[ind_CFAMI] <- 1

#115 late-onset Alzheimers disease
ind_LOAD <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'G301')
})))))
LOAD <- rep(0, nrow(df_eid))
LOAD[ind_LOAD] <- 1

#116 lymphangioleiomyomatosis
ind_lymphangioleiomyomatosis <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'J848')
})))))
lymphangioleiomyomatosis <- rep(0, nrow(df_eid))
lymphangioleiomyomatosis[ind_lymphangioleiomyomatosis] <- 1

#117 spontaneous preterm birth
ind_SPB <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'O601')
})))))
SPB <- rep(0, nrow(df_eid))
SPB[ind_SPB] <- 1

#118 idiopathic pulmonary fibrosis
ind_IPF <- sort(unique(as.vector(unlist(lapply(df_ICD10,function(xvar){
  which(substr(xvar,1,4) == 'J841')
})))))
IPF <- rep(0, nrow(df_eid))
IPF[ind_IPF] <- 1

binary_pheno<-data.frame(Addison,Addison,asthma,Alzheimer,Alzheimer,Alzheimer,Alzheimer,Alzheimer,Alzheimer,
                         ALS,ALS,ALS,Ankylosing,Anorexia,Anorexia,JIA,Asthma,Asthma,AF,ADHD,ADHD,ASD,ASD,ASD,ASD,
                         BA,BD,BD,BD,BD,BC,CIS,CIS,Celia,Cervical,CAE,CSSNS,CKD,CKD,CCOC,Colorectal,CAD,CAD,CAD,
                         MI,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,
                         COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,COVID19,Crohn,CFAMI,DIHS,
                         DLB,DKD,ESRD,EGPA,EGPA,EOC,FE,Gout,HGSOC,HKO,HO,Hirschsprung,IPF,IgA,IFBD,Insomnia,
                         IOC,stroke,stroke,Kawasaki,Lacunar,LADA,LOAD,LGBSOC,LGSOC,MDS,MDS,MDS,MOC,MS,MS,MI,Narcolepsy,
                         Neuroticism,NAFL,obesity,obesity,obesity,OAG,Pancreatic,Pancreatic,PF,POS,PBCH,PSCT,PC,Psoriasis,
                         RCC,RCC,RA,RA,RA,RCI,Sarcoidosis,Schizophrenia,Schizophrenia,Schizophrenia,Schizophrenia,
                         Schizophrenia,BSchizophrenia,Sciatica,SBOC,SIOC,SPB,SALS,SLET,SLET,T1D,T2D,T2D,T2D,T2D,T2D,T2D,
                         T2D,T2D,T2D,T2D,T1D,UC,UC,Vitiligo,Vitiligo)
save(binary_pheno,file = '/public/home/biostat07/Five_binary_validation/temp_data/binary_pheno.RData')
colnames(binary_pheno)<-var_list$ID
binary_all<-as.data.frame(cbind(df_eid,Diabetes,binary_pheno))
rownames(binary_all)<-paste0('S',binary_all$eid)

#Screen out the eid-code of the EUR population
EUR_eid<-fread2('/public/home/Datasets/ukb/pheno/eid_EUR.txt',col.names=c('eid','eid1'))
EUR_eid<-EUR_eid[,1]
#EUR Sorted by fixed number
binary_EUR<-binary_all[paste0('S',EUR_eid),]
colnames(binary_EUR)[2:4]<-c('sex','age','BMI')

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
binary_female<-binary_EUR[which(binary_EUR$sex==0),]
binary_male<-binary_EUR[which(binary_EUR$sex==1),]

set.seed(20230407)
female_sample<-sort(sample(nrow(binary_female),25000,replace = F))
set.seed(19110405)
male_sample<-sort(sample(nrow(binary_male),25000,replace = F))

binary_female_sample<-binary_female[female_sample,]
female_sort<-rownames(binary_female_sample)
binary_male_sample<-binary_male[male_sample,]
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
write.table(plink_nosex,file = '/public/home/biostat07/Five_binary_validation/mysample/get_plink/plink_nosex.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_male,file = '/public/home/biostat07/Five_binary_validation/mysample/get_plink/plink_male.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_female,file = '/public/home/biostat07/Five_binary_validation/mysample/get_plink/plink_female.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_T1D,file = '/public/home/biostat07/Five_binary_validation/mysample/get_plink/plink_T1D.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_T2D,file = '/public/home/biostat07/Five_binary_validation/mysample/get_plink/plink_T2D.txt',
            col.names = F,row.names = F,quote = F)
write.table(plink_diabetes,file = '/public/home/biostat07/Five_binary_validation/mysample/get_plink/plink_diabetes.txt',
            col.names = F,row.names = F,quote = F)

save(nosex_sort,summary_adjust_name, 
     binary_female_sample, binary_male_sample, binary_nosex_sample,
     binary_T1D_sample, binary_T2D_sample, binary_diabetes_sample, 
     binary_EUR, temp_name, 
     file = '/public/home/biostat07/Five_binary_validation/temp_data/validation_dat.RData')