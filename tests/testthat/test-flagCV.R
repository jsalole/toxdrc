pre_df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60))

expt_df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60), CVflag = c("", "", "", "*", "*", "*"))

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list (
 dataset = expt_df,
 Group = "B",
 CVresults = data.frame(x = c(1, 2), CV = c(10, 50), CVflag = c("", "*"))
)

test_that("flagCV identifies groups with high CV and flags them", {
  expect_equal(expt_df, flagCV(dataset = pre_df, Conc = x, Response = y, max_val = 30)
  )
})

test_that("flagCV identifies groups with high CV and flags them in a list", {
  expect_equal(expt_list, flagCV(dataset = pre_list$dataset, Conc = x, Response = y, max_val = 30, list_obj = pre_list)
  )
})

