pre_df <- data.frame(x = rep(1:2, each = 3), y = c(3, 5, 7, 3, 4, 30))
expt_df <- data.frame(x = c(1, 1, 1, 2, 2), y = c(3, 5, 7, 3, 4))

pre_list <- list(
  dataset = data.frame(
    x = rep(1:2, each = 3),
    y = c(3, 5, 7, 3, 4, 30)
  ),
  Group = "B"
)

expt_list <- list (
  dataset = data.frame(x = c(1, 1, 1, 2, 2), y = c(3, 5, 7, 3, 4)),
  Group = "B",
  removed_outliers = data.frame(x = c(2), y = c(30))
)

test_that("removeoutliers identifies outliers and removes them without list_obj", {
  expect_equal(expt_df, removeoutliers(dataset = pre_df, Conc = x, Response = y)
  )
})

test_that("removeoutliers edits list object as intended", {
  expect_equal(expt_list, removeoutliers(dataset= pre_list$dataset, Conc = x, Response = y, list_obj = pre_list)
  )
})


