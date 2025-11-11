
<!-- README.md is generated from README.Rmd. Please edit that file -->

# toxdrc

<!-- badges: start -->

<!-- badges: end -->

The goal of toxdrc is to provide a simple, easy solution to model and
estimate the dose response relationships in complex data sets. This
package provides a suite of modular functions that can take raw data,
perform quality checks, apply user-specified
transformation/normalization steps, fit and select the best fitting
dose-response model, and estimate specified effect measures across
multiple experimental subsets.

## Installation

You can install the development version of toxdrc from
[GitHub](https://github.com/jsalole/toxdrc) with:

``` r
# install.packages("pak")
pak::pak("jsalole/toxdrc")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(toxdrc)
head(cellglow)
#>           TestID Test_Number Conc   RFU Dye   Type Replicate
#> 1 83167_Spiked_A       83167    0 28777  aB Spiked         A
#> 2 83167_Spiked_A       83167    0 27567  aB Spiked         A
#> 3 83167_Spiked_B       83167    0 28985  aB Spiked         B
#> 4 83167_Spiked_B       83167    0 28026  aB Spiked         B
#> 5 83167_Spiked_C       83167    0 26853  aB Spiked         C
#> 6 83167_Spiked_C       83167    0 27831  aB Spiked         C
```

At first glance this dataset seems manageable, but it consists of 45
unique experimental subests of data, all of which need to be considered
independently.

Current approaches would require us to fragment the dataset and analyze
each one manually.

`toxdrc` offers another way to do this, through `runtoxdrc()`, which
analyzes all of them in one function.

``` r
analyzed_data <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  quiet = TRUE,
  qc = toxdrc_qc(), # uses defualt arguments, which can be overwritten. This controls testing for solvent effects, outlier testing, and CV calculations. Use ?toxdrc_qc() for more info.
  normalization = toxdrc_normalization(
    # here we specify to blank correct and normalize, instead of using default values. Only have to specify the arguments that do not use the default value. Use ?toxdrc_normalization() for more info.
    blank.correction = TRUE,
    normalize.resp = TRUE
  ),
  toxicity = toxdrc_toxicity(), # uses defualt arguments, which can be overwritten. This controls how toxicity is determined. Use ?toxdrc_toxicity() for more info.
  modelling = toxdrc_modelling(
    # Use ?toxdrc_modelling() for more info.
    quiet = TRUE
  )
)

analyzed_data
#> $`83167.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.aB.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.CFDA.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.NR.A.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.aB.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.CFDA.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.NR.B.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.aB.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.CFDA.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83167.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83256.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83344.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83475.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
#> 
#> $`83476.NR.C.Spiked`
#>   EC50 Std. Error Lower95 Upper95
#> 1   NA         NA      NA      NA
```

Currently working on other functions to view the plots and combine the
output into useable, readable formats.
