# Shared test data --------------------------------------------------------

NT_toxresult <- toxresult
NT_toxresult$RFU <- c(10001:10024)

# Simple synthetic dataset for target_group and direction tests
target_df <- data.frame(
  dose  = c("ref", "ref", "low", "low", "high", "high"),
  resp  = c(100, 100, 90, 85, 40, 35)
)
# threshold (relative, effect = 0.7): 100 * 0.7 = 70
# "low" values (90, 85) are both above 70  -> no effect
# "high" values (40, 35) are both below 70 -> effect detected

above_df <- data.frame(
  dose = c("ref", "ref", "treated", "treated"),
  resp = c(100, 100, 130, 140)
)
# absolute threshold = 120, direction = "above"
# treated values (130, 140) exceed 120 -> effect detected

below_abs_df <- data.frame(
  dose = c("ref", "ref", "treated", "treated"),
  resp = c(100, 100, 110, 115)
)
# absolute threshold = 120, direction = "above"
# treated values (110, 115) do not exceed 120 -> no effect


# Basic TRUE / FALSE returns ----------------------------------------------

test_that("returns FALSE when response does not drop below relative threshold", {
  expect_equal(
    checktoxicity(
      NT_toxresult,
      Conc     = Conc,
      Response = RFU,
      effect   = 0.7,
      type     = "relative",
      reference_group = "Control",
      quiet    = TRUE
    ),
    FALSE
  )
})

test_that("returns FALSE when response does not drop below absolute threshold", {
  expect_equal(
    checktoxicity(
      NT_toxresult,
      Conc     = Conc,
      Response = RFU,
      effect   = 10000,
      type     = "absolute",
      quiet    = TRUE
    ),
    FALSE
  )
})

test_that("returns TRUE when response drops below absolute threshold", {
  expect_equal(
    checktoxicity(
      toxresult,
      Conc     = Conc,
      Response = RFU,
      effect   = 8000,
      type     = "absolute",
      quiet    = TRUE
    ),
    TRUE
  )
})

test_that("returns TRUE when response drops below relative threshold", {
  expect_equal(
    checktoxicity(
      toxresult,
      Conc     = Conc,
      Response = RFU,
      effect   = 0.5,
      type     = "relative",
      quiet    = TRUE
    ),
    TRUE
  )
})


# direction = "above" -----------------------------------------------------

test_that("returns TRUE when response exceeds absolute threshold from above", {
  expect_equal(
    checktoxicity(
      above_df,
      Conc      = dose,
      Response  = resp,
      effect    = 120,
      type      = "absolute",
      direction = "above",
      quiet     = TRUE
    ),
    TRUE
  )
})

test_that("returns FALSE when no response exceeds absolute threshold from above", {
  expect_equal(
    checktoxicity(
      below_abs_df,
      Conc      = dose,
      Response  = resp,
      effect    = 120,
      type      = "absolute",
      direction = "above",
      quiet     = TRUE
    ),
    FALSE
  )
})


# target_group filtering --------------------------------------------------

test_that("target_group restricts comparison to specified levels only", {
  # Only looking at "low" doses -- all above threshold of 70 -> FALSE
  expect_equal(
    checktoxicity(
      target_df,
      Conc            = dose,
      Response        = resp,
      effect          = 0.7,
      type            = "relative",
      reference_group = "ref",
      target_group    = "low",
      quiet           = TRUE
    ),
    FALSE
  )
})

test_that("without target_group, toxic high doses drive result to TRUE", {
  # All doses included -- "high" values are below threshold -> TRUE
  expect_equal(
    checktoxicity(
      target_df,
      Conc            = dose,
      Response        = resp,
      effect          = 0.7,
      type            = "relative",
      reference_group = "ref",
      quiet           = TRUE
    ),
    TRUE
  )
})


# list_obj integration ----------------------------------------------------

test_that("stores result in list_obj$effect when list_obj is provided", {
  obj <- list(id = "test_entry")
  result <- checktoxicity(
    toxresult,
    Conc     = Conc,
    Response = RFU,
    effect   = 0.5,
    type     = "relative",
    list_obj = obj,
    quiet    = TRUE
  )
  expect_type(result, "list")
  expect_true("effect" %in% names(result))
  expect_equal(result$id, "test_entry")  # other fields preserved
  expect_type(result$effect, "logical")
})
