metadata_toxresult <- toxresult %>%
  dplyr::select("TestID", "Test_Number", "Dye", "Type", "Replicate") %>%
  dplyr::slice(1)

test_that("extracts 1st row values", {
  expect_equal(
    getmetadata(
      dataset = toxresult,
      IDcols = c("TestID", "Test_Number", "Dye", "Type", "Replicate")
    ),
    metadata_toxresult
  )
})
