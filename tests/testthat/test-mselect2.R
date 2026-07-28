mselect2 <- toxdrc:::mselect2

fit_data <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
fit_data$Conc <- as.numeric(fit_data$Conc)

models <- list(
  "LL.4" = LL.4(),
  "LN.4" = LN.4(),
  "W1.4" = W1.4(),
  "W2.4" = W2.4()
)

# drm() is called with a literal formula on purpose. update(), which mselect2
# uses to refit each candidate, re-evaluates the model's stored call, so a fit
# produced through a wrapper that renames the arguments cannot be refitted.
baseline <- drm(RFU ~ Conc, data = fit_data, fct = LL.4())


# Shape -------------------------------------------------------------------

test_that("mselect2 returns a matrix with the expected criteria", {
  out <- mselect2(baseline, models, sorted = "IC")
  expect_true(is.matrix(out))
  expect_true(all(c("logLik", "IC", "Lack of fit") %in% colnames(out)))
})

test_that("include_baseline = TRUE keeps the baseline row, matching drc", {
  out <- mselect2(baseline, models, sorted = "IC", include_baseline = TRUE)
  expect_equal(nrow(out), length(models) + 1L)
})

test_that("include_baseline = FALSE drops the duplicated baseline row", {
  out <- mselect2(baseline, models, sorted = "IC", include_baseline = FALSE)
  expect_equal(nrow(out), length(models))
  expect_false(anyDuplicated(rownames(out)) > 0)
})

test_that("rownames come from the names of the supplied list", {
  out <- mselect2(baseline, models, sorted = "IC", include_baseline = FALSE)
  expect_setequal(rownames(out), names(models))
})

test_that("a single-model list still returns a matrix", {
  out <- mselect2(
    baseline,
    list("LL.4" = LL.4()),
    sorted = "IC",
    include_baseline = FALSE
  )
  expect_true(is.matrix(out))
  expect_equal(nrow(out), 1L)
})


# Refitting ---------------------------------------------------------------

test_that("every candidate is actually refitted, not silently skipped", {
  # A failed update() fills the row with NA. All four defaults fit this data,
  # so an all-NA table means the refit mechanism is broken rather than the
  # models being unsuitable.
  out <- mselect2(baseline, models, sorted = "IC", include_baseline = FALSE)
  expect_false(all(is.na(out[, "IC"])))
  expect_equal(sum(is.na(out[, "IC"])), 0L)
})


# Ordering ----------------------------------------------------------------

test_that("IC is ordered ascending, smallest first", {
  out <- mselect2(baseline, models, sorted = "IC", include_baseline = FALSE)
  scores <- out[, "IC"]
  expect_equal(unname(scores[1]), unname(min(scores, na.rm = TRUE)))
  expect_false(is.unsorted(scores, na.rm = TRUE))
})

test_that("Res var is ordered ascending, smallest first", {
  out <- mselect2(baseline, models, sorted = "Res var", include_baseline = FALSE)
  scores <- out[, "Res var"]
  expect_equal(unname(scores[1]), unname(min(scores, na.rm = TRUE)))
})

test_that("Lack of fit is ordered descending, largest p-value first", {
  # Larger means less evidence against the model, so the best fit sorts first.
  # drc::mselect() sorts this ascending, which selects the worst model.
  out <- mselect2(
    baseline,
    models,
    sorted = "Lack of fit",
    include_baseline = FALSE
  )
  scores <- out[, "Lack of fit"]
  skip_if(all(is.na(scores)), "No lack-of-fit scores available")
  expect_equal(unname(scores[1]), unname(max(scores, na.rm = TRUE)))
})

test_that("sorted = 'no' leaves the order as supplied", {
  out <- mselect2(baseline, models, sorted = "no", include_baseline = FALSE)
  expect_equal(rownames(out), names(models))
})


# Argument checking -------------------------------------------------------

test_that("nested must be logical", {
  expect_error(mselect2(baseline, models, nested = "yes"))
})
