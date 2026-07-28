toxresult_trim <- toxresult[toxresult$Conc != "Blank", ]
mean_ref <- mean(toxresult_trim[toxresult_trim$Conc == 0, ]$RFU)
toxresult_trim$normalized_response <- toxresult_trim$RFU / mean_ref

test_that("normalize response normalizes in df", {
  expect_equal(
    normalizeresponse(
      dataset = toxresult[toxresult$Conc != "Blank", ],
      Conc = Conc,
      reference_group = 0,
      Response = RFU,
      quiet = TRUE
    ),
    toxresult_trim
  )
})


# Hand-computed fixture ---------------------------------------------------
#
#   Reference (Conc 0) responses: 10 and 30
#   mean = 20
#   sd   = sqrt(((10-20)^2 + (30-20)^2) / 1) = sqrt(200) = 14.142136
#   cv   = 70.710678
#   normalized = RFU / 20 = 0.5, 1.5, 0.25, 0.75

nr <- data.frame(
  Conc = c("0", "0", "1", "1"),
  RFU  = c(10, 30, 5, 15),
  stringsAsFactors = FALSE
)

test_that("responses are divided by the reference mean", {
  out <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                           Response = RFU, quiet = TRUE)
  expect_equal(out$normalized_response, c(0.5, 1.5, 0.25, 0.75))
})

test_that("the reference group normalizes to a mean of 1", {
  out <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                           Response = RFU, quiet = TRUE)
  expect_equal(mean(out$normalized_response[out$Conc == "0"]), 1)
})

test_that("the summary reports the reference mean, sd, and CV", {
  out <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                           Response = RFU, quiet = TRUE, list_obj = list())
  summary_df <- out$normalize_response_summary
  expect_equal(summary_df$ref_mean, 20)
  expect_equal(summary_df$ref_sd, sqrt(200))
  expect_equal(summary_df$ref_cv, sqrt(200) / 20 * 100)
})

test_that("a numeric label matches a character column and vice versa", {
  by_chr <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                              Response = RFU, quiet = TRUE)
  by_num <- normalizeresponse(nr, Conc = Conc, reference_group = 0,
                              Response = RFU, quiet = TRUE)
  expect_equal(by_num$normalized_response, by_chr$normalized_response)
})

test_that("the original response column is preserved", {
  out <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                           Response = RFU, quiet = TRUE)
  expect_equal(out$RFU, c(10, 30, 5, 15))
  expect_equal(nrow(out), 4L)
})


# list_obj parity ---------------------------------------------------------

test_that("the dataset is identical with and without list_obj", {
  bare <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                            Response = RFU, quiet = TRUE)
  wrapped <- normalizeresponse(nr, Conc = Conc, reference_group = "0",
                               Response = RFU, quiet = TRUE,
                               list_obj = list(ID = "x"))
  expect_equal(wrapped$dataset, bare)
  expect_equal(wrapped$ID, "x")
})
