toxresult_trim <- toxresult[!toxresult$Conc %in% c("Blank", "Control"), ]
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
