# test if absolute values flagged.

pre_df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60))

expt_df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60))

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list (
  dataset = expt_df,
  Group = "B",
  effect = TRUE
)

test_that("absolute threshold flags", {
  expect_equal(expt_df, checktoxicity(dataset = pre_df, Conc = x, Response = y, effect = 85, type = "abs")
  )
})

test_that("absolute threshold flags in list", {
  expect_equal(expt_list, checktoxicity(dataset = pre_list$dataset, Conc = x, Response = y, effect = 85, type = "abs", list_obj = pre_list)
  )
})
