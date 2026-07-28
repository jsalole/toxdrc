blk_mean <- mean(toxresult[toxresult$Conc == "Blank", ]$RFU)

blkcorr_toxresult <- toxresult

blkcorr_toxresult$c_response = blkcorr_toxresult$RFU - blk_mean

test_that("blank correction", {
  expect_equal(
    blankcorrect(
      toxresult,
      Conc = Conc,
      blank_group = "Blank",
      Response = RFU,
      quiet = TRUE
    ),
    blkcorr_toxresult
  )
})


# Hand-computed fixture ---------------------------------------------------
#
# The test above derives its expectation from the same arithmetic the function
# performs, so it would pass even if that arithmetic were wrong. This fixture
# uses values worked out independently.
#
#   Blank responses: 2 and 4
#   mean = 3
#   sd   = sqrt(((2-3)^2 + (4-3)^2) / 1) = sqrt(2) = 1.4142136
#   cv   = sd / mean * 100 = 47.140452
#   c_response = RFU - 3 = -1, 1, 7, 17

bc <- data.frame(
  Conc = c("Blank", "Blank", "1", "1"),
  RFU  = c(2, 4, 10, 20),
  stringsAsFactors = FALSE
)

test_that("c_response is the response minus the blank mean", {
  out <- blankcorrect(bc, Conc = Conc, blank_group = "Blank", Response = RFU,
                      quiet = TRUE)
  expect_equal(out$c_response, c(-1, 1, 7, 17))
})

test_that("the original response column is left untouched", {
  out <- blankcorrect(bc, Conc = Conc, blank_group = "Blank", Response = RFU,
                      quiet = TRUE)
  expect_equal(out$RFU, c(2, 4, 10, 20))
  expect_equal(nrow(out), nrow(bc))
})

test_that("blank_stats reports the mean, sd, and CV of the blank group", {
  out <- blankcorrect(bc, Conc = Conc, blank_group = "Blank", Response = RFU,
                      quiet = TRUE, list_obj = list())
  expect_equal(out$blank_stats$blank_mean, 3)
  expect_equal(out$blank_stats$blank_sd, sqrt(2))
  expect_equal(out$blank_stats$blank_cv, sqrt(2) / 3 * 100)
})

test_that("blank rows are corrected too, not excluded", {
  out <- blankcorrect(bc, Conc = Conc, blank_group = "Blank", Response = RFU,
                      quiet = TRUE)
  expect_equal(out$c_response[1:2], c(-1, 1))
})

test_that("missing responses in the blank group are ignored", {
  bc_na <- rbind(bc, data.frame(Conc = "Blank", RFU = NA_real_))
  out <- blankcorrect(bc_na, Conc = Conc, blank_group = "Blank",
                      Response = RFU, quiet = TRUE, list_obj = list())
  expect_equal(out$blank_stats$blank_mean, 3)
})

test_that("a zero blank mean gives NA CV rather than a division blow-up", {
  bc_zero <- data.frame(
    Conc = c("Blank", "Blank", "1"),
    RFU  = c(-2, 2, 10),
    stringsAsFactors = FALSE
  )
  out <- blankcorrect(bc_zero, Conc = Conc, blank_group = "Blank",
                      Response = RFU, quiet = TRUE, list_obj = list())
  expect_equal(out$blank_stats$blank_mean, 0)
  expect_true(is.na(out$blank_stats$blank_cv))
})


# list_obj parity ---------------------------------------------------------

test_that("the dataset is identical with and without list_obj", {
  bare <- blankcorrect(bc, Conc = Conc, blank_group = "Blank", Response = RFU,
                       quiet = TRUE)
  wrapped <- blankcorrect(bc, Conc = Conc, blank_group = "Blank",
                          Response = RFU, quiet = TRUE,
                          list_obj = list(ID = "x"))
  expect_equal(wrapped$dataset, bare)
  expect_equal(wrapped$ID, "x")
})
