highCV_toxresult <- toxresult
highCV_toxresult$RFU[15:17] <- c(1000, 5000, 10000)
highCV_toxresult_f <- highCV_toxresult %>%
  dplyr::group_by(Conc) %>%
  mutate(
    meanRFU = mean(RFU),
    sdRFU = sd(RFU),
    CV = sdRFU / meanRFU * 100
  ) %>%
  dplyr::select(-c("meanRFU", "sdRFU")) %>%
  dplyr::ungroup() %>%
  mutate(
    CVflag = ifelse(CV > 30, "*", "")
  ) %>%
  dplyr::select((-c("CV")))
highCV_toxresult_f <- as.data.frame(highCV_toxresult_f)

lowCV_toxresult <- toxresult %>%
  dplyr::group_by(Conc) %>%
  mutate(
    meanRFU = mean(RFU),
    sdRFU = sd(RFU),
    CV = sdRFU / meanRFU * 100
  ) %>%
  dplyr::select(-c("meanRFU", "sdRFU")) %>%
  dplyr::ungroup() %>%
  mutate(
    CVflag = ifelse(CV > 30, "*", "")
  ) %>%
  dplyr::select((-c("CV")))

lowCV_toxresult <- as.data.frame(lowCV_toxresult)

test_that("flags high CV concs", {
  expect_equal(
    flagCV(
      dataset = highCV_toxresult,
      Conc = Conc,
      Response = RFU,
      max_val = 30
    ),
    highCV_toxresult_f
  )
})

test_that("no flag for low CV", {
  expect_equal(
    flagCV(
      dataset = toxresult,
      Conc = Conc,
      Response = RFU,
      max_val = 30
    ),
    lowCV_toxresult
  )
})


# Hand-computed fixture ---------------------------------------------------
#
# The fixtures above rebuild the function's own CV arithmetic to form the
# expectation, so they would pass even if that arithmetic were wrong. These
# values are worked out independently.
#
#   Group 1: 10, 10, 10   mean 10, sd 0,  CV 0
#   Group 2: 10, 20, 30   mean 20, sd 10, CV 50

cv_df <- data.frame(
  Conc = rep(c(1, 2), each = 3),
  RFU  = c(10, 10, 10, 10, 20, 30)
)

test_that("groups above the threshold are flagged and others are not", {
  out <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 30,
                quiet = TRUE)
  expect_equal(out$CVflag, c("", "", "", "*", "*", "*"))
})

test_that("the CV working column is dropped from the returned dataset", {
  out <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 30,
                quiet = TRUE)
  expect_false("CV" %in% names(out))
  expect_true("CVflag" %in% names(out))
})

test_that("the summary carries the computed CV per group", {
  out <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 30,
                quiet = TRUE, list_obj = list())
  expect_equal(out$CVresults$CV, c(0, 50))
  expect_equal(out$CVresults$CVflag, c("", "*"))
  expect_equal(nrow(out$CVresults), 2L)
})

test_that("max_val is a strict threshold, so a CV exactly on it is not flagged", {
  out <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 50,
                quiet = TRUE)
  expect_equal(unique(out$CVflag), "")
})

test_that("raising the threshold above every CV flags nothing", {
  out <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 1000,
                quiet = TRUE)
  expect_equal(unique(out$CVflag), "")
})

test_that("a threshold of zero flags every group with any variation", {
  # Both groups here have CV 50, so a threshold of 0 flags all of them.
  # cv_df cannot be used: its first group has CV exactly 0, and the
  # comparison is strict, so it would not be flagged.
  varying <- data.frame(
    Conc = rep(c(1, 2), each = 3),
    RFU  = c(10, 20, 30, 10, 20, 30)
  )
  out <- flagCV(varying, Conc = Conc, Response = RFU, max_val = 0,
                quiet = TRUE)
  expect_equal(unique(out$CVflag), "*")
})

test_that("a negative threshold is rejected rather than flagging everything", {
  # CV is a percentage, so a threshold below zero is not a meaningful
  # setting.
  expect_error(
    flagCV(cv_df, Conc = Conc, Response = RFU, max_val = -1, quiet = TRUE),
    class = "toxdrc_error_out_of_range"
  )
})

test_that("row count and ordering are unchanged", {
  out <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 30,
                quiet = TRUE)
  expect_equal(nrow(out), nrow(cv_df))
  expect_equal(out$RFU, cv_df$RFU)
})

test_that("the dataset is identical with and without list_obj", {
  bare <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 30,
                 quiet = TRUE)
  wrapped <- flagCV(cv_df, Conc = Conc, Response = RFU, max_val = 30,
                    quiet = TRUE, list_obj = list(ID = "x"))
  expect_equal(wrapped$dataset, bare)
  expect_equal(wrapped$ID, "x")
})
