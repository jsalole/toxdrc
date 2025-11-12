
<!-- README.md is generated from README.Rmd. Please edit that file -->

# toxdrc

<!-- badges: start -->

[![R-CMD-check](https://github.com/jsalole/toxdrc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jsalole/toxdrc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of toxdrc is to provide a simple, easy solution to model and
estimate the dose response relationships in complex data sets. This
package provides a suite of modular functions that can take raw data,
perform quality checks, apply user-specified
transformation/normalization steps, fit and select the best fitting
dose-response model, and estimate specified effect measures across
multiple experimental subsets.

I would like to acknowledge that this package is built using the
[drc](https://cran.r-project.org/web/packages/drc/drc.pdf) package
framework and relies extensively on the functions provided in that
package.

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
    quiet = TRUE,
  )
)
```

We can then inspect all of the data and intermediate steps through the
list structure, or by calling single elements.

``` r
analyzed_data$`83167.aB.A.Spiked`
#> $dataset
#>     Conc mean_response Test_Number Dye Replicate   Type
#> 1   0.00    1.00000000       83167  aB         A Spiked
#> 2 100.00    0.03521757       83167  aB         A Spiked
#> 3  13.17    0.89917251       83167  aB         A Spiked
#> 4  19.75    0.85217208       83167  aB         A Spiked
#> 5  29.63    0.66668850       83167  aB         A Spiked
#> 6  44.44    0.44053623       83167  aB         A Spiked
#> 7  66.67    0.35937352       83167  aB         A Spiked
#> 
#> $ID
#> [1] "83167.aB.A.Spiked"
#> 
#> $blank_stats
#>   blank_mean blank_sd  blank_cv
#> 1     5271.5  41.7193 0.7914123
#> 
#> $normalize_response_summary
#>   ref_mean   ref_sd   ref_cv
#> 1  22900.5 855.5992 3.736159
#> 
#> $pre_average_dataset
#>            TestID Test_Number    Conc   RFU Dye   Type Replicate CVflag
#> 1  83167_Spiked_A       83167       0 28777  aB Spiked         A       
#> 2  83167_Spiked_A       83167       0 27567  aB Spiked         A       
#> 3  83167_Spiked_A       83167   13.17 25176  aB Spiked         A       
#> 4  83167_Spiked_A       83167   13.17 25859  aB Spiked         A       
#> 5  83167_Spiked_A       83167   13.17 26554  aB Spiked         A       
#> 6  83167_Spiked_A       83167   19.75 24620  aB Spiked         A       
#> 7  83167_Spiked_A       83167   19.75 24339  aB Spiked         A       
#> 8  83167_Spiked_A       83167   19.75 25401  aB Spiked         A       
#> 9  83167_Spiked_A       83167   29.63 20219  aB Spiked         A       
#> 10 83167_Spiked_A       83167   29.63 19201  aB Spiked         A       
#> 11 83167_Spiked_A       83167   29.63 22197  aB Spiked         A       
#> 12 83167_Spiked_A       83167   44.44 15184  aB Spiked         A       
#> 13 83167_Spiked_A       83167   44.44 16037  aB Spiked         A       
#> 14 83167_Spiked_A       83167   44.44 14859  aB Spiked         A       
#> 15 83167_Spiked_A       83167   66.67 14170  aB Spiked         A       
#> 16 83167_Spiked_A       83167   66.67 12359  aB Spiked         A       
#> 17 83167_Spiked_A       83167   66.67 13975  aB Spiked         A       
#> 18 83167_Spiked_A       83167     100  6085  aB Spiked         A       
#> 19 83167_Spiked_A       83167     100  6122  aB Spiked         A       
#> 20 83167_Spiked_A       83167     100  6027  aB Spiked         A       
#> 21 83167_Spiked_A       83167   Blank  5301  aB Spiked         A       
#> 22 83167_Spiked_A       83167   Blank  5242  aB Spiked         A       
#> 23 83167_Spiked_A       83167 Control 32861  aB Spiked         A       
#> 24 83167_Spiked_A       83167 Control 28086  aB Spiked         A       
#>    c_response normalized_response
#> 1     23505.5         1.026418637
#> 2     22295.5         0.973581363
#> 3     19904.5         0.869173162
#> 4     20587.5         0.898997838
#> 5     21282.5         0.929346521
#> 6     19348.5         0.844894216
#> 7     19067.5         0.832623742
#> 8     20129.5         0.878998275
#> 9     14947.5         0.652715006
#> 10    13929.5         0.608261828
#> 11    16925.5         0.739088666
#> 12     9912.5         0.432850811
#> 13    10765.5         0.470098906
#> 14     9587.5         0.418658981
#> 15     8898.5         0.388572302
#> 16     7087.5         0.309491059
#> 17     8703.5         0.380057204
#> 18      813.5         0.035523242
#> 19      850.5         0.037138927
#> 20      755.5         0.032990546
#> 21       29.5         0.001288181
#> 22      -29.5        -0.001288181
#> 23    27589.5         1.204755355
#> 24    22814.5         0.996244623
#> 
#> $effect
#> [1] TRUE
#> 
#> $nonnumericgroups
#> [1] "Blank"   "Control"
#> 
#> $model_df
#>        logLik        IC Lack of fit     Res var
#> LN.4 12.44718 -14.89436          NA 0.003899464
#> LL.4 12.30991 -14.61982          NA 0.004055439
#> LL.4 12.30991 -14.61982          NA 0.004055439
#> W2.4 12.18833 -14.37666          NA 0.004198787
#> W1.4 12.06492 -14.12984          NA 0.004349477
#> 
#> $best_model_name
#> [1] "LN.4"
#> 
#> $model
#> 
#> A 'drc' model.
#> 
#> Call:
#> drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#> 
#> Coefficients:
#> b:(Intercept)  c:(Intercept)  d:(Intercept)  e:(Intercept)  
#>       -0.9690        -0.3806         0.9999        63.0776  
#> 
#> 
#> $results
#>   Effect Measure Estimate Std. Error     Lower    Upper
#> 1           EC50 4.420565   2.294559 0.8473618 23.06146
```

We can also estimate multiple effect measures from each dataset as the
same time.

``` r
analyzed_data <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  quiet = TRUE,
  normalization = toxdrc_normalization(
    blank.correction = TRUE,
    normalize.resp = TRUE
  ),
  modelling = toxdrc_modelling(EDx = c(0.2, 0.5, 0.7))
)
analyzed_data$`83167.aB.A.Spiked`$results
#>   Effect Measure Estimate Std. Error     Lower    Upper
#> 1           EC20 3.235809   2.003172 0.4511939 23.20612
#> 2           EC50 4.420565   2.294559 0.8473618 23.06146
#> 3           EC70 4.995914   2.404170 1.0801938 23.10618
```

Currently working on other functions to combine the resulting list into
a more user-friendly interface.
