test_that("first_non_missing identifies first non NA or blank entry in vector", {
  expect_equal("*", first_nonmissing(c("", "", NA, "*")))
})

test_that("the first usable value wins, not the last", {
  expect_equal(first_nonmissing(c("A", "B", "C")), "A")
  expect_equal(first_nonmissing(c(NA, "B", "C")), "B")
})

test_that("empty strings are treated as missing, like NA", {
  expect_equal(first_nonmissing(c("", "B")), "B")
  expect_equal(first_nonmissing(c(NA, "", "B")), "B")
})

test_that("factors are handled as their labels, not their integer codes", {
  # Without the as.character() step this would compare against level indices.
  f <- factor(c(NA, "Spiked", "Control"))
  expect_equal(first_nonmissing(f), "Spiked")
  expect_type(first_nonmissing(f), "character")
})

test_that("a vector with nothing usable gives NA", {
  expect_true(is.na(first_nonmissing(c("", "", NA))))
  expect_true(is.na(first_nonmissing(character(0))))
  expect_true(is.na(first_nonmissing(NA)))
})

test_that("numeric input keeps its value", {
  expect_equal(first_nonmissing(c(NA, 5, 7)), 5)
})
