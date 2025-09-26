df <- data.frame(x = rep(1:2, each = 3), y = c(3, 5, 7, 3, 4, 30))
df_c <- data.frame(x = c(1, 1, 1, 2, 2), y = c(3, 5, 7, 3, 4))

test_that("removeoutliers identifies outliers and removes them", {
  expect_equal(df_c, removeoutliers(dataset = df, Conc = x, Response = y)
  )
})

