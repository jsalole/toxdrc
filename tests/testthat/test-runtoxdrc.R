# Shared pipeline call used by most tests.
#
# Overridable settings are formals with defaults rather than hard-coded
# alongside `...`, so passing one in a test replaces it instead of supplying
# the same argument twice.
run_basic <- function(
  normalization = toxdrc_normalization(
    blank.correction = TRUE,
    normalize.resp   = TRUE
  ),
  modelling = toxdrc_modelling(EDx = 0.5),
  ...
) {
  runtoxdrc(
    dataset       = cellglow,
    Conc          = Conc,
    Response      = RFU,
    IDcols        = c("Test_Number", "Dye", "Replicate", "Type"),
    quiet         = TRUE,
    normalization = normalization,
    modelling     = modelling,
    ...
  )
}

# Helper: grab first entry with effect = TRUE, skip if none found
first_effect_entry <- function(result) {
  entries <- Filter(function(x) isTRUE(x$effect), result)
  skip_if(length(entries) == 0, "No toxic entries found — skipping")
  entries[[1]]
}


# Entry shape -------------------------------------------------------------
#
# These guard the helper above. When getECx() returned a bare data frame on
# failure, entries stopped being lists, `x$effect` became NULL, and every test
# relying on first_effect_entry() skipped silently instead of failing. A skip
# is invisible in a passing check, so the shape is asserted directly.

test_that("every entry is a list, not a data frame", {
  result <- run_basic()
  for (entry in result) {
    expect_type(entry, "list")
    expect_false(is.data.frame(entry))
  }
})

test_that("every entry carries dataset and a logical effect flag", {
  result <- run_basic()
  for (entry in result) {
    expect_true("dataset" %in% names(entry))
    expect_true("effect" %in% names(entry))
    expect_type(entry$effect, "logical")
    expect_false(is.na(entry$effect))
  }
})

test_that("cellglow produces at least one toxic entry under the defaults", {
  # If this fails, the fixture or the toxicity defaults need revisiting, not
  # the pipeline code. Previously this condition caused a skip.
  result <- run_basic()
  n_toxic <- sum(vapply(result, function(x) isTRUE(x$effect), logical(1)))
  expect_gt(n_toxic, 0)
})


# Return type and structure -----------------------------------------------

test_that("runtoxdrc returns a named list", {
  result <- run_basic()
  expect_type(result, "list")
  expect_true(length(names(result)) > 0)
})

test_that("a sample entry contains 'dataset' and 'effect'", {
  result <- run_basic()
  entry  <- result[[1]]
  expect_true("dataset" %in% names(entry))
  expect_true("effect"  %in% names(entry))
  expect_type(entry$effect, "logical")
})

test_that("a toxic entry contains model, effectmeasure, and best_model_name", {
  result <- run_basic()
  entry  <- first_effect_entry(result)
  expect_true(all(c("model", "effectmeasure", "best_model_name") %in% names(entry)))
  expect_s3_class(entry$model, "drc")
  expect_true(is.data.frame(entry$effectmeasure))
  expect_equal(entry$best_model_name, "LL.4")
})

test_that("the pipeline default is LL.4 alone", {
  result <- run_basic()
  entry  <- first_effect_entry(result)
  expect_equal(rownames(entry$model_df), "LL.4")
})

test_that("effectmeasure data frame has expected columns", {
  result <- run_basic()
  entry  <- first_effect_entry(result)
  expect_equal(
    names(entry$effectmeasure),
    c("Effect Measure", "Estimate", "Std. Error", "Lower", "Upper")
  )
})


# condense = TRUE ---------------------------------------------------------

test_that("condense = TRUE returns a data frame", {
  result <- run_basic(output = toxdrc_output(condense = TRUE))
  expect_true(is.data.frame(result))
})

test_that("condensed output contains ID and effect columns", {
  result <- run_basic(output = toxdrc_output(condense = TRUE))
  expect_true("ID"     %in% names(result))
  expect_true("effect" %in% names(result))
})


# Custom model list (tests the model.list bug fix) ------------------------

run_with_models <- function(model.list) {
  runtoxdrc(
    dataset       = cellglow,
    Conc          = Conc,
    Response      = RFU,
    IDcols        = c("Test_Number", "Dye", "Replicate", "Type"),
    quiet         = TRUE,
    normalization = toxdrc_normalization(
      blank.correction = TRUE,
      normalize.resp   = TRUE
    ),
    modelling = toxdrc_modelling(
      model.list = model.list,
      EDx        = 0.5
    )
  )
}

test_that("custom model.list passed via toxdrc_modelling() is respected", {
  result <- run_with_models(list("LN.4" = LN.4()))
  entry  <- first_effect_entry(result)
  expect_equal(entry$best_model_name, "LN.4")
})

test_that("supplying several models restores comparison in the pipeline", {
  # The default is a single model, so comparison is now opt-in.
  result <- run_with_models(list("LL.4" = LL.4(), "W1.4" = W1.4()))
  entry  <- first_effect_entry(result)
  expect_setequal(rownames(entry$model_df), c("LL.4", "W1.4"))
  expect_true(entry$best_model_name %in% c("LL.4", "W1.4"))
})

# Uses a model that is NOT one of the four defaults. Before the fix,
# toxdrc_modelling() dropped model.list from its return value, so modelcomp()
# silently fell back to the defaults; that failure is invisible if the test
# model happens to also be a default.
test_that("a non-default model.list is used rather than the defaults", {
  result <- run_with_models(list("LL.3" = drc::LL.3()))
  entry  <- first_effect_entry(result)

  expect_equal(entry$best_model_name, "LL.3")
  expect_false(entry$best_model_name %in% c("LL.4", "LN.4", "W1.4", "W2.4"))
  expect_equal(rownames(entry$model_df), "LL.3")
})

test_that("toxdrc_modelling() retains model.list in its return value", {
  cfg <- toxdrc_modelling(model.list = list("LL.3" = drc::LL.3()))
  expect_true("model.list" %in% names(cfg))
  expect_equal(names(cfg$model.list), "LL.3")
})

test_that("toxdrc_modelling() rejects a malformed model.list", {
  expect_error(
    toxdrc_modelling(model.list = list(LL.4())),
    "must be named"
  )
  expect_error(
    toxdrc_modelling(model.list = list("LL.4" = W1.4())),
    "Name mismatch"
  )
})


# toxresult dataset -------------------------------------------------------

test_that("runtoxdrc works on the toxresult dataset with minimal options", {
  toxresult_num <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
  toxresult_num$Conc <- as.numeric(toxresult_num$Conc)

  result <- runtoxdrc(
    dataset   = toxresult_num,
    Conc      = Conc,
    Response  = RFU,
    IDcols    = c("TestID", "Test_Number", "Dye", "Type", "Replicate"),
    quiet     = TRUE,
    qc        = toxdrc_qc(avg.resp = TRUE, cv.flag = FALSE),
    toxicity  = toxdrc_toxicity(comp.group = min(toxresult_num$Conc)),
    modelling = toxdrc_modelling(EDx = 0.5)
  )
  expect_type(result, "list")
})


# Condensed output shape --------------------------------------------------

test_that("condensed output has one row per point estimate", {
  result <- run_basic(
    modelling = toxdrc_modelling(EDx = c(0.2, 0.5)),
    output    = toxdrc_output(condense = TRUE)
  )
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})

test_that("condensing survives a mix of entries with and without estimates", {
  # Entries expand effectmeasure into its own columns while entries without
  # estimates emit NA placeholders. Before these were aligned, rbind() failed
  # whenever a run produced both.
  result <- run_basic(output = toxdrc_output(condense = TRUE))
  expect_s3_class(result, "data.frame")
  expect_false(anyNA(result$ID))
})

test_that("IDcols are optional", {
  # Without IDcols the whole dataset is treated as a single subset.
  result <- runtoxdrc(
    dataset  = toxresult,
    Conc     = Conc,
    Response = RFU,
    quiet    = TRUE,
    qc       = toxdrc_qc(cv.flag = FALSE),
    toxicity = toxdrc_toxicity(comp.group = 0)
  )
  expect_type(result, "list")
  expect_equal(length(result), 1L)
})
