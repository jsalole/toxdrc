averaged_toxresult <- toxresult %>%
  dplyr::group_by(Conc) %>%
  dplyr::summarise(
    mean_response = mean(RFU, na.rm = TRUE),
    dplyr::across(
      all_of(c("TestID", "Test_Number", "Dye", "Type", "Replicate")),
      ~ first_nonmissing(.),
      .names = "{.col}"
    ),
    .groups = "drop"
  )

averaged_toxresult <- as.data.frame(averaged_toxresult)

test_that("average response", {
  expect_equal(
    averageresponse(
      toxresult,
      Conc = Conc,
      Response = RFU,
      IDcols = c("TestID", "Test_Number", "Dye", "Type", "Replicate")
    ),
    averaged_toxresult
  )
})


# Hand-computed fixture ---------------------------------------------------
#
# The fixture above rebuilds the function's own grouping and summarising to
# form the expectation. These values are worked out independently.
#
#   Conc 1: 10, 20      mean 15
#   Conc 2: 30, 50, 70  mean 50

avg_df <- data.frame(
  Conc  = c(1, 1, 2, 2, 2),
  RFU   = c(10, 20, 30, 50, 70),
  Plate = c("P1", "P1", "P1", "P1", "P1"),
  Note  = c("", "keep", NA, "", "later"),
  stringsAsFactors = FALSE
)

test_that("responses are averaged within each group", {
  out <- averageresponse(avg_df, Conc = Conc, Response = RFU, quiet = TRUE)
  expect_equal(out$mean_response, c(15, 50))
})

test_that("one row is returned per level of Conc", {
  out <- averageresponse(avg_df, Conc = Conc, Response = RFU, quiet = TRUE)
  expect_equal(nrow(out), 2L)
  expect_equal(out$Conc, c(1, 2))
  expect_s3_class(out, "data.frame")
})

test_that("IDcols keep the first non-blank value in each group", {
  # Conc 1 has "" then "keep"; Conc 2 has NA, "" then "later".
  out <- averageresponse(avg_df, Conc = Conc, Response = RFU,
                         IDcols = c("Plate", "Note"), quiet = TRUE)
  expect_equal(out$Plate, c("P1", "P1"))
  expect_equal(out$Note, c("keep", "later"))
})

test_that("columns not named in IDcols are dropped", {
  out <- averageresponse(avg_df, Conc = Conc, Response = RFU,
                         IDcols = "Plate", quiet = TRUE)
  expect_false("Note" %in% names(out))
  expect_true("Plate" %in% names(out))
})

test_that("missing responses are ignored rather than propagating NA", {
  avg_na <- avg_df
  avg_na$RFU[1] <- NA
  out <- averageresponse(avg_na, Conc = Conc, Response = RFU, quiet = TRUE)
  expect_equal(out$mean_response, c(20, 50))
})

test_that("a single observation per group averages to itself", {
  one_each <- data.frame(Conc = c(1, 2), RFU = c(5, 9))
  out <- averageresponse(one_each, Conc = Conc, Response = RFU, quiet = TRUE)
  expect_equal(out$mean_response, c(5, 9))
})


# list_obj parity ---------------------------------------------------------

test_that("the averaged dataset is identical with and without list_obj", {
  bare <- averageresponse(avg_df, Conc = Conc, Response = RFU,
                          IDcols = "Plate", quiet = TRUE)
  wrapped <- averageresponse(avg_df, Conc = Conc, Response = RFU,
                             IDcols = "Plate", quiet = TRUE,
                             list_obj = list(ID = "x"))
  expect_equal(wrapped$dataset, bare)
  expect_equal(wrapped$ID, "x")
})

test_that("the un-averaged dataset is kept alongside the averaged one", {
  wrapped <- averageresponse(avg_df, Conc = Conc, Response = RFU,
                             quiet = TRUE, list_obj = list())
  expect_equal(nrow(wrapped$pre_average_dataset), nrow(avg_df))
  expect_equal(wrapped$pre_average_dataset$RFU, avg_df$RFU)
})
