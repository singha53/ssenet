  
---
title: "Semi-Supervised Elastic Net (ssenet)"
author: "Amrit Singh"
date: "09 March, 2020"
output: 
  html_document: 
    keep_md: yes
    toc: true
    toc_depth: 5
---



# Zhu *et al* 2018: [seqFISH paper](https://www.nature.com/articles/nbt.4260)
  * 43 genes (Supplementary Table 2) to map cell types in the seqFISH data:

### Step 1: mapping scRNASeq celltypes on seqFISH data
  * Randomly selected a subset of genes from the list of differentially expressed  and applied a multiclass support vector machine; perform evaluated using cross-validation; 43 genes were used to map cell-types in the seqFISH data
  * Applied the SVM classification model to the bias-correct, quantile normalized seqFISH data to assign cell types.


```r
include_graphics("inst/extdata/suppTable2.png")
```

<img src="inst/extdata/suppTable2.png" width="1286" />

```r
selectedGenes <- c("fbll1", "itpr2", "vps13c", "tnfrsf1b", "sox2",
  "hdx", "wrn", "sumf2", "vmn1r65", "rhob",
  "mrgprb1", "calb1", "pld1", "laptm5", "tbr1",
  "slc5a7", "abca9", "ankle1", "olr1", 
  "cecr2", "cpne5", "blzf1", "mertk",
  "nell1", "npy2r", "cdc5l", "slco1c1",
  "pax6", "cldn5", "cyp2j5", "mfge8",
  "col5a1", "bmpr1b", "rrm2", "gja1",
  "dcx", "spag6", "csf2rb2", "gda",
  "arhgef26", "slc4a8", "gm805", "omg")

plot(coord, col = mixOmics::color.mixo(as.numeric(seqfishLabels$V3)), pch = 21, 
  xlab = "x-coordinates", ylab = "y-coordinates")
points(coord, col = mixOmics::color.mixo(as.numeric(seqfishLabels$V3)), pch = 19)
```

![](README_files/figure-html/unnamed-chunk-1-2.png)<!-- -->

### Step 2: a systemic approach to identify multicellular niche
  * HMRF (Hidden Markov Random Field): Systematically dissect the contributions of microenvironments on gene expression variation
  * Divide the visual cortex into domains with coherent gene expression patterns
  * HMRF enables the detection of spatial domains by systemically comparing the gene signature of each cell with its surrounding to search for coherent patterns
  * Domain state of each cell was influence by 2 sources: 1) gene expression pattern and 2) domain states of neighbouring cells
  * To enhance spatial domain detection 11 highly cell-specific genes were removed
  * HMRF revealed 9 spatial domains; four domains were in the outer layers of the cortex ( O1-O4), four domains were located on the inside of the cortex (I1A, I1B, I2, I3), domain IS was sporadically distributed across the inner layers of the cortex.

### Step 3: interactions between cell-type and spatial environment
  * The same cell-types expressed different genes depending on the domain state of the cell.
  * By visual inspection there were notable morphological variations near the boundary between different domains at multiple regions.

# Questions for the BIRSBiointegration workshop:
## 1) Can scRNA-seq data be overlaid onto seqFISH for resolution enhancement?
## 2) What is the minimal number of genes needed for data integration?
## 3) Are there signatures of cellular co-localization or spatial coordinates in non-spatial scRNA-seq data?

## Questions 1 and 2:

## Apply Enet to scRNAseq data and apply to seqFISH to determine cell-type labels


```r
fitEnet <- enet(xtrain=t(scrnaseq), ytrain=scrnaseqLabels$V1, alpha = 1, lambda = 0.01, family = "multinomial", 
  xtest = t(seqfish), ytest = seqfishLabels$V3, filter = "none", topranked = 50, keepVar = NULL, weights = NULL)
cvEnet <- predict(object = fitEnet, validation="Mfold", M = 5, iter = 5, ncores = 5, progressBar = TRUE)
```




# [Data files](https://github.com/BIRSBiointegration/Hackathon/tree/master/seqFISH)


```r
# scrnaseq <- read.delim("inst/extdata/tasic_training_b2.txt", row.names = 1, header = FALSE)
# scrnaseqLabels <- read.delim("inst/extdata/tasic_labels.tsv", header = FALSE)
# seqfish <- read.delim("inst/extdata/seqfish_cortex_b2_testing.txt", row.names = 1, header = FALSE)
# seqfishLabels <- read.delim("inst/extdata/seqfish_labels.tsv", row.names = 1, header = FALSE)
# dim(scrnaseq); dim(scrnaseqLabels);
# dim(seqfish); dim(seqfishLabels);
# 
# coord <- read.delim("inst/extdata/fcortex.coordinates.txt", header = FALSE)
# coord <- lapply(1:nrow(coord), function(i){
#   as.numeric(strsplit(as.character(coord[i,]), " ")[[1]][-c(1, 2)])
# }) %>% 
#   do.call(rbind, .)
# dim(coord)
# 
# usethis::use_data(scrnaseq, overwrite = TRUE)
# usethis::use_data(scrnaseqLabels, overwrite = TRUE)
# usethis::use_data(seqfish, overwrite= TRUE)
# usethis::use_data(seqfishLabels, overwrite = TRUE)
# usethis::use_data(coord, overwrite = TRUE)
```
