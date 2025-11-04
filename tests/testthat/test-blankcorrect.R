blk_mean <- mean(toxresult[toxresult$Conc == "Blank", ]$RFU)

blkcorr_toxresult <- toxresult

blkcorr_toxresult$c_response = blkcorr_toxresult$RFU - blk_mean

test_that("blank correction", {
  expect_equal(
    blankcorrect(
      toxresult,
      Conc = Conc,
      blank_group = "Blank",
      Response = RFU
    ),
    blkcorr_toxresult
  )
})
