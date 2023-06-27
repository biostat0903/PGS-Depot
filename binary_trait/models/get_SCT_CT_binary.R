
library(plyr)
library(bigsnpr)
library(bigreadr)
library(tidyverse)
library(optparse)
library(xgboost)

#!this is the SCT-CT function
#get_CT_SCT_function<-function(phenofile){
  args_list = list(
    make_option("--summ", type="character", default=NULL,
                help="INPUT: gemma file", metavar="character"), 
    make_option("--path", type="character", default=NULL,
                help="INPUT: SCT and CT path", metavar="character"),
    make_option("--pheno", type="character", default=NULL,
                help="INPUT: phenotype qqnorm", metavar="character"), 
    make_option("--cross", type="numeric", default=NULL,
                help="INPUT: cross number", metavar="character"), 
    make_option("--dat", type="character", default=NULL,
                help="INPUT: phenotype type", metavar="character"),
    make_option("--reftype", type="character", default=NULL,
                help="INPUT: reference panel", metavar="character"),
    make_option("--phenofile", type="character", default=NULL,
                help="INPUT: pheno name", metavar="character"),
    make_option("--thread", type="numeric", default=1,
                help="OUTPUT: core number", metavar="character")
  )
  opt_parser = OptionParser(option_list=args_list)
  opt = parse_args(opt_parser)
  
  
  # set parameter
  
  ref_str <- opt$reftype
  val_str <- '/public/home/biostat07/Five_people/genotype/eid_nosex/mergeout'
  ref_sub_str <- paste0(ref_str, "_sub-", as.numeric(as.POSIXlt(Sys.time())))
  val_sub_str <- paste0(val_str, "_sub-", as.numeric(as.POSIXlt(Sys.time())))
  # interect val and ref data
  #ref_bed <- snp_readBed(paste0(ref_str, ".bed"))
  if(file.exists(paste0(val_str, ".rds")) == F | file.exists(paste0(val_str, ".bk")) == F){
    if(file.exists(paste0(val_str, ".bk"))){
      system(paste0("rm ", val_str, ".bk"))
    }
    val_bed <- snp_readBed(paste0(val_str, ".bed"))
  }
  ref_bed <- snp_attach(paste0(ref_str, ".rds"))
  val_bed <- snp_attach(paste0(val_str, ".rds"))
  val_snp <- fread2(paste0(val_str, ".bim"))
  if(all(ref_bed$map$marker.ID == val_bed$map$marker.ID) == F){
    snp_inter <- intersect(ref_bed$map$marker.ID, val_bed$map$marker.ID)
    ref_bed <- snp_attach(snp_subset(ref_bed, 
                                     ind.col = which(ref_bed$map$marker.ID%in%snp_inter), 
                                     backingfile = ref_sub_str))
    val_bed <- snp_attach(snp_subset(val_bed,
                                     ind.col = which(val_bed$map$marker.ID%in%snp_inter),
                                     backingfile = val_sub_str))
  }
  val_n_snp <- dim(val_bed$genotypes)[2]
  # process ref data
  ref_G <- ref_bed$genotypes
  ref_CHR <- ref_bed$map$chromosome
  ref_POS <- ref_bed$map$physical.pos
  ref_n_snp <- dim(ref_G)[2]
  ref_map <- ref_bed$map[, -3]
  names(ref_map) <- c("chr", "rsid", "pos", "a1", "a0")
  
  # process summary statistics
  summstats <- fread2(opt$summ, select =  c(1, 2, 3, 7, 6, 9, 10))
  colnames(summstats) <- c("chr", "rsid", "pos", "a0", "a1", "beta", "se") # calculate P
  t <- summstats$beta/summstats$se
  p_val <- ifelse(t < 0, pnorm(t), pnorm(t, lower.tail = F))*2
  summstats$pval <- ifelse(p_val == 0,
                           min(p_val[-which(p_val==0)]),
                           p_val)
  
  # map summary statistics and reference panel
  info_snp <- snp_match(summstats, ref_map)
  beta <- rep(0, ref_n_snp)
  lp_val <- rep(0, ref_n_snp)
  beta[ref_map[, 2]%in%info_snp[, 5]] <- info_snp$beta
  lp_val[ref_map[, 2]%in%info_snp[, 5]] <- -log10(info_snp$pval)
  
  # clump
  all_keep <- snp_grid_clumping(ref_G,
                                grid.thr.r2 = c(0.01, 0.05, 0.1, 0.2, 0.5, 0.8, 0.95),
                                grid.base.size = c(50, 100, 200, 500),
                                infos.chr = ref_CHR,
                                infos.pos = ref_POS,
                                lpS = lp_val,
                                ncores = opt$thread)
  
  # threshold
  ct_bk_str <- paste0("/public/home/biostat07/Five_people/SCT_CT/ct_bk_str/summary_cross", opt$cross, "1_sub-",
                             as.numeric(as.POSIXlt(Sys.time())))
  multi_PRS <- snp_grid_PRS(val_bed$genotypes,
                            all_keep,
                            betas = beta,
                            lpS = lp_val,
                            n_thr_lpS = 50,
                            backingfile = ct_bk_str,
                            ncores = opt$thread)
  nn <- nrow(attr(all_keep, "grid"))
  grid2 <- attr(all_keep, "grid") %>%
    mutate(thr.lp = list(attr(multi_PRS, "grid.lpS.thr")), id = c(1:nn)) %>%
    unnest(cols = "thr.lp")
  s <- nrow(grid2)
  # load validation trait
  y <- fread2(opt$pheno)[,1]
  val_bk_str2 <- paste0(val_str, "_sub-", as.numeric(as.POSIXlt(Sys.time())))
  idx <- c()
  if (any(is.na(y)) == T){
    idx <- which(!is.na(y))
    val_bed <- snp_attach(snp_subset(val_bed, ind.row = idx, 
                                     backingfile = val_bk_str2))
    y <- y[which(!is.na(y))]
  }
  ct_bk_str2 <- paste0("/public/home/biostat07/Five_people/SCT_CT/ct_bk_str/summary_cross1", opt$cross, "1_sub-",
                       as.numeric(as.POSIXlt(Sys.time())))
  multi_PRS2 <- snp_grid_PRS(val_bed$genotypes,
                             all_keep,
                             betas = beta,
                             lpS = lp_val,
                             n_thr_lpS = 50,
                             backingfile = ct_bk_str2,
                             ncores = opt$thread)
  
  ## subsample phenotype
  grid2$valIdx <- big_apply(multi_PRS2, a.FUN = function(X, ind, s, y.train) {
    single_PRS <- rowSums(X[, ind + s * (0:21)])
    return(cor(single_PRS, y.train)^2)
  },
  ind = 1:s,
  s = s,
  y.train = y,
  a.combine = 'c',
  block.size = 1,
  ncores = opt$thread
  )
  save(grid2,file=paste0('/public/home/biostat07/Five_binary_validation/output_summary/',opt$phenofile,'.effect/RDATA/grid2_',opt$phenofile,'.RData'))
  
  all_pgs_CT <- big_apply(multi_PRS2, a.FUN = function(X, ind, s, y.train) {
    single_PRS <- rowSums(X[, ind + s * (0:21)])
    return(single_PRS)
  },
  ind = 1:s,
  s = s,
  y.train = y,
  a.combine = 'cbind',
  block.size = 1,
  ncores = opt$thread
  )
  final_mod <- snp_grid_stacking(multi_PRS2,
                                 y,
                                 ncores = opt$thread,
                                 K = 10)
  snp_info_CT <- data.frame(ref_map$rsid, ref_map$a1)
  idx_mat_CT <- t(plyr::aaply(c(1: 1400), 1, function(ss){
    info_prs <- grid2 %>% dplyr::slice(ss)
    c_idx <- c(1: val_n_snp) %in% unlist(map(all_keep, info_prs$id))
    t_idx <- c(1: val_n_snp) %in% which(lp_val >= 0.999999*info_prs$thr.lp)
    return(ifelse(c_idx==T&t_idx==T, T, F))
  }))
  save(snp_info_CT, idx_mat_CT, all_pgs_CT,
       file = paste0('/public/home/biostat07/Five_binary_validation/output_summary/',opt$phenofile,".effect/RDATA/CT_",opt$phenofile,'.RData'))
  
  # CT
  max_prs <- grid2 %>% arrange(desc(valIdx)) %>% dplyr::slice(1)
  c_idx <- c(1: ref_n_snp) %in% unlist(map(all_keep, max_prs$id))
  t_idx <- c(1: ref_n_snp) %in% which(lp_val >= 0.999999*max_prs$thr.lp)
  idx <- ifelse(c_idx==T&t_idx==T, T, F)
  snp_sig_CT <- data.frame(ref_map$rsid[idx],
                           ref_map$a1[idx],
                           beta[idx])
  
  # SCT
  new_beta <- final_mod$beta.G 
  idx <- which(new_beta != 0)
  snp_sig_SCT <- data.frame(ref_map$rsid[idx],
                            ref_map$a1[idx],
                            new_beta[idx])
  #output
  write.table(grid2, file = paste0('/public/home/biostat07/Five_binary_validation/output_summary/',opt$phenofile,'.effect/grid2/',opt$phenofile,".txt"),
              col.names = F, row.names = F, quote = F)
  write.table(snp_sig_CT, file = paste0('/public/home/biostat07/Five_binary_validation/output_summary/',opt$phenofile,'.effect/CT/',opt$phenofile,".txt"),
              col.names = F, row.names = F, quote = F)
  write.table(snp_sig_SCT, file = paste0('/public/home/biostat07/Five_binary_validation/output_summary/',opt$phenofile,'.effect/SCT/',opt$phenofile,".txt"),
              col.names = F, row.names = F, quote = F)
