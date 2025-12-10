
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
length(unique(interaction(toxresult$TestID, toxresult$Dye)))
#> [1] 1
```

``` r
length(unique(interaction(cellglow$TestID, cellglow$Dye)))
#> [1] 45
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
```

``` r
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
length(data_01)
#> [1] 45
str(data_01[1])
#> List of 1
#>  $ 83167.aB.A.Spiked:List of 11
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
```

``` r
data_02
#>                     ID Effect Measure   Estimate  Std. Error        Lower
#> 1    83167.aB.A.Spiked           EC50  4.4205652   2.2945587 8.473618e-01
#> 2    83256.aB.A.Spiked           EC50 16.2647147   2.4803215 1.001100e+01
#> 3    83344.aB.A.Spiked           EC50  5.9924242   1.6964279 2.434059e+00
#> 4    83475.aB.A.Spiked           EC50  0.8838429   0.5481938 1.227810e-01
#> 5    83476.aB.A.Spiked           EC50 28.8840432   2.7741255 2.127720e+01
#> 6  83167.CFDA.A.Spiked           EC50 41.4848324  10.7602489 1.817181e+01
#> 7  83256.CFDA.A.Spiked           EC50 25.7846783   3.7404281 1.625047e+01
#> 8  83344.CFDA.A.Spiked           EC50 22.7291615   1.6738490 1.798041e+01
#> 9  83475.CFDA.A.Spiked           EC50 33.4057627  35.8688694 1.095960e+00
#> 10 83476.CFDA.A.Spiked           EC50 21.0746255  10.4167409 4.371272e+00
#> 11   83167.NR.A.Spiked           EC50  6.6672654   5.0882285 5.877085e-01
#> 12   83256.NR.A.Spiked           EC50 48.0741569         NaN          NaN
#> 13   83344.NR.A.Spiked           EC50 11.7631505   1.3806259 8.096664e+00
#> 14   83475.NR.A.Spiked           EC50 13.1305391   3.9497533 5.041178e+00
#> 15   83476.NR.A.Spiked           EC50  7.1430291   2.4911505 2.354316e+00
#> 16   83167.aB.B.Spiked           EC50  3.1015052   2.2375617 3.122133e-01
#> 17   83256.aB.B.Spiked           EC50 15.0306352   3.9815551 6.469334e+00
#> 18   83344.aB.B.Spiked           EC50  5.6279157   0.9405206 3.306526e+00
#> 19   83475.aB.B.Spiked           EC50  1.1971321   0.8201264 1.352962e-01
#> 20   83476.aB.B.Spiked           EC50 27.0466731   8.1196974 1.040368e+01
#> 21 83167.CFDA.B.Spiked           EC50 52.1683707 207.6616110 1.643387e-04
#> 22 83256.CFDA.B.Spiked           EC50 27.8872653   6.7330164 1.293336e+01
#> 23 83344.CFDA.B.Spiked           EC50 13.3797649   3.2240980 6.214437e+00
#> 24 83475.CFDA.B.Spiked           EC50 46.1798484 240.9379303 2.840598e-06
#> 25 83476.CFDA.B.Spiked           EC50 16.5306547   6.0999289 5.108323e+00
#> 26   83167.NR.B.Spiked           EC50 26.7013592   6.3919403 1.246445e+01
#> 27   83256.NR.B.Spiked           EC50 71.5514718 106.9129255 6.158043e-01
#> 28   83344.NR.B.Spiked           EC50  8.2847380   2.4742966 3.202573e+00
#> 29   83475.NR.B.Spiked           EC50 13.2596292   6.1836681 3.005911e+00
#> 30   83476.NR.B.Spiked           EC50  8.1499184   6.8899234 5.529845e-01
#> 31   83167.aB.C.Spiked           EC50  4.8399535   3.2748958 5.618847e-01
#> 32   83256.aB.C.Spiked           EC50 16.0906265   2.5050978 9.803820e+00
#> 33   83344.aB.C.Spiked           EC50  2.3460794   1.7179525 2.281734e-01
#> 34   83475.aB.C.Spiked           EC50  1.2441859   0.6650102 2.270653e-01
#> 35   83476.aB.C.Spiked           EC50 30.0374834   4.1517615 1.934764e+01
#> 36 83167.CFDA.C.Spiked           EC50 51.6601195         NaN          NaN
#> 37 83256.CFDA.C.Spiked           EC50 25.2800021   3.1345406 1.703743e+01
#> 38 83344.CFDA.C.Spiked           EC50 23.7728442   6.5239779 9.926279e+00
#> 39 83475.CFDA.C.Spiked           EC50 30.3526359  31.3301875 1.136487e+00
#> 40 83476.CFDA.C.Spiked           EC50 30.0961435   7.1833616 1.408076e+01
#> 41   83167.NR.C.Spiked           EC50 11.2277516   3.9617660 3.652629e+00
#> 42   83256.NR.C.Spiked           EC50 50.8162341 142.6067332 6.719414e-03
#> 43   83344.NR.C.Spiked           EC50  3.4449769   1.5695160 8.081634e-01
#> 44   83475.NR.C.Spiked           EC50 12.6328277  10.8945631 8.120072e-01
#> 45   83476.NR.C.Spiked           EC50 23.7109101   3.8236087 1.419281e+01
#>           Upper best_model_name effect
#> 1  2.306146e+01            LN.4   TRUE
#> 2  2.642503e+01            W2.4   TRUE
#> 3  1.475279e+01            W1.4   TRUE
#> 4  6.362371e+00            LL.4   TRUE
#> 5  3.921043e+01            W2.4   TRUE
#> 6  9.470664e+01            LN.4   TRUE
#> 7  4.091263e+01            W2.4   TRUE
#> 8  2.873208e+01            W2.4   TRUE
#> 9  1.018235e+03            W1.4   TRUE
#> 10 1.016043e+02            W1.4   TRUE
#> 11 7.563686e+01            W1.4   TRUE
#> 12          NaN            W1.4   TRUE
#> 13 1.708996e+01            LN.4   TRUE
#> 14 3.420055e+01            W2.4   TRUE
#> 15 2.167205e+01            W1.4   TRUE
#> 16 3.081013e+01            LL.4   TRUE
#> 17 3.492168e+01            W2.4   TRUE
#> 18 9.579067e+00            W1.4   TRUE
#> 19 1.059250e+01            LL.4   TRUE
#> 20 7.031380e+01            W2.4   TRUE
#> 21 1.656055e+07            W2.4   TRUE
#> 22 6.013129e+01            W2.4   TRUE
#> 23 2.880681e+01            LN.4   TRUE
#> 24 7.507498e+08            LL.4   TRUE
#> 25 5.349359e+01            W1.4   TRUE
#> 26 5.719970e+01            W2.4   TRUE
#> 27 8.313701e+03            W2.4   TRUE
#> 28 2.143179e+01            LL.4   TRUE
#> 29 5.849068e+01            W2.4   TRUE
#> 30 1.201140e+02            W1.4   TRUE
#> 31 4.169031e+01            LN.4   TRUE
#> 32 2.640892e+01            W2.4   TRUE
#> 33 2.412239e+01            W1.4   TRUE
#> 34 6.817416e+00            W1.4   TRUE
#> 35 4.663362e+01            W2.4   TRUE
#> 36          NaN            W2.4   TRUE
#> 37 3.751026e+01            W2.4   TRUE
#> 38 5.693454e+01            W2.4   TRUE
#> 39 8.106408e+02            W1.4   TRUE
#> 40 6.432734e+01            LN.4   TRUE
#> 41 3.451279e+01            LL.4   TRUE
#> 42 3.843028e+05            LL.4   TRUE
#> 43 1.468498e+01            LL.4   TRUE
#> 44 1.965356e+02            W2.4   TRUE
#> 45 3.961211e+01            LN.4   TRUE
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
