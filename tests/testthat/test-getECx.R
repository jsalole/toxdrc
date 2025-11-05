toxresult <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
mod1 <- drm(toxresult$Conc ~ toxresult$RFU, fct = LL.4())
mod1_estimates <- ED(
  mod1,
  respLev = 0.5,
  type = "rel",
  interval = "tfls"
)

names(mod1_estimates) <- c("EC50", "Std. Error", "Lower95", "Upper95")
mod1_estimates <- as.data.frame(t(mod1_estimates))


test_that("produces estimates ", {
  expect_equal(
    getECx(
      dataset = toxresult,
      model = mod1,
      EDx = 0.5,
      EDargs = list(
        type = "rel",
        interval = "tfls"
      )
    ),
    mod1_estimates
  )
})
