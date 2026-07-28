# Internal validation helpers. Tests match on condition class rather than on
# message wording, so rephrasing an error does not break the suite.

check_dataset   <- toxdrc:::check_dataset
check_column    <- toxdrc:::check_column
check_idcols    <- toxdrc:::check_idcols
check_group     <- toxdrc:::check_group
check_number    <- toxdrc:::check_number
check_flag      <- toxdrc:::check_flag
check_list_obj  <- toxdrc:::check_list_obj
check_config    <- toxdrc:::check_config
assign_field    <- toxdrc:::assign_field

df <- data.frame(
  Conc = c(0, 0, 1, 1),
  RFU  = c(10, 12, 4, 5),
  Rep  = c("A", "A", "A", "A"),
  stringsAsFactors = FALSE
)


# check_dataset -----------------------------------------------------------

test_that("check_dataset accepts a normal data frame", {
  expect_no_error(check_dataset(df))
})

test_that("check_dataset rejects non-frames and empty frames", {
  expect_error(check_dataset(NULL), class = "toxdrc_error_missing_dataset")
  expect_error(check_dataset(1:10), class = "toxdrc_error_bad_dataset")
  expect_error(check_dataset("abc"), class = "toxdrc_error_bad_dataset")
  expect_error(check_dataset(df[0, ]), class = "toxdrc_error_empty_dataset")
})

test_that("check_dataset names the offending class", {
  err <- expect_error(check_dataset(1:10))
  expect_match(conditionMessage(err), "integer")
})


# check_column ------------------------------------------------------------

test_that("check_column accepts a column that exists", {
  expect_equal(check_column(df, rlang::quo(RFU), "Response"), "RFU")
})

test_that("check_column rejects a column that does not exist", {
  expect_error(
    check_column(df, rlang::quo(Fluorescence), "Response"),
    class = "toxdrc_error_missing_column"
  )
})

test_that("check_column error lists the available columns", {
  err <- expect_error(check_column(df, rlang::quo(nope), "Response"))
  expect_match(conditionMessage(err), "Conc")
  expect_match(conditionMessage(err), "RFU")
})

test_that("check_column is case sensitive", {
  expect_error(
    check_column(df, rlang::quo(rfu), "Response"),
    class = "toxdrc_error_missing_column"
  )
})

test_that("check_column skips expressions it cannot resolve", {
  # Not a bare column name, so it cannot be matched against names(dataset)
  # and must not be reported as missing.
  expect_null(check_column(df, rlang::quo(RFU * 2), "Response"))
  expect_null(check_column(df, rlang::quo(log(RFU)), "Response"))
})


# check_idcols ------------------------------------------------------------

test_that("check_idcols accepts NULL and valid names", {
  expect_null(check_idcols(df, NULL))
  expect_equal(check_idcols(df, c("Conc", "Rep")), c("Conc", "Rep"))
})

test_that("check_idcols rejects NULL when required", {
  expect_error(
    check_idcols(df, NULL, required = TRUE),
    class = "toxdrc_error_missing_idcols"
  )
})

test_that("check_idcols rejects non-character input", {
  expect_error(check_idcols(df, 1:2), class = "toxdrc_error_bad_idcols")
})

test_that("check_idcols reports every missing column", {
  err <- expect_error(
    check_idcols(df, c("Rep", "Plate", "Well")),
    class = "toxdrc_error_missing_idcols_columns"
  )
  expect_match(conditionMessage(err), "Plate")
  expect_match(conditionMessage(err), "Well")
  expect_equal(err$missing, c("Plate", "Well"))
})


# check_group -------------------------------------------------------------

test_that("check_group accepts a label present in the column", {
  expect_no_error(check_group(df, rlang::quo(Conc), 0, "reference_group"))
})

test_that("check_group compares as text, so 0 and \"0\" both match", {
  expect_no_error(check_group(df, rlang::quo(Conc), "0", "reference_group"))
})

test_that("check_group rejects a label that is absent", {
  err <- expect_error(
    check_group(df, rlang::quo(Conc), "Control", "reference_group"),
    class = "toxdrc_error_missing_group"
  )
  expect_equal(err$group, "Control")
  # The message should show what levels do exist.
  expect_match(conditionMessage(err), "0")
})

test_that("check_group accepts NULL", {
  expect_null(check_group(df, rlang::quo(Conc), NULL, "target_group"))
})


# check_number ------------------------------------------------------------

test_that("check_number accepts valid scalars", {
  expect_no_error(check_number(0.5, "EDx", min = 0, max = 1))
  expect_no_error(check_number(30, "max_val", min = 0))
})

test_that("check_number rejects wrong types, lengths, and NA", {
  expect_error(check_number("30", "max_val"), class = "toxdrc_error_bad_number")
  expect_error(check_number(NULL, "max_val"), class = "toxdrc_error_bad_number")
  expect_error(check_number(NA_real_, "max_val"), class = "toxdrc_error_bad_number")
  expect_error(check_number(c(1, 2), "max_val"), class = "toxdrc_error_bad_number")
})

test_that("check_number honours allow_null and allow_vector", {
  expect_null(check_number(NULL, "x", allow_null = TRUE))
  expect_no_error(check_number(c(0.2, 0.5), "EDx", allow_vector = TRUE))
})

test_that("check_number enforces bounds", {
  expect_error(
    check_number(-1, "max_val", min = 0),
    class = "toxdrc_error_out_of_range"
  )
  expect_error(
    check_number(1.5, "level", min = 0, max = 1),
    class = "toxdrc_error_out_of_range"
  )
})


# check_flag --------------------------------------------------------------

test_that("check_flag accepts TRUE and FALSE only", {
  expect_no_error(check_flag(TRUE, "quiet"))
  expect_no_error(check_flag(FALSE, "quiet"))

  expect_error(check_flag(NA, "quiet"), class = "toxdrc_error_bad_flag")
  expect_error(check_flag(1, "quiet"), class = "toxdrc_error_bad_flag")
  expect_error(check_flag("TRUE", "quiet"), class = "toxdrc_error_bad_flag")
  expect_error(check_flag(NULL, "quiet"), class = "toxdrc_error_bad_flag")
  expect_error(check_flag(c(TRUE, TRUE), "quiet"), class = "toxdrc_error_bad_flag")
})


# check_list_obj ----------------------------------------------------------

test_that("check_list_obj accepts NULL and lists", {
  expect_null(check_list_obj(NULL))
  expect_no_error(check_list_obj(list()))
  expect_no_error(check_list_obj(list(a = 1)))
})

test_that("check_list_obj rejects other objects, including data frames", {
  expect_error(check_list_obj("nope"), class = "toxdrc_error_bad_list_obj")
  expect_error(check_list_obj(df), class = "toxdrc_error_bad_list_obj")
})


# check_config ------------------------------------------------------------

test_that("check_config accepts output of the matching helper", {
  expect_no_error(check_config(toxdrc_qc(), "qc", "toxdrc_qc"))
  expect_no_error(check_config(toxdrc_output(), "output", "toxdrc_output"))
})

test_that("check_config rejects a bare value in place of a config list", {
  expect_error(
    check_config(TRUE, "qc", "toxdrc_qc"),
    class = "toxdrc_error_bad_config"
  )
})

test_that("check_config rejects a list missing settings", {
  err <- expect_error(
    check_config(list(condense = TRUE), "output", "toxdrc_output"),
    class = "toxdrc_error_incomplete_config"
  )
  expect_equal(err$missing, "sections")
})


# assign_field ------------------------------------------------------------

test_that("assign_field keeps the name when the value is NULL", {
  # `list_obj$field <- NULL` would delete the element entirely.
  out <- assign_field(list(a = 1), "model", NULL)
  expect_true("model" %in% names(out))
  expect_null(out$model)
  expect_equal(out$a, 1)
})

test_that("assign_field stores non-NULL values normally", {
  out <- assign_field(list(), "model", 42)
  expect_equal(out$model, 42)
})


# Condition hierarchy -----------------------------------------------------

test_that("every validation error inherits from toxdrc_error", {
  expect_error(check_dataset(1:10), class = "toxdrc_error")
  expect_error(check_flag(NA, "quiet"), class = "toxdrc_error")
  expect_error(check_list_obj("nope"), class = "toxdrc_error")
})
