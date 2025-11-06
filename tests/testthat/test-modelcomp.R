toxresult_trim <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
mod1 <- drm(toxresult_trim$Conc ~ toxresult_trim$RFU, fct = W1.4())
mod_df <- mselect(
  mod1,
  fctList = list(LL.2(), LL.4(), LN.2(), W1.4()),
  sorted = "IC"
)
toxresult_trim$Conc <- as.numeric(toxresult_trim$Conc)

model_name <- "LL.4"

test_that("model comp returns a drc object", {
  result <- modelcomp(
    toxresult_trim,
    Conc = Conc,
    Response = RFU,
    model_list = NULL,
    metric = "IC"
  )
  expect_s3_class(result, "drc")
})
