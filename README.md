
<!-- README.md is generated from README.Rmd. Please edit that file -->

# toxdrc

<!-- badges: start -->

[![R-CMD-check](https://github.com/jsalole/toxdrc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jsalole/toxdrc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**toxdrc** provides a streamlined workflow for analyzing dose-response
data.  
The package includes a set of modular functions that collectively:

- import and clean raw experimental data
- run quality checks
- apply optional user-defined transformations or normalizations
- fit multiple dose–response models
- automatically select the best-fitting model
- estimate specified effect measures across experimental groups or
  conditions

This makes **toxdrc** well-suited for handling complex or multi-factor
experiments where dose–response relationships must be modelled
consistently.

## Getting Started

You can install the development version of **toxdrc** from
[GitHub](https://github.com/jsalole/toxdrc) with:

``` r
# install.packages("pak")
pak::pak("jsalole/toxdrc")
```

``` r
library("toxdrc")
```

This will get the package into your R session.

## Examples

This package comes built in with two example datasets. `toxresult` is a
small dataset that looks at the results of a toxicity test within a
single 24-well plate. `cellglow` is much larger with 1080 observations.
These demonstrate when this package is useful.

``` r
head(toxresult)
#>           TestID Test_Number  Conc   RFU Dye   Type Replicate
#> 1 83167_Spiked_A       83167     0 28777  aB Spiked         A
#> 2 83167_Spiked_A       83167     0 27567  aB Spiked         A
#> 3 83167_Spiked_A       83167 13.17 25176  aB Spiked         A
#> 4 83167_Spiked_A       83167 13.17 25859  aB Spiked         A
#> 5 83167_Spiked_A       83167 13.17 26554  aB Spiked         A
#> 6 83167_Spiked_A       83167 19.75 24620  aB Spiked         A
unique(interaction(toxresult$TestID, toxresult$Dye))
#> [1] 83167_Spiked_A.aB
#> Levels: 83167_Spiked_A.aB

head(cellglow)
#>           TestID Test_Number Conc   RFU Dye   Type Replicate
#> 1 83167_Spiked_A       83167    0 28777  aB Spiked         A
#> 2 83167_Spiked_A       83167    0 27567  aB Spiked         A
#> 3 83167_Spiked_B       83167    0 28985  aB Spiked         B
#> 4 83167_Spiked_B       83167    0 28026  aB Spiked         B
#> 5 83167_Spiked_C       83167    0 26853  aB Spiked         C
#> 6 83167_Spiked_C       83167    0 27831  aB Spiked         C
unique(interaction(cellglow$TestID, cellglow$Dye))
#>  [1] 83167_Spiked_A.aB   83167_Spiked_B.aB   83167_Spiked_C.aB  
#>  [4] 83167_Spiked_A.CFDA 83167_Spiked_B.CFDA 83167_Spiked_C.CFDA
#>  [7] 83167_Spiked_A.NR   83167_Spiked_B.NR   83167_Spiked_C.NR  
#> [10] 83256_Spiked_A.aB   83256_Spiked_B.aB   83256_Spiked_C.aB  
#> [13] 83256_Spiked_A.CFDA 83256_Spiked_B.CFDA 83256_Spiked_C.CFDA
#> [16] 83256_Spiked_A.NR   83256_Spiked_B.NR   83256_Spiked_C.NR  
#> [19] 83344_Spiked_A.aB   83344_Spiked_B.aB   83344_Spiked_C.aB  
#> [22] 83344_Spiked_A.CFDA 83344_Spiked_B.CFDA 83344_Spiked_C.CFDA
#> [25] 83344_Spiked_A.NR   83344_Spiked_B.NR   83344_Spiked_C.NR  
#> [28] 83475_Spiked_A.aB   83475_Spiked_B.aB   83475_Spiked_C.aB  
#> [31] 83475_Spiked_A.CFDA 83475_Spiked_B.CFDA 83475_Spiked_C.CFDA
#> [34] 83475_Spiked_A.NR   83475_Spiked_B.NR   83475_Spiked_C.NR  
#> [37] 83476_Spiked_A.aB   83476_Spiked_B.aB   83476_Spiked_C.aB  
#> [40] 83476_Spiked_A.CFDA 83476_Spiked_B.CFDA 83476_Spiked_C.CFDA
#> [43] 83476_Spiked_A.NR   83476_Spiked_B.NR   83476_Spiked_C.NR  
#> 45 Levels: 83167_Spiked_A.aB 83167_Spiked_B.aB ... 83476_Spiked_C.NR
```

With one set of data, existing options like the `drc` package can be
quite manageable. These can also be assessed using **toxdrc** through
the many modular functions that exist, like `blankcorrect()`,
`normalizeresponse()`, `modelcomp()`, `getECx()`, among many others.
This package is most useful is through the pipeline function,
`runtoxdrc()`. This pipeline splits up the dataset into the subsets for
analysis.

``` r
data_01 <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  quiet = TRUE,
  qc = toxdrc_qc(),
  normalization = toxdrc_normalization(
    blank.correction = TRUE,
    normalize.resp = TRUE
  ),
  toxicity = toxdrc_toxicity(),
  modelling = toxdrc_modelling(
    quiet = TRUE,
  ),
  output = toxdrc_output()
)

data_02 <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  quiet = TRUE,
  qc = toxdrc_qc(),
  normalization = toxdrc_normalization(
    blank.correction = TRUE,
    normalize.resp = TRUE
  ),
  toxicity = toxdrc_toxicity(),
  modelling = toxdrc_modelling(
    quiet = TRUE,
  ),
  output = toxdrc_output(
    condense = TRUE
  )
)
```

While the pipeline only requires a few functions, it can be tailored to
meet the needs of most assays. The `toxdrc_config()` help file indicates
how these arguments can be used.

The `data_01` provides intermediate information on the pipeline for each
subset, but `data_02` will return a simple dataframe summarizung the
results.

``` r
str(data_01)
#> List of 45
#>  $ 83167.aB.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0352 0.8992 0.8522 0.6667 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.aB.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5272
#>   .. ..$ blank_sd  : num 41.7
#>   .. ..$ blank_cv  : num 0.791
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 22900
#>   .. ..$ ref_sd  : num 856
#>   .. ..$ ref_cv  : num 3.74
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_A" "83167_Spiked_A" "83167_Spiked_A" "83167_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 28777 27567 25176 25859 26554 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 23506 22296 19904 20588 21282 ...
#>   .. ..$ normalized_response: num [1:24] 1.026 0.974 0.869 0.899 0.929 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 12.4 12.3 12.3 12.2 12.1 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "LL.4" "LL.4" "W2.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -0.969 -0.381 1 63.078
#>   .. .. ..$ value      : num 0.0117
#>   .. .. ..$ counts     : Named int [1:2] 560 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.76548 -0.06439 -1.64026 -0.00743 -0.06439 ...
#>   .. .. ..$ ovalue     : num 0.0117
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0117 3 ...
#>   .. ..$ start       : num [1:4] -1.6084 0.0343 1.001 35.409
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.9999 0.0716 0.9108 0.8201 0.6796 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0352 0.8992 0.8522 0.6667 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -0.969 -0.381 1 63.078
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.23 -0.273 -0.34 -0.318 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0352 0.8992 0.8522 0.6667 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0352 0.8992 0.8522 0.6667 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0352 0.8992 0.8522 0.6667 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -0.969 -0.381 1 63.078
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 4.42
#>   .. ..$ Std. Error    : num 2.29
#>   .. ..$ Lower         : num 0.847
#>   .. ..$ Upper         : num 23.1
#>  $ 83256.aB.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.00287 0.98128 1.03047 0.68597 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.aB.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 6196
#>   .. ..$ blank_sd  : num 303
#>   .. ..$ blank_cv  : num 4.9
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 43556
#>   .. ..$ ref_sd  : num 2539
#>   .. ..$ ref_cv  : num 5.83
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_A" "83256_Spiked_A" "83256_Spiked_A" "83256_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 47957 51547 48861 43808 54141 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 41762 45352 42666 37612 47946 ...
#>   .. ..$ normalized_response: num [1:24] 0.959 1.041 0.98 0.864 1.101 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 12.82 11.6 11.11 11.11 9.83 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.3327 -0.0199 1.0083 33.2416
#>   .. .. ..$ value      : num 0.0105
#>   .. .. ..$ counts     : Named int [1:2] 576 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.07969 0.422 -0.05777 0.00329 0.422 ...
#>   .. .. ..$ ovalue     : num 0.0105
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0105 3 ...
#>   .. ..$ start       : num [1:4] -3.61694 0.00185 1.03149 27.49999
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0083 0.0559 1.0081 0.9729 0.7302 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.00287 0.98128 1.03047 0.68597 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.3327 -0.0199 1.0083 33.2416
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.08035 -0.00142 -0.0621 -0.04182 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.00287 0.98128 1.03047 0.68597 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.00287 0.98128 1.03047 0.68597 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.00287 0.98128 1.03047 0.68597 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.3327 -0.0199 1.0083 33.2416
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 16.3
#>   .. ..$ Std. Error    : num 2.48
#>   .. ..$ Lower         : num 10
#>   .. ..$ Upper         : num 26.4
#>  $ 83344.aB.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.000682 0.901248 0.832055 0.717988 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.aB.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 6193
#>   .. ..$ blank_sd  : num 45.3
#>   .. ..$ blank_cv  : num 0.731
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 166116
#>   .. ..$ ref_sd  : num 4408
#>   .. ..$ ref_cv  : num 2.65
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_A" "83344_Spiked_A" "83344_Spiked_A" "83344_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 175426 169192 154015 155008 158691 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 169233 162999 147822 148815 152498 ...
#>   .. ..$ normalized_response: num [1:24] 1.019 0.981 0.89 0.896 0.918 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 16.5 13.7 13.7 12.6 10.6 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 2.633379 -0.000317 0.966668 44.769571
#>   .. .. ..$ value      : num 0.0037
#>   .. .. ..$ counts     : Named int [1:2] 12 10
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.0404 -0.04284 0.3644 0.00234 -0.04284 ...
#>   .. .. ..$ ovalue     : num 0.0037
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0037 3 ...
#>   .. ..$ start       : num [1:4] 2.156117 -0.000317 1.000999 42.143631
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 9.67e-01 -7.69e-05 9.29e-01 8.61e-01 6.90e-01 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.000682 0.901248 0.832055 0.717988 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 2.633379 -0.000317 0.966668 44.769571
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0016 0.0453 0.0817 0.0961 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.000682 0.901248 0.832055 0.717988 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.000682 0.901248 0.832055 0.717988 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.000682 0.901248 0.832055 0.717988 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 2.633379 -0.000317 0.966668 44.769571
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 5.99
#>   .. ..$ Std. Error    : num 1.7
#>   .. ..$ Lower         : num 2.43
#>   .. ..$ Upper         : num 14.8
#>  $ 83475.aB.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.00791 0.79225 0.69511 0.56837 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.aB.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 7596
#>   .. ..$ blank_sd  : num 665
#>   .. ..$ blank_cv  : num 8.76
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 107446
#>   .. ..$ ref_sd  : num 595
#>   .. ..$ ref_cv  : num 0.554
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_A" "83475_Spiked_A" "83475_Spiked_A" "83475_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 115462 114620 93187 93174 91798 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 107866 107024 85592 85578 84202 ...
#>   .. ..$ normalized_response: num [1:24] 1.004 0.996 0.797 0.796 0.784 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 14.84 14.84 14.28 11.45 8.75 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 1.171 -0.823 0.995 81.182
#>   .. .. ..$ value      : num 0.0059
#>   .. .. ..$ counts     : Named int [1:2] 441 204
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.79523 0.46653 1.98828 0.00986 0.46653 ...
#>   .. .. ..$ ovalue     : num 0.59
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0059 3 ...
#>   .. ..$ start       : num [1:4] 3.49544 -0.00891 1.00101 26.71027
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.9954 -0.0245 0.8022 0.7037 0.568 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.00791 0.79225 0.69511 0.56837 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 1.171 -0.823 0.995 81.182
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0934 0.3141 0.3462 0.3296 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.00791 0.79225 0.69511 0.56837 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.00791 0.79225 0.69511 0.56837 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.00791 0.79225 0.69511 0.56837 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 1.171 -0.823 0.995 81.182
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 0.884
#>   .. ..$ Std. Error    : num 0.548
#>   .. ..$ Lower         : num 0.123
#>   .. ..$ Upper         : num 6.36
#>  $ 83476.aB.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0298 0.9729 0.9268 0.9923 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.aB.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5124
#>   .. ..$ blank_sd  : num 0
#>   .. ..$ blank_cv  : num 0
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 65596
#>   .. ..$ ref_sd  : num 5315
#>   .. ..$ ref_cv  : num 8.1
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_A" "83476_Spiked_A" "83476_Spiked_A" "83476_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 74479 66962 72309 69088 65434 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 69355 61838 67185 63964 60310 ...
#>   .. ..$ normalized_response: num [1:24] 1.057 0.943 1.024 0.975 0.919 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 16.2 13.6 13.6 13.6 13.2 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -4.5643 0.0226 0.9745 41.6207
#>   .. .. ..$ value      : num 0.00397
#>   .. .. ..$ counts     : Named int [1:2] 159 133
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.00674 0.13294 0.00678 0.00219 0.13294 ...
#>   .. .. ..$ ovalue     : num 0.00397
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00397 3 ...
#>   .. ..$ start       : num [1:4] -3.6584 0.0288 1.001 28.105
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.9745 0.0399 0.9745 0.9745 0.966 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0298 0.9729 0.9268 0.9923 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -4.5643 0.0226 0.9745 41.6207
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.50e-02 -2.49e-81 -1.92e-12 -1.37e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0298 0.9729 0.9268 0.9923 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0298 0.9729 0.9268 0.9923 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0298 0.9729 0.9268 0.9923 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -4.5643 0.0226 0.9745 41.6207
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 28.9
#>   .. ..$ Std. Error    : num 2.77
#>   .. ..$ Lower         : num 21.3
#>   .. ..$ Upper         : num 39.2
#>  $ 83167.CFDA.A.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0446 1.0179 1.0681 1.0744 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.CFDA.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1149
#>   .. ..$ blank_sd  : num 12.7
#>   .. ..$ blank_cv  : num 1.11
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 45764
#>   .. ..$ ref_sd  : num 2043
#>   .. ..$ ref_cv  : num 4.46
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_A" "83167_Spiked_A" "83167_Spiked_A" "83167_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 48357 45468 46249 47832 49120 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 47208 44319 45100 46683 47971 ...
#>   .. ..$ normalized_response: num [1:24] 1.032 0.968 0.986 1.02 1.048 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 16.2 16.1 16.1 16.1 16 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "LL.4" "LL.4" "W1.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -5.2698 0.0248 1.0399 67.6346
#>   .. .. ..$ value      : num 0.00406
#>   .. .. ..$ counts     : Named int [1:2] 71 55
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.001208 0.031313 -0.034455 -0.000298 0.031313 ...
#>   .. .. ..$ ovalue     : num 0.00406
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00406 3 ...
#>   .. ..$ start       : num [1:4] -1.9996 0.0435 1.0754 62.3978
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0399 0.0448 1.0399 1.0399 1.0399 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0446 1.0179 1.0681 1.0744 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -5.2698 0.0248 1.0399 67.6346
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.89e-02 -4.76e-17 -3.63e-10 -2.61e-05 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0446 1.0179 1.0681 1.0744 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0446 1.0179 1.0681 1.0744 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0446 1.0179 1.0681 1.0744 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -5.2698 0.0248 1.0399 67.6346
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 41.5
#>   .. ..$ Std. Error    : num 10.8
#>   .. ..$ Lower         : num 18.2
#>   .. ..$ Upper         : num 94.7
#>  $ 83256.CFDA.A.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.077 0.984 1.075 1.051 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.CFDA.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1492
#>   .. ..$ blank_sd  : num 99.7
#>   .. ..$ blank_cv  : num 6.68
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 104913
#>   .. ..$ ref_sd  : num 2625
#>   .. ..$ ref_cv  : num 2.5
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_A" "83256_Spiked_A" "83256_Spiked_A" "83256_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 108262 104549 106257 97947 109986 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 106770 103056 104764 96454 108494 ...
#>   .. ..$ normalized_response: num [1:24] 1.018 0.982 0.999 0.919 1.034 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 13.4 12.2 11.4 11.4 10.6 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.5682 -0.0788 1.0306 49.3548
#>   .. .. ..$ value      : num 0.00892
#>   .. .. ..$ counts     : Named int [1:2] 103 85
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.05865 0.28201 -0.0566 0.00208 0.28201 ...
#>   .. .. ..$ ovalue     : num 0.00892
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00892 3 ...
#>   .. ..$ start       : num [1:4] -3.478 0.076 1.076 30.074
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0306 0.0881 1.0306 1.0305 1.0033 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.077 0.984 1.075 1.051 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.5682 -0.0788 1.0306 49.3548
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.09e-01 -5.25e-12 -2.92e-04 -5.15e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.077 0.984 1.075 1.051 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.077 0.984 1.075 1.051 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.077 0.984 1.075 1.051 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.5682 -0.0788 1.0306 49.3548
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 25.8
#>   .. ..$ Std. Error    : num 3.74
#>   .. ..$ Lower         : num 16.3
#>   .. ..$ Upper         : num 40.9
#>  $ 83344.CFDA.A.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0212 1.0498 1.0367 0.9518 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.CFDA.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1630
#>   .. ..$ blank_sd  : num 228
#>   .. ..$ blank_cv  : num 14
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 227554
#>   .. ..$ ref_sd  : num 4439
#>   .. ..$ ref_cv  : num 1.95
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_A" "83344_Spiked_A" "83344_Spiked_A" "83344_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 232323 226046 237275 238958 245296 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 230693 224416 235645 237328 243666 ...
#>   .. ..$ normalized_response: num [1:24] 1.014 0.986 1.036 1.043 1.071 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 19.6 19.3 17.8 17.8 15.6 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.271 -0.181 1.027 47.363
#>   .. .. ..$ value      : num 0.00152
#>   .. .. ..$ counts     : Named int [1:2] 572 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.08402 0.35338 -0.0851 0.00376 0.35338 ...
#>   .. .. ..$ ovalue     : num 0.00152
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00152 3 ...
#>   .. ..$ start       : num [1:4] -3.7679 0.0202 1.0508 30.3419
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.027 0.021 1.027 1.027 0.961 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0212 1.0498 1.0367 0.9518 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.271 -0.181 1.027 47.363
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.38e-01 -3.20e-07 -5.26e-03 -9.04e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0212 1.0498 1.0367 0.9518 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0212 1.0498 1.0367 0.9518 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0212 1.0498 1.0367 0.9518 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.271 -0.181 1.027 47.363
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 22.7
#>   .. ..$ Std. Error    : num 1.67
#>   .. ..$ Lower         : num 18
#>   .. ..$ Upper         : num 28.7
#>  $ 83475.CFDA.A.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.00341 0.73134 0.7352 0.64363 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.CFDA.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 2050
#>   .. ..$ blank_sd  : num 415
#>   .. ..$ blank_cv  : num 20.3
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 107967
#>   .. ..$ ref_sd  : num 8222
#>   .. ..$ ref_cv  : num 7.61
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_A" "83475_Spiked_A" "83475_Spiked_A" "83475_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 115830 104203 80047 76607 86376 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 113780 102154 77998 74558 84326 ...
#>   .. ..$ normalized_response: num [1:24] 1.054 0.946 0.722 0.691 0.781 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 6.13 6.12 6.12 6.12 6.11 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 8.29368 0.00232 0.78067 63.2607
#>   .. .. ..$ value      : num 0.0711
#>   .. .. ..$ counts     : Named int [1:2] 52 41
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.000632 -0.019665 0.022907 -0.000762 -0.019665 ...
#>   .. .. ..$ ovalue     : num 0.0711
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0711 3 ...
#>   .. ..$ start       : num [1:4] 1.43014 0.00242 1.001 45.12223
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.78067 0.00232 0.78066 0.78062 0.77922 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.00341 0.73134 0.7352 0.64363 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 8.29368 0.00232 0.78067 63.2607
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 -6.79e-19 2.72e-06 5.81e-05 1.09e-03 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.00341 0.73134 0.7352 0.64363 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.00341 0.73134 0.7352 0.64363 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.00341 0.73134 0.7352 0.64363 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 8.29368 0.00232 0.78067 63.2607
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 33.4
#>   .. ..$ Std. Error    : num 35.9
#>   .. ..$ Lower         : num 1.1
#>   .. ..$ Upper         : num 1018
#>  $ 83476.CFDA.A.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.00265 0.78798 0.85116 0.8561 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.CFDA.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 3827
#>   .. ..$ blank_sd  : num 195
#>   .. ..$ blank_cv  : num 5.1
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 144109
#>   .. ..$ ref_sd  : num 14849
#>   .. ..$ ref_cv  : num 10.3
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_A" "83476_Spiked_A" "83476_Spiked_A" "83476_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 137436 158436 124003 116546 111595 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 133609 154609 120176 112719 107768 ...
#>   .. ..$ normalized_response: num [1:24] 0.927 1.073 0.834 0.782 0.748 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 10.01 9.97 9.97 9.9 9.59 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 4.75532 0.00164 0.88113 64.18245
#>   .. .. ..$ value      : num 0.0235
#>   .. .. ..$ counts     : Named int [1:2] 23 19
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.004949 -0.002601 0.113989 0.000381 -0.002601 ...
#>   .. .. ..$ ovalue     : num 0.0235
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0235 3 ...
#>   .. ..$ start       : num [1:4] 1.67369 0.00165 1.001 54.57742
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.88113 0.00188 0.88065 0.87789 0.85912 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.00265 0.78798 0.85116 0.8561 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 4.75532 0.00164 0.88113 64.18245
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.00085 0.000746 0.003802 0.016791 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.00265 0.78798 0.85116 0.8561 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.00265 0.78798 0.85116 0.8561 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.00265 0.78798 0.85116 0.8561 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 4.75532 0.00164 0.88113 64.18245
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 21.1
#>   .. ..$ Std. Error    : num 10.4
#>   .. ..$ Lower         : num 4.37
#>   .. ..$ Upper         : num 102
#>  $ 83167.NR.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.203 0.885 0.84 0.874 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.NR.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1490
#>   .. ..$ blank_sd  : num 107
#>   .. ..$ blank_cv  : num 7.17
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 9792
#>   .. ..$ ref_sd  : num 264
#>   .. ..$ ref_cv  : num 2.7
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_A" "83167_Spiked_A" "83167_Spiked_A" "83167_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 11095 11469 10300 9960 10208 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 9606 9980 8810 8470 8718 ...
#>   .. ..$ normalized_response: num [1:24] 0.981 1.019 0.9 0.865 0.89 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 12.1 12 12 11.9 11.7 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "W2.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 2.524 0.195 0.951 54.352
#>   .. .. ..$ value      : num 0.0129
#>   .. .. ..$ counts     : Named int [1:2] 48 41
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.027 -0.03277 0.32336 0.00134 -0.03277 ...
#>   .. .. ..$ ovalue     : num 0.0129
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0129 3 ...
#>   .. ..$ start       : num [1:4] 1.872 0.202 1.001 47.037
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.951 0.202 0.93 0.894 0.804 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.203 0.885 0.84 0.874 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 2.524 0.195 0.951 54.352
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0203 0.0291 0.055 0.0798 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.203 0.885 0.84 0.874 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.203 0.885 0.84 0.874 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.203 0.885 0.84 0.874 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 2.524 0.195 0.951 54.352
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 6.67
#>   .. ..$ Std. Error    : num 5.09
#>   .. ..$ Lower         : num 0.588
#>   .. ..$ Upper         : num 75.6
#>  $ 83256.NR.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.994 0.989 1.12 1.125 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.NR.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 576
#>   .. ..$ blank_sd  : num 2.12
#>   .. ..$ blank_cv  : num 0.368
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 2709
#>   .. ..$ ref_sd  : num 125
#>   .. ..$ ref_cv  : num 4.62
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_A" "83256_Spiked_A" "83256_Spiked_A" "83256_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 3197 3374 3305 3100 3363 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 2620 2798 2728 2524 2786 ...
#>   .. ..$ normalized_response: num [1:24] 0.967 1.033 1.007 0.932 1.029 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 10.6 10.4 10.4 10.4 10.4 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "W2.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 4.011 0.241 1.067 180.039
#>   .. .. ..$ value      : num 0.0198
#>   .. .. ..$ counts     : Named int [1:2] 611 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.004305 0.008237 0.116473 0.000145 0.008237 ...
#>   .. .. ..$ ovalue     : num 0.0198
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0198 3 ...
#>   .. ..$ start       : num [1:4] 0.804 0.989 1.125 258.594
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.067 0.992 1.067 1.066 1.066 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.994 0.989 1.12 1.125 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 4.011 0.241 1.067 180.039
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 4.18e-02 6.01e-05 2.58e-04 1.07e-03 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.994 0.989 1.12 1.125 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.994 0.989 1.12 1.125 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.994 0.989 1.12 1.125 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 4.011 0.241 1.067 180.039
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 48.1
#>   .. ..$ Std. Error    : num NaN
#>   .. ..$ Lower         : num NaN
#>   .. ..$ Upper         : num NaN
#>  $ 83344.NR.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.153 1.021 0.957 0.89 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.NR.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1586
#>   .. ..$ blank_sd  : num 37.5
#>   .. ..$ blank_cv  : num 2.36
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 7574
#>   .. ..$ ref_sd  : num 268
#>   .. ..$ ref_cv  : num 3.54
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_A" "83344_Spiked_A" "83344_Spiked_A" "83344_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 9349 8970 9388 8957 9613 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 7764 7384 7802 7372 8028 ...
#>   .. ..$ normalized_response: num [1:24] 1.025 0.975 1.03 0.973 1.06 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 20.5 19.4 19.4 19.1 17.9 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "LL.4" "LL.4" "W1.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -1.141 -0.897 1.012 112.438
#>   .. .. ..$ value      : num 0.00116
#>   .. .. ..$ counts     : Named int [1:2] 589 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.8504 -0.4301 -2.3911 -0.0112 -0.4301 ...
#>   .. .. ..$ ovalue     : num 0.00116
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00116 3 ...
#>   .. ..$ start       : num [1:4] -2.31 0.152 1.022 46.429
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.012 0.159 0.998 0.967 0.889 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.153 1.021 0.957 0.89 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -1.141 -0.897 1.012 112.438
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0885 -0.0818 -0.1848 -0.319 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.153 1.021 0.957 0.89 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.153 1.021 0.957 0.89 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.153 1.021 0.957 0.89 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -1.141 -0.897 1.012 112.438
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 11.8
#>   .. ..$ Std. Error    : num 1.38
#>   .. ..$ Lower         : num 8.1
#>   .. ..$ Upper         : num 17.1
#>  $ 83475.NR.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.096 1.064 1.036 0.741 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.NR.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 2078
#>   .. ..$ blank_sd  : num 446
#>   .. ..$ blank_cv  : num 21.5
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 2196
#>   .. ..$ ref_sd  : num 91.9
#>   .. ..$ ref_cv  : num 4.19
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_A" "83475_Spiked_A" "83475_Spiked_A" "83475_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 4210 4340 4417 4399 4433 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 2132 2262 2338 2320 2354 ...
#>   .. ..$ normalized_response: num [1:24] 0.97 1.03 1.06 1.06 1.07 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 11.5 11.1 10.7 10.7 10.4 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -1.32 -0.318 1.043 46.459
#>   .. .. ..$ value      : num 0.0153
#>   .. .. ..$ counts     : Named int [1:2] 165 131
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.35397 0.45292 -0.42383 0.00207 0.45292 ...
#>   .. .. ..$ ovalue     : num 0.0153
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0153 3 ...
#>   .. ..$ start       : num [1:4] -3.711 0.095 1.065 28.576
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.043 0.0971 1.0361 0.9812 0.8204 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.096 1.064 1.036 0.741 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -1.32 -0.318 1.043 46.459
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.2637 -0.0462 -0.1635 -0.1813 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.096 1.064 1.036 0.741 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.096 1.064 1.036 0.741 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.096 1.064 1.036 0.741 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -1.32 -0.318 1.043 46.459
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 13.1
#>   .. ..$ Std. Error    : num 3.95
#>   .. ..$ Lower         : num 5.04
#>   .. ..$ Upper         : num 34.2
#>  $ 83476.NR.A.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.155 0.962 0.919 0.818 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "A" "A" "A" "A" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.NR.A.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1586
#>   .. ..$ blank_sd  : num 37.5
#>   .. ..$ blank_cv  : num 2.36
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 6544
#>   .. ..$ ref_sd  : num 55.2
#>   .. ..$ ref_cv  : num 0.843
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_A" "83476_Spiked_A" "83476_Spiked_A" "83476_Spiked_A" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 8090 8168 7735 7834 8077 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "A" "A" "A" "A" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 6504 6582 6150 6248 6492 ...
#>   .. ..$ normalized_response: num [1:24] 0.994 1.006 0.94 0.955 0.992 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 17.1 15.8 15.8 14.9 14.1 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 2.484 0.125 0.982 60.241
#>   .. .. ..$ value      : num 0.00309
#>   .. .. ..$ counts     : Named int [1:2] 79 65
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.03723 -0.03921 0.38703 0.00159 -0.03921 ...
#>   .. .. ..$ ovalue     : num 0.00309
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00309 3 ...
#>   .. ..$ start       : num [1:4] 2.372 0.154 1.001 52.455
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.982 0.15 0.963 0.93 0.847 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.155 0.962 0.919 0.818 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 2.484 0.125 0.982 60.241
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0452 0.0292 0.0563 0.088 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.155 0.962 0.919 0.818 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "A" "A" "A" "A" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.155 0.962 0.919 0.818 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.155 0.962 0.919 0.818 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 2.484 0.125 0.982 60.241
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 7.14
#>   .. ..$ Std. Error    : num 2.49
#>   .. ..$ Lower         : num 2.35
#>   .. ..$ Upper         : num 21.7
#>  $ 83167.aB.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.011 0.897 0.877 0.722 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.aB.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5738
#>   .. ..$ blank_sd  : num 211
#>   .. ..$ blank_cv  : num 3.68
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 22768
#>   .. ..$ ref_sd  : num 678
#>   .. ..$ ref_cv  : num 2.98
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_B" "83167_Spiked_B" "83167_Spiked_B" "83167_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 28985 28026 25015 26045 27408 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 23248 22288 19278 20308 21670 ...
#>   .. ..$ normalized_response: num [1:24] 1.021 0.979 0.847 0.892 0.952 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 12.3 12.3 12 11.8 10.5 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 1.781 -0.368 1.003 60.532
#>   .. .. ..$ value      : num 0.0122
#>   .. .. ..$ counts     : Named int [1:2] 234 104
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.20554 -0.03798 0.78674 0.00315 -0.03798 ...
#>   .. .. ..$ ovalue     : num 1.22
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0122 3 ...
#>   .. ..$ start       : num [1:4] 3.85 0.01 1 31.89
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0032 0.0302 0.9183 0.8391 0.7033 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.011 0.897 0.877 0.722 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 1.781 -0.368 1.003 60.532
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.142 0.122 0.162 0.167 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.011 0.897 0.877 0.722 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.011 0.897 0.877 0.722 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.011 0.897 0.877 0.722 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 1.781 -0.368 1.003 60.532
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 3.1
#>   .. ..$ Std. Error    : num 2.24
#>   .. ..$ Lower         : num 0.312
#>   .. ..$ Upper         : num 30.8
#>  $ 83256.aB.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0137 0.9062 1.0186 0.5995 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.aB.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5987
#>   .. ..$ blank_sd  : num 103
#>   .. ..$ blank_cv  : num 1.72
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 45572
#>   .. ..$ ref_sd  : num 5500
#>   .. ..$ ref_cv  : num 12.1
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_B" "83256_Spiked_B" "83256_Spiked_B" "83256_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 47670 55448 49101 50207 42550 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 41683 49461 43114 44220 36563 ...
#>   .. ..$ normalized_response: num [1:24] 0.915 1.085 0.946 0.97 0.802 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 9.95 9.21 9.05 9.05 8.48 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.1508 -0.0465 0.9791 32.6334
#>   .. .. ..$ value      : num 0.0239
#>   .. .. ..$ counts     : Named int [1:2] 48 40
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.09565 0.46489 -0.0692 0.00296 0.46489 ...
#>   .. .. ..$ ovalue     : num 0.0239
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0239 3 ...
#>   .. ..$ start       : num [1:4] -3.5294 0.0127 1.0196 26.3479
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.9791 0.0417 0.9782 0.9252 0.6796 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0137 0.9062 1.0186 0.5995 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.1508 -0.0465 0.9791 32.6334
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.09442 -0.00574 -0.07979 -0.0356 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0137 0.9062 1.0186 0.5995 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0137 0.9062 1.0186 0.5995 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0137 0.9062 1.0186 0.5995 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.1508 -0.0465 0.9791 32.6334
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 15
#>   .. ..$ Std. Error    : num 3.98
#>   .. ..$ Lower         : num 6.47
#>   .. ..$ Upper         : num 34.9
#>  $ 83344.aB.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.000962 0.99502 0.866183 0.705439 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.aB.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 6223
#>   .. ..$ blank_sd  : num 928
#>   .. ..$ blank_cv  : num 14.9
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 164628
#>   .. ..$ ref_sd  : num 1633
#>   .. ..$ ref_cv  : num 0.992
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_B" "83344_Spiked_B" "83344_Spiked_B" "83344_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 169697 172006 160209 160561 189325 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 163474 165783 153986 154338 183102 ...
#>   .. ..$ normalized_response: num [1:24] 0.993 1.007 0.935 0.937 1.112 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 19.1 15.9 15.9 14.7 11.4 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 2.56643 -0.00196 1.00938 44.31092
#>   .. .. ..$ value      : num 0.00173
#>   .. .. ..$ counts     : Named int [1:2] 13 10
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.05327 -0.04687 0.39311 0.00284 -0.04687 ...
#>   .. .. ..$ ovalue     : num 0.00173
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00173 3 ...
#>   .. ..$ start       : num [1:4] 3.20154 -0.00196 1.001 47.28789
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.00938 -0.00165 0.96543 0.88992 0.70646 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.000962 0.99502 0.866183 0.705439 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 2.56643 -0.00196 1.00938 44.31092
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.00207 0.05215 0.09059 0.10149 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.000962 0.99502 0.866183 0.705439 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.000962 0.99502 0.866183 0.705439 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.000962 0.99502 0.866183 0.705439 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 2.56643 -0.00196 1.00938 44.31092
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 5.63
#>   .. ..$ Std. Error    : num 0.941
#>   .. ..$ Lower         : num 3.31
#>   .. ..$ Upper         : num 9.58
#>  $ 83475.aB.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.00531 0.83232 0.72167 0.52973 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.aB.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 7552
#>   .. ..$ blank_sd  : num 150
#>   .. ..$ blank_cv  : num 1.98
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 104924
#>   .. ..$ ref_sd  : num 147
#>   .. ..$ ref_cv  : num 0.14
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_B" "83475_Spiked_B" "83475_Spiked_B" "83475_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 112372 112580 96534 95001 93113 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 104820 105028 88982 87449 85561 ...
#>   .. ..$ normalized_response: num [1:24] 0.999 1.001 0.848 0.833 0.815 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 13.7 13.7 13.4 11.8 11.7 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 1.363 -0.501 1 58.191
#>   .. .. ..$ value      : num 0.0081
#>   .. .. ..$ counts     : Named int [1:2] 555 267
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.39857 0.04718 1.05612 0.00526 0.04718 ...
#>   .. .. ..$ ovalue     : num 0.81
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0081 3 ...
#>   .. ..$ start       : num [1:4] 3.60109 -0.00632 1.00101 27.25541
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0002 -0.0153 0.8252 0.7202 0.5724 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.00531 0.83232 0.72167 0.52973 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 1.363 -0.501 1 58.191
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.178 0.23 0.246 0.206 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.00531 0.83232 0.72167 0.52973 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.00531 0.83232 0.72167 0.52973 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.00531 0.83232 0.72167 0.52973 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 1.363 -0.501 1 58.191
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 1.2
#>   .. ..$ Std. Error    : num 0.82
#>   .. ..$ Lower         : num 0.135
#>   .. ..$ Upper         : num 10.6
#>  $ 83476.aB.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.021 0.914 0.775 0.873 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.aB.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5597
#>   .. ..$ blank_sd  : num 228
#>   .. ..$ blank_cv  : num 4.07
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 72404
#>   .. ..$ ref_sd  : num 5352
#>   .. ..$ ref_cv  : num 7.39
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_B" "83476_Spiked_B" "83476_Spiked_B" "83476_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 81786 74217 74041 72304 68959 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 76189 68620 68444 66707 63362 ...
#>   .. ..$ normalized_response: num [1:24] 1.052 0.948 0.945 0.921 0.875 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 9.68 9.67 9.66 9.66 9.52 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "W1.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -3.86608 -0.00527 0.89611 41.63125
#>   .. .. ..$ value      : num 0.0258
#>   .. .. ..$ counts     : Named int [1:2] 421 362
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.01064 0.16728 -0.01184 0.00236 0.16728 ...
#>   .. .. ..$ ovalue     : num 0.0258
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0258 3 ...
#>   .. ..$ start       : num [1:4] -3.36 0.02 1 25
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.8961 0.0247 0.8961 0.8961 0.8743 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.021 0.914 0.775 0.873 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -3.86608 -0.00527 0.89611 41.63125
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 2.58e-02 -6.02e-36 -2.09e-07 -2.76e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.021 0.914 0.775 0.873 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.021 0.914 0.775 0.873 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.021 0.914 0.775 0.873 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -3.86608 -0.00527 0.89611 41.63125
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 27
#>   .. ..$ Std. Error    : num 8.12
#>   .. ..$ Lower         : num 10.4
#>   .. ..$ Upper         : num 70.3
#>  $ 83167.CFDA.B.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.041 0.93 0.917 0.939 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.CFDA.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1188
#>   .. ..$ blank_sd  : num 55.9
#>   .. ..$ blank_cv  : num 4.7
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 50082
#>   .. ..$ ref_sd  : num 3956
#>   .. ..$ ref_cv  : num 7.9
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_B" "83167_Spiked_B" "83167_Spiked_B" "83167_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 48474 54068 48838 47352 47127 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 47286 52880 47650 46164 45938 ...
#>   .. ..$ normalized_response: num [1:24] 0.944 1.056 0.951 0.922 0.917 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 15.2 15.2 15.2 15.2 15.1 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -8.2602 0.0183 0.9545 63.8371
#>   .. .. ..$ value      : num 0.00534
#>   .. .. ..$ counts     : Named int [1:2] 47 31
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.000601 0.033679 0.014687 0.001247 0.033679 ...
#>   .. .. ..$ ovalue     : num 0.00534
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00534 3 ...
#>   .. ..$ start       : num [1:4] -3.03 0.04 1 30.63
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.954 0.041 0.954 0.954 0.954 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.041 0.93 0.917 0.939 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -8.2602 0.0183 0.9545 63.8371
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.01e-02 0.00 0.00 -2.71e-244 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.041 0.93 0.917 0.939 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.041 0.93 0.917 0.939 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.041 0.93 0.917 0.939 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -8.2602 0.0183 0.9545 63.8371
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 52.2
#>   .. ..$ Std. Error    : num 208
#>   .. ..$ Lower         : num 0.000164
#>   .. ..$ Upper         : num 16560552
#>  $ 83256.CFDA.B.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0829 1.0133 1.2077 1.2228 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.CFDA.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1442
#>   .. ..$ blank_sd  : num 41
#>   .. ..$ blank_cv  : num 2.84
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 96373
#>   .. ..$ ref_sd  : num 8163
#>   .. ..$ ref_cv  : num 8.47
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_B" "83256_Spiked_B" "83256_Spiked_B" "83256_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 92043 103587 104079 96617 96584 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 90601 102145 102637 95175 95142 ...
#>   .. ..$ normalized_response: num [1:24] 0.94 1.06 1.065 0.988 0.987 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 7.31 6.87 6.52 6.52 6.2 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.8105 -0.0589 1.1083 50.4735
#>   .. .. ..$ value      : num 0.0507
#>   .. .. ..$ counts     : Named int [1:2] 54 41
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.06105 0.26833 -0.04385 0.00121 0.26833 ...
#>   .. .. ..$ ovalue     : num 0.0507
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0507 3 ...
#>   .. ..$ start       : num [1:4] -3.2957 0.0817 1.224 29.4282
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.11 0.1 1.11 1.11 1.09 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0829 1.0133 1.2077 1.2228 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.8105 -0.0589 1.1083 50.4735
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.01e-01 -7.66e-18 -1.31e-05 -3.19e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0829 1.0133 1.2077 1.2228 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0829 1.0133 1.2077 1.2228 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0829 1.0133 1.2077 1.2228 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.8105 -0.0589 1.1083 50.4735
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 27.9
#>   .. ..$ Std. Error    : num 6.73
#>   .. ..$ Lower         : num 12.9
#>   .. ..$ Upper         : num 60.1
#>  $ 83344.CFDA.B.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.021 1.031 1.046 0.822 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.CFDA.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1726
#>   .. ..$ blank_sd  : num 7.78
#>   .. ..$ blank_cv  : num 0.451
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 226702
#>   .. ..$ ref_sd  : num 13058
#>   .. ..$ ref_cv  : num 5.76
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_B" "83344_Spiked_B" "83344_Spiked_B" "83344_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 237662 219195 266235 202063 238175 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 235936 217468 264508 200336 236448 ...
#>   .. ..$ normalized_response: num [1:24] 1.041 0.959 1.167 0.884 1.043 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 13.9 13.7 13.5 13.5 13.3 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "W2.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -1.833 -0.135 1.029 54.561
#>   .. .. ..$ value      : num 0.00763
#>   .. .. ..$ counts     : Named int [1:2] 572 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.145217 0.266999 -0.480938 -0.000523 0.266999 ...
#>   .. .. ..$ ovalue     : num 0.00763
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00763 3 ...
#>   .. ..$ start       : num [1:4] -2.42 0.02 1.05 45.67
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0288 0.0206 1.0235 0.9924 0.8757 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.021 1.031 1.046 0.822 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -1.833 -0.135 1.029 54.561
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.1518 -0.0222 -0.0833 -0.1515 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.021 1.031 1.046 0.822 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.021 1.031 1.046 0.822 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.021 1.031 1.046 0.822 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -1.833 -0.135 1.029 54.561
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 13.4
#>   .. ..$ Std. Error    : num 3.22
#>   .. ..$ Lower         : num 6.21
#>   .. ..$ Upper         : num 28.8
#>  $ 83475.CFDA.B.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.00555 0.76938 0.64288 0.60905 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.CFDA.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1942
#>   .. ..$ blank_sd  : num 265
#>   .. ..$ blank_cv  : num 13.7
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 110738
#>   .. ..$ ref_sd  : num 12945
#>   .. ..$ ref_cv  : num 11.7
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_B" "83475_Spiked_B" "83475_Spiked_B" "83475_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 103526 121833 87873 89849 83702 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 101584 119892 85932 87908 81760 ...
#>   .. ..$ normalized_response: num [1:24] 0.917 1.083 0.776 0.794 0.738 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 5.15 5.15 5.15 5.15 5.15 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W2.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 18.306 0.00543 0.75538 61.664
#>   .. .. ..$ value      : num 0.0941
#>   .. .. ..$ counts     : Named int [1:2] 56 28
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.000167 -0.014826 -0.002314 -0.000633 -0.014826 ...
#>   .. .. ..$ ovalue     : num 9.41
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0941 3 ...
#>   .. ..$ start       : num [1:4] 3.30257 0.00456 1.00099 27.69086
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.75538 0.00554 0.75538 0.75538 0.75538 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.00555 0.76938 0.64288 0.60905 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 18.306 0.00543 0.75538 61.664
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 -5.20e-05 6.17e-13 7.58e-10 8.19e-07 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.00555 0.76938 0.64288 0.60905 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.00555 0.76938 0.64288 0.60905 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.00555 0.76938 0.64288 0.60905 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 18.306 0.00543 0.75538 61.664
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 46.2
#>   .. ..$ Std. Error    : num 241
#>   .. ..$ Lower         : num 2.84e-06
#>   .. ..$ Upper         : num 7.51e+08
#>  $ 83476.CFDA.B.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.00275 0.83949 0.92158 0.89065 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.CFDA.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 3964
#>   .. ..$ blank_sd  : num 87
#>   .. ..$ blank_cv  : num 2.19
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 137594
#>   .. ..$ ref_sd  : num 16948
#>   .. ..$ ref_cv  : num 12.3
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_B" "83476_Spiked_B" "83476_Spiked_B" "83476_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 153542 129574 126274 120126 112017 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 149578 125610 122310 116162 108054 ...
#>   .. ..$ normalized_response: num [1:24] 1.087 0.913 0.889 0.844 0.785 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 12.1 12.1 12.1 11.9 11.3 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 3.94716 0.00175 0.92664 63.2373
#>   .. .. ..$ value      : num 0.0128
#>   .. .. ..$ counts     : Named int [1:2] 25 17
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.010903 -0.005099 0.179253 0.000871 -0.005099 ...
#>   .. .. ..$ ovalue     : num 0.0128
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0128 3 ...
#>   .. ..$ start       : num [1:4] 1.94882 0.00175 1.001 57.02001
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.92664 0.00381 0.92475 0.91733 0.88138 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.00275 0.83949 0.92158 0.89065 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 3.94716 0.00175 0.92664 63.2373
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.00578 0.00296 0.01078 0.03346 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.00275 0.83949 0.92158 0.89065 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.00275 0.83949 0.92158 0.89065 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.00275 0.83949 0.92158 0.89065 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 3.94716 0.00175 0.92664 63.2373
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 16.5
#>   .. ..$ Std. Error    : num 6.1
#>   .. ..$ Lower         : num 5.11
#>   .. ..$ Upper         : num 53.5
#>  $ 83167.NR.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.216 0.874 0.846 0.952 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.NR.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1540
#>   .. ..$ blank_sd  : num 82
#>   .. ..$ blank_cv  : num 5.33
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 9238
#>   .. ..$ ref_sd  : num 24.7
#>   .. ..$ ref_cv  : num 0.268
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_B" "83167_Spiked_B" "83167_Spiked_B" "83167_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 10761 10796 8834 9456 10559 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 9221 9256 7294 7916 9019 ...
#>   .. ..$ normalized_response: num [1:24] 0.998 1.002 0.79 0.857 0.976 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 10.62 9.85 9.77 9.77 9.38 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -3.535 0.205 0.92 42.796
#>   .. .. ..$ value      : num 0.0197
#>   .. .. ..$ counts     : Named int [1:2] 13 10
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.010808 0.14863 -0.013474 0.000655 0.14863 ...
#>   .. .. ..$ ovalue     : num 0.0197
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0197 3 ...
#>   .. ..$ start       : num [1:4] -3.155 0.216 1.001 25.522
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.92 0.24 0.92 0.92 0.901 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.216 0.874 0.846 0.952 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -3.535 0.205 0.92 42.796
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 2.87e-02 -5.65e-27 -1.77e-06 -2.46e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.216 0.874 0.846 0.952 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.216 0.874 0.846 0.952 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.216 0.874 0.846 0.952 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -3.535 0.205 0.92 42.796
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 26.7
#>   .. ..$ Std. Error    : num 6.39
#>   .. ..$ Lower         : num 12.5
#>   .. ..$ Upper         : num 57.2
#>  $ 83256.NR.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.84 0.914 0.965 1.05 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.NR.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 601
#>   .. ..$ blank_sd  : num 8.49
#>   .. ..$ blank_cv  : num 1.41
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 2894
#>   .. ..$ ref_sd  : num 291
#>   .. ..$ ref_cv  : num 10.1
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_B" "83256_Spiked_B" "83256_Spiked_B" "83256_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 3701 3289 3241 3445 3051 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 3100 2688 2640 2844 2450 ...
#>   .. ..$ normalized_response: num [1:24] 1.071 0.929 0.912 0.983 0.847 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 12.7 12.6 12.6 12.6 12.6 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -6.526 0.716 0.992 92.38
#>   .. .. ..$ value      : num 0.011
#>   .. .. ..$ counts     : Named int [1:2] 112 85
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 1.14e-04 7.90e-03 6.13e-03 8.98e-05 7.90e-03 ...
#>   .. .. ..$ ovalue     : num 0.011
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.011 3 ...
#>   .. ..$ start       : num [1:4] -2.12 0.84 1.05 24.8
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.992 0.84 0.992 0.992 0.992 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.84 0.914 0.965 1.05 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -6.526 0.716 0.992 92.38
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.00718 0 0 0 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.84 0.914 0.965 1.05 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.84 0.914 0.965 1.05 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.84 0.914 0.965 1.05 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -6.526 0.716 0.992 92.38
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 71.6
#>   .. ..$ Std. Error    : num 107
#>   .. ..$ Lower         : num 0.616
#>   .. ..$ Upper         : num 8314
#>  $ 83344.NR.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.135 1.003 0.913 0.898 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.NR.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1576
#>   .. ..$ blank_sd  : num 13.4
#>   .. ..$ blank_cv  : num 0.853
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 7752
#>   .. ..$ ref_sd  : num 344
#>   .. ..$ ref_cv  : num 4.43
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_B" "83344_Spiked_B" "83344_Spiked_B" "83344_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 9085 9571 9640 8397 10016 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 7510 7996 8064 6822 8440 ...
#>   .. ..$ normalized_response: num [1:24] 0.969 1.031 1.04 0.88 1.089 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 17.7 17.7 17.6 17.4 16.7 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 2.484 -0.219 1.001 69.812
#>   .. .. ..$ value      : num 0.0026
#>   .. .. ..$ counts     : Named int [1:2] 64 27
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.06672 -0.03763 0.47371 0.00141 -0.03763 ...
#>   .. .. ..$ ovalue     : num 0.26
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0026 3 ...
#>   .. ..$ start       : num [1:4] 5.563 0.134 1.004 40.944
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.001 0.136 0.982 0.951 0.872 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.135 1.003 0.913 0.898 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 2.484 -0.219 1.001 69.812
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0904 0.0313 0.0615 0.0994 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.135 1.003 0.913 0.898 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.135 1.003 0.913 0.898 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.135 1.003 0.913 0.898 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 2.484 -0.219 1.001 69.812
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 8.28
#>   .. ..$ Std. Error    : num 2.47
#>   .. ..$ Lower         : num 3.2
#>   .. ..$ Upper         : num 21.4
#>  $ 83475.NR.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.185 1.233 0.986 0.88 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.NR.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1894
#>   .. ..$ blank_sd  : num 124
#>   .. ..$ blank_cv  : num 6.57
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 2241
#>   .. ..$ ref_sd  : num 206
#>   .. ..$ ref_cv  : num 9.21
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_B" "83475_Spiked_B" "83475_Spiked_B" "83475_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 3989 4281 4889 4151 4932 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 2095 2387 2995 2257 3038 ...
#>   .. ..$ normalized_response: num [1:24] 0.935 1.065 1.336 1.007 1.356 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 8.42 8.4 8.24 8.24 8.2 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -1.242 -0.323 1.096 50.79
#>   .. .. ..$ value      : num 0.037
#>   .. .. ..$ counts     : Named int [1:2] 92 69
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.383118 0.366001 -0.558936 0.000732 0.366001 ...
#>   .. .. ..$ ovalue     : num 0.037
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.037 3 ...
#>   .. ..$ start       : num [1:4] -3.579 0.184 1.234 26.721
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.096 0.174 1.089 1.04 0.895 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.185 1.233 0.986 0.88 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -1.242 -0.323 1.096 50.79
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.2694 -0.0489 -0.1712 -0.212 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.185 1.233 0.986 0.88 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.185 1.233 0.986 0.88 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.185 1.233 0.986 0.88 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -1.242 -0.323 1.096 50.79
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 13.3
#>   .. ..$ Std. Error    : num 6.18
#>   .. ..$ Lower         : num 3.01
#>   .. ..$ Upper         : num 58.5
#>  $ 83476.NR.B.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.151 0.92 0.943 0.761 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "B" "B" "B" "B" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.NR.B.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1589
#>   .. ..$ blank_sd  : num 56.6
#>   .. ..$ blank_cv  : num 3.56
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 6666
#>   .. ..$ ref_sd  : num 484
#>   .. ..$ ref_cv  : num 7.26
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_B" "83476_Spiked_B" "83476_Spiked_B" "83476_Spiked_B" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 7913 8597 8321 7126 7712 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "B" "B" "B" "B" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 6324 7008 6732 5537 6123 ...
#>   .. ..$ normalized_response: num [1:24] 0.949 1.051 1.01 0.831 0.919 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 11.4 10.9 10.9 10.6 10.3 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 2.657 0.126 0.962 59.812
#>   .. .. ..$ value      : num 0.0157
#>   .. .. ..$ counts     : Named int [1:2] 23 19
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.02576 -0.03249 0.33805 0.00133 -0.03249 ...
#>   .. .. ..$ ovalue     : num 0.0157
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0157 3 ...
#>   .. ..$ start       : num [1:4] 2.17 0.15 1 51.61
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.962 0.142 0.948 0.92 0.843 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.151 0.92 0.943 0.761 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 2.657 0.126 0.962 59.812
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0335 0.0223 0.0463 0.0779 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.151 0.92 0.943 0.761 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "B" "B" "B" "B" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.151 0.92 0.943 0.761 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.151 0.92 0.943 0.761 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 2.657 0.126 0.962 59.812
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 8.15
#>   .. ..$ Std. Error    : num 6.89
#>   .. ..$ Lower         : num 0.553
#>   .. ..$ Upper         : num 120
#>  $ 83167.aB.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0355 0.9465 0.8707 0.716 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.aB.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5391
#>   .. ..$ blank_sd  : num 308
#>   .. ..$ blank_cv  : num 5.72
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 21951
#>   .. ..$ ref_sd  : num 692
#>   .. ..$ ref_cv  : num 3.15
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_C" "83167_Spiked_C" "83167_Spiked_C" "83167_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 26853 27831 24107 29157 25239 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 21462 22440 18716 23766 19848 ...
#>   .. ..$ normalized_response: num [1:24] 0.978 1.022 0.853 1.083 0.904 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 10.33 10.15 10.06 10.06 9.87 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "W2.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -0.952 -0.502 1.012 72.354
#>   .. .. ..$ value      : num 0.0214
#>   .. .. ..$ counts     : Named int [1:2] 393 345
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.95459 -0.24096 -2.04797 -0.00988 -0.24096 ...
#>   .. .. ..$ ovalue     : num 0.0214
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0214 3 ...
#>   .. ..$ start       : num [1:4] -1.7292 0.0346 1.001 37.7987
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0123 0.0716 0.933 0.8485 0.713 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0355 0.9465 0.8707 0.716 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -0.952 -0.502 1.012 72.354
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.186 -0.276 -0.365 -0.376 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0355 0.9465 0.8707 0.716 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0355 0.9465 0.8707 0.716 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0355 0.9465 0.8707 0.716 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -0.952 -0.502 1.012 72.354
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 4.84
#>   .. ..$ Std. Error    : num 3.27
#>   .. ..$ Lower         : num 0.562
#>   .. ..$ Upper         : num 41.7
#>  $ 83256.aB.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.00135 1.02649 1.0329 0.69915 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.aB.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 6185
#>   .. ..$ blank_sd  : num 79.2
#>   .. ..$ blank_cv  : num 1.28
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 43571
#>   .. ..$ ref_sd  : num 3816
#>   .. ..$ ref_cv  : num 8.76
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_C" "83256_Spiked_C" "83256_Spiked_C" "83256_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 47058 52454 46673 52446 53612 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 40873 46269 40488 46261 47427 ...
#>   .. ..$ normalized_response: num [1:24] 0.938 1.062 0.929 1.062 1.088 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 13 11.12 10.77 10.77 8.96 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.3776 -0.0161 1.0278 32.444
#>   .. .. ..$ value      : num 0.00999
#>   .. .. ..$ counts     : Named int [1:2] 579 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.07411 0.426 -0.05615 0.00346 0.426 ...
#>   .. .. ..$ ovalue     : num 0.00999
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00999 3 ...
#>   .. ..$ start       : num [1:4] -3.7765 -0.00239 1.03394 28.46145
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0278 0.0533 1.0276 0.9875 0.7259 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.00135 1.02649 1.0329 0.69915 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.3776 -0.0161 1.0278 32.444
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.07548 -0.00158 -0.06507 -0.03398 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.00135 1.02649 1.0329 0.69915 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.00135 1.02649 1.0329 0.69915 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.00135 1.02649 1.0329 0.69915 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.3776 -0.0161 1.0278 32.444
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 16.1
#>   .. ..$ Std. Error    : num 2.51
#>   .. ..$ Lower         : num 9.8
#>   .. ..$ Upper         : num 26.4
#>  $ 83344.aB.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0013 0.7942 0.7044 0.6299 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.aB.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 6147
#>   .. ..$ blank_sd  : num 232
#>   .. ..$ blank_cv  : num 3.77
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 182004
#>   .. ..$ ref_sd  : num 11922
#>   .. ..$ ref_cv  : num 6.55
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_C" "83344_Spiked_C" "83344_Spiked_C" "83344_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 196581 179721 138487 151937 161638 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 190434 173574 132340 145790 155491 ...
#>   .. ..$ normalized_response: num [1:24] 1.046 0.954 0.727 0.801 0.854 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 11.9 10.63 10.63 9.25 7.46 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 1.85 2.98e-04 9.60e-01 4.13e+01
#>   .. .. ..$ value      : num 0.0137
#>   .. .. ..$ counts     : Named int [1:2] 14 10
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.09974 -0.09238 0.50799 0.00227 -0.09238 ...
#>   .. .. ..$ ovalue     : num 0.0137
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0137 3 ...
#>   .. ..$ start       : num [1:4] 1.74 2.98e-04 1.00 3.63e+01
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.9596 0.00599 0.85002 0.74267 0.55807 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0013 0.7942 0.7044 0.6299 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 1.85 2.98e-04 9.60e-01 4.13e+01
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.0258 0.1177 0.1403 0.1002 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0013 0.7942 0.7044 0.6299 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0013 0.7942 0.7044 0.6299 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0013 0.7942 0.7044 0.6299 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 1.85 2.98e-04 9.60e-01 4.13e+01
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 2.35
#>   .. ..$ Std. Error    : num 1.72
#>   .. ..$ Lower         : num 0.228
#>   .. ..$ Upper         : num 24.1
#>  $ 83475.aB.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.00689 0.8823 0.71599 0.55848 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.aB.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 7569
#>   .. ..$ blank_sd  : num 419
#>   .. ..$ blank_cv  : num 5.53
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 105271
#>   .. ..$ ref_sd  : num 6546
#>   .. ..$ ref_cv  : num 6.22
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_C" "83475_Spiked_C" "83475_Spiked_C" "83475_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 108211 117469 92626 105718 103004 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 100642 109900 85057 98149 95435 ...
#>   .. ..$ normalized_response: num [1:24] 0.956 1.044 0.808 0.932 0.907 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 14.4 14.4 14.4 13.6 12.6 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 1.4463 -0.0634 1.002 48.4284
#>   .. .. ..$ value      : num 0.00672
#>   .. .. ..$ counts     : Named int [1:2] 558 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.25768 -0.10774 0.77409 0.00402 -0.10774 ...
#>   .. .. ..$ ovalue     : num 0.00672
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00672 3 ...
#>   .. ..$ start       : num [1:4] 1.8181 -0.0079 1.001 40.8604
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.00203 -0.00202 0.85171 0.74726 0.58842 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.00689 0.8823 0.71599 0.55848 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 1.4463 -0.0634 1.002 48.4284
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.127 0.181 0.199 0.157 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.00689 0.8823 0.71599 0.55848 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.00689 0.8823 0.71599 0.55848 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.00689 0.8823 0.71599 0.55848 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 1.4463 -0.0634 1.002 48.4284
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 1.24
#>   .. ..$ Std. Error    : num 0.665
#>   .. ..$ Lower         : num 0.227
#>   .. ..$ Upper         : num 6.82
#>  $ 83476.aB.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0316 1.0912 0.9899 1.1223 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.aB.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 5592
#>   .. ..$ blank_sd  : num 218
#>   .. ..$ blank_cv  : num 3.91
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 60784
#>   .. ..$ ref_sd  : num 4306
#>   .. ..$ ref_cv  : num 7.08
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_C" "83476_Spiked_C" "83476_Spiked_C" "83476_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 69421 63331 72777 67423 75552 ...
#>   .. ..$ Dye                : chr [1:24] "aB" "aB" "aB" "aB" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 63828 57738 67184 61830 69960 ...
#>   .. ..$ normalized_response: num [1:24] 1.05 0.95 1.11 1.02 1.15 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 11.8 10.5 10.5 10.5 10.5 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -4.9604 0.0322 1.0509 42.0385
#>   .. .. ..$ value      : num 0.0142
#>   .. .. ..$ counts     : Named int [1:2] 79 61
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.00618 0.11999 0.01614 0.00196 0.11999 ...
#>   .. .. ..$ ovalue     : num 0.0142
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0142 3 ...
#>   .. ..$ start       : num [1:4] -3.654 0.0305 1.1234 28.2101
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0509 0.0459 1.0509 1.0509 1.0474 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0316 1.0912 0.9899 1.1223 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -4.9604 0.0322 1.0509 42.0385
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.18e-02 -1.34e-135 -1.25e-17 -6.97e-03 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0316 1.0912 0.9899 1.1223 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "aB" "aB" "aB" "aB" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0316 1.0912 0.9899 1.1223 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0316 1.0912 0.9899 1.1223 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -4.9604 0.0322 1.0509 42.0385
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 30
#>   .. ..$ Std. Error    : num 4.15
#>   .. ..$ Lower         : num 19.3
#>   .. ..$ Upper         : num 46.6
#>  $ 83167.CFDA.C.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0484 1.013 1.0791 1.1535 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.CFDA.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1266
#>   .. ..$ blank_sd  : num 20.5
#>   .. ..$ blank_cv  : num 1.62
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 43442
#>   .. ..$ ref_sd  : num 4545
#>   .. ..$ ref_cv  : num 10.5
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_C" "83167_Spiked_C" "83167_Spiked_C" "83167_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 41494 47922 47086 45883 42845 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 40228 46656 45820 44618 41580 ...
#>   .. ..$ normalized_response: num [1:24] 0.926 1.074 1.055 1.027 0.957 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 11.5 11.4 11.4 11.4 11.4 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -8.061 0.0218 1.0671 63.5313
#>   .. .. ..$ value      : num 0.0156
#>   .. .. ..$ counts     : Named int [1:2] 25 19
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.000886 0.040866 0.017689 0.001663 0.040866 ...
#>   .. .. ..$ ovalue     : num 0.0156
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0156 3 ...
#>   .. ..$ start       : num [1:4] -3.0742 0.0473 1.1546 31.2372
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0671 0.0484 1.0671 1.0671 1.0671 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0484 1.013 1.0791 1.1535 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -8.061 0.0218 1.0671 63.5313
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.19e-02 0.00 0.00 -2.09e-201 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0484 1.013 1.0791 1.1535 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0484 1.013 1.0791 1.1535 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0484 1.013 1.0791 1.1535 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -8.061 0.0218 1.0671 63.5313
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 51.7
#>   .. ..$ Std. Error    : num NaN
#>   .. ..$ Lower         : num NaN
#>   .. ..$ Upper         : num NaN
#>  $ 83256.CFDA.C.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0782 0.9678 1.0374 1.0197 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.CFDA.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1518
#>   .. ..$ blank_sd  : num 108
#>   .. ..$ blank_cv  : num 7.12
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 106748
#>   .. ..$ ref_sd  : num 3913
#>   .. ..$ ref_cv  : num 3.67
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_C" "83256_Spiked_C" "83256_Spiked_C" "83256_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 105500 111034 118247 105871 90360 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 103982 109516 116728 104352 88842 ...
#>   .. ..$ normalized_response: num [1:24] 0.974 1.026 1.093 0.978 0.832 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 15 13.4 12.5 12.5 11.6 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.5133 -0.0792 1.0106 49.0795
#>   .. .. ..$ value      : num 0.00572
#>   .. .. ..$ counts     : Named int [1:2] 63 49
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.05874 0.28356 -0.05935 0.00213 0.28356 ...
#>   .. .. ..$ ovalue     : num 0.00572
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00572 3 ...
#>   .. ..$ start       : num [1:4] -3.5114 0.0772 1.0383 30.3631
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0106 0.0886 1.0106 1.0106 0.9795 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0782 0.9678 1.0374 1.0197 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.5133 -0.0792 1.0106 49.0795
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.10e-01 -5.54e-11 -5.14e-04 -5.59e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0782 0.9678 1.0374 1.0197 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0782 0.9678 1.0374 1.0197 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0782 0.9678 1.0374 1.0197 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.5133 -0.0792 1.0106 49.0795
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 25.3
#>   .. ..$ Std. Error    : num 3.13
#>   .. ..$ Lower         : num 17
#>   .. ..$ Upper         : num 37.5
#>  $ 83344.CFDA.C.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0243 1.2189 1.2107 1.0842 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.CFDA.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1558
#>   .. ..$ blank_sd  : num 54.4
#>   .. ..$ blank_cv  : num 3.5
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 204558
#>   .. ..$ ref_sd  : num 10044
#>   .. ..$ ref_cv  : num 4.91
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_C" "83344_Spiked_C" "83344_Spiked_C" "83344_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 213217 199013 249377 224015 279278 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 211660 197456 247820 222458 277720 ...
#>   .. ..$ normalized_response: num [1:24] 1.035 0.965 1.211 1.088 1.358 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 9.05 8.85 8.53 8.53 8.03 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -2.394 -0.179 1.143 47.704
#>   .. .. ..$ value      : num 0.0309
#>   .. .. ..$ counts     : Named int [1:2] 493 401
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.09117 0.37024 -0.08162 0.00419 0.37024 ...
#>   .. .. ..$ ovalue     : num 0.0309
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0309 3 ...
#>   .. ..$ start       : num [1:4] -3.7902 0.0231 1.2201 30.3832
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.1429 0.0279 1.1429 1.1426 1.085 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0243 1.2189 1.2107 1.0842 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -2.394 -0.179 1.143 47.704
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 1.40e-01 -1.28e-08 -2.49e-03 -8.63e-02 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0243 1.2189 1.2107 1.0842 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0243 1.2189 1.2107 1.0842 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0243 1.2189 1.2107 1.0842 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -2.394 -0.179 1.143 47.704
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 23.8
#>   .. ..$ Std. Error    : num 6.52
#>   .. ..$ Lower         : num 9.93
#>   .. ..$ Upper         : num 56.9
#>  $ 83475.CFDA.C.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.0056 0.7748 0.7825 0.627 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.CFDA.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1989
#>   .. ..$ blank_sd  : num 31.1
#>   .. ..$ blank_cv  : num 1.56
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 102320
#>   .. ..$ ref_sd  : num 19315
#>   .. ..$ ref_cv  : num 18.9
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_C" "83475_Spiked_C" "83475_Spiked_C" "83475_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 117966 90651 74195 82848 86753 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 115977 88662 72206 80859 84764 ...
#>   .. ..$ normalized_response: num [1:24] 1.133 0.867 0.706 0.79 0.828 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 6.18 6.16 6.16 6.15 6.14 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W1.4" "LL.4" "LL.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W1.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 7.2869 0.0043 0.8017 62.7804
#>   .. .. ..$ value      : num 0.0702
#>   .. .. ..$ counts     : Named int [1:2] 42 32
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.000966 -0.021591 0.036491 -0.000692 -0.021591 ...
#>   .. .. ..$ ovalue     : num 0.0702
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0702 3 ...
#>   .. ..$ start       : num [1:4] 1.53971 0.00461 1.00099 46.4364
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.8017 0.0043 0.8017 0.8015 0.7984 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.0056 0.7748 0.7825 0.627 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 7.2869 0.0043 0.8017 62.7804
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 10
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ edfct :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name  : chr "W1.4"
#>   .. .. ..$ text  : chr "Weibull (type 1)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-1"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 -1.35e-12 1.42e-05 2.02e-04 2.51e-03 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : chr [1:4] "" "" "t3" ""
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.0056 0.7748 0.7825 0.627 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.0056 0.7748 0.7825 0.627 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.0056 0.7748 0.7825 0.627 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 7.2869 0.0043 0.8017 62.7804
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 30.4
#>   .. ..$ Std. Error    : num 31.3
#>   .. ..$ Lower         : num 1.14
#>   .. ..$ Upper         : num 811
#>  $ 83476.CFDA.C.Spiked:List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.000181 0.786384 0.893422 0.922888 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.CFDA.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 4222
#>   .. ..$ blank_sd  : num 231
#>   .. ..$ blank_cv  : num 5.46
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 138000
#>   .. ..$ ref_sd  : num 7547
#>   .. ..$ ref_cv  : num 5.47
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_C" "83476_Spiked_C" "83476_Spiked_C" "83476_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 147559 136886 118889 101578 117763 ...
#>   .. ..$ Dye                : chr [1:24] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 143337 132664 114667 97356 113541 ...
#>   .. ..$ normalized_response: num [1:24] 1.039 0.961 0.831 0.705 0.823 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 9.94 9.91 9.91 9.86 9.61 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "LL.4" "LL.4" "W1.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -3.88728 -0.00119 0.90064 58.38316
#>   .. .. ..$ value      : num 0.024
#>   .. .. ..$ counts     : Named int [1:2] 25 18
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.012044 0.084693 -0.084745 0.000389 0.084693 ...
#>   .. .. ..$ ovalue     : num 0.024
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.024 3 ...
#>   .. ..$ start       : num [1:4] -1.53572 -0.00118 1.001 41.75687
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.9006 0.0152 0.9006 0.9006 0.8969 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.000181 0.786384 0.893422 0.922888 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -3.88728 -0.00119 0.90064 58.38316
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 2.17e-02 -2.84e-08 -5.45e-05 -7.55e-03 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.000181 0.786384 0.893422 0.922888 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "CFDA" "CFDA" "CFDA" "CFDA" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.000181 0.786384 0.893422 0.922888 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.000181 0.786384 0.893422 0.922888 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -3.88728 -0.00119 0.90064 58.38316
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 30.1
#>   .. ..$ Std. Error    : num 7.18
#>   .. ..$ Lower         : num 14.1
#>   .. ..$ Upper         : num 64.3
#>  $ 83167.NR.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.226 0.905 0.94 0.875 ...
#>   .. ..$ Test_Number  : chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83167.NR.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1494
#>   .. ..$ blank_sd  : num 18.4
#>   .. ..$ blank_cv  : num 1.23
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 9112
#>   .. ..$ ref_sd  : num 409
#>   .. ..$ ref_cv  : num 4.49
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83167_Spiked_C" "83167_Spiked_C" "83167_Spiked_C" "83167_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83167" "83167" "83167" "83167" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 10317 10896 9047 10628 9551 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 8823 9402 7553 9134 8057 ...
#>   .. ..$ normalized_response: num [1:24] 0.968 1.032 0.829 1.002 0.884 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 16.1 16.1 16.1 15.8 15.7 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 3.397 0.139 0.962 53.331
#>   .. .. ..$ value      : num 0.0041
#>   .. .. ..$ counts     : Named int [1:2] 41 17
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.016418 -0.103847 0.168213 0.000083 -0.103847 ...
#>   .. .. ..$ ovalue     : num 0.41
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0041 3 ...
#>   .. ..$ start       : num [1:4] 3.998 0.225 1.001 33.712
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.962 0.226 0.955 0.935 0.864 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.226 0.905 0.94 0.875 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 3.397 0.139 0.962 53.331
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 -0.04889 0.00978 0.02616 0.05091 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.226 0.905 0.94 0.875 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83167" "83167" "83167" "83167" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.226 0.905 0.94 0.875 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.226 0.905 0.94 0.875 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 3.397 0.139 0.962 53.331
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 11.2
#>   .. ..$ Std. Error    : num 3.96
#>   .. ..$ Lower         : num 3.65
#>   .. ..$ Upper         : num 34.5
#>  $ 83256.NR.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.838 0.845 1.014 0.944 ...
#>   .. ..$ Test_Number  : chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83256.NR.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 622
#>   .. ..$ blank_sd  : num 2.12
#>   .. ..$ blank_cv  : num 0.341
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 2954
#>   .. ..$ ref_sd  : num 226
#>   .. ..$ ref_cv  : num 7.66
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83256_Spiked_C" "83256_Spiked_C" "83256_Spiked_C" "83256_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83256" "83256" "83256" "83256" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 3416 3736 3164 3231 2960 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 2794 3114 2542 2608 2338 ...
#>   .. ..$ normalized_response: num [1:24] 0.946 1.054 0.861 0.883 0.791 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 10.9 10.9 10.9 10.9 10 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 17.283 0.838 0.956 69.026
#>   .. .. ..$ value      : num 0.0181
#>   .. .. ..$ counts     : Named int [1:2] 155 76
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 2.21e-06 5.29e-04 1.25e-03 1.29e-05 5.29e-04 ...
#>   .. .. ..$ ovalue     : num 1.81
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.0181 3 ...
#>   .. ..$ start       : num [1:4] 2.797 0.838 1.014 32.785
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.956 0.838 0.956 0.956 0.956 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.838 0.845 1.014 0.944 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 17.283 0.838 0.956 69.026
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0.00 -7.20e-05 7.19e-14 5.98e-11 4.48e-08 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.838 0.845 1.014 0.944 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83256" "83256" "83256" "83256" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.838 0.845 1.014 0.944 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.838 0.845 1.014 0.944 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 17.283 0.838 0.956 69.026
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 50.8
#>   .. ..$ Std. Error    : num 143
#>   .. ..$ Lower         : num 0.00672
#>   .. ..$ Upper         : num 384303
#>  $ 83344.NR.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.129 0.862 0.807 0.75 ...
#>   .. ..$ Test_Number  : chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83344.NR.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1628
#>   .. ..$ blank_sd  : num 84.9
#>   .. ..$ blank_cv  : num 5.21
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 8690
#>   .. ..$ ref_sd  : num 588
#>   .. ..$ ref_cv  : num 6.76
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83344_Spiked_C" "83344_Spiked_C" "83344_Spiked_C" "83344_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83344" "83344" "83344" "83344" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 9902 10733 8643 9011 9710 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 8274 9105 7015 7383 8082 ...
#>   .. ..$ normalized_response: num [1:24] 0.952 1.048 0.807 0.85 0.93 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 20.2 20.2 18.9 14.9 13.9 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LL.4" "LL.4" "W1.4" "LN.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LL.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] 1.121 -3.737 0.986 387.121
#>   .. .. ..$ value      : num 0.00126
#>   .. .. ..$ counts     : Named int [1:2] 1043 500
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 5.92982 0.79282 7.24415 0.00944 0.79282 ...
#>   .. .. ..$ ovalue     : num 0.126
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00126 3 ...
#>   .. ..$ start       : num [1:4] 3.486 0.128 1.001 30.582
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 0.986 0.137 0.882 0.824 0.735 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.129 0.862 0.807 0.75 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] 1.121 -3.737 0.986 387.121
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 17
#>   .. .. ..$ fct      :function (dose, parm)  
#>   .. .. ..$ ssfct    :function (dframe)  
#>   .. .. ..$ names    : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1   :function (dose, parm)  
#>   .. .. ..$ deriv2   : NULL
#>   .. .. ..$ derivx   :function (x, parm)  
#>   .. .. ..$ edfct    :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ inversion:function (y, parm)  
#>   .. .. ..$ scaleFct :function (doseScaling, respScaling)  
#>   .. .. ..$ name     : chr "LL.4"
#>   .. .. ..$ text     : chr "Log-logistic (ED50 as parameter)"
#>   .. .. ..$ noParm   : int 4
#>   .. .. ..$ lowerAs  :function (parm)  
#>   .. .. ..$ upperAs  :function (parm)  
#>   .. .. ..$ monoton  :function (parm)  
#>   .. .. ..$ retFct   :function (doseScaling, respScaling)  
#>   .. .. ..$ fixed    : num [1:5] NA NA NA NA 1
#>   .. .. ..- attr(*, "class")= chr "llogistic"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.943 0.345 0.466 0.61 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.129 0.862 0.807 0.75 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83344" "83344" "83344" "83344" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.129 0.862 0.807 0.75 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.129 0.862 0.807 0.75 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] 1.121 -3.737 0.986 387.121
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 3.44
#>   .. ..$ Std. Error    : num 1.57
#>   .. ..$ Lower         : num 0.808
#>   .. ..$ Upper         : num 14.7
#>  $ 83475.NR.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 -0.0797 1.0796 1.1272 0.4824 ...
#>   .. ..$ Test_Number  : chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83475.NR.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 2297
#>   .. ..$ blank_sd  : num 76.4
#>   .. ..$ blank_cv  : num 3.32
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 2057
#>   .. ..$ ref_sd  : num 352
#>   .. ..$ ref_cv  : num 17.1
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83475_Spiked_C" "83475_Spiked_C" "83475_Spiked_C" "83475_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83475" "83475" "83475" "83475" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 4105 4603 5045 4594 3914 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 1808 2306 2748 2297 1617 ...
#>   .. ..$ normalized_response: num [1:24] 0.879 1.121 1.336 1.117 0.786 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 3.71 3.28 3.11 3.11 2.83 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "W2.4" "LN.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "W2.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -1.9247 -0.0339 1.0753 30.0429
#>   .. .. ..$ value      : num 0.142
#>   .. .. ..$ counts     : Named int [1:2] 55 32
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 0.15399 0.59546 -0.0942 0.00178 0.59546 ...
#>   .. .. ..$ ovalue     : num 0.142
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.142 3 ...
#>   .. ..$ start       : num [1:4] -3.4137 -0.0809 1.1284 27.5693
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.0753 0.0705 1.067 0.9575 0.6781 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 -0.0797 1.0796 1.1272 0.4824 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -1.9247 -0.0339 1.0753 30.0429
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 11
#>   .. .. ..$ fct   :function (dose, parm)  
#>   .. .. ..$ ssfct :function (dframe)  
#>   .. .. ..$ names : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1:function (dose, parm)  
#>   .. .. ..$ deriv2: NULL
#>   .. .. ..$ derivx: NULL
#>   .. .. ..$ edfct :function (parm, p, reference, type, ...)  
#>   .. .. ..$ name  : chr "W2.4"
#>   .. .. ..$ text  : chr "Weibull (type 2)"
#>   .. .. ..$ noParm: int 4
#>   .. .. ..$ fixed : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "Weibull-2"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.11941 -0.03364 -0.11083 -0.00565 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : chr [1:7] "1" "2" "3" "4" ...
#>   .. .. .. ..$ : NULL
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 -0.0797 1.0796 1.1272 0.4824 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83475" "83475" "83475" "83475" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 -0.0797 1.0796 1.1272 0.4824 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 -0.0797 1.0796 1.1272 0.4824 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -1.9247 -0.0339 1.0753 30.0429
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 12.6
#>   .. ..$ Std. Error    : num 10.9
#>   .. ..$ Lower         : num 0.812
#>   .. ..$ Upper         : num 197
#>  $ 83476.NR.C.Spiked  :List of 11
#>   ..$ dataset                   :'data.frame':   7 obs. of  6 variables:
#>   .. ..$ Conc         : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. ..$ mean_response: num [1:7] 1 0.146 1.061 1.117 1.029 ...
#>   .. ..$ Test_Number  : chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Dye          : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Replicate    : chr [1:7] "C" "C" "C" "C" ...
#>   .. ..$ Type         : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   ..$ ID                        : chr "83476.NR.C.Spiked"
#>   ..$ blank_stats               :'data.frame':   1 obs. of  3 variables:
#>   .. ..$ blank_mean: num 1619
#>   .. ..$ blank_sd  : num 177
#>   .. ..$ blank_cv  : num 10.9
#>   ..$ normalize_response_summary:'data.frame':   1 obs. of  3 variables:
#>   .. ..$ ref_mean: num 5596
#>   .. ..$ ref_sd  : num 514
#>   .. ..$ ref_cv  : num 9.19
#>   ..$ pre_average_dataset       :'data.frame':   24 obs. of  10 variables:
#>   .. ..$ TestID             : chr [1:24] "83476_Spiked_C" "83476_Spiked_C" "83476_Spiked_C" "83476_Spiked_C" ...
#>   .. ..$ Test_Number        : chr [1:24] "83476" "83476" "83476" "83476" ...
#>   .. ..$ Conc               : chr [1:24] "0" "0" "13.17" "13.17" ...
#>   .. ..$ RFU                : num [1:24] 7579 6852 7487 7384 7805 ...
#>   .. ..$ Dye                : chr [1:24] "NR" "NR" "NR" "NR" ...
#>   .. ..$ Type               : chr [1:24] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ Replicate          : chr [1:24] "C" "C" "C" "C" ...
#>   .. ..$ CVflag             : chr [1:24] "" "" "" "" ...
#>   .. ..$ c_response         : num [1:24] 5960 5233 5868 5765 6186 ...
#>   .. ..$ normalized_response: num [1:24] 1.065 0.935 1.049 1.03 1.105 ...
#>   ..$ effect                    : logi TRUE
#>   ..$ nonnumericgroups          : chr [1:2] "Blank" "Control"
#>   ..$ model_df                  : num [1:5, 1:4] 14.3 14.1 13.9 13.9 13.4 ...
#>   .. ..- attr(*, "dimnames")=List of 2
#>   .. .. ..$ : chr [1:5] "LN.4" "W2.4" "LL.4" "LL.4" ...
#>   .. .. ..$ : chr [1:4] "logLik" "IC" "Lack of fit" "Res var"
#>   ..$ best_model_name           : chr "LN.4"
#>   ..$ model                     :List of 30
#>   .. ..$ varParm     : NULL
#>   .. ..$ fit         :List of 7
#>   .. .. ..$ par        : num [1:4] -3.065 0.115 1.059 54.947
#>   .. .. ..$ value      : num 0.00697
#>   .. .. ..$ counts     : Named int [1:2] 24 19
#>   .. .. .. ..- attr(*, "names")= chr [1:2] "function" "gradient"
#>   .. .. ..$ convergence: logi TRUE
#>   .. .. ..$ message    : NULL
#>   .. .. ..$ hessian    : num [1:4, 1:4] 2.32e-02 1.34e-01 -1.40e-01 -2.76e-05 1.34e-01 ...
#>   .. .. ..$ ovalue     : num 0.00697
#>   .. ..$ curve       :List of 2
#>   .. .. ..$ :function (dose)  
#>   .. .. ..$ : NULL
#>   .. ..$ summary     : num [1:6] NA NA NA 0.00697 3 ...
#>   .. ..$ start       : num [1:4] -2.234 0.145 1.118 47.047
#>   .. ..$ parNames    :List of 3
#>   .. .. ..$ : chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ : chr [1:4] "(Intercept)" "(Intercept)" "(Intercept)" "(Intercept)"
#>   .. ..$ predres     : num [1:7, 1:2] 1.059 0.146 1.059 1.058 1.031 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:2] "Predicted values" "Residuals"
#>   .. ..$ call        : language drm(formula = Response ~ Conc, data = ds, fct = model_list[[best_model_name]])
#>   .. ..$ data        :'data.frame':  7 obs. of  5 variables:
#>   .. .. ..$ Conc    : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response: num [1:7] 1 0.146 1.061 1.117 1.029 ...
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ 1       : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ parmMat     : num [1:4, 1] -3.065 0.115 1.059 54.947
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ fct         :List of 14
#>   .. .. ..$ fct    :function (dose, parm)  
#>   .. .. ..$ ssfct  :function (dframe)  
#>   .. .. ..$ names  : chr [1:4] "b" "c" "d" "e"
#>   .. .. ..$ deriv1 :function (dose, parm)  
#>   .. .. ..$ deriv2 : NULL
#>   .. .. ..$ derivx :function (dose, parm)  
#>   .. .. ..$ edfct  :function (parm, respl, reference, type, ...)  
#>   .. .. ..$ name   : chr "LN.4"
#>   .. .. ..$ text   : chr "Log-normal"
#>   .. .. ..$ noParm : int 4
#>   .. .. ..$ lowerAs:function (parm)  
#>   .. .. ..$ upperAs:function (parm)  
#>   .. .. ..$ monoton:function (parm)  
#>   .. .. ..$ fixed  : logi [1:4] NA NA NA NA
#>   .. .. ..- attr(*, "class")= chr "log-normal"
#>   .. ..$ robust      : NULL
#>   .. ..$ estMethod   :List of 8
#>   .. .. ..$ llfct   :function (object)  
#>   .. .. ..$ opfct   :function (parm)  
#>   .. .. ..$ opdfct1 : NULL
#>   .. .. ..$ ssfct   : NULL
#>   .. .. ..$ rvfct   :function (object)  
#>   .. .. ..$ vcovfct :function (object)  
#>   .. .. ..$ parmfct :function (fit, fixed = TRUE)  
#>   .. .. ..$ rstanfct:function (object)  
#>   .. ..$ df.residual : int 3
#>   .. ..$ sumList     :List of 3
#>   .. .. ..$ lenData    : int 7
#>   .. .. ..$ alternative: NULL
#>   .. .. ..$ df.residual: int 3
#>   .. ..$ scaleFct    : NULL
#>   .. ..$ pmFct       :function (fixedParm)  
#>   .. ..$ pfFct       :function (parmMat)  
#>   .. ..$ type        : chr "continuous"
#>   .. ..$ indexMat    : int [1:4, 1] 1 2 3 4
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr "1"
#>   .. ..$ logDose     : NULL
#>   .. ..$ cm          : NULL
#>   .. ..$ deriv1      : num [1:7, 1:4] 0 0.041855 -0.000037 -0.00282 -0.038775 ...
#>   .. .. ..- attr(*, "dimnames")=List of 2
#>   .. .. .. ..$ : NULL
#>   .. .. .. ..$ : chr [1:4] "b" "c" "d" "e"
#>   .. ..$ curveVarNam : chr "1"
#>   .. ..$ origData    :'data.frame':  7 obs. of  6 variables:
#>   .. .. ..$ Conc       : num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. ..$ Response   : num [1:7] 1 0.146 1.061 1.117 1.029 ...
#>   .. .. ..$ Test_Number: chr [1:7] "83476" "83476" "83476" "83476" ...
#>   .. .. ..$ Dye        : chr [1:7] "NR" "NR" "NR" "NR" ...
#>   .. .. ..$ Replicate  : chr [1:7] "C" "C" "C" "C" ...
#>   .. .. ..$ Type       : chr [1:7] "Spiked" "Spiked" "Spiked" "Spiked" ...
#>   .. ..$ weights     : num [1:7] 1 1 1 1 1 1 1
#>   .. ..$ dataList    :List of 6
#>   .. .. ..$ dose    : Named num [1:7] 0 100 13.2 19.8 29.6 ...
#>   .. .. .. ..- attr(*, "names")= chr [1:7] "1" "2" "3" "4" ...
#>   .. .. ..$ origResp: num [1:7] 1 0.146 1.061 1.117 1.029 ...
#>   .. .. ..$ weights : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ curveid : num [1:7] 1 1 1 1 1 1 1
#>   .. .. ..$ resp    : num [1:7] 1 0.146 1.061 1.117 1.029 ...
#>   .. .. ..$ names   :List of 5
#>   .. .. .. ..$ dName : chr "Conc"
#>   .. .. .. ..$ orName: chr "Response"
#>   .. .. .. ..$ wName : chr "weights"
#>   .. .. .. ..$ cNames: chr "1"
#>   .. .. .. ..$ rName : chr ""
#>   .. ..$ coefficients: Named num [1:4] -3.065 0.115 1.059 54.947
#>   .. .. ..- attr(*, "names")= chr [1:4] "b:(Intercept)" "c:(Intercept)" "d:(Intercept)" "e:(Intercept)"
#>   .. ..$ boxcox      : NULL
#>   .. ..$ indexMat2   : num [1:4] 1 2 3 4
#>   .. ..- attr(*, "class")= chr "drc"
#>   ..$ effectmeasure             :'data.frame':   1 obs. of  5 variables:
#>   .. ..$ Effect Measure: chr "EC50"
#>   .. ..$ Estimate      : num 23.7
#>   .. ..$ Std. Error    : num 3.82
#>   .. ..$ Lower         : num 14.2
#>   .. ..$ Upper         : num 39.6
str(data_02)
#> 'data.frame':    45 obs. of  8 variables:
#>  $ ID             : chr  "83167.aB.A.Spiked" "83256.aB.A.Spiked" "83344.aB.A.Spiked" "83475.aB.A.Spiked" ...
#>  $ Effect Measure : chr  "EC50" "EC50" "EC50" "EC50" ...
#>  $ Estimate       : num  4.421 16.265 5.992 0.884 28.884 ...
#>  $ Std. Error     : num  2.295 2.48 1.696 0.548 2.774 ...
#>  $ Lower          : num  0.847 10.011 2.434 0.123 21.277 ...
#>  $ Upper          : num  23.06 26.43 14.75 6.36 39.21 ...
#>  $ best_model_name: chr  "LN.4" "W2.4" "W1.4" "LL.4" ...
#>  $ effect         : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...

head(data_02)
#>                    ID Effect Measure   Estimate Std. Error      Lower     Upper
#> 1   83167.aB.A.Spiked           EC50  4.4205652  2.2945587  0.8473618 23.061455
#> 2   83256.aB.A.Spiked           EC50 16.2647147  2.4803215 10.0109977 26.425033
#> 3   83344.aB.A.Spiked           EC50  5.9924242  1.6964279  2.4340586 14.752787
#> 4   83475.aB.A.Spiked           EC50  0.8838429  0.5481938  0.1227810  6.362371
#> 5   83476.aB.A.Spiked           EC50 28.8840432  2.7741255 21.2771968 39.210426
#> 6 83167.CFDA.A.Spiked           EC50 41.4848324 10.7602489 18.1718124 94.706641
#>   best_model_name effect
#> 1            LN.4   TRUE
#> 2            W2.4   TRUE
#> 3            W1.4   TRUE
#> 4            LL.4   TRUE
#> 5            W2.4   TRUE
#> 6            LN.4   TRUE
```

This package is also capable of making multiple point-estimates for each
subset:

``` r
data_03 <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  quiet = TRUE,
  normalization = toxdrc_normalization(
    blank.correction = TRUE,
    normalize.resp = TRUE
  ),
  modelling = toxdrc_modelling(
    EDx = c(0.2, 0.5, 0.7),
    quiet = TRUE
  ),
  output = toxdrc_output(condense = TRUE)
)

head(data_03)
#>                  ID Effect Measure  Estimate Std. Error      Lower    Upper
#> 1 83167.aB.A.Spiked           EC20  3.235809   2.003172  0.4511939 23.20612
#> 2 83167.aB.A.Spiked           EC50  4.420565   2.294559  0.8473618 23.06146
#> 3 83167.aB.A.Spiked           EC70  4.995914   2.404170  1.0801938 23.10618
#> 4 83256.aB.A.Spiked           EC20 15.189664   2.536946  8.9270818 25.84561
#> 5 83256.aB.A.Spiked           EC50 16.264715   2.480321 10.0109977 26.42503
#> 6 83256.aB.A.Spiked           EC70 16.728695   2.453028 10.4904421 26.67659
#>   best_model_name effect
#> 1            LN.4   TRUE
#> 2            LN.4   TRUE
#> 3            LN.4   TRUE
#> 4            W2.4   TRUE
#> 5            W2.4   TRUE
#> 6            W2.4   TRUE
```

## Authours

- **Jack Salole** - *Intial Work* -
  [jsalole](https://github.com/jsalole)

## Acknowledgments

- This package is an extenision of the [drc
  package](https://cran.r-project.org/web/packages/drc/drc.pdf).
- This package uses code suggested by [Nel on stack
  overflow](https://stackoverflow.com/users/7133643/nel) for mselect2,
  which updates mselect to work within a function.
