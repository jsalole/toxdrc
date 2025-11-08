toxresult_trim <- toxresult[toxresult$Conc != "Blank", ]
mean_ref <- mean(toxresult_trim[toxresult_trim$Conc == 0, ]$RFU)
toxresult_trim$normalized_response <- toxresult_trim$RFU / mean_ref

test_that("normalize response normalizes in df", {
  expect_equal(
    normalizeresponse(
      dataset = toxresult[toxresult$Conc != "Blank", ],
      Conc = Conc,
      reference_group = 0,
      Response = RFU
    ),
    toxresult_trim
  )
})
