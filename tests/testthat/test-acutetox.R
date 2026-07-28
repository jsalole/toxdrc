# The acutetox dataset is constructed to exercise specific paths through the
# quantal pipeline. These tests pin the properties the documentation promises,
# so that regenerating the data cannot quietly invalidate the examples or the
# tests that rely on it.

skip_if_not(exists("acutetox"), "acutetox not built yet; run data-raw/acutetox.R")

graded     <- acutetox[acutetox$Substance == "Graded", ]
steep      <- acutetox[acutetox$Substance == "Steep", ]
background <- acutetox[acutetox$Substance == "Background", ]

pooled <- function(df) {
  concs <- sort(unique(df$Conc))
  vapply(
    concs,
    function(c) sum(df$Affected[df$Conc == c]) / sum(df$Total[df$Conc == c]),
    numeric(1)
  )
}


# Structure ---------------------------------------------------------------

test_that("acutetox has the documented shape", {
  expect_s3_class(acutetox, "data.frame")
  expect_equal(nrow(acutetox), 54L)
  expect_setequal(
    names(acutetox),
    c("TestID", "Test_Number", "Substance", "Replicate", "Conc",
      "Affected", "Total", "Prop")
  )
})

test_that("counts are internally consistent", {
  expect_true(all(acutetox$Affected >= 0))
  expect_true(all(acutetox$Affected <= acutetox$Total))
  expect_equal(acutetox$Prop, acutetox$Affected / acutetox$Total)
  expect_true(all(acutetox$Total == 20))
})

test_that("three substances with three replicates each are present", {
  expect_setequal(
    unique(acutetox$Substance),
    c("Graded", "Steep", "Background")
  )
  expect_setequal(unique(acutetox$Replicate), c("A", "B", "C"))
  expect_equal(length(unique(acutetox$TestID)), 9L)
})

test_that("a control is present for every substance", {
  expect_true(all(
    vapply(
      split(acutetox, acutetox$Substance),
      function(df) 0 %in% df$Conc,
      logical(1)
    )
  ))
})


# Documented response patterns --------------------------------------------

test_that("Graded spans the response range with no control mortality", {
  expect_equal(pooled(graded), c(0, 0.10, 0.25, 0.50, 0.75, 0.90))
})

test_that("Graded has partial effects, so it does not trigger interpolation", {
  expect_true(
    toxdrc:::has_partial_effect(pooled(graded), control = 0, tol = 0.2)
  )
})

test_that("Steep has no partial responses at all", {
  # Nothing affected at or below 10, everything affected above it.
  expect_equal(pooled(steep), c(0, 0, 0, 0, 1, 1))
  expect_false(
    toxdrc:::has_partial_effect(pooled(steep), control = 0, tol = 0.2)
  )
})

test_that("Background has control mortality and still spans the range", {
  p <- pooled(background)
  expect_equal(p[1], 0.10)
  expect_equal(p, c(0.10, 0.20, 0.35, 0.55, 0.75, 0.90))
  expect_true(toxdrc:::has_partial_effect(p, control = 0.10, tol = 0.2))
})


# Behaviour in the pipeline -----------------------------------------------

run_one <- function(substance, ...) {
  runtoxdrc(
    dataset  = acutetox[acutetox$Substance == substance, ],
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    preset   = "quantal",
    quiet    = TRUE,
    ...
  )
}

test_that("Graded is fitted rather than interpolated", {
  entry <- run_one("Graded")[[1]]
  expect_false(identical(entry$best_model_name, "interpolated"))
  expect_s3_class(entry$model, "drc")
})

test_that("Graded recovers an LC50 near the generating value of 10", {
  entry <- run_one("Graded")[[1]]
  estimate <- entry$effectmeasure$Estimate[1]
  expect_gt(estimate, 5)
  expect_lt(estimate, 20)
})

test_that("Steep is interpolated to the geometric mean of 10 and 32", {
  entry <- run_one("Steep")[[1]]
  expect_equal(entry$best_model_name, "interpolated")
  expect_equal(entry$effectmeasure$Estimate[1], sqrt(10 * 32))
})

test_that("counts and proportions give the same answer", {
  by_prop <- run_one("Graded")[[1]]$effectmeasure$Estimate

  by_count <- runtoxdrc(
    dataset  = acutetox[acutetox$Substance == "Graded", ],
    Conc     = Conc,
    Response = Affected,
    N        = Total,
    preset   = "quantal",
    endpoint = toxdrc_endpoint(type = "binomial", response.type = "count"),
    quiet    = TRUE
  )[[1]]$effectmeasure$Estimate

  expect_equal(by_count, by_prop)
})

test_that("the whole dataset runs split by substance", {
  result <- runtoxdrc(
    dataset  = acutetox,
    Conc     = Conc,
    Response = Prop,
    N        = Total,
    IDcols   = c("Test_Number", "Substance"),
    preset   = "quantal",
    quiet    = TRUE
  )
  expect_equal(length(result), 3L)
})

test_that("replicates are pooled by group size, not averaged", {
  # Three replicates of 20 pool to a single group of 60.
  entry <- run_one("Graded")[[1]]
  expect_true(all(entry$dataset$N == 60))
})
