
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
summary(data_01)
#>                     Length Class  Mode
#> 83167.aB.A.Spiked   11     -none- list
#> 83256.aB.A.Spiked   11     -none- list
#> 83344.aB.A.Spiked   11     -none- list
#> 83475.aB.A.Spiked   11     -none- list
#> 83476.aB.A.Spiked   11     -none- list
#> 83167.CFDA.A.Spiked 11     -none- list
#> 83256.CFDA.A.Spiked 11     -none- list
#> 83344.CFDA.A.Spiked 11     -none- list
#> 83475.CFDA.A.Spiked 11     -none- list
#> 83476.CFDA.A.Spiked 11     -none- list
#> 83167.NR.A.Spiked   11     -none- list
#> 83256.NR.A.Spiked   11     -none- list
#> 83344.NR.A.Spiked   11     -none- list
#> 83475.NR.A.Spiked   11     -none- list
#> 83476.NR.A.Spiked   11     -none- list
#> 83167.aB.B.Spiked   11     -none- list
#> 83256.aB.B.Spiked   11     -none- list
#> 83344.aB.B.Spiked   11     -none- list
#> 83475.aB.B.Spiked   11     -none- list
#> 83476.aB.B.Spiked   11     -none- list
#> 83167.CFDA.B.Spiked 11     -none- list
#> 83256.CFDA.B.Spiked 11     -none- list
#> 83344.CFDA.B.Spiked 11     -none- list
#> 83475.CFDA.B.Spiked 11     -none- list
#> 83476.CFDA.B.Spiked 11     -none- list
#> 83167.NR.B.Spiked   11     -none- list
#> 83256.NR.B.Spiked   11     -none- list
#> 83344.NR.B.Spiked   11     -none- list
#> 83475.NR.B.Spiked   11     -none- list
#> 83476.NR.B.Spiked   11     -none- list
#> 83167.aB.C.Spiked   11     -none- list
#> 83256.aB.C.Spiked   11     -none- list
#> 83344.aB.C.Spiked   11     -none- list
#> 83475.aB.C.Spiked   11     -none- list
#> 83476.aB.C.Spiked   11     -none- list
#> 83167.CFDA.C.Spiked 11     -none- list
#> 83256.CFDA.C.Spiked 11     -none- list
#> 83344.CFDA.C.Spiked 11     -none- list
#> 83475.CFDA.C.Spiked 11     -none- list
#> 83476.CFDA.C.Spiked 11     -none- list
#> 83167.NR.C.Spiked   11     -none- list
#> 83256.NR.C.Spiked   11     -none- list
#> 83344.NR.C.Spiked   11     -none- list
#> 83475.NR.C.Spiked   11     -none- list
#> 83476.NR.C.Spiked   11     -none- list
```

``` r
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
