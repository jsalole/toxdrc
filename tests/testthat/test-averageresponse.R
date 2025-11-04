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
