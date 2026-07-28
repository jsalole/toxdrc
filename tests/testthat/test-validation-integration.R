# Validation reaching the exported functions. One representative check per
# function, since the helpers themselves are covered in test-validate.R.

df <- data.frame(
  Conc = c(0, 0, 1, 1, 2, 2),
  RFU  = c(100, 102, 60, 58, 20, 22),
  Rep  = rep("A", 6),
  stringsAsFactors = FALSE
)


# Missing columns ---------------------------------------------------------

test_that("a misspelled Response column is reported by name", {
  err <- expect_error(
    flagCV(df, Conc = Conc, Response = Fluorescence, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
  expect_match(conditionMessage(err), "Fluorescence")
  expect_match(conditionMessage(err), "RFU")
})

test_that("each exported function checks its columns", {
  expect_error(
    removeoutliers(df, Conc = Conc, Response = nope, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
  expect_error(
    averageresponse(df, Conc = Conc, Response = nope, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
  expect_error(
    blankcorrect(df, Conc = Conc, Response = nope, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
  expect_error(
    normalizeresponse(df, Conc = Conc, Response = nope, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
  expect_error(
    checktoxicity(df, Conc = Conc, Response = nope, effect = 0.5, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
  expect_error(
    modelcomp(df, Conc = Conc, Response = nope, quiet = TRUE),
    class = "toxdrc_error_missing_column"
  )
})


# Missing group labels ----------------------------------------------------

test_that("a blank label absent from the data is reported, not silently NaN", {
  err <- expect_error(
    blankcorrect(df, Conc = Conc, blank_group = "Blank", Response = RFU),
    class = "toxdrc_error_missing_group"
  )
  expect_equal(err$group, "Blank")
})

test_that("an absent normalization reference is reported", {
  expect_error(
    normalizeresponse(
      df,
      Conc = Conc,
      reference_group = "Control",
      Response = RFU
    ),
    class = "toxdrc_error_missing_group"
  )
})

test_that("pctl reports whichever group is missing", {
  expect_error(
    pctl(
      df,
      Conc = Conc,
      reference_group = "Control",
      positive_group = 0,
      Response = RFU,
      quiet = TRUE
    ),
    class = "toxdrc_error_missing_group"
  )
})

test_that("checktoxicity only requires the reference group when relative", {
  # Absolute thresholds do not use the reference group, so an unmatched
  # label must not be an error there.
  expect_error(
    checktoxicity(
      df,
      Conc = Conc,
      Response = RFU,
      effect = 0.5,
      reference_group = "Control",
      quiet = TRUE
    ),
    class = "toxdrc_error_missing_group"
  )
  expect_no_error(
    checktoxicity(
      df,
      Conc = Conc,
      Response = RFU,
      effect = 50,
      type = "absolute",
      reference_group = "Control",
      quiet = TRUE
    )
  )
})


# IDcols ------------------------------------------------------------------

test_that("a misspelled IDcol is an error rather than a silent drop", {
  # Previously this warned and continued, so the column was quietly missing
  # from the output.
  err <- expect_error(
    averageresponse(
      df,
      Conc = Conc,
      Response = RFU,
      IDcols = c("Rep", "Plate"),
      quiet = TRUE
    ),
    class = "toxdrc_error_missing_idcols_columns"
  )
  expect_equal(err$missing, "Plate")
})


# list_obj ----------------------------------------------------------------

test_that("a non-list list_obj fails before any work is done", {
  expect_error(
    flagCV(df, Conc = Conc, Response = RFU, list_obj = "nope", quiet = TRUE),
    class = "toxdrc_error_bad_list_obj"
  )
  expect_error(
    getmetadata(df, IDcols = "Rep", list_obj = 1, quiet = TRUE),
    class = "toxdrc_error_bad_list_obj"
  )
})


# Configuration objects ---------------------------------------------------

test_that("runtoxdrc rejects a bare value where a config list is expected", {
  expect_error(
    runtoxdrc(df, Conc = Conc, Response = RFU, qc = TRUE, quiet = TRUE),
    class = "toxdrc_error_bad_config"
  )
})

test_that("config helpers validate their own arguments", {
  expect_error(toxdrc_qc(cv.flag = "yes"), class = "toxdrc_error_bad_flag")
  expect_error(toxdrc_qc(cvflag.lvl = -5), class = "toxdrc_error_out_of_range")
  expect_error(
    toxdrc_modelling(level = 95),
    class = "toxdrc_error_out_of_range"
  )
  expect_error(
    toxdrc_modelling(EDx = 50),
    class = "toxdrc_error_out_of_range"
  )
  expect_error(
    toxdrc_output(sections = 1:3),
    class = "toxdrc_error_bad_sections"
  )
})


# Dataset shape -----------------------------------------------------------

test_that("an empty dataset is reported clearly", {
  expect_error(
    flagCV(df[0, ], Conc = Conc, Response = RFU, quiet = TRUE),
    class = "toxdrc_error_empty_dataset"
  )
})

test_that("a non-data-frame dataset is reported clearly", {
  expect_error(
    flagCV(as.matrix(df), Conc = Conc, Response = RFU, quiet = TRUE),
    class = "toxdrc_error_bad_dataset"
  )
})
