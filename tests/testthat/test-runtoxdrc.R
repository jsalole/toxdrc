test_that("toxdrc produces list", {
  expect_output(
    class(runtoxdrc(
      cellglow,
      Conc,
      RFU,
      c("TestID", "Dye", "Type"),
      normalization = toxdrc_normalization(
        blank.correction = TRUE,
        normalize.resp = FALSE
      ),
      quiet = FALSE
    ))
  )
})
