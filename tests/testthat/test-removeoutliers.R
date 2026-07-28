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




# Group size ---------------------------------------------------------------

test_that("groups of two or fewer are left untouched", {
  # Grubbs' test needs at least three observations.
  small <- data.frame(x = c(1, 1, 2), y = c(5, 500, 9))
  out <- removeoutliers(small, Conc = x, Response = y, quiet = TRUE)
  expect_equal(nrow(out), 3L)
  expect_setequal(out$y, small$y)
})

test_that("a group with no outlier is returned unchanged", {
  tight <- data.frame(x = rep(1, 5), y = c(10, 10.1, 9.9, 10.2, 9.8))
  out <- removeoutliers(tight, Conc = x, Response = y, quiet = TRUE)
  expect_equal(nrow(out), 5L)
})

test_that("each group is tested independently", {
  # The extreme value in group 2 must not affect group 1.
  two <- data.frame(
    x = rep(c(1, 2), each = 5),
    y = c(10, 10.1, 9.9, 10.2, 9.8, 10, 10.1, 9.9, 10.2, 900)
  )
  out <- removeoutliers(two, Conc = x, Response = y, quiet = TRUE)
  expect_equal(sum(out$x == 1), 5L)
  expect_false(900 %in% out$y)
})


# Return shape --------------------------------------------------------------

test_that("removed rows are reported as a data frame", {
  out <- removeoutliers(pre_df, Conc = x, Response = y, quiet = TRUE,
                        list_obj = list())
  expect_s3_class(out$removed_outliers, "data.frame")
  expect_true(all(names(pre_df) %in% names(out$removed_outliers)))
})

test_that("removed and retained rows together account for the input", {
  out <- removeoutliers(pre_df, Conc = x, Response = y, quiet = TRUE,
                        list_obj = list())
  expect_equal(
    nrow(out$dataset) + nrow(out$removed_outliers),
    nrow(pre_df)
  )
})

test_that("removed_outliers is empty when nothing is removed", {
  tight <- data.frame(x = rep(1, 5), y = c(10, 10.1, 9.9, 10.2, 9.8))
  out <- removeoutliers(tight, Conc = x, Response = y, quiet = TRUE,
                        list_obj = list())
  expect_equal(nrow(out$removed_outliers), 0L)
})

test_that("the cleaned dataset is identical with and without list_obj", {
  bare <- removeoutliers(pre_df, Conc = x, Response = y, quiet = TRUE)
  wrapped <- removeoutliers(pre_df, Conc = x, Response = y, quiet = TRUE,
                            list_obj = list(ID = "x"))
  expect_equal(wrapped$dataset, bare)
  expect_equal(wrapped$ID, "x")
})
