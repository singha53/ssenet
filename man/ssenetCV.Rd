% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/predict.ssenet.R
\name{ssenetCV}
\alias{ssenetCV}
\title{M-fold cross-validation function for all methods}
\usage{
ssenetCV(
  Xlabeled,
  Xunlabeled,
  ylabeled,
  yunlabeled,
  alpha,
  lambda,
  folds,
  progressBar,
  family,
  filter,
  topranked,
  keepVar,
  useObsWeights,
  max.iter,
  perc.full,
  thr.conf
)
}
\arguments{
\item{alpha}{= 1 (lasso), alpha = 0 (ridge), 0 < alpha < 1 (elastic net penalty)}

\item{lambda}{= strength of elastic net penalty}

\item{folds}{caret list specifying the indicies in the different folds}

\item{progressBar}{a boolean that specifies whether a progress bar should be displayed or not}

\item{family}{"binomial" or "multinomial"}

\item{filter}{= "none" or "p.value"}

\item{topranked}{= 50 (top number of features to select and build a classifier)}

\item{keepVar}{- names of specific variable to keep in model}

\item{X}{nxp matrix - training dataset}

\item{y}{factor - response variable}

\item{weights}{- observational weights; default to 1}
}
\description{
Estimate test error of elastic net panel
}
