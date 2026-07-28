toxresult_trim <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
toxresult_trim$Conc <- as.numeric(toxresult_trim$Conc)


# Return type -------------------------------------------------------------

test_that("modelcomp returns a drc object", {
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    quiet    = TRUE
  )
  expect_s3_class(result, "drc")
})


# list_obj integration ----------------------------------------------------

test_that("modelcomp populates list_obj with model, model name, and model_df", {
  obj    <- list(id = "test_entry")
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    list_obj = obj,
    quiet    = TRUE
  )
  expect_type(result, "list")
  expect_true(all(c("model", "best_model_name", "model_df") %in% names(result)))
  expect_equal(result$id, "test_entry")     # pre-existing fields preserved
})

test_that("model stored in list_obj is a drc object", {
  obj    <- list(id = "test_entry")
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    list_obj = obj,
    quiet    = TRUE
  )
  expect_s3_class(result$model, "drc")
})

test_that("the default model_list is LL.4 alone", {
  obj    <- list(id = "test_entry")
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    list_obj = obj,
    quiet    = TRUE
  )
  expect_equal(result$best_model_name, "LL.4")
})

test_that("toxdrc_modelling leaves the default unresolved", {
  # NULL means "decide once the endpoint type is known", so that modelcomp()
  # and toxdrc_modelling() cannot disagree about what the default is.
  expect_null(toxdrc_modelling()$model.list)
})

test_that("the resolved default depends on the endpoint type", {
  expect_equal(names(toxdrc:::default_model_list("continuous")), "LL.4")
  expect_equal(
    names(toxdrc:::default_model_list("binomial")),
    c("LL.2", "LL.3u")
  )
})

test_that("modelcomp uses the continuous default when none is given", {
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    list_obj = list(),
    quiet    = TRUE
  )
  expect_equal(rownames(result$model_df), "LL.4")
})

test_that("model_df is a matrix with expected goodness-of-fit columns", {
  obj    <- list(id = "test_entry")
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    list_obj = obj,
    quiet    = TRUE
  )
  expect_true(is.matrix(result$model_df))
  expect_true("IC" %in% colnames(result$model_df))
  expect_true("logLik" %in% colnames(result$model_df))
})


test_that("model_df has one row per supplied model, with no duplicates", {
  four <- list(
    "LL.4" = LL.4(),
    "LN.4" = LN.4(),
    "W1.4" = W1.4(),
    "W2.4" = W2.4()
  )
  result <- modelcomp(
    toxresult_trim,
    Conc       = Conc,
    Response   = RFU,
    model_list = four,
    list_obj   = list(),
    quiet      = TRUE
  )
  # mselect2() previously returned the baseline model twice: once as its own
  # row and once as a member of the comparison list.
  expect_equal(nrow(result$model_df), 4L)
  expect_false(anyDuplicated(rownames(result$model_df)) > 0)
  expect_setequal(rownames(result$model_df), names(four))
})

test_that("every supplied model is scored, none silently skipped", {
  # An all-NA table means update() failed to refit rather than the models
  # being unsuitable; all four fit this data.
  result <- modelcomp(
    toxresult_trim,
    Conc       = Conc,
    Response   = RFU,
    model_list = list(
      "LL.4" = LL.4(),
      "LN.4" = LN.4(),
      "W1.4" = W1.4(),
      "W2.4" = W2.4()
    ),
    list_obj   = list(),
    quiet      = TRUE
  )
  expect_equal(sum(is.na(result$model_df[, "IC"])), 0L)
})

test_that("best_model_name is the top row of model_df", {
  result <- modelcomp(
    toxresult_trim,
    Conc     = Conc,
    Response = RFU,
    list_obj = list(),
    quiet    = TRUE
  )
  expect_equal(result$best_model_name, rownames(result$model_df)[1])
})


# Metric sort direction ---------------------------------------------------
#
# These need more than one candidate. With the single-model default the
# comparison table has one row and every ordering assertion holds trivially.

metric_models <- list(
  "LL.4" = LL.4(),
  "LN.4" = LN.4(),
  "W1.4" = W1.4(),
  "W2.4" = W2.4()
)

compare_with <- function(metric) {
  modelcomp(
    toxresult_trim,
    Conc       = Conc,
    Response   = RFU,
    model_list = metric_models,
    metric     = metric,
    list_obj   = list(),
    quiet      = TRUE
  )
}

test_that("IC and Res var select the smallest value", {
  for (m in c("IC", "Res var")) {
    result <- compare_with(m)
    scores <- result$model_df[, m]
    expect_gt(length(scores), 1)
    expect_equal(
      unname(scores[1]),
      unname(min(scores, na.rm = TRUE)),
      info = m
    )
  }
})

# "Lack of fit" is a p-value: a larger value is a better fit. The previous
# ascending sort therefore selected the worst-fitting model.
test_that("Lack of fit selects the largest p-value", {
  result <- compare_with("Lack of fit")
  scores <- result$model_df[, "Lack of fit"]
  skip_if(all(is.na(scores)), "No lack-of-fit scores available")
  expect_gt(length(scores), 1)
  expect_equal(
    unname(scores[1]),
    unname(max(scores, na.rm = TRUE))
  )
})


# Custom model list -------------------------------------------------------

test_that("custom model_list restricts model selection to supplied models", {
  obj    <- list(id = "test_entry")
  result <- modelcomp(
    toxresult_trim,
    Conc       = Conc,
    Response   = RFU,
    model_list = list("LN.4" = LN.4()),
    list_obj   = obj,
    quiet      = TRUE
  )
  expect_equal(result$best_model_name, "LN.4")
})

test_that("a single-model list still returns a matrix, not a vector", {
  result <- modelcomp(
    toxresult_trim,
    Conc       = Conc,
    Response   = RFU,
    model_list = list("LN.4" = LN.4()),
    list_obj   = list(),
    quiet      = TRUE
  )
  expect_true(is.matrix(result$model_df))
  expect_equal(nrow(result$model_df), 1L)
})

test_that("a model outside the defaults is selected and fitted", {
  result <- modelcomp(
    toxresult_trim,
    Conc       = Conc,
    Response   = RFU,
    model_list = list("LL.3" = drc::LL.3()),
    list_obj   = list(),
    quiet      = TRUE
  )
  expect_equal(result$best_model_name, "LL.3")
  expect_s3_class(result$model, "drc")
  expect_equal(rownames(result$model_df), "LL.3")
})

test_that("a namespaced model call is accepted", {
  # drc derives $name from match.call(), so drc::LL.3() records "::" and the
  # shorthand is unrecoverable; the entry label is trusted instead.
  expect_no_error(
    modelcomp(
      toxresult_trim,
      Conc       = Conc,
      Response   = RFU,
      model_list = list("LL.3" = drc::LL.3()),
      quiet      = TRUE
    )
  )
})


# Argument validation -----------------------------------------------------

test_that("modelcomp rejects a malformed model_list", {
  expect_error(
    modelcomp(toxresult_trim, Conc, RFU, model_list = "LL.4", quiet = TRUE),
    "must be a list"
  )
  expect_error(
    modelcomp(toxresult_trim, Conc, RFU, model_list = list(), quiet = TRUE),
    "is empty"
  )
  expect_error(
    modelcomp(
      toxresult_trim, Conc, RFU,
      model_list = list(LL.4()), quiet = TRUE
    ),
    "must be named"
  )
  expect_error(
    modelcomp(
      toxresult_trim, Conc, RFU,
      model_list = list("W1.4" = LL.4()), quiet = TRUE
    ),
    "Name mismatch"
  )
})

test_that("modelcomp rejects a non-list list_obj", {
  expect_error(
    modelcomp(
      toxresult_trim, Conc, RFU,
      list_obj = "not a list", quiet = TRUE
    ),
    "must be a list"
  )
})


# Console noise from drc -------------------------------------------------

test_that("quiet = TRUE suppresses drc's printed fit failures", {
  # drc reports a failed optimisation via try(), which cats to stderr rather
  # than signalling a condition, so this cannot be tested with
  # expect_silent()/suppressMessages(); the stderr text has to be captured.
  flat <- data.frame(
    Conc = rep(c(1, 2, 3, 4), each = 3),
    RFU  = rep(100, 12)
  )

  noisy <- capture.output(
    suppressWarnings(
      modelcomp(flat, Conc = Conc, Response = RFU, quiet = TRUE)
    ),
    type = "message"
  )
  expect_length(noisy, 0)
})

test_that("the try output option is restored afterwards", {
  before <- getOption("try.outFile")
  suppressWarnings(
    modelcomp(
      toxresult_trim,
      Conc     = Conc,
      Response = RFU,
      quiet    = TRUE
    )
  )
  expect_equal(getOption("try.outFile"), before)
})

test_that("the option is restored even when modelcomp errors", {
  before <- getOption("try.outFile")
  try(
    modelcomp(toxresult_trim, Conc = Conc, Response = nope, quiet = TRUE),
    silent = TRUE
  )
  expect_equal(getOption("try.outFile"), before)
})
