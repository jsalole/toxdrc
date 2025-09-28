test_that("first_non_missing identifies first non NA or blank entry in vector", {
  expect_equal("*", first_nonmissing(c("", "", NA, "*")))
})
