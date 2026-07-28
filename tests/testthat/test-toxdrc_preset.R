resolve_preset <- toxdrc:::resolve_preset

blocks <- c("endpoint", "qc", "normalization", "toxicity", "modelling",
            "output")

quantal_data <- data.frame(
  Conc     = c(0, 1, 3, 10, 30),
  Affected = c(0, 2, 8, 16, 20),
  Total    = rep(20, 5)
)
quantal_data$Prop <- quantal_data$Affected / quantal_data$Total


# Shape -------------------------------------------------------------------

test_that("every preset carries a full set of configuration blocks", {
  for (name in c("continuous", "quantal", "normalized")) {
    preset <- toxdrc_preset(name)
    expect_s3_class(preset, "toxdrc_preset")
    expect_true(all(blocks %in% names(preset)), info = name)
    expect_equal(preset$name, name)
  }
})

test_that("each block is the output of its own config helper", {
  preset <- toxdrc_preset("quantal")
  expect_setequal(names(preset$qc), names(toxdrc_qc()))
  expect_setequal(names(preset$modelling), names(toxdrc_modelling()))
  expect_setequal(names(preset$endpoint), names(toxdrc_endpoint()))
})

test_that("an unknown preset name is rejected", {
  expect_error(toxdrc_preset("binomial"))
  expect_error(toxdrc_preset("Quantal"))
})


# The continuous preset defines the defaults ------------------------------

test_that("the continuous preset matches the bare config defaults exactly", {
  # This is the property that stops the baseline preset drifting away from
  # what runtoxdrc() does with no preset at all.
  preset <- toxdrc_preset("continuous")
  expect_equal(preset$endpoint, toxdrc_endpoint())
  expect_equal(preset$qc, toxdrc_qc())
  expect_equal(preset$normalization, toxdrc_normalization())
  expect_equal(preset$toxicity, toxdrc_toxicity())
  expect_equal(preset$modelling, toxdrc_modelling())
  expect_equal(preset$output, toxdrc_output())
})

test_that("no preset resolves to the continuous preset", {
  expect_equal(resolve_preset(NULL)$name, "continuous")
})


# Preset contents ---------------------------------------------------------

test_that("the quantal preset configures a weighted binomial fit", {
  preset <- toxdrc_preset("quantal")
  expect_equal(preset$endpoint$type, "binomial")
  expect_true(preset$modelling$interpolate)
  expect_equal(preset$modelling$partial.tol, 0.2)
  # Left NULL so it resolves to the binomial default rather than restating it.
  expect_null(preset$modelling$model.list)
})

test_that("the quantal preset disables inapplicable QC", {
  preset <- toxdrc_preset("quantal")
  expect_false(preset$qc$cv.flag)
  expect_false(preset$qc$outlier.test)
  expect_false(preset$normalization$blank.correction)
  expect_false(preset$normalization$normalize.resp)
})

test_that("the normalized preset corrects, normalizes, and bounds the models", {
  preset <- toxdrc_preset("normalized")
  expect_true(preset$normalization$blank.correction)
  expect_true(preset$normalization$normalize.resp)
  expect_equal(names(preset$modelling$model.list), c("LL.2", "LL.3"))
})

test_that("the normalized preset uses an absolute threshold", {
  # Normalization puts the control at 1 by construction, so 0.7 of control is
  # simply 0.7 on the response scale.
  preset <- toxdrc_preset("normalized")
  expect_equal(preset$toxicity$toxic.type, "absolute")
  expect_equal(preset$toxicity$toxic.lvl, 0.7)
  expect_equal(preset$toxicity$toxic.direction, "below")
})

test_that("the continuous preset applies no preprocessing", {
  preset <- toxdrc_preset("continuous")
  expect_false(preset$normalization$blank.correction)
  expect_false(preset$normalization$normalize.resp)
  expect_false(preset$qc$outlier.test)
})


# resolve_preset ----------------------------------------------------------

test_that("a preset can be named by string", {
  expect_equal(resolve_preset("quantal")$name, "quantal")
  expect_equal(resolve_preset(toxdrc_preset("quantal"))$name, "quantal")
})

test_that("a non-preset object is rejected", {
  expect_error(resolve_preset(list(qc = toxdrc_qc())),
               class = "toxdrc_error_bad_preset")
  expect_error(resolve_preset(c("quantal", "continuous")),
               class = "toxdrc_error_bad_preset")
})


# Printing ----------------------------------------------------------------

test_that("printing a preset shows its name and settings", {
  out <- capture.output(print(toxdrc_preset("quantal")))
  expect_true(any(grepl("quantal", out)))
  expect_true(any(grepl("interpolate", out)))
})

test_that("print returns the preset invisibly", {
  preset <- toxdrc_preset("continuous")
  expect_equal(withVisible(print(preset))$visible, FALSE)
})


# Use in the pipeline -----------------------------------------------------

test_that("no preset behaves exactly as the continuous preset", {
  bare <- runtoxdrc(
    dataset = toxresult, Conc = Conc, Response = RFU, quiet = TRUE,
    qc = toxdrc_qc(cv.flag = FALSE),
    toxicity = toxdrc_toxicity(comp.group = 0)
  )
  via_preset <- runtoxdrc(
    dataset = toxresult, Conc = Conc, Response = RFU, quiet = TRUE,
    preset = "continuous",
    qc = toxdrc_qc(cv.flag = FALSE),
    toxicity = toxdrc_toxicity(comp.group = 0)
  )
  expect_equal(
    via_preset[[1]]$effectmeasure,
    bare[[1]]$effectmeasure
  )
})

test_that("the quantal preset runs end to end", {
  result <- runtoxdrc(
    dataset  = quantal_data,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    quiet    = TRUE,
    preset   = "quantal"
  )
  expect_type(result, "list")
  expect_s3_class(result[[1]]$effectmeasure, "data.frame")
})

test_that("the quantal preset interpolates when there are no partial effects", {
  no_partials <- data.frame(
    Conc  = c(0, 10, 30, 100),
    Prop  = c(0, 0, 1, 1),
    Total = rep(20, 4)
  )
  result <- runtoxdrc(
    dataset  = no_partials,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    quiet    = TRUE,
    preset   = "quantal"
  )
  expect_equal(result[[1]]$best_model_name, "interpolated")
  expect_equal(result[[1]]$effectmeasure$Estimate, sqrt(10 * 30))
})

test_that("the normalized preset runs end to end on cellglow", {
  result <- runtoxdrc(
    dataset  = cellglow,
    Conc     = Conc,
    Response = RFU,
    IDcols   = c("Test_Number", "Dye", "Replicate", "Type"),
    quiet    = TRUE,
    preset   = "normalized"
  )
  expect_type(result, "list")
  expect_gt(length(result), 0)
})


# Overrides ---------------------------------------------------------------

test_that("an explicit block overrides the preset", {
  result <- runtoxdrc(
    dataset  = quantal_data,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    quiet    = TRUE,
    preset   = "quantal",
    output   = toxdrc_output(condense = TRUE)
  )
  expect_s3_class(result, "data.frame")
})

test_that("overriding one block leaves the others from the preset", {
  # Interpolation comes from the preset; only output was replaced.
  no_partials <- data.frame(
    Conc  = c(0, 10, 30, 100),
    Prop  = c(0, 0, 1, 1),
    Total = rep(20, 4)
  )
  result <- runtoxdrc(
    dataset  = no_partials,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    quiet    = TRUE,
    preset   = "quantal",
    output   = toxdrc_output(condense = TRUE)
  )
  expect_true("interpolated" %in% result$best_model_name)
})

test_that("a preset does not smuggle in an endpoint the data cannot support", {
  # The quantal preset requires N, and saying so is more useful than failing
  # somewhere inside the fit.
  expect_error(
    runtoxdrc(
      dataset  = quantal_data,
      Conc     = Conc,
      Response = Prop,
      quiet    = TRUE,
      preset   = "quantal"
    ),
    class = "toxdrc_error_missing_counts"
  )
})


# Effect level semantics --------------------------------------------------

test_that("the quantal preset states its effect level type explicitly", {
  # Stated rather than inherited, so that changing the default in
  # toxdrc_modelling() cannot silently alter what the preset's LC50 means.
  expect_equal(toxdrc_preset("quantal")$modelling$type, "relative")
})

test_that("relative and absolute agree without control mortality", {
  # LL.2 fixes both limits at 0 and 1, so the Abbott correction is a no-op.
  clean <- data.frame(
    Conc  = c(0, 1, 3.2, 10, 32, 100),
    Prop  = c(0, 0.10, 0.25, 0.50, 0.75, 0.90),
    Total = rep(20, 6)
  )

  args <- list(
    dataset = clean, Conc = quote(Conc), Response = quote(Prop),
    N = quote(Total), preset = "quantal", quiet = TRUE
  )

  rel <- do.call(runtoxdrc, c(args, list(
    modelling = toxdrc_modelling(type = "relative", interpolate = TRUE)
  )))
  abs <- do.call(runtoxdrc, c(args, list(
    modelling = toxdrc_modelling(type = "absolute", interpolate = TRUE)
  )))

  expect_equal(
    rel[[1]]$effectmeasure$Estimate,
    abs[[1]]$effectmeasure$Estimate,
    tolerance = 1e-4
  )
})
