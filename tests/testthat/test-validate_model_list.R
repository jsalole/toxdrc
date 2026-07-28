# validate_model_list() is internal; reach it through ::: so the error
# messages can be tested directly rather than through modelcomp().
validate <- toxdrc:::validate_model_list


# Accepted input ----------------------------------------------------------

test_that("a correctly named list passes through unchanged in structure", {
  ml     <- list("LL.4" = LL.4(), "W1.4" = W1.4())
  result <- validate(ml)

  expect_type(result, "list")
  expect_equal(names(result), c("LL.4", "W1.4"))
  expect_length(result, 2L)
})

test_that("$name is set to the entry label", {
  result <- validate(list("LL.4" = LL.4()))
  expect_equal(result[["LL.4"]]$name, "LL.4")
  expect_length(result[["LL.4"]]$name, 1L)
})

test_that("a namespaced call is accepted despite carrying no shorthand", {
  # drc builds $name from match.call(), so drc::LL.4() records "::" and the
  # shorthand is unrecoverable. The label is taken on trust and written back.
  expect_equal(LL.4()$name, "LL.4")
  expect_equal(drc::LL.4()$name, "::")

  result <- validate(list("LL.4" = drc::LL.4()))
  expect_equal(result[["LL.4"]]$name, "LL.4")
})

test_that("a single-entry list is accepted", {
  expect_no_error(validate(list("LL.3" = drc::LL.3())))
})


# Rejected input ----------------------------------------------------------

test_that("non-list input is rejected", {
  expect_error(validate("LL.4"), "must be a list")
  expect_error(validate(LL.4), "must be a list")
  expect_error(validate(data.frame(a = 1)), "must be a list")
})

test_that("an empty list is rejected", {
  expect_error(validate(list()), "is empty")
})

test_that("unnamed and partially named lists are rejected", {
  expect_error(validate(list(LL.4())), "must be named")
  expect_error(
    validate(stats::setNames(list(LL.4(), W1.4()), c("LL.4", ""))),
    "must be named"
  )
  expect_error(validate(list(LL.4())), "position\\(s\\): 1")
})

test_that("duplicate names are rejected", {
  expect_error(
    validate(list("LL.4" = LL.4(), "LL.4" = LL.4())),
    "must be unique"
  )
})

test_that("entries that are not model objects are rejected", {
  # Passing the function itself rather than calling it is the likely mistake.
  expect_error(validate(list("LL.4" = LL.4)), "not a drc model function")
  expect_error(validate(list("LL.4" = 1)), "not a drc model function")
})

test_that("a name that disagrees with the model it holds is rejected", {
  err <- expect_error(
    validate(list("LL.4" = W1.4())),
    "Name mismatch"
  )
  # Message should name both the label and the actual model.
  expect_match(conditionMessage(err), "LL.4")
  expect_match(conditionMessage(err), "W1.4")
})

test_that("a model object with no usable name is rejected", {
  bogus <- list(fct = function(x, parm) x)
  expect_error(validate(list("custom" = bogus)), "no usable model name")
})


# Error message context ---------------------------------------------------

test_that("the arg name is echoed in the error message", {
  expect_error(validate(list(), arg = "model.list"), "`model.list`")
  expect_error(validate(list(), arg = "model_list"), "`model_list`")
})
