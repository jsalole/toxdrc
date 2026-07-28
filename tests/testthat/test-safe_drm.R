safe_drm <- toxdrc:::safe_drm

fit_data <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
fit_data$Conc <- as.numeric(fit_data$Conc)

flat_data <- data.frame(
  Conc = rep(c(1, 2, 3, 4), each = 3),
  RFU  = rep(100, 12)
)


test_that("safe_drm returns a fitted model when the fit succeeds", {
  out <- safe_drm(RFU ~ Conc, data = fit_data, fct = LL.4())
  expect_s3_class(out, "drc")
})

test_that("safe_drm returns NULL instead of erroring when the fit fails", {
  out <- safe_drm(RFU ~ Conc, data = flat_data, fct = LL.4())
  expect_null(out)
})

test_that("safe_drm returns NULL for a nonsense formula rather than erroring", {
  expect_no_error(
    out <- safe_drm(RFU ~ NotAColumn, data = fit_data, fct = LL.4())
  )
  expect_null(out)
})

test_that("models from safe_drm cannot be refitted with update()", {
  # Documented limitation, not a wish. safe_drm() passes its own parameter
  # names through to drm(), so the stored call reads
  # `drm(formula, data = data, fct = fct)`. update() re-evaluates that call in
  # its own frame, where `formula` does not exist, and every refit fails.
  #
  # This matters because mselect2() refits candidates with update(). Anything
  # that fits a baseline through safe_drm() and then compares models will get
  # a table of NAs. modelcomp() calls drm() directly for that reason.
  out <- safe_drm(RFU ~ Conc, data = fit_data, fct = LL.4())
  refit <- try(
    update(out, fct = W1.4(), data = out$origData),
    silent = TRUE
  )
  expect_s3_class(refit, "try-error")
})

test_that("a model fitted by a direct drm() call can be refitted", {
  # The contrast to the test above: a literal call is what update() needs.
  direct <- drm(RFU ~ Conc, data = fit_data, fct = LL.4())
  refit <- try(
    update(direct, fct = W1.4(), data = direct$origData),
    silent = TRUE
  )
  expect_false(inherits(refit, "try-error"))
  expect_s3_class(refit, "drc")
})
