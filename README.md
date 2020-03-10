
title: “Semi-Supervised Elastic Net (ssenet)” author: “Amrit Singh”
date: “09 March, 2020”

# Analysis for the Abstract Submission to \#BIRSBioIntegration [Mathematical Frameworks for Integrative Analysis of Emerging Biological Data Types](https://www.birs.ca/events/2020/5-day-workshops/20w5197)

## Zhu *et al* 2018: [seqFISH paper](https://www.nature.com/articles/nbt.4260)

  - 43 genes (Supplementary Table 2) to map cell types in the seqFISH
    data:

### Step 1: mapping scRNASeq celltypes on seqFISH data

  - Randomly selected a subset of genes from the list of differentially
    expressed and applied a multiclass support vector machine; perform
    evaluated using cross-validation; 43 genes were used to map
    cell-types in the seqFISH data
  - Applied the SVM classification model to the bias-correct, quantile
    normalized seqFISH data to assign cell types.

<!-- end list -->

``` r
include_graphics("inst/extdata/suppTable2.png")
```

![](inst/extdata/suppTable2.png)<!-- -->

``` r
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

![](README_files/figure-gfm/unnamed-chunk-1-2.png)<!-- -->

### Step 2: a systemic approach to identify multicellular niche

  - HMRF (Hidden Markov Random Field): Systematically dissect the
    contributions of microenvironments on gene expression variation
  - Divide the visual cortex into domains with coherent gene expression
    patterns
  - HMRF enables the detection of spatial domains by systemically
    comparing the gene signature of each cell with its surrounding to
    search for coherent patterns
  - Domain state of each cell was influence by 2 sources: 1) gene
    expression pattern and 2) domain states of neighbouring cells
  - To enhance spatial domain detection 11 highly cell-specific genes
    were removed
  - HMRF revealed 9 spatial domains; four domains were in the outer
    layers of the cortex ( O1-O4), four domains were located on the
    inside of the cortex (I1A, I1B, I2, I3), domain IS was sporadically
    distributed across the inner layers of the cortex.

### Step 3: interactions between cell-type and spatial environment

  - The same cell-types expressed different genes depending on the
    domain state of the cell.
  - By visual inspection there were notable morphological variations
    near the boundary between different domains at multiple regions.

# Questions for the BIRSBiointegration workshop:

## 1\) Can scRNA-seq data be overlaid onto seqFISH for resolution enhancement?

## 2\) What is the minimal number of genes needed for data integration?

## 3\) Are there signatures of cellular co-localization or spatial coordinates in non-spatial scRNA-seq data?

## Apply Enet to scRNAseq data and apply to seqFISH to determine cell-type labels

``` r
indices1 <- lapply(levels(scrnaseqLabels$V1), function(i){
  which(as.character(scrnaseqLabels$V1) == i)[1:6]
}) %>% unlist()
indices2 <- lapply(levels(seqfishLabels$V3), function(i){
  which(as.character(seqfishLabels$V3) == i)[1:8]
}) %>% unlist()


fitEnet <- enet(xtrain=t(scrnaseq[, indices1]), ytrain=scrnaseqLabels$V1[indices1], alpha = 1, lambda = NULL, family = "multinomial", 
  xtest = t(seqfish[, indices2]), ytest = seqfishLabels$V3[indices2], filter = "none", topranked = 50, keepVar = NULL, weights = NULL)
cvEnet <- predict(object = fitEnet, validation="Mfold", M = 2, iter = 2, ncores = 2, progressBar = TRUE)
cvEnet$perf
```

    ## # A tibble: 10 x 3
    ##    ErrName                Mean     SD
    ##    <chr>                 <dbl>  <dbl>
    ##  1 Astrocyte            0      0     
    ##  2 BER                  0.208  0.0295
    ##  3 Endothelial Cell     0.25   0.118 
    ##  4 ER                   0.208  0.0295
    ##  5 GABA-ergic Neuron    0.25   0.118 
    ##  6 Glutamatergic Neuron 0      0     
    ##  7 Microglia            0      0     
    ##  8 Oligodendrocyte.1    0.5    0     
    ##  9 Oligodendrocyte.2    0.583  0.354 
    ## 10 Oligodendrocyte.3    0.0833 0.118

## Apply Semi-supervised Enet to scRNAseq+seqFISH data to determine cell-type labels

``` r
fitSSEnet <- ssenet(xtrain=t(cbind(scrnaseq[,indices1], seqfish[, indices2])), ytrain=factor(c(as.character(scrnaseqLabels$V1[indices1]), rep(NA, ncol(seqfish))[indices2])), 
  alpha = 1, lambda = fitEnet$lambda, family = "multinomial", 
  xtest = t(seqfish[, indices2]), ytest = seqfishLabels$V3[indices2], filter = "none", topranked = 50, keepVar = NULL, 
  useObsWeights = FALSE, max.iter = 100, perc.full = 1, thr.conf = 0.5)
cvSSEnet <- predict(object = fitSSEnet, validation="Mfold", M = 2, iter = 2, ncores = 2, progressBar = TRUE)
cvSSEnet$perf
```

    ## # A tibble: 10 x 3
    ##    ErrName                Mean     SD
    ##    <chr>                 <dbl>  <dbl>
    ##  1 Astrocyte            0.0833 0.118 
    ##  2 BER                  0.385  0.0147
    ##  3 Endothelial Cell     0.583  0.118 
    ##  4 ER                   0.385  0.0147
    ##  5 GABA-ergic Neuron    0.583  0.118 
    ##  6 Glutamatergic Neuron 0.25   0.354 
    ##  7 Microglia            0.167  0.236 
    ##  8 Oligodendrocyte.1    0.667  0     
    ##  9 Oligodendrocyte.2    0.667  0     
    ## 10 Oligodendrocyte.3    0.0833 0.118

## Compare supervised and semi-supervised Enet (Enet and SSEnet) predicted seqFISH cell-types labels with those estimated via the multiclass SVM used in the paper.

``` r
data.frame(err = c(fitEnet$perfTest, fitSSEnet$perfTest),
  errName = factor(rep(names(fitEnet$perfTest), 2), names(fitEnet$perfTest)),
  type = rep(c("Enet", "SSEnet"), each = length(fitEnet$perfTest))) %>% 
  ggplot(aes(x = errName, y = err, fill = type)) +
  geom_bar(stat = "identity", position = "dodge") +
  customTheme(sizeStripFont = 15, xAngle = 40, hjust = 1, vjust = 1, 
    xSize = 10, ySize = 10, xAxisSize = 15, yAxisSize = 15) +
  ylab("Error") +
  xlab("Cell-type, ER (error rate), BER (balanced error rate)")
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

> SSEnet predicted cell-type labels have less correspondence with the
> multiclass SVM predict cell-types labels as compared to Enet only. The
> major cell-types GABA-ergic Neuron and Glutamatergic Neuron have lower
> error rates than the other cell-types both both Enet and SSEnet.

## Compare supervised and semi-supervised Enet (Enet and SSEnet) performance using cross-validation

``` r
cvErr <- rbind(cvEnet$perf, cvSSEnet$perf) %>% 
  mutate(method = rep(c("Enet", "SSEnet"), each = nrow(cvEnet$perf))) %>% 
  mutate(ErrName = factor(ErrName, names(fitEnet$perfTest)))
pd <- position_dodge(0.5)
cvErr %>% 
  ggplot(aes(x = ErrName, y = Mean, color = method)) +
  geom_errorbar(aes(ymin=Mean-SD, ymax=Mean+SD), width=.2, position=pd) +
  geom_line(position=pd) +
  geom_point(position=pd, size = 3) +
  theme_bw() +
  ylab("Average error rate (2x2 cross-validation)") +
  xlab("Cell-type, ER (error rate), BER (balanced error rate)") +
  customTheme(sizeStripFont = 15, xAngle = 40, hjust = 1, vjust = 1, 
    xSize = 10, ySize = 10, xAxisSize = 15, yAxisSize = 15) +
  ylab("Error") +
  xlab("Cell-type, ER (error rate), BER (balanced error rate)")
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

| ErrName              |      Mean |        SD | method |
| :------------------- | --------: | --------: | :----- |
| Astrocyte            | 0.0000000 | 0.0000000 | Enet   |
| BER                  | 0.2083333 | 0.0294628 | Enet   |
| Endothelial Cell     | 0.2500000 | 0.1178511 | Enet   |
| ER                   | 0.2083333 | 0.0294628 | Enet   |
| GABA-ergic Neuron    | 0.2500000 | 0.1178511 | Enet   |
| Glutamatergic Neuron | 0.0000000 | 0.0000000 | Enet   |
| Microglia            | 0.0000000 | 0.0000000 | Enet   |
| Oligodendrocyte.1    | 0.5000000 | 0.0000000 | Enet   |
| Oligodendrocyte.2    | 0.5833333 | 0.3535534 | Enet   |
| Oligodendrocyte.3    | 0.0833333 | 0.1178511 | Enet   |
| Astrocyte            | 0.0833333 | 0.1178511 | SSEnet |
| BER                  | 0.3854167 | 0.0147314 | SSEnet |
| Endothelial Cell     | 0.5833333 | 0.1178511 | SSEnet |
| ER                   | 0.3854167 | 0.0147314 | SSEnet |
| GABA-ergic Neuron    | 0.5833333 | 0.1178511 | SSEnet |
| Glutamatergic Neuron | 0.2500000 | 0.3535534 | SSEnet |
| Microglia            | 0.1666667 | 0.2357023 | SSEnet |
| Oligodendrocyte.1    | 0.6666667 | 0.0000000 | SSEnet |
| Oligodendrocyte.2    | 0.6666667 | 0.0000000 | SSEnet |
| Oligodendrocyte.3    | 0.0833333 | 0.1178511 | SSEnet |

> The semi-supervised approach performs slightly better for the lower
> abundant cell-types.

## Abstract

### Your Name

> Amrit Singh

### Slack name on \#BIRSBioIntegration

> Amrit Singh

### Your Position

> trainee (post-doc)

### Name of supervisor

> Kim-Anh Le Cao/Bruce McManus

### Affiliation

> PROOF Centre of Excellence and The University of British Columbia

### Email

> <asingh@hli.ubc.ca>

### Co-authors

> none

### Which dataset(s) did you select for analysis?

> Spatial transcriptomics: seqFISH + scRNA-seq

### Why did you select this dataset(s) for analysis

> recommended by supervisor

### What integrative data analysis question have you addressed with the selected data and why?

> Can scRNA-seq data be overlaid onto seqFISH for resolution
> enhancement?

What are the advantages and performance of your approach? \> The
published approach trained a multiclass SVM on the scRNAseq data and
applied it to the seqFISH data to estimate the cell-types labels. My
approach uses a penalized regression method (glmnet) with a
semi-supervised appraoch in order to build a model using both the
scRNAseq+seqFISH data. This strategy uses a recursive approach that
invovles multiple rounds of training glmnet models using labeled data
(label and imputed) and predicting the cell-type labels of unlabeled
data. At each iteration, cell-type labels with high confidence
(probability \> 0.5) are retained for the next iteration, where a new
glmnet model is trained with the scRNAseq data and seqFISH data with
imputed cell-type labels with high confidence. This process is repeated
until all cell-types in the seqFISH data have been labeled or until 50
iterations have been reached (in order to reduce compute times). The
advantage of this approach is that more data in used for model training
such that the resulting model may generalize better to new data. The
performance of this appraoch was estimated using cross-validation, using
only the scRNAseq data as the test set.

### What were the specific challenges you have encountered so far?

> Compute times are significantly longer for the semi-supervised
> approach for model training. Thus, cross-validation takes even longer.
> The datasets are restricted to 113 genes and therefore the discovery
> space is very limited for the semi-supervised approach to learn
> classification rules that are superior to the supervised approach.

### How are you going to address those challenges?

> Cross-validation was parallelized such that each iteration of
> cross-validation was run on an independent cpu thread. If additional
> data is available for this study it may be better than the current
> results given that the genes are limited to those identified using the
> scRNAseq data only.

### Link to your preliminary code and results on a Github account (optional)

> <https://github.com/singha53/ssenet>

### Additional information you would like the organizers to know

> This is my first time looking at single cell data and this opportunity
> would expose me to knew methods, technologies and research in this
> field.

## References

1)  <https://github.com/mabelc/SSC>

# [Data files](https://github.com/BIRSBiointegration/Hackathon/tree/master/seqFISH)

``` r
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
