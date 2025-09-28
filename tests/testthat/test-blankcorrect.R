pre_df <- data.frame(x = rep(1:2, each = 3), y = c(3, 5, 4, 20, 40, 60))

expt_df <- data.frame(x = rep(1:2, each = 3), y = (c(3, 5, 4, 20, 40, 60)), c_response = c(-1, 1, 0, 16, 36, 56))

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list (
  dataset = expt_df,
  Group = "B",
  blank_stats = data.frame(
    blank_mean = 4,
    blank_sd = 1,
    blank_cv = 25
  )
)

test_that("blankcorrert subtracts blank correctly", {
  expect_equal(expt_df, blankcorrect(dataset = pre_df, Conc = x, blank_group = 1, Response = y)
  )
})

test_that("blankcorrert subtracts blank correctly and updates list", {
  expect_equal(expt_list, blankcorrect(dataset = pre_list$dataset, Conc = x, blank_group = 1, Response = y, list_obj = pre_list)
  )
})
