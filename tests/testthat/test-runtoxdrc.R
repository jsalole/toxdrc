test_that("runtoxdrc produces a list of results", {
  result <- runtoxdrc(
    dataset = cellglow,
    Conc = Conc,
    Response = RFU,
    IDcols = c("TestID", "Dye")
  )
})
