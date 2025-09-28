pre_df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60))

expt_df <- data.frame(x = rep(1:2, each = 3), y = c(100, 110, 90, 40, 50, 60), normalized_response = c(1, 1.1, 0.9, 0.4, 0.5, 0.6))

pre_list <- list(
  dataset = pre_df,
  Group = "B"
)

expt_list <- list (
  dataset = expt_df,
  Group = "B",
  normalize_response_summary = data.frame(
    ref_mean = 100,
    ref_sd = 10,
    ref_cv = 10
  )
)

test_that("normalize response normalizes in df", {
  expect_equal(expt_df, normalizeresponse(dataset = pre_df, Conc = x, reference_group = 1, Response = y)
  )
})

test_that("normalize response normalizes in df", {
  expect_equal(expt_list, normalizeresponse(dataset = pre_list$dataset, Conc = x, reference_group = 1, Response = y, list_obj = pre_list)
  )
})
