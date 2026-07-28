# Return shapes must not change depending on whether a step succeeded.
# runtoxdrc() accumulates results into a list, so a step that returns a bare
# data frame or drops a field leaves later stages with the wrong object.

ecx_cols <- c("Effect Measure", "Estimate", "Std. Error", "Lower", "Upper")

flat_data <- data.frame(
  Conc = rep(c(0, 1, 2, 3), each = 3),
  RFU  = rep(100, 12),
  stringsAsFactors = FALSE
)


# getECx ------------------------------------------------------------------

test_that("getECx returns a data frame when no list_obj is supplied", {
  out <- getECx(dataset = flat_data, model = NULL, EDx = 0.5, quiet = TRUE)
  expect_s3_class(out, "data.frame")
  expect_equal(names(out), ecx_cols)
})

test_that("getECx returns the list, not a data frame, when list_obj is given", {
  # Previously the failure path returned a bare data frame regardless of
  # list_obj, so runtoxdrc() silently received the wrong shape.
  out <- getECx(
    dataset  = flat_data,
    model    = NULL,
    EDx      = 0.5,
    quiet    = TRUE,
    list_obj = list(ID = "entry_1")
  )
  expect_type(out, "list")
  expect_false(is.data.frame(out))
  expect_equal(out$ID, "entry_1")
  expect_s3_class(out$effectmeasure, "data.frame")
})

test_that("the failure placeholder has the same columns as a real result", {
  # check.names would otherwise mangle these to Effect.Measure and Std..Error.
  out <- getECx(dataset = flat_data, model = NULL, EDx = 0.5, quiet = TRUE)
  expect_equal(names(out), ecx_cols)
  expect_equal(out$`Effect Measure`, "EC50")
  expect_true(is.na(out$Estimate))
})

test_that("the placeholder has one row per requested effect level", {
  out <- getECx(
    dataset = flat_data,
    model   = NULL,
    EDx     = c(0.2, 0.5, 0.8),
    quiet   = TRUE
  )
  expect_equal(nrow(out), 3L)
  expect_equal(out$`Effect Measure`, c("EC20", "EC50", "EC80"))
})

test_that("getECx rejects a model that is not a drc fit", {
  expect_error(
    getECx(dataset = flat_data, model = "not a model", quiet = TRUE),
    class = "toxdrc_error_bad_model"
  )
})


# modelcomp ---------------------------------------------------------------

test_that("modelcomp keeps its fields when nothing can be fitted", {
  # A flat response cannot be fitted by any dose-response model. The fields
  # must still be present, holding NULL, rather than being dropped from the
  # list entirely.
  out <- suppressWarnings(
    modelcomp(
      flat_data,
      Conc     = Conc,
      Response = RFU,
      list_obj = list(ID = "entry_1"),
      quiet    = TRUE
    )
  )

  expect_true(all(
    c("model_df", "best_model_name", "model") %in% names(out)
  ))
  expect_equal(out$ID, "entry_1")
})

test_that("modelcomp warns rather than failing silently when nothing fits", {
  expect_warning(
    modelcomp(
      flat_data,
      Conc     = Conc,
      Response = RFU,
      list_obj = list(),
      quiet    = TRUE
    )
  )
})
