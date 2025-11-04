#' Example toxicity test data with multiple experimental groups.
#'
#' A subset of data from a study using the RTgill-W1 assay (ISO 21115/OECD 249). Briefly, cells are exposed to a toxicant and the fluorescent signal is measured using 3 indicators.
#'
#' Data collected as part of a study. Full dataset is available within a data repository:
#' Salole, Jack; Wilson, Joanna; Taylor, Lisa, 2025, "RTgill-W1 Assay - Optimization and Effluent Testing", https://doi.org/10.5683/SP3/ES7GDM, Borealis, V2.
#'
#'
#' @format ## `cellglow`
#' A data frame with 1,080 rows and 7 columns:
#' \describe{
#'   \item{TestID}{Combination of Test_Number, Dye, Type, and Replicate}
#'   \item{Test_Number}{Identifying number of each effluent sample}
#'   \item{Conc}{Concentration of reference toxicant (3,4 dichloranaline). 0 is solvent control, "control" is a lab control}
#'   \item{RFU}{Fluoresence produced as determined by a plate reader}
#'   \item{Dye}{Three cell viability indicators; aB = alamarBlue, CFDA = 5-CFDA-AM, NR = Neutral Red}
#'   \item{Type}{Only spiked exists in this dataset; indicates a reference toxicant was added to the effluent.}
#'   \item{Replicate}{The experimental replicate; replication occured at a well-plate level.}

#' /item

#'   ...
#' }
#' @source https://doi.org/10.5683/SP3/ES7GDM
"cellglow"
