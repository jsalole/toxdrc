pre_df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60), time = c("noon", "noon", "noon", "", "one_pm", ""))

expt_df <- data.frame(x = c(1, 2), mean_response = c(100, 50), time = c("noon", "one_pm"))

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list (
  dataset = expt_df,
  Group = "B",
  pre_average_dataset = data.frame(
    pre_df
  )
)

test_that("normalize response normalizes in df", {
  expect_equal(expt_df, averageresponse(dataset = pre_df, Conc = x, Response = y, keep_cols = c("time"))
  )
})


test_that("normalize response normalizes in list", {
  expect_equal(expt_list, averageresponse(dataset = pre_list$dataset, Conc = x, Response = y, keep_cols = c("time"), list_obj = pre_list)
  )
})
