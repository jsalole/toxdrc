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


# Hand-computed fixture ---------------------------------------------------
#
#   Control mean = 100, positive mean = 80
#   percent difference = |100 - 80| / 100 * 100 = 20

pctl_df <- data.frame(
  Conc = c("Control", "Control", "0", "0"),
  RFU  = c(90, 110, 70, 90),
  stringsAsFactors = FALSE
)

run_pctl <- function(max_diff, ...) {
  pctl(pctl_df, Conc = Conc, reference_group = "Control",
       positive_group = "0", Response = RFU, max_diff = max_diff,
       quiet = TRUE, ...)
}

test_that("the reported percent difference matches the hand calculation", {
  out <- run_pctl(10, list_obj = list())
  expect_equal(out$pctlresults$ref_ctl_mean, 100)
  expect_equal(out$pctlresults$p_ctl_mean, 80)
  expect_equal(out$pctlresults$percent_difference, 20)
})

test_that("a difference above max_diff flags every row", {
  out <- run_pctl(10)
  expect_equal(unique(out$Validity), "*")
})

test_that("a difference below max_diff leaves Validity blank", {
  out <- run_pctl(25)
  expect_equal(unique(out$Validity), "")
})

test_that("max_diff is a strict threshold, so an exact match is not flagged", {
  out <- run_pctl(20)
  expect_equal(unique(out$Validity), "")
})

test_that("row count and ordering are unchanged", {
  out <- run_pctl(10)
  expect_equal(nrow(out), nrow(pctl_df))
  expect_equal(out$RFU, pctl_df$RFU)
})

test_that("the direction of the difference does not matter", {
  # Positive control higher than the reference is just as much a difference.
  higher <- pctl_df
  higher$RFU <- c(90, 110, 130, 110)
  out <- pctl(higher, Conc = Conc, reference_group = "Control",
              positive_group = "0", Response = RFU, max_diff = 10,
              quiet = TRUE, list_obj = list())
  expect_equal(out$pctlresults$percent_difference, 20)
  expect_equal(unique(out$dataset$Validity), "*")
})

test_that("the dataset is identical with and without list_obj", {
  bare <- run_pctl(10)
  wrapped <- run_pctl(10, list_obj = list(ID = "x"))
  expect_equal(wrapped$dataset, bare)
  expect_equal(wrapped$ID, "x")
})
