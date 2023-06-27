library(plyr)
library(bigreadr)
library(Metrics)
library(optparse)
library(ggplot2)
library(hrbrthemes)
library(viridis)
library(patchwork)
library(stringr)

args_list = list(
  make_option("--pheno", type="character", default=NULL,
              help="INPUT: phenotype number", metavar="character")
)

opt_parser = OptionParser(option_list=args_list)
opt = parse_args(opt_parser)

round_fun<-function(xvar){
  noround<-as.character(xvar)
  if(str_detect(noround,'e-')){
    ntail<-as.numeric(str_split_fixed(noround,'e-',n=2)[,2])
    nhead<-as.numeric(str_split_fixed(noround,'e-',n=2)[,1])
    #nhead<-round(nhead,1)
    if(nchar(as.character(nhead))<3){
      myvalue<-as.numeric(paste0('0.',str_dup('0',ntail-1),str_sub(as.character(nhead),1,1),'0'))
    }else if(nchar(as.character(nhead))==3){
      myvalue<-as.numeric(paste0('0.',str_dup('0',ntail-1),str_sub(as.character(nhead),1,1),str_sub(nhead,3,3)))
    }else{
      sub_nhead<-str_sub(as.character(nhead),1,4)
      if(as.numeric(str_sub(sub_nhead,4,4))==0){
        myvalue<-as.numeric(paste0('0.',str_dup('0',ntail-1),str_sub(as.character(nhead),1,1),str_sub(nhead,3,3)))
      }else{
        if(as.numeric(str_sub(sub_nhead,3,3))==9){
          myvalue<-as.numeric(paste0('0.',str_dup('0',ntail-1),as.character(as.numeric(str_sub(as.character(nhead),1,1))+1)))
        }else{
          myvalue<-as.numeric(paste0('0.',str_dup('0',ntail-1),str_sub(as.character(nhead),1,1),as.character(as.numeric(str_sub(nhead,3,3))+1)))
        }
      }
    }
    return(myvalue)
  }else{
    for(i in 1:nchar(noround)){
      if(as.numeric(str_sub(noround,1,i))==0){
        cat(paste0("is 0 fail!\n"))
      }else{
        nlocate=i
        break
      }
    }
    if(is.na(as.numeric(str_sub(as.character(noround),nlocate+2,nlocate+2)))){
      return(round(as.numeric(str_sub(noround,1,nlocate+2)),nlocate-1))
    }else if(as.numeric(str_sub(as.character(noround),nlocate+2,nlocate+2))==0){
      return(round(as.numeric(str_sub(noround,1,nlocate+2)),nlocate-1))
    }else{
      return(round(as.numeric(str_sub(noround,1,nlocate+1)),nlocate-1)+as.numeric(paste0('0.',str_dup(0,nlocate-2),'1')))
    }
  }
}
Methods<-c()
my_min<-c()
my_max<-c()
Prop<-c()
method_ord<-c()
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/CT/rsquare/',opt$pheno,'.txt'))){
  CT<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/CT/rsquare/',opt$pheno,'.txt'),header=F)[,1]
  if (all(!is.na(CT))){
    Methods<-append(Methods,rep('CT',100))
    my_min<-append(my_min,min(CT))
    my_max<-append(my_max,max(CT))
    Prop<-append(Prop,CT)
    method_ord<-append(method_ord,'CT')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_sp.txt'))){
  LDpred2_sp<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_sp.txt'),header=F)[,1]
  if (all(!is.na(LDpred2_sp))){
    Methods<-append(Methods,rep('LDpred2-sp',100))
    my_min<-append(my_min,min(LDpred2_sp))
    my_max<-append(my_max,max(LDpred2_sp))
    Prop<-append(Prop,LDpred2_sp)
    method_ord<-append(method_ord,'LDpred2-sp')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_nosp.txt'))){
  LDpred2_nosp<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_nosp.txt'),header=F)[,1]
  if (all(!is.na(LDpred2_nosp))){
    Methods<-append(Methods,rep('LDpred2-nosp',100))
    my_min<-append(my_min,min(LDpred2_nosp))
    my_max<-append(my_max,max(LDpred2_nosp))
    Prop<-append(Prop,LDpred2_nosp)
    method_ord<-append(method_ord,'LDpred2-nosp')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_auto.txt'))){
  LDpred2_auto<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_auto.txt'),header=F)[,1]
  if (all(!is.na(LDpred2_auto))){
    Methods<-append(Methods,rep('LDpred2-auto',100))
    my_min<-append(my_min,min(LDpred2_auto))
    my_max<-append(my_max,max(LDpred2_auto))
    Prop<-append(Prop,LDpred2_auto)
    method_ord<-append(method_ord,'LDpred2-auto')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_inf.txt'))){
  LDpred2_inf<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/LDpred2/rsquare/',opt$pheno,'_inf.txt'),header=F)[,1]
  if (all(!is.na(LDpred2_inf))){
    Methods<-append(Methods,rep('LDpred2-inf',100))
    my_min<-append(my_min,min(LDpred2_inf))
    my_max<-append(my_max,max(LDpred2_inf))
    Prop<-append(Prop,LDpred2_inf)
    method_ord<-append(method_ord,'LDpred2-inf')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/DBSLMM/rsquare/',opt$pheno,'.txt'))){
  DBSLMM<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/DBSLMM/rsquare/',opt$pheno,'.txt'),header=F)[,1]
  if (all(!is.na(DBSLMM))){
    Methods<-append(Methods,rep('DBSLMM',100))
    my_min<-append(my_min,min(DBSLMM))
    my_max<-append(my_max,max(DBSLMM))
    Prop<-append(Prop,DBSLMM)
    method_ord<-append(method_ord,'DBSLMM')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/DBSLMM/rsquare/',opt$pheno,'_auto.txt'))){
  DBSLMM_auto<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/DBSLMM/rsquare/',opt$pheno,'_auto.txt'),header=F)[,1]
  if (all(!is.na(DBSLMM_auto))){
    Methods<-append(Methods,rep('DBSLMM-auto',100))
    my_min<-append(my_min,min(DBSLMM_auto))
    my_max<-append(my_max,max(DBSLMM_auto))
    Prop<-append(Prop,DBSLMM_auto)
    method_ord<-append(method_ord,'DBSLMM-auto')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/DBSLMM/rsquare/',opt$pheno,'_lmm.txt'))){
  DBSLMM_lmm<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/DBSLMM/rsquare/',opt$pheno,'_lmm.txt'),header=F)[,1]
  if (all(!is.na(DBSLMM_lmm))){
    Methods<-append(Methods,rep('DBSLMM-lmm',100))
    my_min<-append(my_min,min(DBSLMM_lmm))
    my_max<-append(my_max,max(DBSLMM_lmm))
    Prop<-append(Prop,DBSLMM_lmm)
    method_ord<-append(method_ord,'DBSLMM-lmm')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/PRScs/rsquare/',opt$pheno,'.txt'))){
  PRSCS<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/PRScs/rsquare/',opt$pheno,'.txt'),header=F)[,1]
  if (all(!is.na(PRSCS))){
    Methods<-append(Methods,rep('PRS-CS',100))
    my_min<-append(my_min,min(PRSCS))
    my_max<-append(my_max,max(PRSCS))
    Prop<-append(Prop,PRSCS)
    method_ord<-append(method_ord,'PRS-CS')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/SBLUP/rsquare/',opt$pheno,'.txt'))){
  SBLUP<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/SBLUP/rsquare/',opt$pheno,'.txt'),header=F)[,1]
  if (all(!is.na(SBLUP))){
    Methods<-append(Methods,rep('SBLUP',100))
    my_min<-append(my_min,min(SBLUP))
    my_max<-append(my_max,max(SBLUP))
    Prop<-append(Prop,SBLUP)
    method_ord<-append(method_ord,'SBLUP')
  }
}
if (file.exists(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/SCT/rsquare/',opt$pheno,'.txt'))){
  SCT<-fread2(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/SCT/rsquare/',opt$pheno,'.txt'),header=F)[,1]
  if (all(!is.na(SCT))){
    Methods<-append(Methods,rep('SCT',100))
    my_min<-append(my_min,min(SCT))
    my_max<-append(my_max,max(SCT))
    Prop<-append(Prop,SCT)
    method_ord<-append(method_ord,'SCT')
  }
}

minvalue<-round_fun(min(na.omit(my_min)))
maxvalue<-round_fun(max(na.omit(my_max)))
diff<-maxvalue-minvalue
r2_dat<-data.frame(Methods,Prop)
colnames(r2_dat)<-c('Methods','Prop')
unique_methods<-unique(r2_dat[,1])
col_dat <- read.table("/public/home/biostat07/Five_people_test/code/col.txt", sep = "\t")
col_dat <- col_dat[match(unique_methods, col_dat[, 2]), ]
col_dat <- col_dat[order(col_dat[,2]),]
r2_mean_plt <- ggplot(r2_dat, aes(x=Methods, y=Prop)) + 
  geom_boxplot( aes(color = Methods),size = 0.7, position=position_dodge(width = 1)) +
  stat_summary( fun.y = mean,colour = "black", geom="text", show_guide = FALSE,vjust = -2, aes(label=round(..y.., digits=4)), size = 5.5) +
  theme_bw() +
  theme(axis.text.x = element_blank(), 
        axis.title.x = element_blank(),
        axis.text.y = element_text(size = 12), 
        axis.title.y = element_text(size = 16, face = "bold"),
        #legend.text = element_text(size = 12, face = "bold"),
        #legend.title = element_text(size = 12, face = "bold"),
        legend.position = "none",
        panel.grid = element_blank(), 
        panel.border = element_blank(), 
        axis.line.y.left = element_line(size = 1, color = "#E0E0E0"), 
        axis.line.x = element_line(size = 1, color = "#E0E0E0"))+ 
  scale_color_manual(values=as.character(col_dat[,1])) + 
  scale_y_continuous(limits = c(minvalue-diff/15, maxvalue), breaks = c(round_fun(minvalue),
                                                                        round_fun(minvalue+diff/3),
                                                                        round_fun(maxvalue-diff/3),
                                                                        round_fun(maxvalue)))+
  ylab("R2") +
  labs(x = "", y = expression(paste(bold('Pearson '),italic(R^2))))
jpeg(paste0('/public/home/biostat07/Five_people_test/prediction/',opt$pheno,'.effect/',opt$pheno,'_boxplot.jpeg'),
     width = 8, height = 7,units = 'in',res=300)
r2_mean_plt +
  plot_layout(guides = 'collect')&
  theme(legend.position='bottom',
        legend.text = element_text(size = 10, face = "bold"),
        legend.title = element_text(size = 14, face = "bold"))
dev.off()








