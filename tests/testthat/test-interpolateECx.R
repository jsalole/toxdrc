has_partial_effect <- toxdrc:::has_partial_effect
interpolate_one   <- toxdrc:::interpolate_one

ecx_cols <- c("Effect Measure", "Estimate", "Std. Error", "Lower", "Upper")

# No partial responses: nothing affected at 10, everything at 30.
degenerate <- data.frame(
  Conc  = c(0, 10, 30, 100),
  Prop  = c(0, 0, 1, 1),
  Total = rep(20, 4)
)

# A graded response, so interpolation has real intermediate points to use.
graded <- data.frame(
  Conc  = c(0, 1, 10, 100),
  Prop  = c(0, 0.25, 0.75, 1),
  Total = rep(20, 4)
)


# The geometric mean identity ---------------------------------------------

test_that("EC50 between a no-effect and a full-effect concentration is their geometric mean", {
  # Between A = 10 and B = 30, EC50 = sqrt(10 * 30) = 17.3205.
  out <- interpolateECx(degenerate, Conc = Conc, Response = Prop,
                        quiet = TRUE)
  expect_equal(out$Estimate, sqrt(10 * 30))
})

test_that("the identity holds for other bracketing pairs", {
  d <- data.frame(Conc = c(2, 8), Prop = c(0, 1))
  out <- interpolateECx(d, Conc = Conc, Response = Prop, quiet = TRUE)
  expect_equal(out$Estimate, sqrt(2 * 8))
  expect_equal(out$Estimate, 4)
})

test_that("interpolation is geometric, not arithmetic", {
  # The arithmetic midpoint of 10 and 30 is 20, which would be wrong.
  out <- interpolateECx(degenerate, Conc = Conc, Response = Prop,
                        quiet = TRUE)
  expect_false(isTRUE(all.equal(out$Estimate, 20)))
})


# Output shape ------------------------------------------------------------

test_that("the output matches getECx's columns", {
  out <- interpolateECx(degenerate, Conc = Conc, Response = Prop,
                        quiet = TRUE)
  expect_s3_class(out, "data.frame")
  expect_equal(names(out), ecx_cols)
  expect_equal(out$`Effect Measure`, "EC50")
})

test_that("no confidence interval is reported, because there is none", {
  out <- interpolateECx(degenerate, Conc = Conc, Response = Prop,
                        quiet = TRUE)
  expect_true(is.na(out$`Std. Error`))
  expect_true(is.na(out$Lower))
  expect_true(is.na(out$Upper))
})

test_that("list_obj integration returns the list, not a data frame", {
  out <- interpolateECx(degenerate, Conc = Conc, Response = Prop,
                        quiet = TRUE, list_obj = list(ID = "x"))
  expect_type(out, "list")
  expect_false(is.data.frame(out))
  expect_equal(out$ID, "x")
  expect_s3_class(out$effectmeasure, "data.frame")
})


# Refusing to extrapolate -------------------------------------------------

test_that("a target above every observed response gives NA", {
  partial_only <- data.frame(Conc = c(1, 10), Prop = c(0, 0.4))
  out <- interpolateECx(partial_only, Conc = Conc, Response = Prop,
                        quiet = TRUE)
  expect_true(is.na(out$Estimate))
})

test_that("a target below every observed response gives NA", {
  # Absolute, because a relative target is anchored at the control response
  # and so can never fall below the observed range.
  high_only <- data.frame(Conc = c(1, 10), Prop = c(0.8, 1))
  out <- interpolateECx(high_only, Conc = Conc, Response = Prop,
                        EDx = 0.5, type = "absolute", quiet = TRUE)
  expect_true(is.na(out$Estimate))
})

test_that("a relative target is anchored at the control response", {
  # Control affected 80 percent, so the relative EC50 targets
  # 0.8 + 0.5 * 0.2 = 0.9, which is inside the observed range.
  high_only <- data.frame(Conc = c(1, 10), Prop = c(0.8, 1))
  out <- interpolateECx(high_only, Conc = Conc, Response = Prop,
                        EDx = 0.5, type = "relative", quiet = TRUE)
  expect_false(is.na(out$Estimate))
  expect_gt(out$Estimate, 1)
  expect_lt(out$Estimate, 10)
})

test_that("an exactly observed target needs no interpolation", {
  flat <- data.frame(Conc = c(1, 10, 100), Prop = c(0.5, 0.5, 0.5))
  out <- interpolateECx(flat, Conc = Conc, Response = Prop,
                        type = "absolute", quiet = TRUE)
  # 0.5 is observed exactly, so the lowest such concentration is returned
  # rather than dividing by a zero difference between bracketing responses.
  expect_equal(out$Estimate, 1)
})

test_that("a flat response cannot reach a relative target", {
  flat <- data.frame(Conc = c(1, 10, 100), Prop = c(0.5, 0.5, 0.5))
  out <- interpolateECx(flat, Conc = Conc, Response = Prop,
                        type = "relative", quiet = TRUE)
  # Relative targets 0.5 + 0.5 * 0.5 = 0.75, which nothing reaches.
  expect_true(is.na(out$Estimate))
})


# Warning on unsupported effect levels ------------------------------------

test_that("non-50 levels warn when no partial responses exist", {
  expect_warning(
    interpolateECx(degenerate, Conc = Conc, Response = Prop, EDx = 0.1,
                   quiet = TRUE),
    "partial effect"
  )
})

test_that("EC50 alone does not warn", {
  expect_no_warning(
    interpolateECx(degenerate, Conc = Conc, Response = Prop, EDx = 0.5,
                   quiet = TRUE)
  )
})

test_that("non-50 levels do not warn when partial responses exist", {
  expect_no_warning(
    interpolateECx(graded, Conc = Conc, Response = Prop, EDx = 0.25,
                   quiet = TRUE)
  )
})

test_that("a warned estimate is still returned", {
  out <- suppressWarnings(
    interpolateECx(degenerate, Conc = Conc, Response = Prop, EDx = 0.1,
                   quiet = TRUE)
  )
  # EC10 lands just above the bracketing no-effect concentration of 10,
  # which is the point of the warning.
  expect_equal(out$Estimate, 10 * (30 / 10)^0.1)
  expect_lt(out$Estimate, 12)
})

test_that("several levels can be requested at once", {
  out <- suppressWarnings(
    interpolateECx(degenerate, Conc = Conc, Response = Prop,
                   EDx = c(0.1, 0.5, 0.9), quiet = TRUE)
  )
  expect_equal(nrow(out), 3L)
  expect_equal(out$`Effect Measure`, c("EC10", "EC50", "EC90"))
  expect_true(!is.unsorted(out$Estimate))
})


# Input handling ----------------------------------------------------------

test_that("zero and negative concentrations are excluded from the log scale", {
  # The control at 0 sets the background response but cannot be interpolated.
  out <- interpolateECx(degenerate, Conc = Conc, Response = Prop,
                        quiet = TRUE)
  expect_equal(out$Estimate, sqrt(300))
})

test_that("fewer than two positive concentrations is an error", {
  too_few <- data.frame(Conc = c(0, 10), Prop = c(0, 1))
  expect_error(
    interpolateECx(too_few, Conc = Conc, Response = Prop, quiet = TRUE),
    class = "toxdrc_error_no_interpolation_data"
  )
})

test_that("replicates at a concentration are averaged before interpolating", {
  reps <- data.frame(
    Conc = c(10, 10, 30, 30),
    Prop = c(0, 0, 1, 1)
  )
  out <- interpolateECx(reps, Conc = Conc, Response = Prop, quiet = TRUE)
  expect_equal(out$Estimate, sqrt(300))
})

test_that("a response outside 0 to 1 is rejected", {
  bad <- data.frame(Conc = c(10, 30), Prop = c(0, 100))
  expect_error(
    interpolateECx(bad, Conc = Conc, Response = Prop, quiet = TRUE),
    class = "toxdrc_error_bad_proportion"
  )
})

test_that("relative type targets the background response", {
  # Control affected 20 percent; relative EC50 targets 0.2 + 0.5 * 0.8 = 0.6.
  bg <- data.frame(
    Conc = c(0, 10, 30),
    Prop = c(0.2, 0.2, 1)
  )
  out <- interpolateECx(bg, Conc = Conc, Response = Prop, type = "relative",
                        quiet = TRUE)
  expected <- 10^(log10(10) + (0.6 - 0.2) * (log10(30) - log10(10)) / 0.8)
  expect_equal(out$Estimate, expected)
})


# Helpers -----------------------------------------------------------------

test_that("has_partial_effect applies the tolerance at both ends", {
  expect_false(has_partial_effect(c(0, 1)))
  expect_false(has_partial_effect(c(0, 0.1, 1)))   # too close to control
  expect_false(has_partial_effect(c(0, 0.9, 1)))   # too close to complete
  expect_true(has_partial_effect(c(0, 0.5, 1)))
  expect_true(has_partial_effect(c(0, 0.25, 1)))
})

test_that("has_partial_effect measures against the control response", {
  # A 30 percent response is partial against a control of 0, but not against
  # a control of 20 percent with the default tolerance.
  expect_true(has_partial_effect(c(0, 0.3), control = 0))
  expect_false(has_partial_effect(c(0.2, 0.3), control = 0.2))
})

test_that("has_partial_effect copes with empty and missing input", {
  expect_false(has_partial_effect(numeric(0)))
  expect_false(has_partial_effect(c(NA_real_, NA_real_)))
  expect_true(has_partial_effect(c(NA, 0.5)))
})

test_that("interpolate_one returns NA outside the observed range", {
  x <- log10(c(10, 30))
  y <- c(0, 1)
  expect_true(is.na(interpolate_one(x, y, 1.5)))
  expect_true(is.na(interpolate_one(x, y, -0.5)))
  expect_true(is.na(interpolate_one(x, y, NA_real_)))
})

test_that("interpolate_one uses the first bracketing pair", {
  # A non-monotone response crosses 0.5 more than once; the lowest crossing
  # is the conservative choice.
  x <- log10(c(1, 10, 100, 1000))
  y <- c(0, 1, 0, 1)
  expect_equal(interpolate_one(x, y, 0.5), sqrt(1 * 10))
})
