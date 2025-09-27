df <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60))

df_c <- data.frame(x = rep(1:2, each = 3), y = c(10, 11, 9, 20, 40, 60), CV = c(10, 10, 10, 50, 50, 50), CVflag = c("", "", "", "*", "*", "*"))

test_that("flagCV identifies groups with high CV and flags them", {
  expect_equal(df_c, flagCV(dataset = df, Conc = x, Response = y, max_val = 30, update_dataset = TRUE)
  )
})

test_that("flagCV identifies groups with high CV and flags them via printing", {
  expect_equal(df, flagCV(dataset = df, Conc = x, Response = y, max_val = 30, update_dataset = FALSE)
  )
})
