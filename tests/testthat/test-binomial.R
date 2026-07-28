# Quantal endpoint support.
#
# Fixture: a clean concentration-response in affected fraction, 20 organisms
# per group, spanning none affected to all affected.

quantal <- data.frame(
  Conc     = c(0, 1, 3, 10, 30),
  Affected = c(0, 2, 8, 16, 20),
  Total    = rep(20, 5),
  Rep      = rep("A", 5),
  stringsAsFactors = FALSE
)
quantal$Prop <- quantal$Affected / quantal$Total

fit_quantal <- quantal[quantal$Conc > 0, ]


# toxdrc_endpoint ---------------------------------------------------------

test_that("the endpoint defaults to a continuous response", {
  cfg <- toxdrc_endpoint()
  expect_equal(cfg$type, "continuous")
  expect_equal(cfg$response.type, "proportion")
})

test_that("endpoint arguments are matched, not taken on trust", {
  expect_equal(toxdrc_endpoint(type = "binomial")$type, "binomial")
  expect_error(toxdrc_endpoint(type = "quantal"))
  expect_error(toxdrc_endpoint(response.type = "percent"))
})


# Fitting -----------------------------------------------------------------

test_that("a binomial fit returns a drc model", {
  result <- modelcomp(
    fit_quantal,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    type     = "binomial",
    list_obj = list(),
    quiet    = TRUE
  )
  expect_s3_class(result$model, "drc")
})

test_that("the binomial default compares LL.2 against LL.3u", {
  result <- modelcomp(
    fit_quantal,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    type     = "binomial",
    list_obj = list(),
    quiet    = TRUE
  )
  expect_setequal(rownames(result$model_df), c("LL.2", "LL.3u"))
  expect_true(result$best_model_name %in% c("LL.2", "LL.3u"))
})

test_that("candidates are scored rather than silently failing to refit", {
  # update() re-evaluates the stored call, which now carries weights = N.
  # An all-NA table means the weights column could not be resolved.
  result <- modelcomp(
    fit_quantal,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    type     = "binomial",
    list_obj = list(),
    quiet    = TRUE
  )
  expect_false(all(is.na(result$model_df[, "IC"])))
})

test_that("group size changes the fit, not just the point estimate", {
  # The whole reason for binomial support: identical proportions backed by
  # different numbers of organisms must not be treated as equally certain.
  small <- fit_quantal
  large <- fit_quantal
  large$Total <- large$Total * 10

  fit_small <- modelcomp(small, Conc = Conc, Response = Prop, N = Total,
                         type = "binomial", quiet = TRUE)
  fit_large <- modelcomp(large, Conc = Conc, Response = Prop, N = Total,
                         type = "binomial", quiet = TRUE)

  se_small <- summary(fit_small)$coefficients[, "Std. Error"]
  se_large <- summary(fit_large)$coefficients[, "Std. Error"]

  expect_true(all(se_large < se_small))
})


# Required inputs ---------------------------------------------------------

test_that("N is required for a binomial fit", {
  expect_error(
    modelcomp(fit_quantal, Conc = Conc, Response = Prop,
              type = "binomial", quiet = TRUE),
    class = "toxdrc_error_missing_counts"
  )
})

test_that("a response outside 0 to 1 is rejected", {
  pct <- fit_quantal
  pct$Prop <- pct$Prop * 100

  err <- expect_error(
    modelcomp(pct, Conc = Conc, Response = Prop, N = Total,
              type = "binomial", quiet = TRUE),
    class = "toxdrc_error_bad_proportion"
  )
  # Percentages are the likely mistake, so the message should say so.
  expect_match(conditionMessage(err), "percentage")
})

test_that("group sizes must be positive whole numbers", {
  zero <- fit_quantal
  zero$Total[1] <- 0
  expect_error(
    modelcomp(zero, Conc = Conc, Response = Prop, N = Total,
              type = "binomial", quiet = TRUE),
    class = "toxdrc_error_bad_counts"
  )

  frac <- fit_quantal
  frac$Total[1] <- 20.5
  expect_error(
    modelcomp(frac, Conc = Conc, Response = Prop, N = Total,
              type = "binomial", quiet = TRUE),
    class = "toxdrc_error_bad_counts"
  )
})


# Metric availability -----------------------------------------------------

test_that("Res var is refused for binomial data", {
  # A binomial fit has no residual variance column, so this previously died
  # with a subscript error from inside mselect2().
  expect_error(
    modelcomp(fit_quantal, Conc = Conc, Response = Prop, N = Total,
              type = "binomial", metric = "Res var", quiet = TRUE),
    class = "toxdrc_error_metric_not_available"
  )
})

test_that("IC and Lack of fit remain available", {
  for (m in c("IC", "Lack of fit")) {
    expect_no_error(
      modelcomp(fit_quantal, Conc = Conc, Response = Prop, N = Total,
                type = "binomial", metric = m, quiet = TRUE)
    )
  }
})


# Pooled averaging --------------------------------------------------------

test_that("quantal replicates are pooled by group size, not averaged", {
  # Replicates at one concentration: 1 of 10 and 15 of 30.
  # Pooled   = (1 + 15) / 40 = 0.4
  # Averaged = (0.1 + 0.5) / 2 = 0.3
  reps <- data.frame(
    Conc  = c(1, 1),
    Prop  = c(0.1, 0.5),
    Total = c(10, 30)
  )

  out <- averageresponse(reps, Conc = Conc, Response = Prop, N = Total,
                         type = "binomial", quiet = TRUE)

  expect_equal(out$mean_response, 0.4)
  expect_equal(out$N, 40)
})

test_that("continuous averaging is unchanged by the new arguments", {
  reps <- data.frame(Conc = c(1, 1), Prop = c(0.1, 0.5), Total = c(10, 30))
  out <- averageresponse(reps, Conc = Conc, Response = Prop, quiet = TRUE)
  expect_equal(out$mean_response, 0.3)
  expect_false("N" %in% names(out))
})

test_that("averageresponse requires N for pooling", {
  reps <- data.frame(Conc = c(1, 1), Prop = c(0.1, 0.5), Total = c(10, 30))
  expect_error(
    averageresponse(reps, Conc = Conc, Response = Prop, type = "binomial",
                    quiet = TRUE),
    class = "toxdrc_error_missing_counts"
  )
})


# Pipeline ----------------------------------------------------------------

# Overridable settings are formals with defaults rather than hard-coded
# alongside `...`, so passing one in a test replaces it instead of supplying
# the same argument twice.
run_quantal <- function(
  qc            = toxdrc_qc(cv.flag = FALSE),
  normalization = toxdrc_normalization(),
  toxicity      = toxdrc_toxicity(comp.group = 0, toxic.direction = "above",
                                  toxic.type = "absolute", toxic.lvl = 0.1),
  ...
) {
  runtoxdrc(
    dataset       = quantal,
    Conc          = Conc,
    Response      = Prop,
    N             = Total,
    quiet         = TRUE,
    endpoint      = toxdrc_endpoint(type = "binomial"),
    qc            = qc,
    normalization = normalization,
    toxicity      = toxicity,
    ...
  )
}

test_that("the pipeline runs end to end on quantal data", {
  result <- run_quantal()
  expect_type(result, "list")
  expect_equal(length(result), 1L)
})

test_that("a count response gives the same answer as a proportion", {
  by_prop <- runtoxdrc(
    dataset  = quantal, Conc = Conc, Response = Prop, N = Total,
    quiet    = TRUE,
    endpoint = toxdrc_endpoint(type = "binomial"),
    qc       = toxdrc_qc(cv.flag = FALSE),
    toxicity = toxdrc_toxicity(comp.group = 0, toxic.direction = "above",
                               toxic.type = "absolute", toxic.lvl = 0.1)
  )
  by_count <- runtoxdrc(
    dataset  = quantal, Conc = Conc, Response = Affected, N = Total,
    quiet    = TRUE,
    endpoint = toxdrc_endpoint(type = "binomial", response.type = "count"),
    qc       = toxdrc_qc(cv.flag = FALSE),
    toxicity = toxdrc_toxicity(comp.group = 0, toxic.direction = "above",
                               toxic.type = "absolute", toxic.lvl = 0.1)
  )

  expect_equal(
    by_count[[1]]$effectmeasure$Estimate,
    by_prop[[1]]$effectmeasure$Estimate
  )
})

test_that("N is required by the pipeline for a quantal endpoint", {
  expect_error(
    runtoxdrc(
      dataset  = quantal, Conc = Conc, Response = Prop, quiet = TRUE,
      endpoint = toxdrc_endpoint(type = "binomial")
    ),
    class = "toxdrc_error_missing_counts"
  )
})


# Guardrails --------------------------------------------------------------

test_that("continuous-only preprocessing is refused for quantal data", {
  expect_error(
    run_quantal(
      normalization = toxdrc_normalization(blank.correction = TRUE)
    ),
    class = "toxdrc_error_step_not_applicable"
  )
  expect_error(
    run_quantal(
      normalization = toxdrc_normalization(normalize.resp = TRUE)
    ),
    class = "toxdrc_error_step_not_applicable"
  )
  expect_error(
    run_quantal(qc = toxdrc_qc(outlier.test = TRUE, cv.flag = FALSE)),
    class = "toxdrc_error_step_not_applicable"
  )
})

test_that("the refusal names the step and suggests an alternative", {
  err <- expect_error(
    run_quantal(normalization = toxdrc_normalization(normalize.resp = TRUE))
  )
  expect_equal(err$step, "normalize.resp")
  expect_match(conditionMessage(err), "Abbott")
})

test_that("those steps are still allowed for continuous data", {
  expect_no_error(
    runtoxdrc(
      dataset       = toxresult,
      Conc          = Conc,
      Response      = RFU,
      quiet         = TRUE,
      qc            = toxdrc_qc(cv.flag = FALSE),
      normalization = toxdrc_normalization(blank.correction = TRUE),
      toxicity      = toxdrc_toxicity(comp.group = 0)
    )
  )
})


# Interpolation fallback --------------------------------------------------

# No partial responses: nothing affected at 10, everything at 30.
no_partials <- data.frame(
  Conc  = c(0, 10, 30, 100),
  Prop  = c(0, 0, 1, 1),
  Total = rep(20, 4)
)

run_no_partials <- function(modelling = toxdrc_modelling(interpolate = TRUE),
                            ...) {
  runtoxdrc(
    dataset   = no_partials,
    Conc      = Conc,
    Response  = Prop,
    N         = Total,
    quiet     = TRUE,
    endpoint  = toxdrc_endpoint(type = "binomial"),
    qc        = toxdrc_qc(cv.flag = FALSE),
    toxicity  = toxdrc_toxicity(comp.group = 0, toxic.direction = "above",
                                toxic.type = "absolute", toxic.lvl = 0.1),
    modelling = modelling,
    ...
  )
}

test_that("interpolation supplies an estimate where no model could be fitted", {
  result <- run_no_partials()
  entry  <- result[[1]]
  expect_equal(entry$effectmeasure$Estimate, sqrt(10 * 30))
})

test_that("interpolated entries are marked in best_model_name", {
  entry <- run_no_partials()[[1]]
  expect_equal(entry$best_model_name, "interpolated")
  expect_null(entry$model)
  expect_true("model" %in% names(entry))
})

test_that("interpolation is off by default", {
  # Without it the degenerate case yields no usable estimate rather than
  # silently switching estimator.
  entry <- suppressWarnings(run_no_partials(modelling = toxdrc_modelling()))
  expect_false(identical(entry[[1]]$best_model_name, "interpolated"))
})

test_that("provenance reaches the condensed output", {
  result <- run_no_partials(output = toxdrc_output(condense = TRUE))
  expect_true("best_model_name" %in% names(result))
  expect_true("interpolated" %in% result$best_model_name)
})

test_that("interpolation does not fire when partial responses exist", {
  graded <- data.frame(
    Conc  = c(0, 1, 10, 100),
    Prop  = c(0, 0.25, 0.75, 1),
    Total = rep(20, 4)
  )
  result <- runtoxdrc(
    dataset   = graded,
    Conc      = Conc,
    Response  = Prop,
    N         = Total,
    quiet     = TRUE,
    endpoint  = toxdrc_endpoint(type = "binomial"),
    qc        = toxdrc_qc(cv.flag = FALSE),
    toxicity  = toxdrc_toxicity(comp.group = 0, toxic.direction = "above",
                                toxic.type = "absolute", toxic.lvl = 0.1),
    modelling = toxdrc_modelling(interpolate = TRUE)
  )
  entry <- result[[1]]
  expect_false(identical(entry$best_model_name, "interpolated"))
  expect_s3_class(entry$model, "drc")
})

test_that("interpolation settings are validated", {
  expect_error(
    toxdrc_modelling(interpolate = "yes"),
    class = "toxdrc_error_bad_flag"
  )
  expect_error(
    toxdrc_modelling(partial.tol = 0.9),
    class = "toxdrc_error_out_of_range"
  )
})

test_that("interpolation is ignored for a continuous endpoint", {
  # The switch exists on toxdrc_modelling(), which is shared, so it must be a
  # no-op rather than an error when the endpoint is continuous.
  expect_no_error(
    runtoxdrc(
      dataset   = toxresult,
      Conc      = Conc,
      Response  = RFU,
      quiet     = TRUE,
      qc        = toxdrc_qc(cv.flag = FALSE),
      toxicity  = toxdrc_toxicity(comp.group = 0),
      modelling = toxdrc_modelling(interpolate = TRUE)
    )
  )
})
