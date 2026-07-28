---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# toxdrc

<!-- badges: start -->
[![R-CMD-check](https://github.com/jsalole/toxdrc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jsalole/toxdrc/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**toxdrc** analyses dose-response data across many experimental subsets at
once, applying the same preprocessing, model selection and effect-concentration
estimation to each.

Fitting a single curve is already well served by
[drc](https://CRAN.R-project.org/package=drc). **toxdrc** instead focuses on 
the application of `drc` to analyzing datasets containing several curves that
all need to be processed independantly, but identically.


## Installation
 
```r
# install.packages("pak")
pak::pak("jsalole/toxdrc") # for GitHub version
install.packages("toxdrc") # for CRAN version
```


``` r
library(toxdrc)
```

## Getting started

**toxdrc** has a preset arguments that can be used to set advanced arguments.
It is also possible to tailor the function to specific experiments. The presets 
supply a sensible configuration for a kind of study, to limit the number of
arguments to be entered.

The `cellglow` dataset has a response in arbitrary units (fluorescence) that
requires blank correction and normalization to a solvent control, which is 
what the `"normalized"` preset is for.


``` r
results <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  preset = "normalized",
  quiet = TRUE,
  output = toxdrc_output(condense = TRUE)
)

head(results[, c("best_model_name", "Effect Measure", "Estimate")])
#>                     best_model_name Effect Measure Estimate
#> 83167.aB.A.Spiked              LL.2           EC50 41.65928
#> 83256.aB.A.Spiked              LL.2           EC50 40.37425
#> 83344.aB.A.Spiked              LL.3           EC50 38.78646
#> 83475.aB.A.Spiked              LL.2           EC50 32.03180
#> 83476.aB.A.Spiked              LL.2           EC50 45.89727
#> 83167.CFDA.A.Spiked            LL.3           EC50 67.99410
```

`IDcols` is what makes this work: the dataset is split on those columns, each
subset is carried through the pipeline independently, and the results are
recombined. Nothing about the column naming is fixed, so any long-format
dataset fits.

Leaving `condense = FALSE` returns the full working of each subset instead, which includes
the intermediate datasets, quality-control summaries, the fitted model object,
and the point estimates. 

## What the pipeline does

Each stage is optional and configurable, and each is also an exported function
you can use on its own:

| Stage | Function | Purpose |
|---|---|---|
| Outlier removal | `removeoutliers()` | Iterative Grubbs' test within each group |
| Variability check | `flagCV()` | Flag groups whose CV exceeds a threshold |
| Solvent check | `pctl()` | Compare a solvent control against a true control |
| Blank correction | `blankcorrect()` | Subtract a measured blank |
| Normalization | `normalizeresponse()` | Express the response relative to a control |
| Averaging | `averageresponse()` | Collapse replicates within a concentration |
| Effect screening | `checktoxicity()` | Decide whether a curve is worth fitting |
| Model fitting | `modelcomp()` | Fit candidate models and select between them |
| Estimation | `getECx()` | Effect concentrations with confidence intervals |

## Continuous and quantal endpoints

Continuous responses — fluorescence, growth, biomass — are the default.

Binary endpoints such as mortality are supported by declaring the endpoint and
supplying the number of organisms per group. Models are then fitted as binomial
data weighted by group size, so a response of 0.1 from 1 of 10 organisms is not
treated as equally certain as the same value from 10 of 100.


``` r
runtoxdrc(
  dataset = acutetox,
  Conc = Conc,
  Response = Prop,
  N = Total,
  IDcols = "Substance",
  preset = "quantal",
  quiet = TRUE,
  output = toxdrc_output(condense = TRUE)
)[, c("ID", "best_model_name", "Estimate")]
#>                    ID best_model_name Estimate
#> Background Background           LL.3u 10.02813
#> Graded         Graded            LL.2 10.05541
#> Steep           Steep    interpolated 17.88854
```

### Tests with no partial effects

A quantal test where nothing is affected at one concentration and everything is
affected at the next contains no information about the slope, so no model can be
fitted at all. This is common with small groups and widely spaced
concentrations.

Setting `interpolate = TRUE` estimates the EC50 by log-linear interpolation
between the two bracketing concentrations, which is their geometric mean. Those
estimates are marked `best_model_name = "interpolated"` and carry no confidence
interval, since there is no model to derive one from.

The `Steep` substance in `acutetox` is exactly this case, and appears as
`interpolated` in the output above. `interpolateECx()` can also be called
directly on any dataset.

## Configuration

Presets are ordinary lists, so you can see what one sets:


``` r
toxdrc_preset("quantal")
#> <toxdrc preset: quantal>
#> 
#> $endpoint
#>   type           binomial
#>   response.type  proportion
#> 
#> $qc
#>   outlier.test  FALSE
#>   cv.flag       FALSE
#>   cvflag.lvl    30
#>   pctl.test     FALSE
#>   pctl.lvl      10
#>   ref.label     Control
#>   pctl.label    0
#>   avg.resp      TRUE
#> 
#> $normalization
#>   blank.correction  FALSE
#>   blank.label       Blank
#>   normalize.resp    FALSE
#>   relative.label    0
#> 
#> $toxicity
#>   toxic.lvl        0.2
#>   toxic.type       absolute
#>   toxic.direction  above
#>   comp.group       0
#>   target.group     NULL
#> 
#> $modelling
#>   model.list         NULL
#>   model.metric       IC
#>   EDx                0.5
#>   interval           tfls
#>   level              0.95
#>   type               relative
#>   quiet              FALSE
#>   EDargs.supplement  <>
#>   interpolate        TRUE
#>   partial.tol        0.2
#> 
#> $output
#>   condense  FALSE
#>   sections  ID             , effectmeasure  , best_model_name, effect
```

Anything passed explicitly overrides the preset, so it is a starting point
rather than a fixed recipe:


``` r
multi <- runtoxdrc(
  dataset = cellglow,
  Conc = Conc,
  Response = RFU,
  IDcols = c("Test_Number", "Dye", "Replicate", "Type"),
  preset = "normalized",
  quiet = TRUE,
  modelling = toxdrc_modelling(EDx = c(0.1, 0.5, 0.9)),
  output = toxdrc_output(condense = TRUE)
)

head(multi[, c("ID", "Effect Measure", "Estimate")])
#>                                    ID Effect Measure  Estimate
#> 83167.aB.A.Spiked.1 83167.aB.A.Spiked           EC10  16.36186
#> 83167.aB.A.Spiked.2 83167.aB.A.Spiked           EC50  73.24048
#> 83167.aB.A.Spiked.3 83167.aB.A.Spiked           EC90 327.84583
#> 83256.aB.A.Spiked.1 83256.aB.A.Spiked           EC10  20.48914
#> 83256.aB.A.Spiked.2 83256.aB.A.Spiked           EC50  39.38690
#> 83256.aB.A.Spiked.3 83256.aB.A.Spiked           EC90  75.71464
```

Every setting can also be given directly through `toxdrc_qc()`,
`toxdrc_normalization()`, `toxdrc_toxicity()`, `toxdrc_modelling()`,
`toxdrc_endpoint()` and `toxdrc_output()`, without using a preset at all. See
`?config_runtoxdrc` for the full set.

## Example data

| Dataset | Endpoint | Description |
|---|---|---|
| `toxresult` | Continuous | A single 24-well plate, for trying individual functions |
| `cellglow` | Continuous | 1,080 observations across 108 curves, from an RTgill-W1 assay |
| `acutetox` | Quantal | Simulated acute lethality, covering normal, degenerate and control-mortality cases |

## Authors

* **Jack Salole** - [jsalole](https://github.com/jsalole)

## Acknowledgments

* This package builds off of the [drc](https://CRAN.R-project.org/package=drc) package.
* `mselect2()` adapts code suggested by [Nel on Stack Overflow](https://stackoverflow.com/users/7133643/nel), which allows `mselect` to work within a function.
