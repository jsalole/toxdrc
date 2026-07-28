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


# Row selection -------------------------------------------------------------

meta_df <- data.frame(
  Plate = c("P1", "P1", "P1"),
  Dye   = c("aB", "aB", "aB"),
  Conc  = c(0, 1, 2),
  RFU   = c(10, 20, 30),
  stringsAsFactors = FALSE
)

test_that("metadata is a single row regardless of input size", {
  out <- getmetadata(meta_df, IDcols = c("Plate", "Dye"), quiet = TRUE)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 1L)
})

test_that("only the requested columns are returned, in the requested order", {
  out <- getmetadata(meta_df, IDcols = c("Dye", "Plate"), quiet = TRUE)
  expect_equal(names(out), c("Dye", "Plate"))
})

test_that("values are taken from the first row", {
  varying <- meta_df
  varying$Plate <- c("P1", "P2", "P3")
  out <- getmetadata(varying, IDcols = "Plate", quiet = TRUE)
  expect_equal(out$Plate, "P1")
})

test_that("NULL IDcols gives a frame with no columns rather than an error", {
  # runtoxdrc() reaches this whenever it is called without IDcols.
  out <- getmetadata(meta_df, IDcols = NULL, quiet = TRUE)
  expect_s3_class(out, "data.frame")
  expect_equal(ncol(out), 0L)
})


# list_obj parity -----------------------------------------------------------

test_that("metadata is identical with and without list_obj", {
  bare <- getmetadata(meta_df, IDcols = "Plate", quiet = TRUE)
  wrapped <- getmetadata(meta_df, IDcols = "Plate", quiet = TRUE,
                         list_obj = list(ID = "x"))
  expect_equal(wrapped$metadata, bare)
  expect_equal(wrapped$ID, "x")
})
