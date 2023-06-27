#! /usr/bin/env Rscript
library(plyr)
library(dplyr)
library(bigsnpr)
library(bigreadr)
library(optparse)

## Input parameters
args_list = list(
  make_option("--summ", type="character", default=NULL,
              help="INPUT: gemma file", metavar="character"), 
  make_option("--output", type="character", default=NULL,
              help="INPUT: LDpred2 path", metavar="character"),
  make_option("--dat", type="character", default=NULL,
              help="INPUT: phenotype type", metavar="character"),
  make_option("--thread", type="numeric", default=1,
              help="OUTPUT: core number", metavar="character"), 
  make_option("--model", type="character", default=NULL,
              help="INPUT: model setting", metavar="character"),
  make_option("--phenoname", type="character", default=NULL,
              help="INPUT: pheno name", metavar="character"),
  make_option("--chr", type="character", default=NULL,
              help="INPUT: chr number", metavar="character")
)

opt_parser = OptionParser(option_list=args_list)
opt = parse_args(opt_parser)


## Set parameters
p_len <- 21
REF_PATH <- "/public/home/Datasets/1000GP/EUR"
VAL_PATH <- "/public/home/biostat07/Five_people/genotype"
ref_str <- paste0(REF_PATH, "/hm3_imp/chr", opt$chr)
val_str <- paste0(VAL_PATH, "/eid_nosex_imp/xchr", opt$chr)

## Load reference panel
ref_bed <- snp_attach(paste0(ref_str, ".rds"))
ref_map <- ref_bed$map[-3]
names(ref_map) <- c("chr", "marker.ID", "pos", "a1", "a0")

## Load summary statistics
summstats <- fread2(opt$summ,
                    select =  c(1, 2, 3, 5, 6, 7, 8, 9, 10))
colnames(summstats) <- c("chr", "rsid", "pos", "n_obs", 
                         "a1", "a0", "MAF", "beta", "beta_se")
summstats$n_eff <- summstats$n_obs
summstats$n_obs <- NULL
summstats <- summstats[summstats[, 1] == opt$chr, ]

  
  ## Intersect summary and reference
  ref_sub_str <- paste0("/public/home/biostat07/Five_people/tmp_data/ref_chr",opt$chr,"_sub-", as.numeric(as.POSIXlt(Sys.time())))
  val_sub_str <- paste0("/public/home/biostat07/Five_people/tmp_data/val_chr",opt$chr,"_sub-", as.numeric(as.POSIXlt(Sys.time())))
  snp_ref_summ_inter <- snp_match(summstats, ref_map, 
                                  match.min.prop = 0.05)
  snp_ref_summ_inter <- snp_ref_summ_inter[snp_ref_summ_inter$rsid == snp_ref_summ_inter$marker.ID, ]
  val_bed <- snp_attach(paste0(val_str, ".rds"))
  val_map <- val_bed$map[-3]
  names(val_map) <- c("chr", "marker.ID", "pos", "a1", "a0")
  snp_val_summ_inter <- snp_match(summstats, val_map, 
                                  match.min.prop = 0.05)
  snp_val_summ_inter <- snp_val_summ_inter[snp_val_summ_inter$rsid == snp_val_summ_inter$marker.ID, ]
  snp_inter <- intersect(snp_val_summ_inter$rsid, snp_ref_summ_inter$rsid)
  ref_sub_bed <- snp_attach(snp_subset(ref_bed, 
                                       ind.col = which(ref_bed$map$marker.ID%in%snp_inter), 
                                       backingfile = ref_sub_str))
  val_sub_bed <- snp_attach(snp_subset(val_bed,
                                       ind.col = which(val_bed$map$marker.ID%in%snp_inter),
                                       backingfile = val_sub_str))
  df_beta_h2 <- snp_ref_summ_inter[, c("rsid", "a1", "beta", "beta_se", "n_eff")]
  df_beta_h2 <- df_beta_h2[df_beta_h2$rsid %in% snp_inter, ]
  corr <- snp_cor(ref_sub_bed$genotypes, size = 1000)
  h2 <- snp_ldsc2(corr, df_beta_h2)
  cat("Heritability: ", h2[2], "\n")
  
  if (h2[2] < 0){
    
    beta_LDpred2 <- data.frame(df_beta_h2$rsid[df_beta_h2$rsid %in% snp_inter],
                               df_beta_h2$a1[df_beta_h2$rsid %in% snp_inter],
                               0,
                               0)
  } else {
    
    
    y <- fread2(paste0("/public/home/biostat07/Five_binary_validation/validation/rstandard/",opt$phenoname,".txt"))[,1]
    
    p_seq <- signif(seq_log(1e-5, 1, length.out = p_len), 2)
    h_seq <- round(h2[2] * c(0.7, 1, 1.4), 4)
    params <- expand.grid(p = p_seq, h2 = h_seq, 
                          sparse = c(FALSE, TRUE))
    cat("ok1\n")
    beta_grid <- snp_ldpred2_grid(as_SFBM(corr), df_beta_h2,
                                  params, ncores = opt$thread)
    cat("ok2\n")
    if (any(is.na(y))){
      
      val_sub_str2 <- paste0("/public/home/biostat07/Five_people/tmp_data/s_val_chr",opt$chr,"_sub-", as.numeric(as.POSIXlt(Sys.time())))
      row_idx <- which(!is.na(y))
      val_sub_bed <- snp_attach(snp_subset(val_sub_bed, 
                                           ind.row = row_idx, 
                                           backingfile = val_sub_str2))
      y <- y[row_idx]
    }
    val_G <- val_sub_bed$genotypes
    beta_grid_sub <- beta_grid[df_beta_h2$rsid %in% snp_inter, ]
    pred_grid <- big_prodMat(val_G, beta_grid_sub)
    idx_na <- apply(pred_grid, 2, function(a) all(is.na(a))) | 
      apply(beta_grid, 2, function(a) all(is.na(a)))
    beta_grid_na <- beta_grid[, !idx_na]
    pred_grid_na <- pred_grid[, !idx_na]
    params_na <- params[!idx_na, ]
    
    if (all(idx_na)){
      
      beta_LDpred2 <- data.frame(df_beta_h2$rsid[df_beta_h2$rsid %in% snp_inter],
                                 df_beta_h2$a1[df_beta_h2$rsid %in% snp_inter],
                                 0,
                                 0)
    } else {
      
      
      if (opt$dat == "c"){
        
        params_na[c("coef", "score")] <-
          big_univLinReg(big_copy(pred_grid_na), y)[c("estim", "score")]
        params_na$idx_val <- apply(pred_grid_na, 2, function(a) cor(a, y)^2)
      } else {
        
        params_na[c("coef", "score")] <-
          big_univLinReg(big_copy(pred_grid_na), 
                         y, 
                         covar.train = as.matrix(covar))[c("estim", "score")]
        params_na$idx_val  <- apply(pred_grid_na, 2, AUC, target = y)
      }
      
      ## parameters
      params_na %>%
        mutate(sparsity = colMeans(beta_grid_na == 0, na.rm = T),
               id = c(1: nrow(params_na))) %>%
        arrange(desc(score)) %>%
        mutate_at(4:8, signif, digits = 3)
      # no-sparsity effect
      best_grid_nosp <- params_na %>%
        mutate(id = c(1: nrow(params_na))) %>%
        filter(!sparse) %>%
        arrange(desc(score)) %>%
        slice(1) %>%
        { beta_grid_na[, .$id] * .$coef }
      # sparsity effect
      best_grid_sp <- params_na %>%
        mutate(id = c(1: nrow(params_na))) %>%
        filter(sparse) %>%
        arrange(desc(score)) %>%
        slice(1) %>%
        { beta_grid_na[, .$id] * .$coef }
      ## output
      beta_LDpred2 <- data.frame(df_beta_h2$rsid[df_beta_h2$rsid %in% snp_inter],
                                 df_beta_h2$a1[df_beta_h2$rsid %in% snp_inter],
                                 best_grid_nosp[df_beta_h2$rsid %in% snp_inter],
                                 best_grid_sp[df_beta_h2$rsid %in% snp_inter])
    }
  }
  
  cat ("LDpred model is ok!\n")
  write.table(beta_LDpred2, file = paste0(opt$output,opt$phenoname,".effect/LDpred2/effect_chr", opt$chr, ".txt"), 
              row.names = F, col.names = F, quote = F)
  system(paste0("rm ", val_sub_str, ".bk"))
  cat ("rm bk1 is ok!\n")
  system(paste0("rm ", val_sub_str, ".rds"))
  cat ("rm rds1 is ok!\n")
  system(paste0("rm ", ref_sub_str, ".bk"))
  cat ("rm bk2 is ok!\n")
  system(paste0("rm ", ref_sub_str, ".rds"))
  cat ("rm rds2 is ok!\n")

