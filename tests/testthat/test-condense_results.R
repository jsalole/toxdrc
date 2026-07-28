condense_results <- toxdrc:::condense_results

fields <- c("ID", "effectmeasure", "best_model_name", "effect")

ecx <- function(...) {
  data.frame(
    "Effect Measure" = c(...),
    "Estimate" = seq_along(c(...)) * 10,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

with_estimates <- list(
  ID              = "entry_a",
  effect          = TRUE,
  best_model_name = "LL.4",
  effectmeasure   = ecx("EC20", "EC50")
)

without_estimates <- list(
  ID     = "entry_b",
  effect = FALSE
)


# Row expansion -----------------------------------------------------------

test_that("one row is produced per effectmeasure row", {
  out <- condense_results(list(a = with_estimates), fields)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 2L)
})

test_that("effectmeasure is expanded into its own columns", {
  out <- condense_results(list(a = with_estimates), fields)
  expect_true(all(c("Effect Measure", "Estimate") %in% names(out)))
  expect_false("effectmeasure" %in% names(out))
  expect_equal(out$`Effect Measure`, c("EC20", "EC50"))
  expect_equal(out$Estimate, c(10, 20))
})

test_that("scalar fields are repeated across the expanded rows", {
  out <- condense_results(list(a = with_estimates), fields)
  expect_equal(out$ID, c("entry_a", "entry_a"))
  expect_equal(out$best_model_name, c("LL.4", "LL.4"))
  expect_equal(out$effect, c(TRUE, TRUE))
})

test_that("an entry without estimates gives a single row", {
  out <- condense_results(list(b = without_estimates), fields)
  expect_equal(nrow(out), 1L)
  expect_equal(out$ID, "entry_b")
  expect_false(out$effect)
})

test_that("fields absent from an entry become NA", {
  out <- condense_results(list(b = without_estimates), fields)
  expect_true(is.na(out$best_model_name))
})


# Mixed entries -----------------------------------------------------------

test_that("entries with and without estimates combine into one frame", {
  # Entries with estimates expand effectmeasure into its own columns, while
  # entries without previously emitted a literal "effectmeasure" column, so
  # rbind() received mismatched frames and errored.
  out <- condense_results(
    list(a = with_estimates, b = without_estimates),
    fields
  )

  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 3L)
  expect_equal(out$ID, c("entry_a", "entry_a", "entry_b"))
})

test_that("the entry without estimates gets NA point-estimate columns", {
  out <- condense_results(
    list(a = with_estimates, b = without_estimates),
    fields
  )
  expect_true(is.na(out$`Effect Measure`[3]))
  expect_true(is.na(out$Estimate[3]))
})

test_that("column order does not depend on which entry comes first", {
  ab <- condense_results(list(a = with_estimates, b = without_estimates), fields)
  ba <- condense_results(list(b = without_estimates, a = with_estimates), fields)
  expect_setequal(names(ab), names(ba))
  expect_equal(nrow(ba), 3L)
})


# Field flattening --------------------------------------------------------

test_that("multi-value fields are collapsed to a comma-separated string", {
  entry <- list(ID = "x", groups = c("Blank", "Control"), effect = FALSE)
  out   <- condense_results(list(x = entry), c("ID", "groups", "effect"))
  expect_equal(out$groups, "Blank,Control")
})

test_that("NULL and zero-length fields become NA", {
  entry <- list(ID = "x", best_model_name = NULL, effect = character(0))
  out   <- condense_results(list(x = entry), fields)
  expect_true(is.na(out$best_model_name))
  expect_true(is.na(out$effect))
})


# Degenerate input --------------------------------------------------------

test_that("no entries produce estimates, so effectmeasure stays one NA column", {
  out <- condense_results(list(b = without_estimates), fields)
  expect_true("effectmeasure" %in% names(out))
  expect_true(is.na(out$effectmeasure))
})

test_that("an empty results list gives an empty frame rather than an error", {
  out <- condense_results(list(), fields)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 0L)
})
