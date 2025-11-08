toxresult_neg <- toxresult
toxresult_neg$Validity <- ""

toxresult_pos <- toxresult
toxresult_pos[toxresult_pos$Conc == "0", ]$RFU <- c(10, 20)
toxresult_pos_check <- toxresult_pos
toxresult_pos$Validity <- "*"

test_that("pctl does not flag if no solvent effect", {
  (expect_equal(
    pctl(
      dataset = toxresult,
      Conc,
      reference_group = "Control",
      positive_group = 0,
      RFU,
      max_diff = 10
    ),
    toxresult_neg
  ))
})

test_that("pctl flags solvent effect", {
  (expect_equal(
    pctl(
      dataset = toxresult_pos_check,
      Conc,
      reference_group = "Control",
      positive_group = 0,
      RFU,
      max_diff = 10
    ),
    toxresult_pos
  ))
})
