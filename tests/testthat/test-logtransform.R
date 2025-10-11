pre_df <- data.frame(
  x = rep(c(10, 100), each = 3),
  y = c(10, 11, 9, 20, 40, 60)
)

expt_df <- data.frame(
  x = rep(c(10, 100), each = 3),
  y = c(10, 11, 9, 20, 40, 60),
  log_Conc = c(1, 1, 1, 2, 2, 2)
)

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list(
  dataset = expt_df,
  Group = "B"
)

test_that("logtransform transfroms and stores in new row", {
  expect_equal(
    expt_df,
    logtransform(dataset = pre_df, Conc = x)
  )
})

test_that("log transfrom works with lists", {
  expect_equal(
    expt_list,
    logtransform(
      dataset = pre_list$dataset,
      Conc = x,
      list_obj = pre_list
    )
  )
})
