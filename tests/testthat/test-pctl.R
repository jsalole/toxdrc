pre_df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60))

expt_df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60), Validity = c("*", "*", "*", "*", "*", "*"))

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list (
  dataset = expt_df,
  Group = "B",
  pctlresults = data.frame(
    p_ctl_mean = 40,
    ref_ctl_mean = 10,
    percent_difference = 300
  )
)

test_that("pctl flags differences between groups", {
  expect_equal(expt_df, pctl(dataset = pre_df, Conc = x, reference_group = 1, positive_group = 2, Response = y, max_diff = 10)
  )
})

test_that("pctl flags differences between groups", {
  expect_equal(expt_list, pctl(dataset = pre_list$dataset, Conc = x, reference_group = 1, positive_group = 2, Response = y, max_diff = 10, list_obj = pre_list)
  )
})
