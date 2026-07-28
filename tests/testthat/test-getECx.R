toxresult_trim <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
toxresult_trim$Conc <- as.numeric(toxresult_trim$Conc)

mod1 <- drm(RFU ~ Conc, data = toxresult_trim, fct = LL.4())


# Output matches drc::ED() directly ---------------------------------------

test_that("getECx output matches drc::ED() directly for EC50", {
  # respLev is 50, not 0.5. toxdrc takes EDx as a proportion, while drc::ED()
  # wants a percentage under the relative type, and getECx() converts between
  # them. Building the reference with respLev = 0.5 made this test agree with
  # the units bug rather than catch it: both sides asked for the EC0.5 and
  # both sides labelled it EC50.
  ref <- as.data.frame(ED(mod1, respLev = 50, type = "relative",
                          interval = "tfls", display = FALSE))
  names(ref) <- c("Estimate", "Std. Error", "Lower", "Upper")
  ref <- cbind(`Effect Measure` = "EC50", ref)
  rownames(ref) <- NULL

  result <- getECx(
    dataset  = toxresult_trim,
    model    = mod1,
    EDx      = 0.5,
    interval = "tfls",
    type     = "relative",
    quiet    = TRUE
  )
  expect_equal(result, ref)
})


# Output structure --------------------------------------------------------

test_that("getECx returns a data frame", {
  result <- getECx(
    dataset = toxresult_trim,
    model   = mod1,
    EDx     = 0.5,
    quiet   = TRUE
  )
  expect_true(is.data.frame(result))
})

test_that("getECx returns expected column names", {
  result <- getECx(
    dataset = toxresult_trim,
    model   = mod1,
    EDx     = 0.5,
    quiet   = TRUE
  )
  expect_equal(
    names(result),
    c("Effect Measure", "Estimate", "Std. Error", "Lower", "Upper")
  )
})

test_that("EC label is formatted correctly", {
  result <- getECx(
    dataset = toxresult_trim,
    model   = mod1,
    EDx     = 0.5,
    quiet   = TRUE
  )
  expect_equal(result$`Effect Measure`, "EC50")
})


# Multiple EDx values -----------------------------------------------------

test_that("multiple EDx values return one row per value", {
  result <- getECx(
    dataset = toxresult_trim,
    model   = mod1,
    EDx     = c(0.2, 0.5, 0.8),
    quiet   = TRUE
  )
  expect_equal(nrow(result), 3)
  expect_equal(result$`Effect Measure`, c("EC20", "EC50", "EC80"))
})


# interval = "none" -------------------------------------------------------

test_that("interval = 'none' yields NA for Lower and Upper columns", {
  result <- getECx(
    dataset  = toxresult_trim,
    model    = mod1,
    EDx      = 0.5,
    interval = "none",
    quiet    = TRUE
  )
  expect_true(is.na(result$Lower))
  expect_true(is.na(result$Upper))
})


# Estimate is finite and positive -----------------------------------------

test_that("EC50 estimate is finite and positive", {
  result <- getECx(
    dataset = toxresult_trim,
    model   = mod1,
    EDx     = 0.5,
    quiet   = TRUE
  )
  expect_true(is.finite(result$Estimate))
  expect_true(result$Estimate > 0)
})


# list_obj integration ----------------------------------------------------

test_that("stores result in list_obj$effectmeasure when list_obj is provided", {
  obj    <- list(id = "test_entry")
  result <- getECx(
    dataset  = toxresult_trim,
    model    = mod1,
    EDx      = 0.5,
    list_obj = obj,
    quiet    = TRUE
  )
  expect_type(result, "list")
  expect_true("effectmeasure" %in% names(result))
  expect_true(is.data.frame(result$effectmeasure))
  expect_equal(result$id, "test_entry")  # pre-existing fields preserved
})


# Effect level units ------------------------------------------------------
#
# EDx is a proportion throughout toxdrc, but drc::ED() takes a percentage
# under type = "relative" and a response value under type = "absolute".
# Passing 0.5 straight through under the relative default asked for the EC0.5
# and labelled the result EC50, roughly a hundredfold error in the estimate.

ecx_fit_data <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
ecx_fit_data$Conc <- as.numeric(ecx_fit_data$Conc)
ecx_model <- modelcomp(ecx_fit_data, Conc = Conc, Response = RFU,
                       quiet = TRUE)

test_that("EDx = 0.5 gives the midpoint of the fitted range", {
  # The EC50 must sit inside the tested concentration range, not orders of
  # magnitude below it.
  out <- getECx(ecx_fit_data, ecx_model, EDx = 0.5, type = "relative",
                quiet = TRUE)
  expect_gt(out$Estimate, min(ecx_fit_data$Conc))
  expect_lt(out$Estimate, max(ecx_fit_data$Conc))
})

test_that("effect levels are ordered by concentration", {
  out <- getECx(ecx_fit_data, ecx_model, EDx = c(0.1, 0.5, 0.9),
                type = "relative", quiet = TRUE)
  expect_equal(nrow(out), 3L)
  expect_false(is.unsorted(out$Estimate, na.rm = TRUE))
})

test_that("the EC label reflects EDx, not the units passed to drc", {
  out <- getECx(ecx_fit_data, ecx_model, EDx = c(0.1, 0.5, 0.9),
                type = "relative", quiet = TRUE)
  expect_equal(out$`Effect Measure`, c("EC10", "EC50", "EC90"))
})

test_that("the label is the same under either type", {
  rel <- getECx(ecx_fit_data, ecx_model, EDx = 0.5, type = "relative",
                quiet = TRUE)
  abs <- getECx(ecx_fit_data, ecx_model, EDx = 0.5, type = "absolute",
                quiet = TRUE)
  expect_equal(rel$`Effect Measure`, "EC50")
  expect_equal(abs$`Effect Measure`, "EC50")
})

test_that("the pipeline default recovers a sensible EC50", {
  # Guards the whole chain, since toxdrc_modelling() defaults to the relative
  # type and it is the pipeline that most users go through.
  result <- runtoxdrc(
    dataset  = ecx_fit_data,
    Conc     = Conc,
    Response = RFU,
    quiet    = TRUE,
    qc       = toxdrc_qc(cv.flag = FALSE),
    toxicity = toxdrc_toxicity(comp.group = min(ecx_fit_data$Conc))
  )
  estimate <- result[[1]]$effectmeasure$Estimate[1]
  expect_gt(estimate, min(ecx_fit_data$Conc))
  expect_lt(estimate, max(ecx_fit_data$Conc))
})
