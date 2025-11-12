toxresult <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
mod1 <- drm(toxresult$Conc ~ toxresult$RFU, fct = LL.4())

test_that("getECx produces correct ECx estimates", {
  # Reference output using ED() directly
  mod1_estimates <- ED(
    mod1,
    respLev = 0.5,
    type = "rel",
    interval = "tfls"
  )

  # Convert to tidy data frame
  mod1_estimates <- as.data.frame((mod1_estimates))
  names(mod1_estimates) <- c("Estimate", "Std. Error", "Lower", "Upper")

  # Add effect label like getECx() does
  mod1_estimates <- cbind(
    `Effect Measure` = "EC50",
    mod1_estimates
  )

  rownames(mod1_estimates) <- NULL

  # Test that getECx reproduces this output
  result <- getECx(
    dataset = toxresult,
    model = mod1,
    EDx = 0.5,
    interval = "tfls",
    type = "rel",
    quiet = TRUE
  )

  expect_equal(
    result,
    mod1_estimates
  )
})
